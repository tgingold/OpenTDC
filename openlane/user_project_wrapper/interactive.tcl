package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag user -overwrite
set save_path $script_dir/../..

verilog_elaborate
#run_synthesis

init_floorplan

place_io_ol -cfg $::env(FP_PIN_ORDER_CFG)

# user_prj: vcc at  27530, 333890, 640250, 793430, 1099790

# fd_hd at 27290, x = .460 * 400
set x0 110.4 ; # 64.4
add_macro_placement mprj.i_tdc1 $x0 306.6 N

# VPWR at 1099550
#  x = .460 * 2500 = 1104.0
add_macro_placement mprj.i_tdc2 $x0 766.14 N

# in macro: VPWR at 27290
set x1 [expr $x0 + 598]
add_macro_placement mprj.i_itf $x1 306.6 N

# From pdn.def runs/user/tmp/floorplan/pdn.def
# x = .460 * 4100
set x2 [expr $x1 + 598]
add_macro_placement mprj.i_fd1 $x2 306.6 N

# x = .460 * 5400
add_macro_placement mprj.i_fd2 $x2 612.96 N

# x = .460 * 5400
add_macro_placement mprj.i_fd3 $x2 919.32 N

add_macro_placement mprj.b_zero.i_zero 220.8 1241.697 N
add_macro_placement gbl_z 506.0 1241.697 N


manual_macro_placement f

run_placement

gen_pdn

global_routing_or
detailed_routing

run_magic
run_magic_spice_export

#save_views       -lef_path $::env(magic_result_file_tag).lef \
                 -def_path $::env(tritonRoute_result_file_tag).def \
                 -gds_path $::env(magic_result_file_tag).gds \
                 -mag_path $::env(magic_result_file_tag).mag \
                 -save_path $save_path \
                 -tag $::env(RUN_TAG)

run_magic_drc

run_lvs; # requires run_magic_spice_export

run_antenna_check
