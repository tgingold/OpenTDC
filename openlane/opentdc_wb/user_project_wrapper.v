/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * Derived from caravel/verilog/rtl/user_project_wrapper.v
 *
 * SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
 * SPDX-License-Identifier: Apache-2.0
 *
 *-------------------------------------------------------------
 */

`define MPRJ_IO_PADS 38

module user_project_wrapper (
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Independent clock (on independent integer divider)
    input   user_clock2
);

    /*--------------------------------------*/
    /* User project is instantiated  here   */
    /*--------------------------------------*/

   wire     inp0_i, inp1_i, inp2_i;
   wire     out0_o;

    opentdc_wb mprj
      (
       // clock and reset

       .wb_clk_i(wb_clk_i),
       .wb_rst_i(wb_rst_i),

       // Wishbone Slave

       .wbs_stb_i(wbs_stb_i),
       .wbs_cyc_i(wbs_cyc_i),
       .wbs_we_i(wbs_we_i),
       .wbs_sel_i(wbs_sel_i),
       .wbs_dat_i(wbs_dat_i),
       .wbs_adr_i(wbs_adr_i),
       .wbs_ack_o(wbs_ack_o),
       .wbs_dat_o(wbs_dat_o),

       // IO Pads
       .inp1_i(io_in[35]),
       .inp2_i(io_in[36]),
       .inp3_i(io_in[37]),

       .out0_o(io_out[13]),
       .rst_time_n_i(1'b1)
    );

   assign io_out[0:12] = 0;
   assign io_out[14:37] = 0;

   assign io_oeb[0:12] = 0;
   assign io_oeb[13] = 1'b1;
   assign io_oeb[14:37] = 0;

endmodule
