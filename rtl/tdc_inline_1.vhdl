-- TDC with inline tap line.
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity tdc_inline_1 is
  port (
    --  Control
    clk_i : std_logic;
    rst_n_i : std_logic;

    bus_in : dev_bus_in;
    bus_out : out dev_bus_out;

    inp_i : std_logic);
end tdc_inline_1;

architecture behav of tdc_inline_1 is
begin
  inst: entity work.tdc_inline
    generic map (
      cell => 1)
    port map (clk_i => clk_i,
              rst_n_i => rst_n_i,
              bus_in => bus_in,
              bus_out => bus_out,
              inp_i => inp_i);
end behav;
