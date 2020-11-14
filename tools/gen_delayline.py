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

verbose = False

class DelayLine(GenDef):
    def __init__(self, name, nstages):
        super().__init__(name)
        self.nstages = nstages

    def build_netlist(self):
        res = {'inp': None, 'out': None, 'stages': [] }
        res['inp'] = self.add_pin('inp_i', 'I')
        res['out'] = self.add_pin('out_o', 'O')
        last = res['inp'].net
        for i in range(self.nstages):
            stage = { }
            res['stages'].append(stage)
            # Enable input
            en = self.add_pin('en_i[{}]'.format(i), 'I')
            stage['en'] = en
            # Delays
            last_delay = last
            stage['delays'] = []
            for k in range(2**i):
                delay = self.add_component(
                    'delay_{}_{}'.format(i, k), self.cells['delay'])
                stage['delays'].append(delay)
                self.connect(last_delay, delay, 'input')
                last_delay = self.add_net('in{}_d{}'.format(i, k))
                self.connect(last_delay, delay, 'output')
            # Mux
            mux = self.add_component('mux_{}'.format(i), self.cells['mux2'])
            stage['mux'] = mux
            self.connect(last, mux, 'in0')
            self.connect(last_delay, mux, 'in1')
            self.connect(en.net, mux, 'sel')
            if i != 0:
                last = self.add_net('o_{}'.format(i))
            else:
                last = res['out'].net
            self.connect(last, mux, 'output')
        self.netlist = res

    def build_square(self):
        # Use self.nstages stages, so 2**nstages delay cells
        # To have a square shape, the maximum length should be
        # about 2**(nstages//2)
        self.build(2**(self.nstages//2))

    def build_linear(self):
        # No limits
        self.build(2**self.nstages)

    def build(self, maxcells):
        # Compute the number of rows for each stage:
        rows = [None] * self.nstages
        nrows = 0
        for i in range(self.nstages):
            if i < 1:
                rows[i] = 1
            elif 2**(i - 1) <= maxcells:
                rows[i] = 2
            else:
                rows[i] = 2**i // maxcells
            nrows += rows[i]
        self.build_rows(nrows)
        self.place_pin(self.netlist['inp'], 'W', 0 * self.row_height)
        self.place_pin(self.netlist['out'], 'W', nrows * self.row_height)
        stages = self.netlist['stages']
        # First the muxes
        row = nrows - 1
        for i in range(self.nstages):
            stage = stages[i]
            self.place_pin(stage['en'], 'W', row * self.row_height)
            self.place_component(stage['mux'], row)
            row -= rows[i]
        assert row == -1
        # Second pad + tap
        self.pad_rows()
        for i in range(self.nrow):
            self.build_tap_decap(i, 0)
        # Third delays
        row = nrows - 1
        for i in range(self.nstages):
            stage = stages[i]
            dlys = stage['delays']
            # Number of delay cells per row
            assert len(dlys) % rows[i] == 0
            n = len(dlys) // rows[i]
            # Ordered list of delay cells for each row
            l = [None] * rows[i]
            for j in range(rows[i]):
                if j % 2 == 0:
                    l[j] = dlys[j*n:j*n+n]
                else:
                    l[j] = dlys[j*n+n-1:j*n-1:-1]
            # Place delay cells
            row -= rows[i]
            if verbose:
                print("stage {}: {} rows, n={}".format(i, rows[i], n))
                for k in range(rows[i]):
                    print([c.name for c in l[k]])
            for j in range(n):
                for k in range(rows[i]):
                    self.place_component(l[k].pop(0), row + k)
                    self.build_tap_decap(row + k, j + 1)
        self.pad_rows()
        self.compute_size()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate a tapline')
    parser.add_argument('--length', '-l', required=True, type=int,
                        help='log2 of tap number')
    parser.add_argument('--name', '-n', type=str, default='delayline',
                        help='name of the design')
    args = parser.parse_args()

    inst = DelayLine(args.name, args.length)
    inst.build_netlist()
    inst.build_square()
    inst.disp_def(args.name + '.def')
