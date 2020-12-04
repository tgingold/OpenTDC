#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Read power strips from DEF and apply them to a LEF as PIN shape
# Workaround an OpenRoad issue

import sys
import argparse
from lef_def_parser.def_parser import DefParser

LEF_GRAMMAR = {
    'VERSION': None,
    'NOWIREEXTENSIONATPIN': None,
    'DIVIDERCHAR': None,
    'BUSBITCHARS': None,
    'MACRO': {
        '_end': True,
        'CLASS': None,
        'FOREIGN': None,
        'ORIGIN': None,
        'SIZE': None,
        'PIN': {
            '_end': True,
            'DIRECTION': None,
            'USE': None,
            'PORT': {
                'LAYER': None,
                'RECT': None
            }
        },
        'OBS': {
            'LAYER': None,
            'RECT': None
        }
    }
}

class LefStatement:
    def __init__(self, name, value, nest, end_label):
        self.name = name
        self.value = value
        self.nest = nest
        self.end_label = end_label

class LefParser:
    def __init__(self, filename):
        self.filename = filename
        self.statement = None
        self.pins = {}

    def parse(self):
        f = open(self.filename, 'r')
        lib = LefStatement('LIBRARY', [], [], False)
        stack = [(LEF_GRAMMAR, lib)]
        for line in f:
            toks = line.split()
            if not toks:
                continue
            key = toks[0]
            #print(toks)
            state = stack[-1]
            if key == 'END':
                if len(stack) == 1:
                    # Last END
                    self.statement = stack[0][1]
                    break
                else:
                    stack.pop()
                continue
            if key not in state[0]:
                raise Exception('unknown statement {}'.format(key))
            next = state[0][key]
            if next is None:
                # A simple attribute
                assert toks[-1] == ';'
                s = LefStatement(key, toks[1:-1], None, False)
                stack[-1][1].nest.append(s)
            else:
                # A nested statement
                s = LefStatement(key, toks[1:], [], '_end' in next)
                stack[-1][1].nest.append(s)
                if key == 'PIN':
                    self.pins[toks[1]] = s
                stack.append((next, s))
        f.close()

    def write1(self, file, s, level):
        file.write('  ' * level + s.name + ' ' + ' '.join(s.value))
        if s.nest:
            file.write('\n')
            for s1 in s.nest:
                self.write1(file, s1, level + 1)
            file.write('  ' * level + 'END')
            if s.end_label:
                file.write(' ' + s.value[0])
            file.write('\n')
        else:
            file.write(' ;\n')

    def write(self, file):
        for s1 in self.statement.nest:
            self.write1(file, s1, 0)
        file.write('END LIBRARY\n')


def rect_filter(shapes, rect):
    res = []
    r = [[float(rect[0]), float(rect[1])],
         [float(rect[2]), float(rect[3])]]
    for s in shapes:
        # That's very rough, but we are talking about power strips.
        if (abs(s[0][0] - r[0][0]) < 1
                and abs(s[0][1] - r[0][1]) < 1
                and abs(s[1][0] - r[1][0]) < 1
                and abs(s[1][1] - r[1][1]) < 1):
            pass
        else:
            res.append(s)
    return res

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Create a parasitic SPEF file from def and lef files.')

    parser.add_argument('--def_file', '-d', required=True,
                        help='Input DEF')
    parser.add_argument('--lef_file', '-l', required=True,
                        help='Input LEF')
    parser.add_argument('--pin', '-p', nargs='+',
                        help='Pin name')
    parser.add_argument('--layer', '-L', required=True,
                        help='Layer name')
    parser.add_argument('--output', '-o', required=True,
                        help='Output LEF file')
    args = parser.parse_args()

    my_def = DefParser(args.def_file)
    my_def.parse()

    my_lef = LefParser(args.lef_file)
    my_lef.parse()

    unit = 1000.0
    for pin in args.pin:
        print("Pins: {}".format(pin))
        n = my_def.specialnets.net_dict.get(pin)
        if n is None:
            print("Cannot find SPECIALNET {}".format(pin))
            continue
        rects = []
        for r in n.routed:
            if r.layer == args.layer and r.shape == 'STRIPE':
                print('Shape: wd: {}, pts: {}'.format(r.shape_width, r.points))
                hw = float(r.shape_width) / 2
                if r.points[0][0] == r.points[1][0]:
                    # Vertical shape - extend horizontally
                    if r.points[0][1] < r.points[1][1]:
                        d = hw
                    else:
                        d = -hw
                    rect = [[r.points[0][0] - d, r.points[0][1]],
                            [r.points[1][0] + d, r.points[1][1]]]
                elif r.points[0][1] == r.points[1][1]:
                    # Horizontal shape - extend vertically
                    if r.points[0][0] < r.points[1][0]:
                        d = hw
                    else:
                        d = -hw
                    rect = [[r.points[0][0], r.points[0][1] - d],
                            [r.points[1][0], r.points[1][1] + d]]
                else:
                    raise Exception
                rects.append([[rect[0][0] / unit, rect[0][1] / unit],
                              [rect[1][0] / unit, rect[1][1] / unit]])
        # Now, insert in LEF
        p = my_lef.pins[pin]
        port = [s for s in p.nest if s.name == 'PORT']
        assert len(port) == 1
        port = port[0]
        # First remove existing rect.
        layer = None
        for s in port.nest:
            if s.name == 'LAYER':
                layer = s.value[0]
            elif s.name == 'RECT':
                if layer == args.layer:
                    rects = rect_filter(rects, s.value)
            else:
                raise Exception
        for i, s in enumerate(port.nest):
            if s.name == 'LAYER' and s.value[0] == args.layer:
                for r in rects:
                    stmt = LefStatement('RECT', [str(r[0][0]), str(r[0][1]),
                                                 str(r[1][0]), str(r[1][1])],
                                        None, False)
                    port.nest.insert(i + 1, stmt)
                break
    with open(args.output, 'w') as f:
        my_lef.write(f)
