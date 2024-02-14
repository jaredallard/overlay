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

	logger "github.com/charmbracelet/log"
	"github.com/davecgh/go-spew/spew"
	"github.com/jaredallard/overlay/.updater/internal/config"
	"github.com/jaredallard/overlay/.updater/internal/steps"
	"github.com/spf13/cobra"
)

var log = logger.NewWithOptions(os.Stderr, logger.Options{
	ReportCaller:    true,
	ReportTimestamp: true,
	Level:           logger.DebugLevel,
})

// rootCmd is the root command used by cobra
var rootCmd = &cobra.Command{
	Use:           "updater",
	Short:         "updater automatically updates ebuilds",
	RunE:          entrypoint,
	SilenceErrors: true,
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		log.With("error", err).Error("failed to execute command")
	}
}

func entrypoint(cmd *cobra.Command, args []string) error {
	ctx := cmd.Context()

	cfg, err := config.LoadConfig("updater.yml")
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	for _, ebuild := range cfg {
		log.With("name", ebuild.Name).With("backend", ebuild.Backend).Info("checking for updates")

		// update, err := updater.CheckForUpdate(&ebuild)
		// if err != nil {
		// 	log.With("error", err).Error("failed to check for update")
		// 	continue
		// }

		// if update != nil {
		// 	log.With("name", ebuild.Name).Info("update available")
		// } else {
		// 	log.With("name", ebuild.Name).Info("no update available")
		// }

		spew.Dump(ebuild.Steps)

		e := steps.NewExecutor(log, ebuild.Steps)
		res, err := e.Run(ctx)
		if err != nil {
			log.With("error", err).Error("failed to run steps")
			continue
		}

		log.With("name", ebuild.Name).With("contents", res.Contents).Info("steps ran successfully")
	}

	return nil
}
