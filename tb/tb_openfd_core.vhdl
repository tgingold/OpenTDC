-- Testbench for FD
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_openfd_core is
end;

architecture behav of tb_openfd_core is
  constant period : time := 10 ns;

  signal clk_i        : std_logic;
  signal rst_n_i      : std_logic;
  signal trigger_o    : std_logic;
  signal coarse_i     : std_logic_vector(31 downto 0);
  signal fine_i       : std_logic_vector(15 downto 0);
  signal valid_i      : std_logic;
  signal pulse        : std_logic;
  signal cur_cycles : std_logic_vector(31 downto 0);

  signal done : boolean := false;

begin
  dut: entity work.openfd_core
    generic map (
      plen => 7)
    port map (
      clk_i        => clk_i,
      rst_n_i      => rst_n_i,
      cur_cycles_i => cur_cycles,
      coarse_i     => coarse_i,
      fine_i       => fine_i,
      valid_i      => valid_i,
      out_o        => pulse);

  process
  begin
    clk_i <= '0';
    wait for period / 2;
    clk_i <= '1';
    wait for period / 2;
    if done then
      wait;
    end if;
  end process;

  --  Cur_cycles
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

  process
    variable t1: time;
  begin
    rst_n_i <= '0';
    valid_i <= '0';

    wait for 2 * period;
    wait until rising_edge(clk_i);
    rst_n_i <= '1';

    assert cur_cycles = x"0000_0000";
    wait until cur_cycles = x"0000_0001";
    t1 := now;
    report "cur_cycles = 1";

    --  Setup.
    coarse_i <= x"0000_0004";
    fine_i   <= x"001b"; -- 27
    valid_i  <= '1';
    wait until rising_edge (clk_i);
    valid_i <= '0';

    wait until rising_edge (pulse);
    assert now = t1 + 3 * period + 27 * 100 ps;
    report "done";

    done <= true;
    wait;
  end process;
end behav;
