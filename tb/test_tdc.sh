# Testbench for TDC core
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

ghdl -c --std=08 tb_opentdc_core.vhdl ../rtl/opentdc_tap.vhdl ../rtl/opentdc_tapline.vhdl ../rtl/opentdc_time.vhdl ../rtl/opentdc_core.vhdl ../rtl/opentdc_delay.vhdl ../rtl/opentdc_delay-sim.vhdl -r tb_opentdc_core
