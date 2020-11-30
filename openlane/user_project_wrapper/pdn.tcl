# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-FileCopyrightText: (Based on caravel file by efabless)
# SPDX-License-Identifier: Apache-2.0

# Power nets
set ::power_nets $::env(_VDD_NET_NAME)
set ::ground_nets $::env(_GND_NET_NAME)

set top_grid {
    name grid
	core_ring {
		met5 {width $::env(_WIDTH) spacing $::env(_SPACING) core_offset $::env(_H_OFFSET)}
		met4 {width $::env(_WIDTH) spacing $::env(_SPACING) core_offset $::env(_V_OFFSET)}
	}
	rails {
	}
    straps {
	    met4 {width $::env(_WIDTH) pitch $::env(_V_PITCH) offset $::env(_V_PDN_OFFSET)}
	    met5 {width $::env(_WIDTH) pitch $::env(_H_PITCH) offset $::env(_H_PDN_OFFSET)}
    }
    connect {{met4 met5}}
}

if { $::env(_NO_STRAPS) } {
    dict set top_grid straps {}
}

pdngen::specify_grid stdcell $top_grid

pdngen::specify_grid macro {
	instance "obs_core_obs"
    power_pins $::env(_VDD_NET_NAME)
    ground_pins $::env(_GND_NET_NAME)
    blockages "li1 met1 met2 met3 met4 met5"
    straps { 
    } 
    connect {}
}

#    power_pins $::env(_VDD_NET_NAME)
#    ground_pins $::env(_GND_NET_NAME)

pdngen::specify_grid macro {
    power_pins "VPWR"
    ground_pins "VGND"
    blockages "li1 met1 met2 met3 met4"
    straps { 
    } 
    connect {{met4_PIN_ver met5}}
}

set ::halo 0

# POWER or GROUND #Std. cell rails starting with power or ground rails at the bottom of the core area
set ::rails_start_with "POWER" ;

# POWER or GROUND #Upper metal stripes starting with power or ground rails at the left/bottom of the core area
set ::stripes_start_with "POWER" ;

