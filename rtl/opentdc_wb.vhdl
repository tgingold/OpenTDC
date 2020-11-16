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

  type dev_in_array is array(natural range <>) of tdc_bus_in;
  type dev_out_array is array(natural range <>) of tdc_bus_out;

  constant NDEVS : natural := 4;
  signal devs_in: dev_in_array (NDEVS - 1 downto 0);
  signal devs_out: dev_out_array (NDEVS - 1 downto 0);
begin
  rst_n <= not wb_rst_i;

  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      wbs_ack_o <= '0';
      wbs_dat_o <= (others => '0');

      if rst_n = '0' then
        start <= '1';
      else
        if wbs_stb_i = '1' and wbs_cyc_i = '1' then
          -- 8 words per sub-device (so 3+2 bits)
          case wbs_adr_i (6 downto 5) is
            when "00" =>
              wbs_ack_o <= devs_out(0).wack or devs_out(0).rack;
              wbs_dat_o <= devs_out(0).dato;
            when "01" =>
              wbs_ack_o <= devs_out(1).wack or devs_out(1).rack;
              wbs_dat_o <= devs_out(1).dato;
            when "10" =>
              wbs_ack_o <= devs_out(2).wack or devs_out(2).rack;
              wbs_dat_o <= devs_out(2).dato;
            when "11" =>
              wbs_ack_o <= devs_out(3).wack or devs_out(3).rack;
              wbs_dat_o <= devs_out(3).dato;
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

  gen_devs: for i in NDEVS - 1 downto 0 generate
    process (wb_clk_i)
    begin
      if rising_edge(wb_clk_i) then
        devs_in (i).cur_cycles <= cur_cycles;

        if rst_n = '0' then
          devs_in (i).re <= '0';
          devs_in (i).we <= '0';
        else
          if wbs_stb_i = '1' and wbs_cyc_i = '1' then
            if wbs_adr_i (6 downto 5) = std_logic_vector(to_unsigned(i, 2)) then
              devs_in (i).adr <= wbs_adr_i (4 downto 2);
              devs_in (i).dati <= wbs_dat_i;
              devs_in (i).sel <= wbs_sel_i;
              devs_in (i).we <= start and wbs_we_i;
              devs_in (i).re <= start and not wbs_we_i;
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;
    
  --  Pseudo dev0 (ro)
  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      devs_out(0).wack <= '0';
      devs_out(0).rack <= '0';
      devs_out(0).dato <= (others => '0');

      if rst_n = '0' then
        devs_out(0).trig <= '0';
      else
        --  Write (nop)
        if devs_in(0).we = '1' then
          devs_out(0).wack <= '1';
        end if;

        --  Read (nop)
        if devs_in(0).re = '1' then
          case devs_in(0).adr is
            when "000" =>
              devs_out(0).dato <= x"54_64_63_01";  -- 'Tdc\1'
            when "001" =>
              devs_out(0).dato <= cur_cycles;
            when "010" =>
              --  Global status
              devs_out(0).dato (1) <= devs_out(1).trig;
              devs_out(0).dato (2) <= devs_out(2).trig;
            when others =>
              null;
          end case;
          devs_out(0).rack <= '1';
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
        bin => devs_in(1),
        bout => devs_out(1));
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
        bin => devs_in(2),
        bout => devs_out(2));
  end block;

  b_dev3: block
    constant length : natural := 200;
    signal taps : std_logic_vector(length - 1 downto 0);
    signal tap_clks : std_logic_vector(2*length - 1 downto 0);
  begin
    tap_clks <= (others => wb_clk_i);
    inst_tap_line: tapline_200_x2_hd port map
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
        bin => devs_in(3),
        bout => devs_out(3));
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
