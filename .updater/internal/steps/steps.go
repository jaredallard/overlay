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
	Run(context.Context, Enviromment) (*StepOutput, error)
}

// StepOutput is the output of a step, if applicable.
type StepOutput struct {
	// Contents is the contents of the ebuild that was generated.
	Contents string
}

// Steps contains a collection of steps.
type Steps []StepRunner

// UnmarshalYAML unmarshals the steps from the YAML configuration file
// turning them into their type safe representations.
func (s *Steps) UnmarshalYAML(node *yaml.Node) error {
	var raw []map[string]any
	if err := node.Decode(&raw); err != nil {
		return err
	}

	// knownSteps map of key values to their respective steps.
	knownSteps := map[string]func(any) (StepRunner, error){
		"command": NewCommandStep,
	}

	for _, rawStep := range raw {
		// Find the first key that maps to a known step.
		var found bool
		for key := range knownSteps {
			if _, ok := rawStep[key]; ok {
				found = true

				step, err := knownSteps[key](rawStep[key])
				if err != nil {
					return fmt.Errorf("failed to create step: %w", err)
				}

				*s = append(*s, step)
				break
			}
		}
		if !found {
			return fmt.Errorf("invalid step")
		}
	}

	return nil
}
