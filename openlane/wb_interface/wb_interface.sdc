# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

source $::env(OPENLANE_ROOT)/scripts/base.sdc

# Internal tdc & fd
# The path is too long (that's the purpose) so disable timing check
# Ideally, we need to constraint time between delay cells.
set_false_path -from [get_ports "tdc0_inp_i"]
set_false_path -from [get_ports "rst_time_n_i"]
set_false_path -to [get_ports "fd0_out_o"]
set_false_path -to [get_ports "oen_o*"]
#set_false_path -through [get_pins "mprj.g_tdcs:?.inst_itaps.gen_delay:0.inst.g_*.dly/X"]
#set_false_path -through [get_pins "mprj.g_tdcs:?.inst_rtaps.gen_delay:0.inst.g_*.dly/X"]
