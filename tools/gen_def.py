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

# TODO:
# * gen verilog/vhdl netlist
# * gen config (adjust powers)
# * read info from LEF

config_sky130_fd_hd = {
    'dff': {'name': 'sky130_fd_sc_hd__dfxtp_4', 'width': 19 * 460,
            'input': 'D', 'output': 'Q', 'clock': 'CLK'},
    'cdly15_1': {'name': 'sky130_fd_sc_hd__clkdlybuf4s15_1', 'width': 8 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly15_2': {'name': 'sky130_fd_sc_hd__clkdlybuf4s15_2', 'width': 9 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly18_1': {'name': 'sky130_fd_sc_hd__clkdlybuf4s18_1', 'width': 8 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly18_2': {'name': 'sky130_fd_sc_hd__clkdlybuf4s18_1', 'width': 8 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly25_1': {'name': 'sky130_fd_sc_hd__clkdlybuf4s25_1', 'width': 8 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly25_2': {'name': 'sky130_fd_sc_hd__clkdlybuf4s25_2', 'width': 8 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly50_1': {'name': 'sky130_fd_sc_hd__clkdlybuf4s50_1', 'width': 8 * 460,
                 'input': 'A', 'output': 'X'},
    'cdly50_2': {'name': 'sky130_fd_sc_hd__clkdlybuf4s50_2', 'width': 9 * 460,
                 'input': 'A', 'output': 'X'},
    'cbuf_1':   {'name': 'sky130_fd_sc_hd__clkbuf_1', 'width': 3 * 460,
                 'input': 'A', 'output': 'X'},
    'cbuf_2':   {'name': 'sky130_fd_sc_hd__clkbuf_2', 'width': 4 * 460,
                 'input': 'A', 'output': 'X'},
    'cbuf_4':   {'name': 'sky130_fd_sc_hd__clkbuf_4', 'width': 6 * 460,
                 'input': 'A', 'output': 'X'},
    'cbuf_8':   {'name': 'sky130_fd_sc_hd__clkbuf_2', 'width': 11 * 460,
                 'input': 'A', 'output': 'X'},
    'cbuf_16':  {'name': 'sky130_fd_sc_hd__clkbuf_16', 'width': 20 * 460,
                 'input': 'A', 'output': 'X'},
    'cinv_1':   {'name': 'sky130_fd_sc_hd__clkinv_1', 'width': 3 * 460,
                 'input': 'A', 'output': 'Y'},
    'cinv_2':   {'name': 'sky130_fd_sc_hd__clkinv_2', 'width': 4 * 460,
                 'input': 'A', 'output': 'Y'},
    'inv_1':    {'name': 'sky130_fd_sc_hd__inv_1', 'width': 3 * 460,
                 'input': 'A', 'output': 'Y'},
    'mux2':  {'name': 'sky130_fd_sc_hd__mux2_1', 'width': 9 * 460,
              'in0': 'A0', 'in1': 'A1', 'sel': 'S', 'output': 'X'},
    'decap': {'name': 'sky130_fd_sc_hd__decap_3', 'width': 3 * 460},
    'tap':   {'name': 'sky130_fd_sc_hd__tapvpwrvgnd_1', 'width': 1 * 460},
    'fill1': {'name': 'sky130_fd_sc_hd__fill_1', 'width': 1 * 460},
    'fill2': {'name': 'sky130_fd_sc_hd__fill_2', 'width': 2 * 460},
    'fill4': {'name': 'sky130_fd_sc_hd__fill_4', 'width': 4 * 460},
    'fill8': {'name': 'sky130_fd_sc_hd__fill_8', 'width': 8 * 460},
}

config_sky130_fd_hs = {
    'dff': {'name': 'sky130_fd_sc_hs__dfxtp_4', 'width': 20 * 480,
            'input': 'D', 'output': 'Q', 'clock': 'CLK'},
    'dly4_1':  {'name': 'sky130_fd_sc_hs__dlygate4sd1', 'width': 8 * 480,
                'input': 'A', 'output': 'X'},
    'cdinv_1': {'name': 'sky130_fd_sc_hs__clkdlyinv3sd1_1', 'width': 6 * 480,
                'input': 'A', 'output': 'Y'},
    'mux2':  {'name': 'sky130_fd_sc_hs__mux2_1', 'width': 9 * 480,
              'in0': 'A0', 'in1': 'A1', 'sel': 'S', 'output': 'X'},
    'decap': {'name': 'sky130_fd_sc_hs__decap_4', 'width': 4 * 480},
    'tap':   {'name': 'sky130_fd_sc_hs__tapvpwrvgnd_1', 'width': 1 * 480},
    'fill1': {'name': 'sky130_fd_sc_hs__fill_1', 'width': 1 * 480},
    'fill2': {'name': 'sky130_fd_sc_hs__fill_2', 'width': 2 * 480},
    'fill4': {'name': 'sky130_fd_sc_hs__fill_4', 'width': 4 * 480},
    'fill8': {'name': 'sky130_fd_sc_hs__fill_8', 'width': 8 * 480},
}

config_sky130_fd_ls = {
    'dff': {'name': 'sky130_fd_sc_ls__dfxtp_4', 'width': 20 * 480,
            'input': 'D', 'output': 'Q', 'clock': 'CLK'},
    'dly4_1':  {'name': 'sky130_fd_sc_ls__dlygate4sd1_1', 'width': 8 * 480,
                'input': 'A', 'output': 'X'},
    'cdinv_1': {'name': 'sky130_fd_sc_ls__clkdlyinv3sd1_1', 'width': 6 * 480,
                'input': 'A', 'output': 'Y'},
    'mux2':  {'name': 'sky130_fd_sc_ls__mux2_1', 'width': 9 * 480,
              'in0': 'A0', 'in1': 'A1', 'sel': 'S', 'output': 'X'},
    'decap': {'name': 'sky130_fd_sc_ls__decap_4', 'width': 4 * 480},
    'tap':   {'name': 'sky130_fd_sc_ls__tapvpwrvgnd_1', 'width': 1 * 480},
    'fill1': {'name': 'sky130_fd_sc_ls__fill_1', 'width': 1 * 480},
    'fill2': {'name': 'sky130_fd_sc_ls__fill_2', 'width': 2 * 480},
    'fill4': {'name': 'sky130_fd_sc_ls__fill_4', 'width': 4 * 480},
    'fill8': {'name': 'sky130_fd_sc_ls__fill_8', 'width': 8 * 480},
}

config_sky130_fd_ms = {
    'dff': {'name': 'sky130_fd_sc_ms__dfxtp_4', 'width': 20 * 480,
            'input': 'D', 'output': 'Q', 'clock': 'CLK'},
    'dly4_1':  {'name': 'sky130_fd_sc_ms__dlygate4sd1_1', 'width': 8 * 480,
                'input': 'A', 'output': 'X'},
    'cdinv_1': {'name': 'sky130_fd_sc_ms__clkdlyinv3sd1_1', 'width': 6 * 480,
                'input': 'A', 'output': 'Y'},
    'mux2':  {'name': 'sky130_fd_sc_ms__mux2_1', 'width': 9 * 480,
              'in0': 'A0', 'in1': 'A1', 'sel': 'S', 'output': 'X'},
    'decap': {'name': 'sky130_fd_sc_ms__decap_4', 'width': 4 * 480},
    'tap':   {'name': 'sky130_fd_sc_ms__tapvpwrvgnd_1', 'width': 1 * 480},
    'fill1': {'name': 'sky130_fd_sc_ms__fill_1', 'width': 1 * 480},
    'fill2': {'name': 'sky130_fd_sc_ms__fill_2', 'width': 2 * 480},
    'fill4': {'name': 'sky130_fd_sc_ms__fill_4', 'width': 4 * 480},
    'fill8': {'name': 'sky130_fd_sc_ms__fill_8', 'width': 8 * 480},
}

TECHS = {
    'fd_hd': {'cells': config_sky130_fd_hd, 'width': 460, 'height': 2720,
              'tracks': [('li1', 460, 340),
                         ('met1', 340, 340),
                         ('met2', 460, 460),
                         ('met3', 680, 680),
                         ('met4', 920, 920),
                         ('met5', 3400, 3400)],
              'site': 'unithd',
              'libname': 'sky130_fd_sc_hd'},
    'fd_hs': {'cells': config_sky130_fd_hs, 'width': 480, 'height': 3330,
              'tracks': [('li1', 480, 370),
                         ('met1', 370, 370),
                         ('met2', 480, 480),
                         ('met3', 740, 740),
                         ('met4', 960, 960),
                         ('met5', 3330, 3330)],
              'site': 'unit',
              'libname': 'sky130_fd_sc_hs'},
    'fd_ls': {'cells': config_sky130_fd_ls, 'width': 480, 'height': 3330,
              'tracks': [('li1', 480, 480),
                         ('met1', 370, 370),
                         ('met2', 480, 480),
                         ('met3', 740, 740),
                         ('met4', 960, 960),
                         ('met5', 3330, 3330)],
              'site': 'unit',
              'libname': 'sky130_fd_sc_ls'},
    'fd_ms': {'cells': config_sky130_fd_ms, 'width': 480, 'height': 3330,
              'tracks': [('li1', 480, 480),
                         ('met1', 370, 370),
                         ('met2', 480, 480),
                         ('met3', 740, 740),
                         ('met4', 960, 960),
                         ('met5', 3330, 3330)],
              'site': 'unit',
              'libname': 'sky130_fd_sc_ms'},
}


class GenDef:
    def __init__(self, tech, name):
        self.name = name
        self.tech = TECHS[tech]
        self.row_width = self.tech['width']
        self.row_height = self.tech['height']
        self.cells = self.tech['cells']
        self.hmargin = 12 * self.row_width  # = 5520
        self.vmargin = 2 * self.row_height
        self.nrow = 0   # Number of rows
        self.rowl = 0   # Length of rows
        self.rows = []
        self.nets = []
        self.pins = []
        self.components = []
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
            self.conns = []

    def add_component(self, name, klass):
        comp = GenDef.Component(name, klass)
        self.components.append(comp)
        return comp

    def place_component(self, comp, row):
        self.rows[row]['comps'].append(comp)
        self.rows[row]['width'] += comp.klass['width']

    def connect(self, net, inst, port):
        net.conn.append((inst, port))
        if inst is not None:
            inst.conns.append({'port': port, 'net': net})

    def build_fillers(self):
        fillers = [v for k, v in self.cells.items() if k.startswith('fill')]
        self.fillers = sorted(fillers,
                              key=lambda key: key['width'], reverse=True)
        self.fill_label = 0

    def pad_rows(self):
        """Add fillers so that all rows have the same length"""
        wd = max([r['width'] for r in self.rows])
        for i, r in enumerate(self.rows):
            for f in self.fillers:
                while r['width'] + f['width'] <= wd:
                    c = self.add_component('FILL_{}'.format(
                        self.fill_label), f)
                    self.place_component(c, i)
                    self.fill_label += 1
            assert r['width'] == wd

    def build_tap_decap(self, row, idx):
        # tap
        tap = self.add_component('tap{}_{}'.format(row, idx),
                                 self.cells['tap'])
        self.place_component(tap, row)
        # decap
        decap = self.add_component('decap{}_{}'.format(row, idx),
                                   self.cells['decap'])
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
            print("ROW ROW_{} {} {} {} {} DO {} BY 1 STEP {} 0 ;".format(
                i, self.tech['site'], r['x'], r['y'], r['orientation'],
                self.rowl, self.row_width),
                  file=f)

    def disp_def_tracks(self, f):
        for layer, xstep, ystep in self.tech['tracks']:
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

    def write_config(self, filename):
        with open(filename, 'w') as f:
            print('set ::env(STD_CELL_LIBRARY) "{}"'.format(
                self.tech['libname']), file=f)
            print(file=f)
            print('set ::env(FP_PDN_VOFFSET) 0', file=f)
            print('set ::env(FP_PDN_VPITCH) 16', file=f)
            print('set ::env(FP_PDN_HOFFSET) {}'.format(
                self.row_height / 1000), file=f)
            print('set ::env(FP_PDN_HPITCH) {}'.format(
                3 * self.row_height / 1000), file=f)

            print(file=f)
            print('set ::env(FP_SIZING) absolute', file=f)
            print('set ::env(DIE_AREA) "0 0 {} {}"'.format(
                self.x_size / 1000, self.y_size / 1000), file=f)

    def _add_net_name(self, dct, name, obj):
        b = name.find('[')
        if b == -1:
            idx = None
        else:
            # This is part of a bus.
            idx = int(name[b + 1:-1])
            name = name[:b]
        if name in dct:
            dct[name][idx] = obj
        else:
            dct[name] = {idx: obj}

    def write_verilog(self, f):
        # 1. gather input-outputs
        pins = {}
        for p in self.pins:
            self._add_net_name(pins, p.name, p)
        f.write("module {} (\n".format(self.name))
        for i, name in enumerate(sorted(pins.keys())):
            p = pins[name]
            k = list(p.keys())
            first = p[k[0]]
            if i != 0:
                f.write(",\n")
            f.write("    {}".format({'I': 'input', 'O': 'output'}[first.dir]))
            if k[0] is not None:
                assert min(k) == 0
                assert max(k) == len(k) - 1
                f.write(" [{}:0]".format(len(k) - 1))
            f.write(" {}".format(name))
        f.write(");\n")
        # 2. gather wires
        wires = {}
        for n in self.nets:
            self._add_net_name(wires, n.name, n)
        for name in sorted(wires.keys()):
            w = wires[name]
            k = list(w.keys())
            f.write("  wire")
            if k[0] is not None:
                assert min(k) == 0
                assert max(k) == len(k) - 1
                f.write(" [{}:0]".format(len(k) - 1))
            f.write(" {};\n".format(name))
        # 3. write cells
        for c in self.components:
            if not c.conns:
                # Discard components without connections (fill, taps...)
                continue
            f.write("  {} {}(".format(c.klass['name'], c.name))
            for i, conn in enumerate(c.conns):
                if i != 0:
                    f.write(", ")
                f.write(".{}({})".format(c.klass[conn['port']],
                                         conn['net'].name))
            f.write(");\n")
        f.write("endmodule\n")
