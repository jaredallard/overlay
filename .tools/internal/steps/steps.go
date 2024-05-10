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

// Pack steps contains a generic step runner in the context of being
// able to encapsulate custom logic for updating ebuilds.
package steps

import (
	"context"
	"fmt"

	"gopkg.in/yaml.v3"
)

// StepRunner is a generic interface that all step runners must implement.
type StepRunner interface {
	// Run runs the step. The first argument should be the input provided
	// through the configuration file.
	Run(context.Context, Environment) (*StepOutput, error)
}

// StepOutput is the output of a step, if applicable.
type StepOutput struct {
	// Ebuild is the contents of the ebuild that was generated.
	Ebuild []byte

	// Manifest is the contents of the manifest that was generated.
	Manifest []byte
}

// Steps contains a collection of steps.
type Steps []Step

// Step encapsulates a step that should be ran.
type Step struct {
	// Args are the arguments that were provided to the step.
	Args any

	// Runner is the runner that runs this step.
	Runner StepRunner
}

// UnmarshalYAML unmarshals the steps from the YAML configuration file
// turning them into their type safe representations.
func (s *Steps) UnmarshalYAML(node *yaml.Node) error {
	var raw []any
	if err := node.Decode(&raw); err != nil {
		return err
	}

	// knownSteps map of key values to their respective steps.
	knownSteps := map[string]func(any) (StepRunner, error){
		"command":         NewCommandStep,
		"checkout":        NewCheckoutStep,
		"ebuild":          NewEbuildStep,
		"original_ebuild": NewOriginalEbuildStep,
		"upload_artifact": NewUploadArtifactStep,
	}

	for _, rawStep := range raw {
		var stepName string
		var stepData any

		switch rawStep := rawStep.(type) {
		case map[string]any:
			// If there's more than one key, fail.
			if len(rawStep) != 1 {
				return fmt.Errorf("expected one key on step, got %d", len(rawStep))
			}

			// If it's a map, use the first key.
			for key, value := range rawStep {
				stepName = key
				stepData = value
				break
			}
		case string:
			// If it's just a string, then we use it as-is.
			stepName = rawStep
		}

		if _, ok := knownSteps[stepName]; !ok {
			return fmt.Errorf("unknown step: %s", stepName)
		}

		step, err := knownSteps[stepName](stepData)
		if err != nil {
			return fmt.Errorf("failed to create step: %w", err)
		}

		*s = append(*s, Step{
			Args:   stepData,
			Runner: step,
		})
	}

	return nil
}
