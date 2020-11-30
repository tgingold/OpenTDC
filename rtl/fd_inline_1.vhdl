-- Fine Delay with inline delay line.
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity fd_inline_1 is
  port (
    --  Control
    clk_i : std_logic;
    rst_n_i : std_logic;

    bus_in : dev_bus_in;
    bus_out : out dev_bus_out;

    out_o : out std_logic);
end fd_inline_1;

architecture behav of fd_inline_1 is
begin
  inst: entity work.fd_inline
    generic map (
      cell => 1)
    port map (
      clk_i   => clk_i,
      rst_n_i => rst_n_i,
      bus_in  => bus_in,
      bus_out => bus_out,
      out_o   => out_o);
end behav;
