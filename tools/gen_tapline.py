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

import argparse
from gen_def import GenDef


class tap_line(GenDef):
    def __init__(self, name, ntaps, ref, tech, delay, nfill):
        super().__init__(tech, name)
        self.cells['delay'] = self.cells[delay]
        self.ntaps = ntaps
        self.nfill = nfill
        self.ref = ref

    def build_tap(self, pfx, idx, last):
        tap = {}
        # Row 1:
        dff1 = self.add_component('{}dff1_{}'.format(pfx, idx),
                                  self.cells['dff'])
        tap['dff1'] = dff1
        self.connect(last, dff1, 'input')
        o1 = self.add_net('{}q1_{}'.format(pfx, idx))
        self.connect(o1, dff1, 'output')
        # Row 2: dff
        dff2 = self.add_component('{}dff2_{}'.format(pfx, idx),
                                  self.cells['dff'])
        tap['dff2'] = dff2
        self.connect(o1, dff2, 'input')
        out = self.add_pin('{}tap_o[{}]'.format(pfx, idx), 'O')
        self.connect(out.net, dff2, 'output')
        # Row 0: delay
        if idx != self.ntaps - 1:
            delay = self.add_component(
                '{}delay_{}'.format(pfx, idx), self.cells['delay'])
            self.connect(last, delay, 'input')
            last = self.add_net('{}in_d{}'.format(pfx, idx))
            self.connect(last, delay, 'output')
        else:
            delay = None
        tap['delay'] = delay
        tap['last'] = last
        tap['opad'] = [out]
        return tap

    def build_netlist_taps(self, inp_name, pfx):
        inp = self.add_pin(inp_name, 'I')
        taps = []
        last = inp.net
        for i in range(self.ntaps):
            tap = self.build_tap(pfx, i, last)
            last = tap.pop('last')
            taps.append(tap)
        return (inp, taps)

    def build_netlist(self):
        inp, taps = self.build_netlist_taps('inp_i', '')
        if self.ref:
            ref, rtaps = self.build_netlist_taps('ref_i', 'r')
        else:
            ref, rtaps = (None, None)
        self.netlist = {'inp': inp, 'taps': taps, 'ref': ref, 'rtaps': rtaps}

    def insert_all_tap_decap(self, col):
        for k in range(self.nrow):
            self.build_tap_decap(k, col)

    def arrange_taps_line(self, taps, linelen, pos):
        stride = linelen * pos
        if pos % 2 == 0:
            res = taps[stride:stride + linelen]
        else:
            res = taps[stride + linelen-1:stride-1:-1]
            for t in res:
                # line in reverse direction, flip delay components
                if t['delay']:
                    t['delay'].flip = True
        return res

    def arrange(self, nlines):
        """Arrange the tap per lines"""
        lines_mul = 2 if self.ref else 1
        # Create list of taps per line
        taps = self.netlist['taps']
        rtaps = self.netlist['rtaps']
        linelen = (len(taps) + nlines - 1) // nlines
        extra = linelen * nlines - len(taps)
        taps.extend([None] * extra)  # Pad with None
        if self.ref:
            rtaps.extend([None] * extra)  # Pad with None
        arr = [None] * (nlines * lines_mul)
        for j in range(nlines):
            if self.ref:
                arr[j*2] = self.arrange_taps_line(taps, linelen, j)
                arr[j*2+1] = self.arrange_taps_line(rtaps, linelen, j)
            else:
                arr[j] = self.arrange_taps_line(taps, linelen, j)
        self.arrangement = arr

    def build_clock_netlist_indiv(self, taps, pfx):
        """Add clock net and pads.  This is done after arrange() so that it
        is easier to share pins"""
        # Method 1: each dff has its own clock pin
        for idx, p in enumerate(taps):
            ck1 = self.add_pin('{}clk_i[{}]'.format(pfx, 2*idx), 'I')
            self.connect(ck1.net, p['dff1'], 'clock')
            ck2 = self.add_pin('{}clk_i[{}]'.format(pfx, 2*idx + 1), 'I')
            self.connect(ck2.net, p['dff2'], 'clock')
            p['opad'].extend([ck2, ck1])

    def build_clock_netlist(self, conf):
        """Add clock net and pads.  This is done after arrange() so that it
        is easier to share pins"""
        arr = self.arrangement
        if conf == 'indiv':
            # indiv: each dff has its own clock pin
            self.build_clock_netlist_indiv(self.netlist['taps'], '')
            if self.ref:
                self.build_clock_netlist_indiv(self.netlist['rtaps'], 'r')
        elif conf == 'share' or conf == 's1':
            # share: all the dff of the same column share the clock
            for i in range(len(arr[0])):
                ck = self.add_pin('clk_i[{}]'.format(i), 'I')
                for k in range(len(arr)):
                    self.connect(ck.net, arr[k][i]['dff1'], 'clock')
                    self.connect(ck.net, arr[k][i]['dff2'], 'clock')
                arr[0][i]['opad'].append(ck)
        else:
            raise Exception  # bad clock config

    def place_horizontal_x(self):
        arr = self.arrangement
        self.build_rows(3 * len(arr))
        # Place inputs
        self.place_pin(self.netlist['inp'], 'W', 2 * self.row_height)
        if self.ref:
            self.place_pin(self.netlist['ref'], 'W', 3 * self.row_height)
        # Place cells and pins
        for i in range(len(arr[0])):
            x_pin = self.rows[0]['width']  # x offset of the next cell
            opads = []
            for j in range(len(arr)):
                tap = arr[j].pop(0)
                if tap is None:
                    continue
                crow = list(range(3 * j, 3 * j + 3))
                if j % 2 == 1:
                    crow.reverse()
                # Row 0: dff
                self.place_component(tap['dff2'], crow[0])
                # Row 1: dff
                self.place_component(tap['dff1'], crow[1])
                # Row 2: delay
                if tap['delay'] is not None:
                    self.place_component(tap['delay'], crow[2])
                opads.extend(tap['opad'])
                self.row_add_fill(crow[0], self.nfill)
                self.row_add_fill(crow[1], self.nfill)
                self.row_add_fill(crow[2], self.nfill)
            # Opads
            x_pin_step = self.cells['dff']['width'] // len(opads)
            for k, p in enumerate(opads):
                self.place_pin(p, 'N', x_pin + k * x_pin_step)
            self.insert_all_tap_decap(i)
            self.pad_rows()
        self.compute_size()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate a tapline')
    # Other args: -c (with clock buf), -d (delay cell)
    parser.add_argument('--length', '-l', required=True, type=int,
                        help='number of taps')
    parser.add_argument('--name', '-n', type=str, default='tap_line',
                        help='name of the design')
    parser.add_argument('--geo', '-g', type=int, default=1,
                        help='geometry of the tapline')
    parser.add_argument('--tech', '-t', type=str, default="fd_hd",
                        help='technology')
    parser.add_argument('--ref', '-r', default=False, action='store_true',
                        help='add a second ref line')
    parser.add_argument('--clock', '-c', default='indiv',
                        choices=['indiv', 'share', 's1'],
                        help='select clock configuration')
    parser.add_argument('--delay', '-d', default='cdly15_1',
                        help='select delay gate')
    parser.add_argument('--fill', '-f', default=0, type=int,
                        help='extra empty columns')
    args = parser.parse_args()

    inst = tap_line(args.name, args.length, args.ref, args.tech, args.delay,
                    args.fill)
    inst.build_netlist()
    inst.arrange(args.geo)
    inst.build_clock_netlist(args.clock)
    inst.place_horizontal_x()
    inst.disp_def(args.name + '.def')
    inst.write_config(args.name + '.tcl')
    inst.write_verilog(open(args.name + '.v', 'w'))
    inst.write_vhdl_component(open(args.name + '_comp.vhdl', 'w'))
