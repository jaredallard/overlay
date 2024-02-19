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

package ebuild

import (
	"fmt"
	"reflect"
	"testing"
)

// ebuild creates an ebuild for testing.
func ebuild(e *Ebuild) []byte {
	var serialized string

	// default to 8
	if e.EAPI == 0 {
		e.EAPI = 8
	}

	serialized += fmt.Sprintf("EAPI=%d\n", e.EAPI)

	if e.Description != "" {
		serialized += fmt.Sprintf("DESCRIPTION=%q\n", e.Description)
	}

	return []byte(serialized)
}

func Test_parse(t *testing.T) {
	type args struct {
		fileName string
		b        []byte
	}
	tests := []struct {
		name    string
		args    args
		want    *Ebuild
		wantErr bool
	}{
		{
			name: "should parse basic ebuild",
			args: args{
				fileName: "foo-1.2.3.ebuild",
				b:        ebuild(&Ebuild{}),
			},
			want: &Ebuild{
				EAPI:    8,
				Name:    "foo",
				Version: "1.2.3",
			},
		},
		{
			name: "should parse an ebuild with multiple dashes in the name",
			args: args{
				fileName: "foo-buzz-bar-1.2.3.ebuild",
				b:        ebuild(&Ebuild{}),
			},
			want: &Ebuild{
				EAPI:    8,
				Name:    "foo-buzz-bar",
				Version: "1.2.3",
			},
		},
		{
			name: "should parse an ebuild with a description",
			args: args{
				fileName: "foo-buzz-bar-1.2.3.ebuild",
				b: ebuild(&Ebuild{
					Description: "This is a description",
				}),
			},
			want: &Ebuild{
				EAPI:        8,
				Name:        "foo-buzz-bar",
				Version:     "1.2.3",
				Description: "This is a description",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := parse(tt.args.fileName, tt.args.b)
			if (err != nil) != tt.wantErr {
				t.Errorf("parse() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("parse() = %v, want %v", got, tt.want)
			}
		})
	}
}
