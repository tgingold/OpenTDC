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

config_sky130_fd_hd = {
    'dff': {'name': 'sky130_fd_sc_hd__dfxtp_4', 'width': 19 * 460,
            'input': 'D', 'output': 'Q', 'clock': 'CLK'},
    'delay': {'name': 'sky130_fd_sc_hd__clkdlybuf4s15_1', 'width': 8 * 460,
              'input': 'A', 'output': 'X'},
    'mux2':  {'name': 'sky130_fd_sc_hd__mux2_1', 'width': 9 * 460,
              'in0': 'A0', 'in1': 'A1', 'sel': 'S', 'output': 'X'},
    'decap': {'name': 'sky130_fd_sc_hd__decap_3', 'width': 3 * 460},
    'tap':   {'name': 'sky130_fd_sc_hd__tapvpwrvgnd_1', 'width': 1* 460},
    'fill1': {'name': 'sky130_fd_sc_hd__fill_1', 'width': 1 * 460},
    'fill2': {'name': 'sky130_fd_sc_hd__fill_2', 'width': 2 * 460},
    'fill4': {'name': 'sky130_fd_sc_hd__fill_4', 'width': 4 * 460},
    'fill8': {'name': 'sky130_fd_sc_hd__fill_8', 'width': 8 * 460},
}


class GenDef:
    def __init__(self, name):
        self.name = name
        self.row_width = 460
        self.row_height = 2720
        self.hmargin = 12 * self.row_width  # = 5520
        self.vmargin = 2 * self.row_height
        self.nrow = 0   # Number of rows
        self.rowl = 0   # Length of rows
        self.rows = []
        self.nets = []
        self.pins = []
        self.config = config_sky130_fd_hd
        self.build_fillers()

    def build_rows(self, nrow):
        self.nrow = nrow
        for i in range(self.nrow):
            r = {'comps': [], 'width': 0,
                 'x': self.hmargin, 'y': self.vmargin + i * self.row_height,
                 'orientation': "FS" if i % 2 == 0 else "N"}
            self.rows.append(r)

    class Net:
        def __init__(self, name):
            self.name = name
            self.conn = []

    def add_net(self, name):
        n = GenDef.Net(name)
        self.nets.append(n)
        return n

    class Pin:
        def __init__(self, name, io):
            self.name = name
            self.dir = io
            self.net = None
            self.place = None
            self.offset = None

    def add_pin(self, name, io):
        """Add a pin, return the corresponding net"""
        assert io in "IO"
        n = self.add_net(name)
        p = GenDef.Pin(name, io)
        p.net = n
        self.pins.append(p)
        n.conn.append((None, p))
        return p

    def place_pin(self, pin, place, offset):
        assert pin.place is None, "pin already placed"
        assert place in "NSEW"
        pin.place = place
        pin.offset = offset

    class Component:
        def __init__(self, name, klass):
            self.name = name
            self.klass = klass

    def add_component(self, name, klass):
        return GenDef.Component(name, klass)

    def place_component(self, comp, row):
        self.rows[row]['comps'].append(comp)
        self.rows[row]['width'] += comp.klass['width']

    def connect(self, net, inst, port):
        net.conn.append((inst, port))

    def build_fillers(self):
        fillers = [v for k, v in self.config.items() if k.startswith('fill')]
        self.fillers = sorted(fillers,
                              key=lambda key: key['width'], reverse=True)
        self.fill_label = 0

    def pad_rows(self):
        """Add fillers so that all rows have the same length"""
        wd = max([r['width'] for r in self.rows])
        for i, r in enumerate(self.rows):
            for f in self.fillers:
                while r['width'] + f['width'] <= wd:
                    c = self.add_component('FILL_{}'.format(self.fill_label), f)
                    self.place_component(c, i)
                    self.fill_label += 1
            assert r['width'] == wd

    def build_tap_decap(self, row, idx):
        # tap
        tap = self.add_component('tap{}_{}'.format(row, idx),
                                 self.config['tap'])
        self.place_component(tap, row)
        # decap
        decap = self.add_component('decap{}_{}'.format(row, idx),
                                   self.config['decap'])
        self.place_component(decap, row)

    def compute_size(self):
        self.rowl = max(r['width'] for r in self.rows) // self.row_width
        self.x_size = self.rowl * self.row_width + 2 * self.hmargin
        self.y_size = self.nrow * self.row_height + 2 * self.vmargin

    def disp_def_hdr(self, f):
        print("VERSION 5.8 ;", file=f)
        print('DIVIDERCHAR "/" ;', file=f)
        print('BUSBITCHARS "[]" ;', file=f)
        print('DESIGN {} ;'.format(self.name), file=f)
        print('UNITS DISTANCE MICRONS 1000 ;', file=f)
        print('DIEAREA ( 0 0 ) ( {} {} ) ;'.format(
            self.x_size, self.y_size), file=f)

    def disp_def_row(self, f):
        for i in range(self.nrow):
            r = self.rows[i]
            print("ROW ROW_{} unithd {} {} {} DO {} BY 1 STEP {} 0 ;".format(
                i, r['x'], r['y'], r['orientation'],
                self.rowl, self.row_width),
                  file=f)

    def disp_def_tracks(self, f):
        for layer, xstep, ystep in [('li1', 460, 340),
                                    ('met1', 340, 340),
                                    ('met2', 460, 460),
                                    ('met3', 680, 680),
                                    ('met4', 920, 920),
                                    ('met5', 3400, 3400)]:
            print("TRACKS X {} DO {} STEP {} LAYER {} ;".format(
                xstep // 2, (self.x_size + xstep // 2) // xstep, xstep, layer),
                  file=f)
            print("TRACKS Y {} DO {} STEP {} LAYER {} ;".format(
                ystep // 2, (self.y_size + ystep // 2) // ystep, ystep, layer),
                  file=f)

    def disp_def_components(self, f):
        ncomps = sum([len(r['comps']) for r in self.rows])
        print('COMPONENTS {} ;'.format(ncomps), file=f)
        for r in self.rows:
            x = r['x']
            y = r['y']
            orien = r['orientation']
            for c in r['comps']:
                print('  - {} {}'.format(c.name, c.klass['name']),
                      end='', file=f)
                print(' + FIXED ( {} {} ) {}'.format(
                    x, y, orien), end='', file=f)
                x += c.klass['width']
                print(' ;', file=f)
        print('END COMPONENTS', file=f)

    def disp_def_pins(self, f):
        print('PINS {} ;'.format(len(self.pins)), file=f)
        for p in self.pins:
            print('  - {} + NET {}'.format(p.name, p.net.name),
                  end='', file=f)
            print(' + DIRECTION {}'.format(
                {'I': 'INPUT', 'O': 'OUTPUT'}[p.dir]), end='', file=f)
            print(' + USE SIGNAL', end='', file=f)
            if p.place in "NS":
                if p.place == 'S':
                    y = 2000
                else:
                    y = self.y_size - 2000
                print(' + PLACED ( {} {} ) N '.format(
                    self.hmargin + p.offset, y), end='', file=f)
                print(' + LAYER met2 ( {} {} ) ( {} {} )'.format(
                    -140, -2000, 140, 2000), end='', file=f)
            elif p.place in "EW":
                if p.place == 'W':
                    x = 2000
                else:
                    x = self.x_size - 2000
                print(' + PLACED ( {} {} ) N '.format(
                    x, self.vmargin + p.offset), end='', file=f)
                print(' + LAYER met3 ( {} {} ) ( {} {} )'.format(
                    -2000, -300, 2000, 300), end='', file=f)
            print(' ;', file=f)
        print('END PINS', file=f)

    def disp_def_nets(self, f):
        print('NETS {} ;'.format(len(self.nets)), file=f)
        for n in self.nets:
            print('  - {}'.format(n.name), end='', file=f)
            for inst, port in n.conn:
                if inst is None:
                    # This is a pin.
                    print(' ( PIN {} )'.format(port.name), end='', file=f)
                else:
                    # This is an instance
                    print(' ( {} {} )'.format(
                        inst.name, inst.klass[port]), end='', file=f)
            print(' + USE SIGNAL ;', file=f)
        print('END NETS', file=f)

    def disp_def(self, filename):
        with open(filename, 'w') as f:
            self.disp_def_hdr(f)
            self.disp_def_row(f)
            self.disp_def_tracks(f)
            self.disp_def_components(f)
            self.disp_def_pins(f)
            self.disp_def_nets(f)
            print('END DESIGN', file=f)
