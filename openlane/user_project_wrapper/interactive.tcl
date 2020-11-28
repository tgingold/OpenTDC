package require openlane
set script_dir [file dirname [file normalize [info script]]]

prep -design $script_dir -tag user -overwrite
set save_path $script_dir/../..

verilog_elaborate
#run_synthesis

init_floorplan

place_io_ol ; # -cfg $::env(FP_PIN_ORDER_CFG)

set ::env(FP_DEF_TEMPATE) $script_dir/../../def/user_project_wrapper_empty.def

apply_def_template

set x0 [expr 90 * .46]
set x1 [expr $x0 + 1200 * .46]  ; # ~ width of tdc
set x2 [expr $x1 + 1200 * .46]  ; # ~ width of wb_interface

# From pdn.def runs/user/tmp/floorplan/pdn.def
# x = .460 * 4100
set y0 [expr ( 190880 - 33680 ) / 1000 ]
add_macro_placement i_fd1 $x2 $y0 N

# in macro: VPWR at 27290
add_macro_placement i_itf $x1 $y0 N

# fd_hd at 27290, x = .460 * 400
add_macro_placement i_tdc1 $x0 $y0 N

# x = .460 * 5400
set y1 [expr ( 550880 - 33680 ) / 1000 ]
add_macro_placement i_fd2 $x2 $y1 N

# VPWR at 1099550
#  x = .460 * 2500 = 1104.0
add_macro_placement i_tdc2 $x0 636.14 N

# x = .460 * 5400
set y2 [expr ( 910880 - 33680 ) / 1000 ]
add_macro_placement i_fd3 $x2 $y2 N

#  Extender 2
set y2_2 [expr ( 1270880 - 33680 ) / 1000 ]
add_macro_placement i_fd2_2 $x2 $y2_2 N

add_macro_placement i_itf2 $x1 $y2_2 N
add_macro_placement i_tdc2_0 $x0 $y2_2 N

add_macro_placement i_fd2_3 $x2 1838.4 N

add_macro_placement i_tdc2_1 $x0 1618.4 N


add_macro_placement b_zero.i_zero 2448.0 1241.697 N

# x = 4500 * .46
add_macro_placement inst_rescue 2070.0 68 N

manual_macro_placement f

run_placement

set ::env(_SPACING) 1.6
set ::env(_WIDTH) 3

# We only use vccd1/vssd1
set power_domains [list {vccd1 vssd1} {vccd2 vssd2} {vdda1 vssa1} {vdda2 vssa2}]

set ::env(_VDD_NET_NAME) vccd1
set ::env(_GND_NET_NAME) vssd1
set ::env(_V_OFFSET) 14
set ::env(_H_OFFSET) $::env(_V_OFFSET)
set ::env(_V_PITCH) 180
set ::env(_H_PITCH) 180
set ::env(_V_PDN_OFFSET) 0
set ::env(_H_PDN_OFFSET) 0
set ::env(_NO_STRAPS) 0

foreach domain $power_domains {
	set ::env(_VDD_NET_NAME) [lindex $domain 0]
	set ::env(_GND_NET_NAME) [lindex $domain 1]
	gen_pdn

    set ::env(_NO_STRAPS) 1
    
	set ::env(_V_OFFSET) \
		[expr $::env(_V_OFFSET) + 2*($::env(_WIDTH)+$::env(_SPACING))]
	set ::env(_H_OFFSET) \
		[expr $::env(_H_OFFSET) + 2*($::env(_WIDTH)+$::env(_SPACING))]
	set ::env(_V_PDN_OFFSET) [expr $::env(_V_PDN_OFFSET)+6*$::env(_WIDTH)]
	set ::env(_H_PDN_OFFSET) [expr $::env(_H_PDN_OFFSET)+6*$::env(_WIDTH)]
}

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
