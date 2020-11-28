-- Top-level with a wishbone bus
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity wb_interface is
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

    --  Downstream interface
    down_rst_n_o : out std_logic;
    down_bus_in : out dev_bus_in;
    down_bus_out : dev_bus_out;
    down_adr_o : out std_logic_vector (4 downto 0);

    --  TDCs
    
    tdc0_inp_i : std_logic;
    
    tdc1_rst_n : out std_logic;
    tdc1_bus_in : out dev_bus_in;
    tdc1_bus_out : dev_bus_out;

    tdc2_rst_n : out std_logic;
    tdc2_bus_in : out dev_bus_in;
    tdc2_bus_out : dev_bus_out;

    --  FDs
    fd0_out_o : out std_logic;
    
    fd1_rst_n : out std_logic;
    fd1_bus_in : out dev_bus_in;
    fd1_bus_out : dev_bus_out;

    fd2_rst_n : out std_logic;
    fd2_bus_in : out dev_bus_in;
    fd2_bus_out : dev_bus_out;

    fd3_rst_n : out std_logic;
    fd3_bus_in : out dev_bus_in;
    fd3_bus_out : dev_bus_out;

    --  Outputs enable
    oen_o : out std_logic_vector(15 downto 0);

    rst_time_n_i : std_logic);
end wb_interface;

architecture behav of wb_interface is
  --  Config (not generics to keep the same name).
  --  XX_MACROS is the number of hard macros in XX
  constant NTDC : natural := 3;
  constant NFD_MACROS : natural := 3;
  constant NFD : natural := 1 + NFD_MACROS + 0;

  signal rst_d : std_logic_vector(3 downto 0);
  alias rst_n : std_logic is rst_d (0);
  
  signal cycles_rst_n : std_logic;
  signal cur_cycles : std_logic_vector(31 downto 0);

  --  Set when a WB transaction can start
  signal start : std_logic;

  signal oen : std_logic_vector(oen_o'range);

  signal rst_time_en : std_logic;

  constant FTDC : natural := 1;
  constant FFD : natural := NTDC + 1;

  signal devs_in, devs_in_d: dev_in_array (NTDC + NFD downto 0);
  signal devs_out, devs_out_d: dev_out_array (NTDC + NFD downto 0);

  signal ctrl_in : dev_bus_in;
  signal ctrl_out : dev_bus_out;

  signal down_bus_out_r : dev_bus_out;

  signal areg : std_logic_vector(31 downto 0);
begin
  --  Apply reset for at least N cycles.
  process (wb_clk_i)
  begin
    if wb_rst_i = '1' then
      rst_d <= (others => '0');
    elsif rising_edge(wb_clk_i) then
      rst_d <= not wb_rst_i & rst_d (rst_d'left downto 1);
    end if;
  end process;

  --  Extra FF for oen.
  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      if rst_n = '0' then
        oen_o <= (others => '0');
      else
        oen_o <= oen;
      end if;
    end if;
  end process;

  --  FF on devs_out, devs_in
  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      devs_out_d <= devs_out;
      devs_in_d <= devs_in;
      down_rst_n_o <= rst_n;
      down_bus_out_r <= down_bus_out;
    end if;
  end process;

  --  Wishbone out process
  process (wb_clk_i)
    variable n : natural range 0 to 7;
  begin
    if rising_edge(wb_clk_i) then
      wbs_ack_o <= '0';
      wbs_dat_o <= (others => '0');

      if rst_n = '0' then
        start <= '1';
      else
        if wbs_stb_i = '1' and wbs_cyc_i = '1' then
          if wbs_adr_i (9 downto 8) = "00" then
            -- 8 words per sub-device (so 3+2 bits)
            n := to_integer(unsigned(wbs_adr_i (7 downto 5)));
            -- report "write to device " & natural'image(n);
            wbs_ack_o <= devs_out_d(n).wack or devs_out_d(n).rack;
            wbs_dat_o <= devs_out_d(n).dato;

            --  Freeze until the end of the transfer
            start <= '0';
          else
            wbs_ack_o <= down_bus_out_r.wack or down_bus_out_r.rack;
            wbs_dat_o <= down_bus_out_r.dato;
          end if;
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
        devs_in (i).cycles_rst_n <= cycles_rst_n;

        if rst_n = '0' then
          devs_in (i).re <= '0';
          devs_in (i).we <= '0';
        else
          if wbs_stb_i = '1' and wbs_cyc_i = '1' then
            if wbs_adr_i (9 downto 8) = "00"
              and wbs_adr_i (7 downto 5) = std_logic_vector(to_unsigned(i, 3))
            then
              devs_in (i).adr <= wbs_adr_i (4 downto 2);
              devs_in (i).dati <= wbs_dat_i;
              devs_in (i).sel <= wbs_sel_i;
              devs_in (i).we <= start and wbs_we_i;
              devs_in (i).re <= start and not wbs_we_i;
            else
              devs_in (i) <= null_dev_bus_in;
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;

  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      down_bus_in <= null_dev_bus_in;
      down_bus_in.cycles_rst_n <= cycles_rst_n;

      if rst_n = '0' then
        null;
      else
        if (wbs_stb_i = '1' and wbs_cyc_i = '1')
          and wbs_adr_i (9 downto 7) /= "00"
        then
          down_bus_in.adr <= wbs_adr_i (4 downto 2);
          down_bus_in.dati <= wbs_dat_i;
          down_bus_in.sel <= wbs_sel_i;
          down_bus_in.we <= start and wbs_we_i;
          down_bus_in.re <= start and not wbs_we_i;

          down_adr_o <=
            std_logic_vector (unsigned (wbs_adr_i (9 downto 5)) - "1000");
        end if;
      end if;
    end if;
  end process;

  ctrl_in <= devs_in_d(0);
  devs_out(0) <= ctrl_out;
  
  --  Pseudo dev0
  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      ctrl_out.wack <= '0';
      ctrl_out.rack <= '0';
      ctrl_out.dato <= (others => '0');

      if rst_n = '0' then
        ctrl_out.trig <= '0';
        oen <= (others => '0');
        rst_time_en <= '0';
        areg <= x"10_20_30_40";
      else
        --  Write
        if ctrl_in.we = '1' then
          case ctrl_in.adr is
            when "011" =>
              --  Outputs enable
              oen <= ctrl_in.dati(oen'range);
            when "100" =>
              rst_time_en <= ctrl_in.dati(0);
            when "110" =>
              for i in 3 downto 0 loop
                if ctrl_in.sel (i) = '1' then
                  areg(i*8+7 downto i*8) <= ctrl_in.dati(i*8+7 downto i*8);
                end if;
              end loop;
            when others =>
              null;
          end case;
          ctrl_out.wack <= '1';
        end if;

        --  Read
        if ctrl_in.re = '1' then
          case ctrl_in.adr is
            when "000" =>
              ctrl_out.dato <= x"54_64_63_01";  -- 'Tdc\1'
            when "001" =>
              ctrl_out.dato <= cur_cycles;
            when "010" =>
              --  Global status
              for i in NTDC - 1 downto 0 loop
                ctrl_out.dato (i) <= devs_out_d(i).trig;
              end loop;
            when "011" =>
              --  Outputs enable
              ctrl_out.dato(oen'range) <= oen;
            when "100" =>
              --  Config
              ctrl_out.dato(0) <= rst_time_en;
            when "110" =>
              ctrl_out.dato <= areg;
            when "111" =>
              ctrl_out.dato(31 downto 24) <=
                std_logic_vector(to_unsigned(NFD, 8));
              ctrl_out.dato(23 downto 16) <=
                std_logic_vector(to_unsigned(NTDC, 8));
            when others =>
              null;
          end case;
          ctrl_out.rack <= '1';
        end if;
      end if;
    end if;
  end process;

  --  Time counter.
  process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if (rst_time_en = '1' and rst_time_n_i = '0') or rst_n = '0' then
        cycles_rst_n <= '0';
      else
        cycles_rst_n <= '1';
      end if;
    end if;
  end process;

  i_cycles: entity work.counter
    port map (
      clk_i => wb_clk_i,
      rst_n_i => cycles_rst_n,
      cur_cycles_o => cur_cycles);

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
        inp_i => tdc0_inp_i,
        tap_o => taps);

    inst_core: entity work.opentdc_core2
      generic map (
        g_with_ref => false,
        length => ndly,
        fine_bits => 8)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        itaps => taps,
        rtaps => (others => '0'),
        bin => devs_in_d(FTDC + 0),
        bout => devs_out(FTDC + 0));
  end block;

  g_tdc1: if NTDC >= 2 generate
    tdc1_rst_n <= rst_n;
    tdc1_bus_in <= devs_in_d(FTDC + 1);
    devs_out(FTDC + 1) <= tdc1_bus_out;
  end generate;
  
  g_tdc2: if NTDC >= 2 generate
    tdc2_rst_n <= rst_n;
    tdc2_bus_in <= devs_in_d(FTDC + 2);
    devs_out(FTDC + 2) <= tdc2_bus_out;
  end generate;

  --  fd0: inline delay
  b_fd0: block
    constant length : natural := 8;
    signal delay : std_logic_vector(length - 1 downto 0);
    signal pulse : std_logic;
  begin
    inst_delay_line: entity work.openfd_delayline
      generic map (
        cell => 0,
        plen => length)
      port map (
        inp_i => pulse, out_o => fd0_out_o, delay_i => delay);

    inst_core: entity work.openfd_core2
      generic map (
        g_with_ref => false,
        plen => length)
      port map (
        clk_i => wb_clk_i,
        rst_n_i => rst_n,
        idelay_o => delay,
        ipulse_o => pulse,
        bin => devs_in_d(FFD + 0),
        bout => devs_out(FFD + 0));
  end block;

  --  fd1: macro (fd_hd)
  b_mac_fd1: if NFD_MACROS >= 1 generate
    fd1_rst_n <= rst_n;
    fd1_bus_in <= devs_in_d(FFD + 1);
    devs_out(FFD + 1) <= fd1_bus_out;
  end generate;

  --  fd2: macro (fd_hs)
  b_mac_fd2: if NFD_MACROS >= 2 generate
    fd2_rst_n <= rst_n;
    fd2_bus_in <= devs_in_d(FFD + 2);
    devs_out(FFD + 2) <= fd2_bus_out;
  end generate;

  --  fd3: macro (fd_ms)
  b_mac_fd3: if NFD_MACROS >= 3 generate
    fd3_rst_n <= rst_n;
    fd3_bus_in <= devs_in_d(FFD + 3);
    devs_out(FFD + 3) <= fd3_bus_out;
  end generate;
end behav;
