-- Time to Digital Conversion (TDC) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity openfd_core2 is
  generic (
    g_with_ref : boolean := True;
    plen : natural := 7);
  port (
    clk_i : std_logic;
    rst_n_i : std_logic;

    idelay_o : out std_logic_vector(plen - 1 downto 0);
    --  rdelay_o : std_logic_vector(plen - 1 downto 0);

    --  Source of idelay taps
    pulse_o : out std_logic;

    bin : tdc_bus_in;
    bout : out tdc_bus_out);
end openfd_core2;

--  This core is made of 2 submodules, so that it is easy to harden
--  the tapline.
architecture behav of openfd_core2 is
  signal coarse, rcoarse  : std_logic_vector(31 downto 0);
  signal fine, rfine      : std_logic_vector(plen - 1 downto 0);
  signal valid            : std_logic;
  signal pulse            : std_logic;
begin
  process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_n_i = '0' then
        pulse <= '0';
      elsif valid = '1' and coarse = bin.cur_cycles then
        pulse <= '1';
      else
        pulse <= '0';
      end if;
    end if;
  end process;

  pulse_o <= pulse;
  idelay_o <= fine;

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
                          others => '0');
          when "001" =>
            bout.dato <= (others => '0');
          when "010" =>
            bout.dato <= coarse;
          when "011" =>
            bout.dato (31 downto plen) <= (others => '0');
            bout.dato (plen - 1 downto 0) <= fine;
          when "100" =>
            bout.dato <= (others => '0');
          when "101" =>
            bout.dato <= (others => '0');
          when "110" =>
            bout.dato <= (others => '0');
          when "111" =>
            bout.dato <= (others => '0');
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
      if rst_n_i = '0' then
        valid <= '0';
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
            when others =>
              null;
          end case;
          bout.wack <= '1';
        end if;
        if pulse = '1' then
          valid <= '0';
        end if;
      end if;
    end if;
  end process;
end behav;
