source $::env(OPENLANE_ROOT)/scripts/base.sdc

# Internal tdc & fd
# The path is too long (that's the purpose) so disable timing check
# Ideally, we need to constraint time between delay cells.
set_false_path -to [get_ports "io_out[13]"]
set_false_path -to [get_ports "io_out[14]"]
set_false_path -from [get_ports "io_in[37]"]
set_false_path -from [get_ports "io_in[36]"]
set_false_path -from [get_ports "io_in[34]"]
set_false_path -through [get_pins "mprj.g_tdcs:?.inst_itaps.gen_delay:0.inst.g_clkbuf_?.dly/X"]
set_false_path -through [get_pins "mprj.g_tdcs:?.inst_rtaps.gen_delay:0.inst.g_clkbuf_?.dly/X"]
