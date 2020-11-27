# Testbench for rescue
#
# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

${GHDL:-ghdl} -c --std=08 \
 ../rtl/opentdc_delay.vhdl \
 ../rtl/opentdc_delay-sim.vhdl \
 ../rtl/opentdc_sync.vhdl \
 ../rtl/opentdc_time.vhdl \
 ../rtl/opentdc_tapline.vhdl \
 ../rtl/openfd_delayline.vhdl \
 ../rtl/counter.vhdl \
 ../rtl/rescue.vhdl  \
 tb_rescue.vhdl \
 -r tb_rescue --wave=tb_rescue.ghw #--stop-time=4us --trace-processes #--backtrace-severity=warning
