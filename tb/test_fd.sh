# Testbench for FD
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

ghdl -c --std=08 tb_openfd_core.vhdl ../rtl/openfd_core.vhdl ../rtl/opentdc_delay.vhdl ../rtl/opentdc_delay-sim.vhdl -r tb_openfd_core
