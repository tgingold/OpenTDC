// Time to Digital Conversion (TDC) core
// SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
// SPDX-License-Identifier: Apache-2.0

// Stupid macro that just outputs '0'.
// The purpose is to avoid standard cells at the top-level in order to not have
// to fill with taps (and thus make DRC much faster).

//  Those modules are filtered out so not visible to Yosys!
//  We need to declare them
(* blackbox *)
module  sky130_fd_sc_hd__fill_4 ();
endmodule

(* blackbox *)
module  sky130_fd_sc_hd__or2_4(A, B, X);
   input A;
   input B;
   output X;
endmodule // sky130_fd_sc_hd__or2_4

(* blackbox *)
module  sky130_fd_sc_hd__buf_2(A, X);
   input A;
   output X;
endmodule

(* blackbox *)
module sky130_fd_sc_hd__conb_1 (HI, LO);
   input HI;
   input LO;
endmodule

module zero(n_o, s_o, w_o, e_o);
   output e_o;
   output n_o;
   output s_o;
   output w_o;
   wire  w;
   
   sky130_fd_sc_hd__buf_2 LEFT1a (.A(w), .X(w_o));
   sky130_fd_sc_hd__buf_2 LEFT2a (.A(w), .X(n_o));
   (* keep *)
   sky130_fd_sc_hd__fill_4 LEFT1 ();
   (* keep *)
   sky130_fd_sc_hd__fill_4 LEFT2 ();
   (* keep *)
   sky130_fd_sc_hd__conb_1 ZEROA (.LO(w));
   (* keep *)
   sky130_fd_sc_hd__fill_4 RIGHT1 ();
   (* keep *)
   sky130_fd_sc_hd__fill_4 RIGHT2 ();
   sky130_fd_sc_hd__buf_2 RIGHT1a (.A(w), .X(s_o));
   sky130_fd_sc_hd__buf_2 RIGHT2a (.A(w), .X(e_o));
endmodule

   
