-- Independant TDC + FD
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity rescue_top is
  port (
    clk_i : std_logic;
    la_data_in : std_logic_vector(127 downto 0);
    la_data_out : out std_logic_vector(127 downto 0);
    la_oen : std_logic_vector(127 downto 0);

    tdc_inp_i : std_logic;
    fd_out_o : out std_logic);
end rescue_top;

architecture rtl of rescue_top is
begin
  inst_rescue: entity work.rescue
    port map (
      clk_i      => clk_i,
      rst_n_i    => la_data_in(127),
      tdc_coarse => la_data_out(31 downto 0),
      tdc_fine   => la_data_out(40 downto 32),
      tdc_done   => la_data_out(41),
      tdc_start  => la_data_in(42),
      fd_coarse  => la_data_in(95 downto 64),
      fd_fine    => la_data_in(104 downto 96),
      fd_done    => la_data_out(105),
      fd_start   => la_data_in(106),
      fd_force   => la_data_in(107),
      tdc_inp_i  => tdc_inp_i,
      fd_out_o   => fd_out_o);

  la_data_out(104 downto 42) <= (others => '0');
  la_data_out(127 downto 106) <= (others => '0');
end rtl;
