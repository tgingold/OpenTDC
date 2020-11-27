-- Time to Digital Conversion (TDC) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity openfd_core2 is
  generic (
    g_with_ref : boolean := False;
    g_with_test : boolean := False;
    plen : natural := 7);
  port (
    clk_i : std_logic;
    rst_n_i : std_logic;

    --  Taps value
    idelay_o : out std_logic_vector(plen - 1 downto 0);
    rdelay_o : out std_logic_vector(plen - 1 downto 0);
    tdelay_o : out std_logic_vector(plen - 1 downto 0);

    --  Source of delay taps
    ipulse_o : out std_logic;
    rpulse_o : out std_logic;
    tpulse_o : out std_logic;

    tpulse_i : std_logic := '0';

    bin : dev_bus_in;
    bout : out dev_bus_out);
end openfd_core2;

--  This core is made of 2 submodules, so that it is easy to harden
--  the tapline.
architecture behav of openfd_core2 is
  signal coarse, rcoarse  : std_logic_vector(31 downto 0);
  signal fine, rfine, tfine  : std_logic_vector(plen - 1 downto 0);
  signal valid, rvalid    : std_logic;
  signal pulse, rpulse, tpulse    : std_logic;
  signal cur_cycles : std_logic_vector(31 downto 0);
  signal twrite : std_logic;

  signal mini_taps : std_logic_vector(7 downto 0);
begin
  i_cycles: entity work.counter
    port map (
      clk_i => clk_i,
      rst_n_i => bin.cycles_rst_n,
      cur_cycles_o => cur_cycles);

  process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_n_i = '0' then
        pulse <= '0';
      elsif valid = '1' and coarse = cur_cycles then
        pulse <= '1';
      else
        pulse <= '0';
      end if;
    end if;
  end process;

  ipulse_o <= pulse;
  idelay_o <= fine;

  g_ref: if g_with_ref generate
    process (clk_i)
    begin
      if rising_edge (clk_i) then
        if rst_n_i = '0' then
          rpulse <= '0';
        elsif rvalid = '1' and rcoarse = cur_cycles then
          rpulse <= '1';
        else
          rpulse <= '0';
        end if;
      end if;
    end process;

    rpulse_o <= rpulse;
    rdelay_o <= rfine;
  end generate;
  g_no_ref: if not g_with_ref generate
    rpulse_o <= '0';
    rdelay_o <= (others => '0');
  end generate;

  g_test: if g_with_test generate
    constant length : natural := mini_taps'length;
    signal taps : std_logic_vector(length - 1 downto 0);
    signal taps_clks : std_logic_vector (2 * length - 1 downto 0);
    signal twrite_d : std_logic_vector(2 downto 0);
  begin
    process (clk_i)
    begin
      if rising_edge (clk_i) then
        tpulse_o <= tpulse;
        twrite_d <= twrite & twrite_d (twrite_d'left downto 1);
      end if;
    end process;

    taps_clks <= (others => clk_i);

    i_minitdc: entity work.opentdc_tapline
      generic map (
        cell => 0,
        length => length)
      port map (
        clks_i => taps_clks,
        inp_i => tpulse_i,
        tap_o => taps);
    
    process (clk_i)
    begin
      if rising_edge (clk_i) and twrite_d (0) = '1' then
        mini_taps <= taps;
      end if;
    end process;

    tdelay_o <= tfine;
  end generate;
  g_no_test: if not g_with_test generate
    tdelay_o <= (others => '0');
    tpulse_o <= '0';
  end generate;

  --  Read process
  process (clk_i) is
  begin
    if rising_edge (clk_i) then
      bout.trig <= '0';

      bout.dato <= (others => '0');
      bout.rack <= '0';

      if bin.re = '1' then
        case bin.adr is
          when "000" =>
            bout.dato <= (0 => valid,
                          1 => rvalid,
                          others => '0');
          when "001" =>
            if g_with_test then
              bout.dato (mini_taps'range) <= mini_taps;
            end if;
          when "010" =>
            bout.dato <= coarse;
          when "011" =>
            bout.dato (plen - 1 downto 0) <= fine;
          when "100" =>
            if g_with_ref then
              bout.dato <= rcoarse;
            end if;
          when "101" =>
            if g_with_ref then
              bout.dato (plen - 1 downto 0) <= rfine;
            end if;
          when "110" =>
            if g_with_test then
              bout.dato (plen - 1 downto 0) <= rfine;
            end if;
          when "111" =>
            bout.dato (0) <= '1';  -- Config
            bout.dato (1) <= '0';  -- FD
            if g_with_ref then
              bout.dato (2) <= '1';
            end if;
            if g_with_test then
              bout.dato (3) <= '1';
            end if;
            bout.dato (31 downto 16) <=
              std_logic_vector (to_unsigned(plen, 16));
          when others =>
            bout.dato <= (others => 'X');
        end case;
        bout.rack <= '1';
      end if;
    end if;
  end process;

  --  Write process
  process (clk_i) is
  begin
    if rising_edge (clk_i) then
      bout.wack <= '0';

      twrite <= '0';

      if rst_n_i = '0' then
        valid <= '0';
        rvalid <= '0';
        tpulse <= '0';
      else
        if bin.we = '1' then
          case bin.adr is
            when "000" =>
              null;
            when "001" =>
              null;
            when "010" =>
              coarse <= bin.dati;
              valid <= '1';
            when "011" =>
              fine <= bin.dati (plen - 1 downto 0);
            when "100" =>
              if g_with_ref then
                rcoarse <= bin.dati;
                rvalid <= '1';
              end if;
            when "101" =>
              if g_with_ref then
                rfine <= bin.dati (plen - 1 downto 0);
              end if;
            when "110" =>
              if g_with_test then
                tfine <= bin.dati (plen - 1 downto 0);
                tpulse <= bin.dati (31);
                twrite <= '1';
              end if;
            when others =>
              null;
          end case;
          bout.wack <= '1';
        end if;

        if pulse = '1' then
          valid <= '0';
        end if;
        if g_with_ref and rpulse = '1' then
          rvalid <= '0';
        end if;
      end if;
    end if;
  end process;
end behav;
