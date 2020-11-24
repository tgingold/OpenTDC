source $::env(OPENLANE_ROOT)/scripts/base.sdc

# Internal tdc & fd
# The path is too long (that's the purpose) so disable timing check
# Ideally, we need to constraint time between delay cells.
set_false_path -to [get_ports "out_o"]
