-- Fine Delay (FD) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity openfd_time is
  generic (
    --  log2(nbr_taps).  This is also the number of significant bits of
    --  fine_i
    plen : natural := 7);
  port (
    clk_i : std_logic;
    rst_n_i : std_logic;

    --  Current time (in cycles).
    cur_cycles_i : std_logic_vector(31 downto 0);

    --  Parameters for the next pulse (set when valid_i is true)
    coarse_i  : std_logic_vector(31 downto 0);
    fine_i    : std_logic_vector(15 downto 0);
    valid_i   : std_logic;

    --  Set on valid, cleared on the pulse.
    busy_o    : out std_logic;

    --  Delay line value
    delay_o : out std_logic_vector (plen - 1 downto 0);

    --  Pulse (of clk_i width), delayed by coarse + fine
    pulse_o     : out std_logic);
end openfd_time;

architecture behav of openfd_time is
  signal coarse  : std_logic_vector(31 downto 0);
  signal valid   : std_logic;
begin
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        coarse <= (others => '0');
        delay_o <= (others => '0');
        valid <= '0';
      elsif valid_i = '1' then
        coarse <= std_logic_vector (unsigned(coarse_i) - 1);
        delay_o <= fine_i(fine'range);
        valid <= '1';
      elsif pulse = '1' then
        valid <= '0';
      end if;
    end if;
  end process;

  busy_o <= valid;

  process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_n_i = '0' then
        pulse_o <= '0';
      elsif valid = '1' and coarse = cur_cycles_i then
        pulse_o <= '1';
      else
        pulse_o <= '0';
      end if;
    end if;
  end process;
end behav;
