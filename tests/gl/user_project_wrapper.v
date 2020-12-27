/*
/ SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
/ SPDX-License-Identifier: Apache-2.0
*/

`define FD_MS_BB

`include "blackbox.v"
`include "zero.simple.v"

`ifndef FD_HD_BB
 `include "delayline_9_hd.simple.v"
 `include "fd_hd.simple.v"
`endif

`ifndef FD_HD_25_1_BB
 `include "delayline_9_hd_25_1.simple.v"
 `include "fd_hd_25_1.simple.v"
`endif
//`include "delayline_9_hs.simple.v"
//`include "fd_hs.simple.v"

`ifndef FD_MS_BB
 `include "delayline_9_ms.simple.v"
 `include "fd_ms.simple.v"
`endif

`ifndef FD_INLINE_1_BB
 `include "tdc_inline_1.simple.v"
`endif

`include "tdc_inline_2.simple.v"
`include "tdc_inline_3.simple.v"
`include "fd_inline_1.simple.v"

`ifndef TDC_HD_CBUF2_X4_BB
 `include "tapline_200_x4_cbuf2_hd.simple.v"
 `include "tdc_hd_cbuf2_x4.simple.v"
`endif

`ifndef RESCUE_TOP_BB
 `include "rescue_top.simple.v"
`endif

`include "wb_interface.simple.v"
`include "wb_extender.simple.v"
`include "user_project_wrapper.simple.v"
//`include "../src/user_project_wrapper.power.v"

`ifndef FD_MS_BB
`include "libs.ref/sky130_fd_sc_ms/verilog/primitives.v"
`include "libs.ref/sky130_fd_sc_ms/verilog/sky130_fd_sc_ms.v"
`endif

// Not working
//`include "libs.ref/sky130_fd_sc_hs/verilog/primitives.v"
//`include "libs.ref/sky130_fd_sc_hs/verilog/sky130_fd_sc_hs.v"
