-- Cycle counter used by every sub-block
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  port (
    --  Control
    clk_i : std_logic;
    rst_n_i : std_logic;

    cur_cycles_o : out std_logic_vector(31 downto 0));
end counter;

architecture behav of counter is
  signal cur_cycles : std_logic_vector(31 downto 0);
begin
  cur_cycles_o <= cur_cycles;
  
  --  Time counter.
  process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        cur_cycles <= (others => '0');
      else
        cur_cycles <= std_logic_vector(unsigned(cur_cycles) + 1);
      end if;
    end if;
  end process;
end behav;
