-- Top-level with a wishbone bus
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;
use work.opentdc_comps.all;

entity opentdc_wb is
  port (
    --  Control
    wb_clk_i : std_logic;
    wb_rst_i : std_logic;

    --  Wishbone
    wbs_stb_i : in  std_logic;
    wbs_cyc_i : in  std_logic;
    wbs_we_i  : in  std_logic;
    wbs_sel_i : in  std_logic_vector(3 downto 0);
    wbs_dat_i : in  std_logic_vector(31 downto 0);
    wbs_adr_i : in  std_logic_vector(31 downto 0);
    wbs_ack_o : out std_logic;
    wbs_dat_o : out std_logic_vector(31 downto 0);

    --  Tdc input signals
    inp1_i : std_logic;
    inp2_i : std_logic;
    inp3_i : std_logic;

    --  Fd output signals
    out0_o : out std_logic;

    rst_time_n_i : std_logic);
end opentdc_wb;

architecture behav of opentdc_wb is
  --  Regs for the bus interface.
  signal b_idle : std_logic;

  signal rst_n : std_logic;

  signal cur_cycles : std_logic_vector(31 downto 0);

  --  fd0
  signal fd0_coarse : std_logic_vector(31 downto 0);
  signal fd0_fine   : std_logic_vector(15 downto 0);
  signal fd0_valid  : std_logic;
  signal fd0_busy  : std_logic;

  signal start : std_logic;
  signal dev0_in,  dev1_in,  dev2_in,  dev3_in  : tdc_bus_in;
  signal dev0_out, dev1_out, dev2_out, dev3_out : tdc_bus_out;

begin
  rst_n <= not wb_rst_i;

  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      wbs_ack_o <= '0';
      wbs_dat_o <= (others => '0');

      dev0_in.cur_cycles <= cur_cycles;
      dev1_in.cur_cycles <= cur_cycles;
      dev2_in.cur_cycles <= cur_cycles;
      dev3_in.cur_cycles <= cur_cycles;

      if rst_n = '0' then
        start <= '1';
        dev0_in.re <= '0';
        dev0_in.we <= '0';
        dev1_in.re <= '0';
        dev1_in.we <= '0';
        dev2_in.re <= '0';
        dev2_in.we <= '0';
        dev3_in.re <= '0';
        dev3_in.we <= '0';
      else
        if wbs_stb_i = '1' and wbs_cyc_i = '1' then
          -- 8 words per sub-device (so 3+2 bits)
          case wbs_adr_i (6 downto 5) is
            when "00" =>
              dev0_in.adr <= wbs_adr_i (4 downto 2);
              dev0_in.dati <= wbs_dat_i;
              dev0_in.sel <= wbs_sel_i;
              dev0_in.we <= start and wbs_we_i;
              dev0_in.re <= start and not wbs_we_i;
              wbs_ack_o <= dev0_out.wack or dev0_out.rack;
              wbs_dat_o <= dev0_out.dato;
            when "01" =>
              dev1_in.adr <= wbs_adr_i (4 downto 2);
              dev1_in.dati <= wbs_dat_i;
              dev1_in.sel <= wbs_sel_i;
              dev1_in.we <= start and wbs_we_i;
              dev1_in.re <= start and not wbs_we_i;
              wbs_ack_o <= dev1_out.wack or dev1_out.rack;
              wbs_dat_o <= dev1_out.dato;
            when "10" =>
              dev2_in.adr <= wbs_adr_i (4 downto 2);
              dev2_in.dati <= wbs_dat_i;
              dev2_in.sel <= wbs_sel_i;
              dev2_in.we <= start and wbs_we_i;
              dev2_in.re <= start and not wbs_we_i;
              wbs_ack_o <= dev2_out.wack or dev2_out.rack;
              wbs_dat_o <= dev2_out.dato;
            when "11" =>
              dev3_in.adr <= wbs_adr_i (4 downto 2);
              dev3_in.dati <= wbs_dat_i;
              dev3_in.sel <= wbs_sel_i;
              dev3_in.we <= start and wbs_we_i;
              dev3_in.re <= start and not wbs_we_i;
              wbs_ack_o <= dev3_out.wack or dev3_out.rack;
              wbs_dat_o <= dev3_out.dato;
            when others =>
              null;
          end case;
          start <= '0';
        else
          start <= '1';
        end if;
      end if;
    end if;
  end process;

  --  Pseudo dev0 (ro)
  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      dev0_out.wack <= '0';
      dev0_out.rack <= '0';
      dev0_out.dato <= (others => '0');

      if rst_n = '0' then
        dev0_out.trig <= '0';
      else
        --  Write (nop)
        if dev0_in.we = '1' then
          dev0_out.wack <= '1';
        end if;

        --  Read (nop)
        if dev0_in.re = '1' then
          case dev0_in.adr is
            when "000" =>
              dev0_out.dato <= x"54_64_63_01";  -- 'Tdc\1'
            when "001" =>
              dev0_out.dato <= cur_cycles;
            when "010" =>
              --  Global status
              dev0_out.dato (1) <= dev1_out.trig;
              dev0_out.dato (2) <= dev2_out.trig;
            when others =>
              null;
          end case;
          dev0_out.rack <= '1';
        end if;
      end if;
    end if;
  end process;

  --  Time counter.
  process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if rst_time_n_i = '0' or rst_n = '0' then
        cur_cycles <= (others => '0');
      else
        cur_cycles <= std_logic_vector(unsigned(cur_cycles) + 1);
      end if;
    end if;
  end process;

  --  Dev 1
  b_dev1: block
    constant ndly : natural := 200;

    signal taps : std_logic_vector (ndly - 1 downto 0);
    signal clks : std_logic_vector (2*ndly - 1 downto 0);
  begin
    clks <= (others => wb_clk_i);

    inst_itaps: entity work.opentdc_tapline
      generic map (
        length => ndly)
      port map (
        clks_i => clks,
        inp_i => inp1_i,
        tap_o => taps);

    inst_core: entity work.opentdc_core2
      generic map (
        g_with_ref => false,
        length => ndly)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        itaps => taps,
        rtaps => (others => '0'),
        bin => dev1_in,
        bout => dev1_out);
  end block;

  --  Dev 2
  b_dev2: block
    constant ndly : natural := 200;

    signal taps, rtaps : std_logic_vector (ndly - 1 downto 0);
    signal clks, rclks : std_logic_vector (2*ndly - 1 downto 0);
    signal rin : std_logic;
  begin
    clks <= (others => wb_clk_i);
    rclks <= (others => wb_clk_i);

    inst_itaps: entity work.opentdc_tapline
      generic map (
        length => ndly)
      port map (
        clks_i => clks,
        inp_i => inp2_i,
        tap_o => taps);

    inst_rtaps: entity work.opentdc_tapline
      generic map (
        length => ndly)
      port map (
        clks_i => rclks,
        inp_i => rin,
        tap_o => rtaps);

    inst_core: entity work.opentdc_core2
      generic map (
        g_with_ref => true,
        g_with_scan => true,
        length => ndly)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        itaps => taps,
        rtaps => rtaps,
        rin_o => rin,
        bin => dev2_in,
        bout => dev2_out);
  end block;

  b_dev3: block
    constant length : natural := 200;
    signal taps : std_logic_vector(length - 1 downto 0);
    signal tap_clks : std_logic_vector(2*length - 1 downto 0);
  begin
    tap_clks <= (others => wb_clk_i);
    inst_tap_line: tapline_200_x1_hd port map
      (inp_i => inp2_i, clk_i => tap_clks, tap_o => taps);

    inst_core: entity work.opentdc_core2
      generic map (
        g_with_ref => false,
        length => length)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        itaps => taps,
        rtaps => (others => '0'),
        bin => dev3_in,
        bout => dev3_out);
  end block;

  --  FD0
  inst_fd0: entity work.openfd_core
    generic map (
      plen => 8)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      coarse_i     => fd0_coarse,
      fine_i       => fd0_fine,
      valid_i      => fd0_valid,
      busy_o       => fd0_busy,
      out_o        => out0_o);
end behav;
