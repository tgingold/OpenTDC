-- Top-level with a wishbone bus
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity wb_extender_last is
  port (
    --  Control
    clk_i : std_logic;

    --  Upstream
    up_rst_n_i : std_logic;
    up_bus_in : dev_bus_in;
    up_bus_out : out dev_bus_out;
    up_adr_i : std_logic_vector (4 downto 0);

    --  Devices

    dev0_rst_n : out std_logic;
    dev0_bus_in : out dev_bus_in;
    dev0_bus_out : dev_bus_out;

    dev1_rst_n : out std_logic;
    dev1_bus_in : out dev_bus_in;
    dev1_bus_out : dev_bus_out;

    dev2_rst_n : out std_logic;
    dev2_bus_in : out dev_bus_in;
    dev2_bus_out : dev_bus_out;

    dev3_rst_n : out std_logic;
    dev3_bus_in : out dev_bus_in;
    dev3_bus_out : dev_bus_out);
end wb_extender_last;

architecture behav of wb_extender_last is
  signal bus_in : dev_bus_in;
  signal bus_out : dev_bus_out;
begin
  bus_out.dato <= (others => '1');
  bus_out.wack <= bus_in.we;
  bus_out.rack <= bus_in.re;
  bus_out.trig <= '0';

  wb_extender_1: entity work.wb_extender
    port map (
      clk_i        => clk_i,
      up_rst_n_i   => up_rst_n_i,
      up_bus_in    => up_bus_in,
      up_bus_out   => up_bus_out,
      up_adr_i     => up_adr_i,
      down_rst_n_o => open,
      down_bus_in  => bus_in,
      down_bus_out => bus_out,
      down_adr_o   => open,
      dev0_rst_n   => dev0_rst_n,
      dev0_bus_in  => dev0_bus_in,
      dev0_bus_out => dev0_bus_out,
      dev1_rst_n   => dev1_rst_n,
      dev1_bus_in  => dev1_bus_in,
      dev1_bus_out => dev1_bus_out,
      dev2_rst_n   => dev2_rst_n,
      dev2_bus_in  => dev2_bus_in,
      dev2_bus_out => dev2_bus_out,
      dev3_rst_n   => dev3_rst_n,
      dev3_bus_in  => dev3_bus_in,
      dev3_bus_out => dev3_bus_out);
end behav;
