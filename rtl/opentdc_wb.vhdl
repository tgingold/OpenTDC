-- Top-level with a wishbone bus
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

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
    inp_i : std_logic_vector(2 downto 0);

    --  Fd output signals
    out_o : out std_logic_vector(1 downto 0);

    --  Outputs enable
    oen_o : out std_logic_vector(1 downto 0);

    rst_time_n_i : std_logic);
end opentdc_wb;

architecture behav of opentdc_wb is
  --  Config (not generics to keep the same name).
  constant NTDC : natural := inp_i'length;
  constant NFD : natural := out_o'length;
  
  --  Regs for the bus interface.
  signal b_idle : std_logic;

  signal rst_n : std_logic;

  signal cur_cycles : std_logic_vector(31 downto 0);

  signal start : std_logic;

  signal oen : std_logic_vector(oen_o'range);

  signal rst_time_en : std_logic;

  type dev_in_array is array(natural range <>) of tdc_bus_in;
  type dev_out_array is array(natural range <>) of tdc_bus_out;

  constant FTDC : natural := 1;
  constant FFD : natural := NTDC + 1;
  
  signal devs_in: dev_in_array (NTDC + NFD downto 0);
  signal devs_out: dev_out_array (NTDC + NFD downto 0);
begin
  rst_n <= not wb_rst_i;

  oen_o <= oen;

  --  Wishbone out process
  process (wb_clk_i)
    variable n : natural range 0 to 15;
  begin
    if rising_edge(wb_clk_i) then
      wbs_ack_o <= '0';
      wbs_dat_o <= (others => '0');

      if rst_n = '0' then
        start <= '1';
      else
        if wbs_stb_i = '1' and wbs_cyc_i = '1' then
          -- 8 words per sub-device (so 3+2 bits)
          n := to_integer(unsigned(wbs_adr_i (8 downto 5)));
          wbs_ack_o <= devs_out(n).wack or devs_out(n).rack;
          wbs_dat_o <= devs_out(n).dato;
          start <= '0';
        else
          start <= '1';
        end if;
      end if;
    end if;
  end process;

  --  Wishbone inputs process
  gen_devs: for i in devs_in'range generate
    process (wb_clk_i)
    begin
      if rising_edge(wb_clk_i) then
        devs_in (i).cur_cycles <= cur_cycles;

        if rst_n = '0' then
          devs_in (i).re <= '0';
          devs_in (i).we <= '0';
        else
          if wbs_stb_i = '1' and wbs_cyc_i = '1' then
            if wbs_adr_i (8 downto 5) = std_logic_vector(to_unsigned(i, 4))
            then
              devs_in (i).adr <= wbs_adr_i (4 downto 2);
              devs_in (i).dati <= wbs_dat_i;
              devs_in (i).sel <= wbs_sel_i;
              devs_in (i).we <= start and wbs_we_i;
              devs_in (i).re <= start and not wbs_we_i;
            else
              devs_in (i).adr <= (others => '0');
              devs_in (i).dati <= (others => '0');
              devs_in (i).sel <= (others => '0');
              devs_in (i).we <= '0';
              devs_in (i).re <= '0';
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;

  --  Pseudo dev0
  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      devs_out(0).wack <= '0';
      devs_out(0).rack <= '0';
      devs_out(0).dato <= (others => '0');

      if rst_n = '0' then
        devs_out(0).trig <= '0';
        oen <= (others => '0');
        rst_time_en <= '0';
      else
        --  Write
        if devs_in(0).we = '1' then
          case devs_in(0).adr is
            when "011" =>
              --  Outputs enable
              oen <= devs_in(0).dati(oen'range);
            when "100" =>
              rst_time_en <= devs_in(0).dati(0);
            when others =>
              null;
          end case;
          devs_out(0).wack <= '1';
        end if;

        --  Read
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
            when "011" =>
              --  Outputs enable
              devs_out(0).dato(oen'range) <= oen;
            when "100" =>
              --  Config
              devs_out(0).dato(0) <= rst_time_en;
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
      if (rst_time_en = '1' and rst_time_n_i = '0') or rst_n = '0' then
        cur_cycles <= (others => '0');
      else
        cur_cycles <= std_logic_vector(unsigned(cur_cycles) + 1);
      end if;
    end if;
  end process;

  --  Dev 0: tdc (without a macro)
  b_tdc0: block
    constant ndly : natural := 200;

    signal taps : std_logic_vector (ndly - 1 downto 0);
    signal clks : std_logic_vector (2*ndly - 1 downto 0);
  begin
    clks <= (others => wb_clk_i);

    inst_itaps: entity work.opentdc_tapline
      generic map (
        cell => 0,
        length => ndly)
      port map (
        clks_i => clks,
        inp_i => inp_i(0),
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
        bin => devs_in(FTDC + 0),
        bout => devs_out(FTDC + 0));
  end block;

  g_tdcs: for cell in inp_i'left downto 1 generate
    constant ndly : natural := 200;

    signal taps, rtaps : std_logic_vector (ndly - 1 downto 0);
    signal clks, rclks : std_logic_vector (2*ndly - 1 downto 0);
    signal rin : std_logic;
  begin
    clks <= (others => wb_clk_i);
    rclks <= (others => wb_clk_i);

    inst_itaps: entity work.opentdc_tapline
      generic map (
        cell => cell,
        length => ndly)
      port map (
        clks_i => clks,
        inp_i => inp_i(cell),
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
        g_with_ref => true,
        g_with_scan => true,
        length => ndly)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        itaps => taps,
        rtaps => rtaps,
        rin_o => rin,
        bin => devs_in(FTDC + cell),
        bout => devs_out(FTDC + cell));
  end generate;

  --  fd0: inline delay
  b_fd1: block
    constant length : natural := 8;
    signal delay : std_logic_vector(length - 1 downto 0);
    signal pulse : std_logic;
  begin
    inst_delay_line: entity work.openfd_delayline
      generic map (
        cell => 1,
        plen => length)
      port map (
        inp_i => pulse, out_o => out_o(0), delay_i => delay);

    inst_core: entity work.openfd_core2
      generic map (
        g_with_ref => false,
        plen => length)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        idelay_o => delay,
        pulse_o => pulse,
        bin => devs_in(FFD + 0),
        bout => devs_out(FFD + 0));
  end block;

  --  fd1: macro
  b_fd2: if NFD > 1 generate
    constant length : natural := 8;
    signal delay : std_logic_vector(length - 1 downto 0);
    signal pulse : std_logic;
  begin
    inst_delay_line: entity work.openfd_delayline
      generic map (
        cell => 2,
        plen => length)
      port map (
        inp_i => pulse, out_o => out_o(1), delay_i => delay);

    inst_core: entity work.openfd_core2
      generic map (
        g_with_ref => false,
        plen => length)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        idelay_o => delay,
        pulse_o => pulse,
        bin => devs_in(FFD + 1),
        bout => devs_out(FFD + 1));
  end generate;
  b_no_fd2: if NFD <= 1 generate
    out_o(FFD + 1) <= '0';
  end generate;
end behav;
