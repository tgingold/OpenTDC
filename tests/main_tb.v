/*
/ SPDX-FileCopyrightText: Changes by (c) 2020 Tristan Gingold <tgingold@free.fr>
/ SPDX-License-Identifier: Apache-2.0
*/

`default_nettype wire
/*
 *  StriVe - A full example SoC using PicoRV32 in SkyWater s8
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Tim Edwards <tim@efabless.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1 ns / 1 ps

`include "caravel.v"
`include "spiflash.v"

//`define RESCUE

module main_tb;
	reg clock;
	reg RSTB;
	reg power1, power2;

	wire gpio;
	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire [37:0] mprj_io;
	wire [6:0] checkbits;
	wire uart_tx;
	wire SDO;
   wire    [25:0]  dev_io;
   reg             tdc1, tdc2, tdc3, tdc8, tdc9, tdc12, tdc_rescue;


   assign checkbits = mprj_io[11:5];
   assign dev_io = mprj_io[37:12];

   assign uart_tx = mprj_io[6];

   assign mprj_io[31] = tdc1;
   assign mprj_io[30] = tdc2;
   assign mprj_io[29] = tdc3;
`ifdef RESCUE
   assign mprj_io[12] = tdc_rescue;
`else
   assign mprj_io[28] = tdc8; // Also used by rescue FD
`endif
   assign mprj_io[27] = tdc9;
   assign mprj_io[26] = tdc12;

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
	   //$dumpfile("main.vcd");
           //$dumpvars(1, uut.padframe.mprj_pads); //.area2_io_pad[1]);
           //$dumpvars(0, uut.mprj.io_out);
           //$dumpvars(2, uut.mprj.i_tdc2_0);
	   //$dumpvars(1, uut.mprj.inst_rescue);

		$display("Wait for test o/p");
		repeat (150) begin
			repeat (10000) @(posedge clock);
			// Diagnostic. . . interrupts output pattern.
		end
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		#1000;
		RSTB <= 1'b1;	    // Release reset
		#2000;
	end

   	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

   initial begin
      tdc1 <= 0;
      tdc2 <= 0;
      tdc3 <= 0;
      tdc8 <= 0;
      tdc9 <= 0;
      tdc12 <= 0;
      tdc_rescue <= 0;
   end

   always @(dev_io[0]) begin
      if (dev_io[0] == 1'b1) begin
         $display("fd4->tdc1 pulse at %t", $time);
         tdc1 <= 1;
      end
   end

   always @(dev_io[1]) begin
      if (dev_io[1] == 1'b1) begin
         $display("fd5->tdc2, tdc3 pulse at %t", $time);
         tdc2 <= 1;
         # 25;
         tdc3 <= 1;
      end
   end

   always @(dev_io[7]) begin
      if (dev_io[7] == 1'b1) begin
         $display("fd10->tdc8 pulse at %t", $time);
         tdc8 <= 1;
      end
   end

   always @(dev_io[8]) begin
      if (dev_io[8] == 1'b1) begin
         $display("fd11->tdc9 pulse at %t", $time);
         tdc9 <= 1;
      end
   end
   always @(dev_io[11]) begin
      if (dev_io[11] == 1'b1) begin
         $display("fd15->tdc12 pulse at %t", $time);
         tdc12 <= 1;
      end
   end
   always @(dev_io[16]) begin
      if (dev_io[16] == 1'b1) begin
         $display("rescue pulse at %t", $time);
         tdc_rescue <= 1;
      end
   end
	always @(checkbits) begin
           //$display("checkbits: %b", checkbits);

		if(checkbits == 8'h01) begin
			$display("Test started");
		end
		else if(checkbits == 8'h02) begin
			$display("Test passed");
			$finish;
                end
		else if(checkbits == 8'h7f) begin
			$display("Test failed");
			$finish;
		end
                else if (checkbits != 0) begin
			$write("%s", checkbits);
                        $fflush;
                end
	end

   always @(dev_io)
     $display("IO: %b at %t", dev_io, $time);

	wire VDD3V3;
	wire VDD1V8;
	wire VSS;

	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("main.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

endmodule
