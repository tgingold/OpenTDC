-- Time to Digital Conversion (TDC) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity tb_rescue is
end;

architecture behav of tb_rescue is
  constant cycle : time := 20 ns; --  50 Mhz

  signal clk        : std_logic := '0';
  signal rst_n      : std_logic := '0';
  signal tdc_coarse : std_logic_vector(31 downto 0);
  signal tdc_fine   : std_logic_vector(8 downto 0);
  signal tdc_done   : std_logic;
  signal tdc_start  : std_logic;
  signal fd_coarse  : std_logic_vector(31 downto 0);
  signal fd_fine    : std_logic_vector(8 downto 0);
  signal fd_done    : std_logic;
  signal fd_start   : std_logic;
  signal fd_force   : std_logic;
  signal tdc_inp_i  : std_logic;
  signal fd_out_o   : std_logic;

  signal fd_time : time;

  signal tb_done : std_logic := '0';
begin
  process (fd_out_o)
  begin
    fd_time <= now;
  end process;

  process
  begin
    --  Important: start at level 1, so that a rising_edge happen every
    --  CYCLE.
    wait for cycle / 2;
    clk <= not clk;
    if tb_done = '1' then
      wait;
    end if;
  end process;

  process
    variable t0 : time;
  begin
    report "start";
    tdc_inp_i <= '0';

    wait until rising_edge(clk);
    wait until rising_edge(clk);

    rst_n <= '1';
    tdc_start <= '0';
    fd_start <= '0';
    fd_force <= '0';

    wait until rising_edge(clk);

    --  TDC first pulse

    assert tdc_done = '0';

    tdc_inp_i <= '1' after 12.3 ns;

    for i in 1 to 5 loop
      wait until rising_edge(clk);
    end loop;

    assert tdc_done = '1';
    assert tdc_coarse = x"0000_0003"; -- 3 - 2 = 1!
    assert tdc_fine = 9x"4d";   -- 0x4d = 77, 123 + 77 = 200

    wait until rising_edge(clk);

    tdc_inp_i <= '0';

    wait until rising_edge(clk);
    wait until rising_edge(clk);
    assert tdc_done = '1';

    tdc_start <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    assert tdc_done = '0';

    tdc_inp_i <= '1' after 4.7 ns;

    for i in 1 to 5 loop
      wait until rising_edge(clk);
    end loop;

    assert tdc_done = '1';
    assert tdc_coarse = x"0000_000e";
    assert tdc_fine = 9d"153";

    --  Fine delay

    t0 := now;
    
    fd_coarse <= x"0000_0012";
    fd_fine <= 9d"73";
    fd_start <= '1';

    wait until rising_edge(clk);

    wait on fd_time for 5 * cycle;
    assert fd_time > t0;
    assert fd_time - t0 = 2 * cycle + 7300 ps;

    report "done";
    tb_done <= '1';
    wait;
  end process;

  i_rescue: entity work.rescue
    port map (
      clk_i      => clk,
      rst_n_i    => rst_n,
      tdc_coarse => tdc_coarse,
      tdc_fine   => tdc_fine,
      tdc_done   => tdc_done,
      tdc_start  => tdc_start,
      fd_coarse  => fd_coarse,
      fd_fine    => fd_fine,
      fd_done    => fd_done,
      fd_start   => fd_start,
      fd_force   => fd_force,
      tdc_inp_i  => tdc_inp_i,
      fd_out_o   => fd_out_o);
end behav;
