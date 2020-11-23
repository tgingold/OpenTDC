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
    'dly4_1':  {'name': 'sky130_fd_sc_hs__dlygate4sd1_1', 'width': 8 * 480,
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

# with/height: from the site size in tech LEF.
# Tracks: layer: (HPITCH, VPITCH, WD)
# pins: layer used to place pins
TECHS = {
    'fd_hd': {'cells': config_sky130_fd_hd, 'width': 460, 'height': 2720,
              'tracks': {'li1': (460, 340, 170),
                         'met1': (340, 340, 140),
                         'met2': (460, 460, 140),
                         'met3': (680, 680, 300),
                         'met4': (920, 920, 300),
                         'met5': (3400, 3400, 1600)},
              'site': 'unithd',
              'pins': ('met2', 'met3'),
              'libname': 'sky130_fd_sc_hd'},
    'fd_hs': {'cells': config_sky130_fd_hs, 'width': 480, 'height': 3330,
              'tracks': {'li1': (480, 370, 170),
                         'met1': (370, 370, 140),
                         'met2': (480, 480, 140),
                         'met3': (740, 740, 300),
                         'met4': (960, 960, 300),
                         'met5': (3330, 3330, 1600)},
              'site': 'unit',
              'pins': ('met2', 'met3'),
              'libname': 'sky130_fd_sc_hs'},
    'fd_ls': {'cells': config_sky130_fd_ls, 'width': 480, 'height': 3330,
              'tracks': {'li1': (480, 480, 170),
                         'met1': (370, 370, 140),
                         'met2': (480, 480, 140),
                         'met3': (740, 740, 300),
                         'met4': (960, 960, 300),
                         'met5': (3330, 3330, 1600)},
              'site': 'unit',
              'pins': ('met2', 'met3'),
              'libname': 'sky130_fd_sc_ls'},
    'fd_ms': {'cells': config_sky130_fd_ms, 'width': 480, 'height': 3330,
              'tracks': {'li1': (480, 480, 170),
                         'met1': (370, 370, 140),
                         'met2': (480, 480, 140),
                         'met3': (740, 740, 300),
                         'met4': (960, 960, 300),
                         'met5': (3330, 3330, 1600)},
              'site': 'unit',
              'pins': ('met2', 'met3'),
              'libname': 'sky130_fd_sc_ms'},
}


class GenDef:
    def __init__(self, tech, name):
        self.name = name
        self.tech = TECHS[tech]
        self.pintech = TECHS['fd_hd']
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
        self.ppow = None  # power name (for hdl output)
        self.pgnd = None
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
            self.layer = None

    def add_pin(self, name, io):
        """Add a pin, return the corresponding net"""
        assert io in "IO"
        n = self.add_net(name)
        p = GenDef.Pin(name, io)
        p.net = n
        self.pins.append(p)
        n.conn.append((None, p))
        return p

    def place_pin(self, pin, orient, offset):
        assert pin.place is None, "pin already placed"
        assert orient in "NSEW"
        pin.place = orient
        offset += self.hmargin if orient in "NS" else self.vmargin
        # Adjust pin position: put it on the grid
        idx = 0 if orient in "NS" else 1
        pin.layer = self.pintech['pins'][idx]
        pitch = self.pintech['tracks'][pin.layer][idx]
        offset -= pitch // 2
        offset = (offset // pitch) * pitch
        offset += pitch // 2
        pin.offset = offset

    class Component:
        def __init__(self, name, model):
            self.name = name
            self.model = model
            self.flip = False
            self.conns = []

    def add_component(self, name, model):
        comp = GenDef.Component(name, model)
        self.components.append(comp)
        return comp

    def place_component(self, comp, row):
        assert row >= 0
        self.rows[row]['comps'].append(comp)
        self.rows[row]['width'] += comp.model['width']

    def connect(self, net, inst, port):
        net.conn.append((inst, port))
        if inst is not None:
            inst.conns.append({'port': port, 'net': net})

    def build_fillers(self):
        fillers = [v for k, v in self.cells.items() if k.startswith('fill')]
        self.fillers = sorted(fillers,
                              key=lambda key: key['width'], reverse=True)
        self.fill_label = 0

    def _add_fill(self, row, comp):
        c = self.add_component('FILL_{}'.format(self.fill_label), comp)
        self.place_component(c, row)
        self.fill_label += 1

    def pad_rows(self):
        """Add fillers so that all rows have the same length"""
        wd = max([r['width'] for r in self.rows])
        for i, r in enumerate(self.rows):
            for f in self.fillers:
                while r['width'] + f['width'] <= wd:
                    self._add_fill(i, f)
            assert r['width'] == wd

    def row_add_fill(self, row, wd):
        wd *= self.row_width
        for f in self.fillers:
            if wd == 0:
                break
            fw = f['width']
            while wd >= fw:
                self._add_fill(row, f)
                wd -= fw

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

    def set_power_pin(self, ppow, pgnd):
        self.ppow = ppow
        self.pgnd = pgnd

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
        for layer, (xpitch, ypitch, wd) in self.tech['tracks'].items():
            print("TRACKS X {} DO {} STEP {} LAYER {} ;".format(
                xpitch // 2,
                (self.x_size + xpitch // 2) // xpitch, xpitch, layer),
                  file=f)
            print("TRACKS Y {} DO {} STEP {} LAYER {} ;".format(
                ypitch // 2,
                (self.y_size + ypitch // 2) // ypitch, ypitch, layer),
                  file=f)

    def disp_def_components(self, f):
        ncomps = sum([len(r['comps']) for r in self.rows])
        print('COMPONENTS {} ;'.format(ncomps), file=f)
        for r in self.rows:
            x = r['x']
            y = r['y']
            orient = r['orientation']
            for c in r['comps']:
                print('  - {} {}'.format(c.name, c.model['name']),
                      end='', file=f)
                if c.flip:
                    if orient[0] == 'F':
                        corient = orient[1:]
                    else:
                        corient = 'F' + orient
                else:
                    corient = orient
                print(' + FIXED ( {} {} ) {}'.format(
                    x, y, corient), end='', file=f)
                x += c.model['width']
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
            idx = 0 if p.place in "NS" else 1
            pinwd = self.pintech['tracks'][p.layer][2]
            pinpitch = self.pintech['tracks'][p.layer][idx]
            corepitch = self.tech['tracks'][p.layer][idx]
            corewd = self.tech['tracks'][p.layer][2]
            if p.place in "NS":
                # In general: met2
                pinln = pinwd
                if p.place == 'S':
                    y = pinwd
                else:
                    y = self.y_size - pinwd
                print(' + PLACED ( {} {} ) {} '.format(
                    p.offset, y, p.place), end='', file=f)
                print(' + LAYER {} ( {} {} ) ( {} {} )'.format(
                    p.layer,
                    -pinwd, -pinln, pinwd, pinln), end='', file=f)
            elif p.place in "EW":
                # In general: met3
                if p.place == 'W':
                    x = pinwd
                else:
                    x = self.x_size - pinwd
                print(' + PLACED ( {} {} ) N '.format(
                    x, p.offset), end='', file=f)
                if corepitch != pinpitch:
                    pinln = pinpitch + pinwd
                else:
                    pinln = pinwd
                print(' + LAYER {} ( {} {} ) ( {} {} )'.format(
                    p.layer,
                    -pinwd, -pinwd, pinwd, pinln), end='', file=f)
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
                        inst.name, inst.model[port]), end='', file=f)
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
            # Horizontal lines must agree with the parent
            pdn_hpitch = 153180  # From configuration/floorplan.tcl
            if self.y_size < pdn_hpitch // 2:
                print('Design is too small: height={}, power pitch={}'.format(
                    self.y_size, pdn_hpitch))
            pdn_vpitch = 153600
            if self.x_size > pdn_vpitch:
                # Align
                vpitch = (pdn_vpitch // self.row_width) * self.row_width
            else:
                vpitch = (self.rowl // 2) * self.row_width
            print('set ::env(FP_PDN_VOFFSET) 0', file=f)
            print('set ::env(FP_PDN_VPITCH) {}'.format(vpitch / 1000), file=f)
            print('set ::env(FP_PDN_HOFFSET) {}'.format(
                (90 + self.row_height) / 1000), file=f)
            print('set ::env(FP_PDN_HPITCH) {}'.format(
                pdn_hpitch / 1000), file=f)
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

    def write_verilog_range(self, f, key):
        if key[0] is not None:
            assert min(key) == 0
            assert max(key) == len(key) - 1
            f.write(" [{}:0]".format(len(key) - 1))

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
            self.write_verilog_range(f, k)
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
            self.write_verilog_range(f, k)
            f.write(" {};\n".format(name))
        # 3. write cells
        for c in self.components:
            if not c.conns:
                # Discard components without connections (fill, taps...)
                continue
            f.write("  {} {}(".format(c.model['name'], c.name))
            for i, conn in enumerate(c.conns):
                if i != 0:
                    f.write(", ")
                f.write(".{}({})".format(c.model[conn['port']],
                                         conn['net'].name))
            f.write(");\n")
        f.write("endmodule\n")

    def write_vhdl_component(self, f):
        pins = {}
        for p in self.pins:
            self._add_net_name(pins, p.name, p)
        f.write("  component {} is\n".format(self.name))
        f.write("    port (\n")
        for i, name in enumerate(sorted(pins.keys())):
            p = pins[name]
            k = list(p.keys())
            first = p[k[0]]
            if i != 0:
                f.write(";\n")
            f.write("      {}: {}".format(
                name, {'I': 'in ', 'O': 'out'}[first.dir]))
            if k[0] is not None:
                assert min(k) == 0
                assert max(k) == len(k) - 1
                f.write(" std_logic_vector({} downto 0)".format(len(k) - 1))
            else:
                f.write(" std_logic")
        if self.ppow:
                f.write(";\n")
                f.write("      \\{}\\: std_logic".format(self.ppow))
        if self.pgnd:
                f.write(";\n")
                f.write("      \\{}\\: std_logic".format(self.pgnd))
        f.write(");\n")
        f.write("  end component;\n")
