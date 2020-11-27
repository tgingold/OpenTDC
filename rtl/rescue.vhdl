-- Time to Digital Conversion (TDC) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity rescue is
  port (
    clk_i : std_logic;
    rst_n_i : std_logic;

    --  TDC
    tdc_coarse : out std_logic_vector(31 downto 0);
    tdc_fine : out std_logic_vector(8 downto 0);
    tdc_done : out std_logic;
    tdc_start : std_logic;

    --  FD
    fd_coarse : std_logic_vector(31 downto 0);
    fd_fine : std_logic_vector(8 downto 0);
    fd_done : out std_logic;
    fd_start : std_logic;
    fd_force : std_logic;

    tdc_inp_i : std_logic;
    fd_out_o : out std_logic);
end rescue;

architecture behav of rescue is
  signal cur_cycles : std_logic_vector(31 downto 0);
  signal pulse : std_logic;

  constant ndly : natural := 200;
  signal taps : std_logic_vector (ndly - 1 downto 0);
  signal clks : std_logic_vector (2*ndly - 1 downto 0);
  signal restart : std_logic;
  signal tdc_start_d : std_logic;
  signal fine : std_logic_vector (9 downto 0);
begin
  i_cycles: entity work.counter
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      cur_cycles_o => cur_cycles);

  process (clk_i)
  begin
    if rising_edge (clk_i) then
      pulse <= '0';
      
      if rst_n_i = '0' then
        fd_done <= '0';
      elsif (fd_start = '1' and fd_coarse = cur_cycles) or fd_force = '1' then
        pulse <= '1';
        fd_done <= '1';
      elsif fd_start = '0' and fd_force = '0' then
        fd_done <= '0';
      end if;
    end if;
  end process;

  inst_delay_line: entity work.openfd_delayline
    generic map (
      cell => 0,
      plen => fd_fine'length)
    port map (
      inp_i => pulse, out_o => fd_out_o, delay_i => fd_fine);

  clks <= (others => clk_i);

  inst_itaps: entity work.opentdc_tapline
    generic map (
      cell => 0,
      length => ndly)
    port map (
      clks_i => clks,
      inp_i => tdc_inp_i,
      tap_o => taps);

  --  Detect pulse
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      restart <= tdc_start and not tdc_start_d;

      tdc_start_d <= tdc_start;
    end if;
  end process;

  inst_time: entity work.opentdc_time
    generic map (
      length => ndly,
      fine_bits => tdc_fine'length)
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      cur_cycles_i => cur_cycles,
      restart_i => restart,
      detect_rise_i => '1',
      detect_fall_i => '0',
      tap_i => taps,
      triggered_o => tdc_done,
      coarse_o => tdc_coarse,
      fine_o => tdc_fine);
end behav;
