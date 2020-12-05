#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse

import opendbpy as odb


class DiodeInserter:

	def __init__(self, block, cfg):
		self.block = block
		self.cfg = cfg
		self.diode_master = block.getDataBase().findMaster(self.cfg['diode_cell_true'])
		self.inserted = {}

	def net_source(self, net):
		# See if it's an input pad
		for bt in net.getBTerms():
			if bt.getIoType != 'INPUT':
				continue
			good, x, y = bt.getFirstPinLocation()
			if good:
				return (True, (x, y))

		# Or maybe output of a cell
		x = odb.new_int(0)
		y = odb.new_int(0)

		for it in net.getITerms():
			if not it.isOutputSignal():
				continue
			if it.getAvgXY(x,y):
				return (False, (odb.get_int(x), odb.get_int(y)))

		# Nothing found
		return None, None

	def net_has_diode(self, net):
		for it in net.getITerms():
			cell_type = it.getInst().getMaster().getName()
			cell_pin  = it.getMTerm().getConstName()
			if (cell_type == self.cfg['diode_cell_true']) and (cell_pin == self.cfg['diode_cell_pin']):
				return True
		else:
			return False

	def net_span(self, net):
		xs = []
		ys = []

		for bt in net.getBTerms():
			good, x, y = bt.getFirstPinLocation()
			if good:
				xs.append(x)
				ys.append(y)

		for it in net.getITerms():
			x, y = self.pin_position(it)
			xs.append(x)
			ys.append(y)

		if len(xs) == 0:
			return 0

		return (max(ys) - min(ys)) + (max(xs) - min(xs))

	def pin_position(self, it):
		px = odb.new_int(0)
		py = odb.new_int(0)

		if it.getAvgXY(px,py):
			# Got it
			return odb.get_int(px), odb.get_int(py)
		else:
			# Failed, use the center coordinate of the instance as fall back
			return it.getInst().getLocation()

	def place_diode_stdcell(self, it, px, py, src_pos=None):
		# Get information about the instance
		inst_name  = it.getInst().getName()
		inst_width = it.getInst().getMaster().getWidth()
		inst_pos   = it.getInst().getLocation()
		inst_ori   = it.getInst().getOrient()

		# Is the pin left-ish, center-ish or right-ish ?
		th_left  = int(inst_pos[0] + inst_width * 0.30)
		th_right = int(inst_pos[0] + inst_width * 0.70)

		if px < th_left:
			pos = 'l'
		elif px > th_right:
			pos = 'r'
		elif src_pos is not None:
			# Sort of middle, so put it on the side where signal is coming from
			pos = 'l' if (src_pos[0] < inst_pos[0]) else 'r'
		else:
			# Coin toss ...
			pos = 'l'

			# FIXME: Seems it's better to always be on the side of the source ?
		if src_pos is not None:
			pos = 'l' if (src_pos[0] < inst_pos[0]) else 'r'

		# X position
		dw = self.diode_master.getWidth()

		if pos == 'l':
			dx = inst_pos[0] - dw * (1 + self.inserted.get((inst_name, 'l'), 0))
		else:
			dx = inst_pos[0] + inst_width + dw * self.inserted.get((inst_name, 'r'), 0)

		# Record insertion
		self.inserted[(inst_name, pos)] = self.inserted.get((inst_name, pos), 0) + 1

		# Done
		return dx, inst_pos[1], inst_ori

	def place_diode_macro(self, it, px, py, src_pos=None):
		# Scan all rows to see how close we can get to the point
		best = None

		for row in self.block.getRows():
			rbb = row.getBBox()

			dx = max(min(rbb.xMax(), px), rbb.xMin())
			dy = rbb.yMin()
			do = row.getOrient()

			d = abs(px - dx) + abs(py - dy)

			if (best is None) or (best[0] > d):
				best = (d, dx, dy, do)

		return best[1:]

	def insert_diode(self, it, src_pos):
		# Get information about the instance
		inst_cell  = it.getInst().getMaster().getName()
		inst_name  = it.getInst().getName()
		inst_pos   = it.getInst().getLocation()

		# Find where the pin is
		px, py = self.pin_position(it)

		# Apply standard cell or macro placement ?
		if inst_cell.startswith('sky130_fd_sc_hd__'):	# FIXME
			dx, dy, do = self.place_diode_stdcell(it, px, py, src_pos)
		else:
			dx, dy, do = self.place_diode_macro(it, px, py, src_pos)

		# Insert instance and wire it up
		diode_inst_name = 'ANTENNA_' + inst_name + '_' + it.getMTerm().getConstName()

		diode_inst = odb.dbInst_create(self.block, self.diode_master, diode_inst_name)

		diode_inst.setOrient(do)
		diode_inst.setLocation(dx, dy)
		diode_inst.setPlacementStatus('PLACED')

		ait = diode_inst.findITerm(self.cfg['diode_cell_pin'])
		odb.dbITerm_connect(ait, it.getNet())

	def execute(self):
		# Scan all nets
		for net in self.block.getNets():
			# Skip special nets
			if net.isSpecial():
				print(f"[w] Skipping special net {net.getName():s}")
				continue

			# Check if we already have diode on the net
			# if yes, then we assume that the user took care of that net manually
			if self.net_has_diode(net):
				print(f"[w] Skipping manually protected net {net.getName():s}")
				continue

			# Find signal source (first one found ...)
			force, src_pos = self.net_source(net)

			# Determine the span of the signal
			if not force:
				span = self.net_span(net)
				if span < 70000:
					continue

			print(f"Insert diode on net {net.getName():s}")
			for it in net.getITerms():
				if it.isInputSignal():
					self.insert_diode(it, src_pos)


# Arguments
parser = argparse.ArgumentParser(
		description='Cleanup XXX')

parser.add_argument('--lef', '-l',
		nargs='+',
		type=str,
		default=None,
		required=True,
		help='Input LEF file(s)')

parser.add_argument('--input-def', '-id', required=True,
		help='DEF view of the design that needs to have its instances placed')

parser.add_argument('--output-def', '-o', required=True,
		help='Output placed DEF file')


args = parser.parse_args()
input_lef_file_names = args.lef
input_def_file_name = args.input_def
output_def_file_name = args.output_def

# Load
db_design = odb.dbDatabase.create()

for lef in input_lef_file_names:
    odb.read_lef(db_design, lef)
odb.read_def(db_design, input_def_file_name)

chip_design = db_design.getChip()
block_design = chip_design.getBlock()
top_design_name = block_design.getName()
print("Design name:", top_design_name)


cfg = {
	'diode_cell_true': 'sky130_fd_sc_hd__diode_2',
	'diode_cell_fake': 'sky130_ef_sc_hd__fakediode_2',
	'diode_cell_pin':  'DIODE',
}
di = DiodeInserter(block_design, cfg)
di.execute()

# Write result
odb.write_def(block_design, output_def_file_name)
