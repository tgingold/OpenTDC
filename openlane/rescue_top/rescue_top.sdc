# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

source $::env(OPENLANE_ROOT)/scripts/base.sdc

# Internal tdc & fd
# The path is too long (that's the purpose) so disable timing check
# Ideally, we need to constraint time between delay cells.
set_false_path -from [get_ports "tdc_inp_i"]
set_false_path -through [get_pins "inst_rescue.inst_delay_line.g_taps:*.g_subtaps:*.inst_tap.g_*.dly/X"]
