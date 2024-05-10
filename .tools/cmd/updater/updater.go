// Copyright (C) 2024 Jared Allard
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Main implements the main entrypoint for the updater CLI. This CLI
// aims to automate the updates of various ebuilds. It works by reading
// an updater.yml file and checking to see if new versions are
// available, if so it moves the file and regenerates the manifest. If
// this process fails at any point, it will revert the changes and
// move onwards.
package main

import (
	"fmt"
	"os"
	"path/filepath"

	logger "github.com/charmbracelet/log"
	"github.com/jaredallard/overlay/.tools/internal/config"
	"github.com/jaredallard/overlay/.tools/internal/config/packages"
	"github.com/jaredallard/overlay/.tools/internal/ebuild"
	updater "github.com/jaredallard/overlay/.tools/internal/resolver"
	"github.com/jaredallard/overlay/.tools/internal/steps"
	"github.com/spf13/cobra"
)

var log = logger.NewWithOptions(os.Stderr, logger.Options{
	ReportCaller:    true,
	ReportTimestamp: true,
	Level:           logger.DebugLevel,
})

// rootCmd is the root command used by cobra
var rootCmd = &cobra.Command{
	Use:           "updater <package>",
	Short:         "updater automatically updates ebuilds",
	Args:          cobra.MaximumNArgs(1),
	RunE:          entrypoint,
	SilenceErrors: true,
}

// main handles cobra execution to run the updater CLI.
func main() {
	if err := rootCmd.Execute(); err != nil {
		log.With("error", err).Error("failed to execute command")
	}
}

// getDefaultSteps returns the default steps if not provided. The
// default action is to copy the ebuild to the container, rename it, and
// then run `ebuild <ebuild> manifest` to get the new manifest.
func getDefaultSteps() []steps.Step {
	defaultSteps := []struct {
		args any
		fn   func(any) (steps.StepRunner, error)
	}{
		{args: "original.ebuild", fn: steps.NewOriginalEbuildStep},
		{args: "original.ebuild", fn: steps.NewEbuildStep},
	}

	// Convert the default steps into their type safe representations.
	out := make([]steps.Step, len(defaultSteps))
	for i := range defaultSteps {
		r, err := defaultSteps[i].fn(defaultSteps[i].args)
		if err != nil {
			panic(fmt.Errorf("failed to create default steps: %w", err))
		}

		out[i] = steps.Step{
			Args:   defaultSteps[i].args,
			Runner: r,
		}
	}

	return out
}

// entrypoint is the main entrypoint for the updater CLI.
func entrypoint(cmd *cobra.Command, args []string) error {
	ctx := cmd.Context()

	cfg, err := config.LoadConfig(".updater.yml")
	if err != nil {
		cfg = &config.Config{}
	}

	pkgs, err := packages.LoadPackages("packages.yml")
	if err != nil {
		return fmt.Errorf("failed to load packages: %w", err)
	}

	// If we have exactly one argument, we only want to update that
	// package.
	if len(args) == 1 {
		pkgName := args[0]
		if _, ok := pkgs[pkgName]; !ok {
			return fmt.Errorf("package not found in packages.yml: %s", pkgName)
		}
		pkgs = packages.List{pkgName: pkgs[pkgName]}
	}

	for _, ce := range pkgs {
		log.With("name", ce.Name).With("resolver", ce.Resolver).Info("checking for updates")

		ebuildDir := ce.Name
		if _, err := os.Stat(ebuildDir); os.IsNotExist(err) {
			return fmt.Errorf("ebuild directory does not exist: %s", ebuildDir)
		}

		ebuilds, err := ebuild.ParseDir(ebuildDir)
		if err != nil {
			return fmt.Errorf("failed to parse ebuilds: %w", err)
		}
		if len(ebuilds) == 0 {
			return fmt.Errorf("no ebuilds found in directory: %s", ebuildDir)
		}

		// TODO(jaredallard): Select newest version somehow.
		e := ebuilds[0]

		latestVersion, err := updater.GetLatestVersion(&ce)
		if err != nil {
			log.With("error", err).Error("failed to check for update")
			continue
		}

		if e.Version == latestVersion {
			log.With("name", ce.Name).With("version", e.Version).Info("no update available")
			continue
		}

		// Otherwise, update the ebuild.
		log.With("name", ce.Name).With("version", e.Version).With("latestVersion", latestVersion).Info("update available")

		ceSteps := ce.Steps
		if len(ceSteps) == 0 {
			ceSteps = getDefaultSteps()
		}

		executor := steps.NewExecutor(log, ceSteps, &steps.ExecutorInput{
			Config:          cfg,
			OriginalEbuild:  e,
			ExistingEbuilds: ebuilds,
			LatestVersion:   latestVersion,
		})
		res, err := executor.Run(ctx)
		if err != nil {
			log.With("error", err).Error("failed to run steps")
			continue
		}

		if err := validateExecutorResponse(res); err != nil {
			log.With("error", err).Error("failed to validate executor response")
			continue
		}

		// write the ebuild to disk
		newPath := filepath.Join(ebuildDir, filepath.Base(ce.Name)+"-"+latestVersion+".ebuild")
		if err := os.WriteFile(newPath, []byte(res.Ebuild), 0o644); err != nil {
			log.With("error", err).Error("failed to write ebuild to disk")
			continue
		}

		newManifestPath := filepath.Join(ebuildDir, "Manifest")
		if err := os.WriteFile(newManifestPath, []byte(res.Manifest), 0o644); err != nil {
			log.With("error", err).Error("failed to write manifest to disk")
			continue
		}

		log.With("name", ce.Name).Info("steps ran successfully")
	}

	return nil
}

// validateExecutorResponse ensures that the executor response is
// contains all of the required fields to update an ebuild.
func validateExecutorResponse(res *steps.Results) error {
	if res == nil {
		return fmt.Errorf("no results returned from executor")
	}

	if res.Ebuild == nil {
		return fmt.Errorf("no ebuild returned from executor")
	}

	if res.Manifest == nil {
		return fmt.Errorf("no manifest returned from executor")
	}

	return nil
}
