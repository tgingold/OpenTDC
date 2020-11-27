package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag user -overwrite
set save_path $script_dir/../..

verilog_elaborate
#run_synthesis

run_floorplan

run_placement

gen_pdn

set y 57.120

set x [expr 44 * 0.46]
add_macro_placement LEFT1 $x $y N
set x [expr $x + 4 * 0.46]
add_macro_placement LEFT2 $x $y N
set x [expr $x + 4 * 0.46]
add_macro_placement ZEROA $x $y N
set x [expr $x + 3 * 0.46]
add_macro_placement RIGHT1 $x $y N
set x [expr $x + 4 * 0.46]
add_macro_placement RIGHT2 $x $y N

manual_macro_placement f

run_routing

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
