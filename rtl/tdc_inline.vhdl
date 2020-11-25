-- TDC with inline tap line.
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity tdc_inline is
  generic (
    cell : natural := 1);
  port (
    --  Control
    clk_i : std_logic;
    rst_n_i : std_logic;

    bus_in : dev_bus_in;
    bus_out : out dev_bus_out;

    inp_i : std_logic);
end tdc_inline;

architecture behav of tdc_inline is
  constant ndly : natural := 200;

  signal taps, rtaps : std_logic_vector (ndly - 1 downto 0);
  signal clks, rclks : std_logic_vector (2*ndly - 1 downto 0);
  signal rin : std_logic;
begin
  clks <= (others => clk_i);
  rclks <= (others => clk_i);

  inst_itaps: entity work.opentdc_tapline
    generic map (
      cell => cell,
      length => ndly)
    port map (
      clks_i => clks,
      inp_i => inp_i,
      tap_o => taps);

  inst_rtaps: entity work.opentdc_tapline
    generic map (
      cell => cell,
      length => ndly)
    port map (
      clks_i => rclks,
      inp_i => rin,
      tap_o => rtaps);

  inst_core: entity work.opentdc_core2
    generic map (
      g_with_ref => cell /= 1,
      g_with_scan => cell = 1,
      length => ndly)
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      itaps => taps,
      rtaps => rtaps,
      rin_o => rin,
      bin => bus_in,
      bout => bus_out);
end behav;
