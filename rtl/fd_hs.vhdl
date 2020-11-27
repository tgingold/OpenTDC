-- Fine Delay with hs tech
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;
use work.opendelay_comps.all;

entity fd_hs is
  port (
    --  Control
    clk_i : std_logic;
    rst_n_i : std_logic;

    bus_in : dev_bus_in;
    bus_out : out dev_bus_out;

    out1_o : out std_logic;
    out2_o : out std_logic);
end fd_hs;

architecture behav of fd_hs is
  constant length : natural := 9;
  signal idelay, rdelay, tdelay : std_logic_vector(length - 1 downto 0);
  signal ipulse, rpulse : std_logic;
  signal tpulse_in, tpulse_out : std_logic;
begin
  inst_idelay_line: delayline_9_hs
    port map (
      inp_i => ipulse, out_o => out1_o, en_i => idelay);

  inst_rdelay_line: delayline_9_hs
    port map (
      inp_i => rpulse, out_o => out2_o, en_i => rdelay);

  inst_tdelay_line: delayline_9_hs
    port map (
      inp_i => tpulse_in, out_o => tpulse_out, en_i => tdelay);

  inst_core: entity work.openfd_core2
    generic map (
      g_with_ref => true,
      g_with_test => true,
      plen => length)
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      idelay_o => idelay,
      rdelay_o => rdelay,
      tdelay_o => tdelay,
      ipulse_o => ipulse,
      rpulse_o => rpulse,
      tpulse_o => tpulse_in,
      tpulse_i => tpulse_out,
      bin => bus_in,
      bout => bus_out);
end behav;
