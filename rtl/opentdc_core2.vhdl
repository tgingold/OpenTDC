-- Time to Digital Conversion (TDC) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity opentdc_core2 is
  generic (
    g_with_ref : boolean := True;
    length : natural := 1024);
  port (
    clk_i : std_logic;
    rst_n_i : std_logic;

    itaps : std_logic_vector(length - 1 downto 0);
    rtaps : std_logic_vector(length - 1 downto 0);

    --  Source of ref taps
    rin_o : out std_logic;

    bin : tdc_bus_in;
    bout : out tdc_bus_out);
end opentdc_core2;

--  This core is made of 2 submodules, so that it is easy to harden
--  the tapline.
architecture behav of opentdc_core2 is
  signal trigger, rtrigger : std_logic;
  signal restart, rrestart : std_logic;

  signal coarse, rcoarse  : std_logic_vector(31 downto 0);
  signal fine, rfine      : std_logic_vector(15 downto 0);
  signal detect_rise, detect_fall : std_logic;
  signal rdetect_rise, rdetect_fall : std_logic;

  signal clk_div : std_logic_vector(3 downto 0);
  signal clk_cnt : std_logic_vector(7 downto 0);
  signal clk_out : std_logic;
  signal clk_dir : std_logic;
begin
  inst_itime: entity work.opentdc_time
    generic map (
      length => length)
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      cur_cycles_i => bin.cur_cycles,
      restart_i => restart,
      detect_rise_i => detect_rise,
      detect_fall_i => detect_fall,
      tap_i => itaps,
      trigger_o => trigger,
      coarse_o => coarse,
      fine_o => fine);

  gen_rtime: if g_with_ref generate
    inst_rtime: entity work.opentdc_time
      generic map (
        length => length)
      port map (
        clk_i => clk_i,
        rst_n_i => rst_n_i,
        cur_cycles_i => bin.cur_cycles,
        restart_i => rrestart,
        detect_rise_i => rdetect_rise,
        detect_fall_i => rdetect_fall,
        tap_i => rtaps,
        trigger_o => rtrigger,
        coarse_o => rcoarse,
        fine_o => rfine);
  end generate;

  gen_no_rtime: if not g_with_ref generate
    rtrigger <= '0';
    rcoarse <= (others => '0');
    rfine <= (others => '0');
  end generate;

  --  Read process
  process (clk_i) is
  begin
    if rising_edge (clk_i) then
      bout.trig <= trigger or rtrigger;
      if bin.re = '1' then
        case bin.adr is
          when "000" =>
            bout.dato <= (19 => rdetect_fall,
                          18 => rdetect_rise,
                          17 => detect_fall,
                          16 => detect_rise,
                          9  => rrestart,
                          8  => restart,
                          1 => rtrigger,
                          0 => trigger,
                          others => '0');
            bout.dato (27 downto 24) <= clk_div;
          when "001" =>
            bout.dato (31 downto 16) <= rcoarse(15 downto 0);
            bout.dato (15 downto 0) <= rfine(15 downto 0);
          when "010" =>
            bout.dato <= coarse;
          when "011" =>
            bout.dato (31 downto 16) <= (others => '0');
            bout.dato (15 downto 0) <= fine;
          when "100" =>
            --  TODO: scan pos
            bout.dato <= (others => '0');
          when "101" =>
            --  TODO: scan value
            bout.dato <= (others => '0');
          when "110" =>
            bout.dato <= (others => '0');
          when "111" =>
            bout.dato <= (others => '0');
          when others =>
            bout.dato <= (others => 'X');
        end case;
        bout.wack <= '1';
      else
        bout.dato <= (others => '0');
        bout.wack <= '0';
      end if;
    end if;
  end process;

  --  Write process
  process (clk_i) is
  begin
    if rising_edge (clk_i) then
      --  restart is a pulse
      rrestart <= '0';
      restart <= '0';
      bout.rack <= '0';

      if rst_n_i = '0' then
        rdetect_fall <= '0';
        rdetect_rise <= '0';
        detect_fall <= '0';
        detect_rise <= '0';
        clk_div <= x"0";
      else
        if bin.we = '1' then
          case bin.adr is
            when "000" =>
              if bin.sel(1) = '1' then
                rrestart <= bin.dati (9);
                restart <= bin.dati (8);
              end if;

              if bin.sel(2) = '1' then
                 rdetect_fall <= bin.dati (19);
                 rdetect_rise <= bin.dati (18);
                 detect_fall <= bin.dati (17);
                 detect_rise <= bin.dati (16);
              end if;

              if bin.sel(3) = '1' then
                clk_div <= bin.dati (27 downto 24);
              end if;

              if not g_with_ref then
                rrestart <= '0';
                rdetect_fall <= '0';
                rdetect_rise <= '0';
                clk_div <= (others => '0');
              end if;
            when "001" =>
              null;
            when "010" =>
              null;
            when "011" =>
              null;
            when others =>
              null;
          end case;
          bout.rack <= '1';
        end if;
      end if;
    end if;
  end process;

  gen_rin: if g_with_ref generate
    rin_o <= clk_i when clk_dir = '1' else clk_out;

    process (clk_i)
    begin
      if rising_edge(clk_i) then
        if rst_n_i = '0' then
          clk_cnt <= (others => '0');
        else
          clk_cnt <= std_logic_vector(unsigned(clk_cnt) + 1);
        end if;
      end if;
    end process;

    process (clk_i) is
    begin
      if rising_edge (clk_i) then
        clk_dir <= '0';
        case clk_div is
          when x"0" => clk_out <= '0';
          when x"1" => clk_dir <= '1';
          when x"2" => clk_out <= clk_cnt(0);
          when x"3" => clk_out <= clk_cnt(1);
          when x"4" => clk_out <= clk_cnt(2);
          when x"5" => clk_out <= clk_cnt(3);
          when x"6" => clk_out <= clk_cnt(4);
          when x"7" => clk_out <= clk_cnt(5);
          when x"8" => clk_out <= clk_cnt(6);
          when x"9" => clk_out <= clk_cnt(7);
          when others => clk_out <= '0';
        end case;
      end if;
    end process;
  end generate;

  gen_no_rin: if not g_with_ref generate
    rin_o <= '0';
  end generate;
end behav;
