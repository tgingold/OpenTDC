#!/usr/bin/env python3
# Copyright 2020 Tristan Gingold
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

import argparse
from gen_def import GenDef

class tap_line(GenDef):
    def __init__(self, name, ntaps):
        super().__init__(name)
        self.ntaps = ntaps

    def build_netlist(self):
        res = {'inp': None, 'taps': [] }
        res['inp'] = self.add_pin('inp_i', 'I')
        last = res['inp'].net
        for i in range(self.ntaps):
            tap = { }
            res['taps'].append(tap)
            # Row 1:
            dff1 = self.add_component('dff1_{}'.format(i), self.config['dff'])
            tap['dff1'] = dff1
            self.connect(last, dff1, 'input')
            o1 = self.add_net('q1_{}'.format(i))
            self.connect(o1, dff1, 'output')
            ck1 = self.add_pin('clk_i[{}]'.format(2*i), 'I')
            tap['ck1'] = ck1
            self.connect(ck1.net, dff1, 'clock')
            # Row 2: dff
            dff2 = self.add_component('dff2_{}'.format(i), self.config['dff'])
            tap['dff2'] = dff2
            self.connect(o1, dff2, 'input')
            out = self.add_pin('tap_o[{}]'.format(i), 'O')
            tap['out'] = out
            self.connect(out.net, dff2, 'output')
            ck2 = self.add_pin('clk_i[{}]'.format(2*i + 1), 'I')
            tap['ck2'] = ck2
            self.connect(ck2.net, dff2, 'clock')
            # Row 0: delay
            if i != self.ntaps - 1:
                delay = self.add_component(
                    'delay_{}'.format(i), self.config['delay'])
                self.connect(last, delay, 'input')
                last = self.add_net('in_d{}'.format(i))
                self.connect(last, delay, 'output')
            else:
                delay = None
            tap['delay'] = delay
        self.netlist = res

    def build_all_tap_decap(self, col):
        for k in range(self.nrow):
            self.build_tap_decap(k, col)

    def build_horizontal(self):
        self.build_rows(3)
        self.place_pin(self.netlist['inp'], 'W', 0)
        for i, t in enumerate(self.netlist['taps']):
            x_pin = self.rows[0]['width']
            x_pin_step = self.config['dff']['width'] // 4
            # Row 1:
            self.place_component(t['dff1'], 1)
            self.place_pin(t['ck1'], 'N', x_pin + x_pin_step)
            # Row 2: dff
            self.place_component(t['dff2'], 2)
            self.place_pin(t['out'], 'N', x_pin + 3 * x_pin_step)
            self.place_pin(t['ck2'], 'N', x_pin + 2 * x_pin_step)
            # Row 0: delay
            if t['delay'] is not None:
                self.place_component(t['delay'], 0)
            self.build_all_tap_decap(i)
            self.pad_rows()
        self.compute_size()

    def build_horizontal_x2(self):
        self.build_rows(6)
        self.place_pin(self.netlist['inp'], 'W', 2 * self.row_height)
        taps = self.netlist['taps']
        mid = (self.ntaps + 1) // 2
        l1 = taps[:mid]
        l2 = taps[len(taps):mid - 1:-1]
        if self.ntaps % 2 == 1:
            l2.append(None)
        assert len(l1) == len(l2)
        for i, (t1, t2) in enumerate(zip(l1, l2)):
            x_pin = self.rows[0]['width']
            x_pin_step = self.config['dff']['width'] // 8
            # Row 0: dff
            self.place_component(t1['dff2'], 0)
            self.place_pin(t1['out'], 'N', x_pin + 1 * x_pin_step)
            self.place_pin(t1['ck2'], 'N', x_pin + 2 * x_pin_step)
            # Row 1: dff
            self.place_component(t1['dff1'], 1)
            self.place_pin(t1['ck1'], 'N', x_pin + 3 * x_pin_step)
            # Row 2: delay
            if t1['delay'] is not None:
                self.place_component(t1['delay'], 2)
            # Row 3: delay
            if t2['delay'] is not None:
                self.place_component(t2['delay'], 3)
            # Row 4: dff
            self.place_component(t2['dff1'], 4)
            self.place_pin(t2['ck1'], 'N', x_pin + 4 * x_pin_step)
            # Row 5: dff2
            self.place_component(t2['dff2'], 5)
            self.place_pin(t2['out'], 'N', x_pin + 5 * x_pin_step)
            self.place_pin(t2['ck2'], 'N', x_pin + 6 * x_pin_step)
            self.build_all_tap_decap(i)
            self.pad_rows()
        self.compute_size()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate a tapline')
    parser.add_argument('--length', '-l', required=True, type=int,
                        help='number of taps')
    parser.add_argument('--name', '-n', type=str, default='tap_line',
                        help='name of the design')
    parser.add_argument('--geo', '-g', choices=['x1', 'x2'], default='x1',
                        help='geometry of the tapline')
    args = parser.parse_args()

    inst = tap_line(args.name, args.length)
    inst.build_netlist()
    if args.geo == 'x1':
        inst.build_horizontal()
    elif args.geo == 'x2':
        inst.build_horizontal_x2()
    else:
        raise Exception
    inst.disp_def(args.name + '.def')
