# Testbench for top-level (opentdc_wb)
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

${GHDL:-ghdl} -c --std=08 \
 ../rtl/opendelay_comps.vhdl \
 delaylines.vhdl \
 ../rtl/opentdc_pkg.vhdl \
 ../rtl/opentdc_delay.vhdl \
 ../rtl/opentdc_delay-sim.vhdl \
 ../rtl/opentdc_sync.vhdl \
 ../rtl/opentdc_time.vhdl \
 ../rtl/opentdc_tapline.vhdl \
 ../rtl/openfd_delayline.vhdl \
 ../rtl/counter.vhdl \
 ../rtl/opentdc_core2.vhdl \
 ../rtl/openfd_core2.vhdl \
 ../rtl/openfd_comps.vhdl \
 ../rtl/opentdc_comps.vhdl \
 ../rtl/fd_hs.vhdl \
 ../rtl/fd_hd.vhdl \
 ../rtl/fd_ms.vhdl \
 ../rtl/fd_hd_25_1.vhdl \
 ../rtl/fd_inline.vhdl \
 ../rtl/fd_inline_1.vhdl \
 ../rtl/tdc_inline.vhdl \
 ../rtl/tdc_inline_1.vhdl \
 ../rtl/tdc_inline_2.vhdl \
 ../rtl/tdc_inline_3.vhdl \
 ../rtl/wb_interface.vhdl  \
 ../rtl/rescue.vhdl \
 ../rtl/rescue_top.vhdl \
 ../rtl/wb_extender.vhdl \
 zero.vhdl \
 ../rtl/user_project_wrapper.vhdl  \
 tb_proj.vhdl \
 -r tb_proj --wave=tb_proj.ghw --stop-time=10us #--backtrace-severity=warning
