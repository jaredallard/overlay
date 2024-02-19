// Copyright (C) 2023 Jared Allard <jared@rgst.io>
// Copyright (C) 2023 Outreach <https://outreach.io>
//
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License version
// 2 as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

// Package main implements a linter for Gentoo ebuilds. It is intended
// to be ran only on the jaredallard/asahi-overlay repository. It mainly
// handles:
// - Ensuring ebuilds have certain variables set.
// - Ensuring that Manifest files have been updated.
package main

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/egym-playground/go-prefix-writer/prefixer"
	"github.com/fatih/color"
	"github.com/jaredallard/overlay/.tools/internal/ebuild"
	"github.com/pkg/errors"
	"github.com/spf13/cobra"
)

// contains color helpers
var (
	bold   = color.New(color.Bold).SprintFunc()
	faint  = color.New(color.Faint).SprintFunc()
	red    = color.New(color.FgRed).SprintFunc()
	green  = color.New(color.FgGreen).SprintFunc()
	yellow = color.New(color.FgYellow).SprintFunc()
)

// main is the entrypoint for the linter.
func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

// lint lints the provided packageName in the provided workDir.
func lint(workDir, packageName string) (errOutput string) {
	// packageName is the format of "category/package".
	packageName = strings.TrimSuffix(packageName, "/")
	packagePath := packageName

	// find the first ebuild in the package directory.
	files, err := os.ReadDir(packagePath)
	if err != nil {
		return "failed to read package directory"
	}

	var ebuildPath string
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".ebuild" {
			ebuildPath = filepath.Join(packagePath, file.Name())
			break
		}
	}
	if ebuildPath == "" {
		return "no ebuild found in package directory"
	}

	e, err := ebuild.Parse(ebuildPath)
	if err != nil {
		return errors.Wrap(err, "failed to parse ebuild").Error()
	}

	if e.Description == "" {
		return "ebuild: missing DESCRIPTION " + "(" + filepath.Base(ebuildPath) + ")"
	}

	if e.License == "" {
		return "ebuild: missing LICENSE " + "(" + filepath.Base(ebuildPath) + ")"
	}

	// Validate that the Manifest file is up-to-date for the package.
	var buf bytes.Buffer
	out := prefixer.New(&buf, func() string { return color.New(color.Faint).Sprint(" => ") })
	if err := ebuild.ValidateManifest(
		out, out,
		workDir,
		packageName,
	); err != nil {
		errOutput = buf.String()
		if errors.Is(err, ebuild.ErrManifestInvalid) {
			errOutput += yellow("Manifest is out-of-date or otherwise invalid. Regenerate with 'ebuild <.ebuild> manifest'")
			return
		}

		errOutput += "Manifest validation failed for an unknown reason (err: " + err.Error() + ")"
		return
	}

	errOutput = ""
	return
}

var rootCmd = &cobra.Command{
	Use:   "linter [packageName...]",
	Short: "Ensures ebuilds pass lint checks as well as being valid.",
	Long: "If no arguments are passed, all packages in the current directory will be linted.\n" +
		"If arguments are passed, only those packages will be linted.",
	Run: func(cmd *cobra.Command, args []string) {
		workDir, err := os.Getwd()
		if err != nil {
			fmt.Fprintln(os.Stderr, "failed to get working directory:", err)
			os.Exit(1)
		}

		if len(args) == 0 {
			// If no arguments are passed, lint all packages in the current
			// directory.
			files, err := os.ReadDir(workDir)
			if err != nil {
				fmt.Fprintln(os.Stderr, "failed to read directory:", err)
				os.Exit(1)
			}

			for _, file := range files {
				if !file.IsDir() {
					continue
				}

				// skip hidden directories.
				if strings.HasPrefix(file.Name(), ".") {
					continue
				}

				// Skip non-package directories.
				if file.Name() == "metadata" || file.Name() == "profiles" {
					continue
				}

				subDir := filepath.Join(workDir, file.Name())
				subFiles, err := os.ReadDir(subDir)
				if err != nil {
					fmt.Fprintln(os.Stderr, "failed to read directory", subDir+":", err)
					os.Exit(1)
				}
				for _, subFile := range subFiles {
					if !subFile.IsDir() {
						continue
					}

					// join the subdirectory with the subdir to get the full
					// package name (category/package).
					args = append(args, filepath.Join(file.Name(), subFile.Name()))
				}
			}
		}

		if len(args) == 0 {
			fmt.Fprintln(os.Stdout, "no packages to lint")
			os.Exit(0)
		}

		if len(args) == 1 {
			fmt.Println("Linting package", args[0])
		} else {
			fmt.Println("Linting all packages in the current directory")
		}

		for _, packageName := range args {
			packageNameFaint := faint(packageName)
			fmt.Print(packageNameFaint, bold(" ..."))

			if err := lint(workDir, packageName); err != "" {
				// update the line to be red.
				fmt.Printf("\r%s %s\n", packageNameFaint, red("✘    "))

				// print the error and then exit
				fmt.Fprintln(os.Stderr, err)
				fmt.Println("Linting failed for package", packageName)
				os.Exit(1)
			}

			// update the line to be green.
			fmt.Printf("\r%s %s\n", packageNameFaint, green("✔    "))
		}

		fmt.Println("All package(s) linted successfully")
	},
}
