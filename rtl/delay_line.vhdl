-- Delay line
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tap_line is
  generic (
    length : natural := 1024);
  port (
    clk_i : std_logic;

    --  Input signal.
    inp_i : std_logic;

    tap_o : out std_logic_vector(length downto 0));
end tap_line;

architecture behav of tap_line is
  signal tap0, tap1, tap2 : std_logic_vector(length downto 0);
begin
  --  Delay line
  tap0 (0) <= inp_i;
  gen: for i in 0 to length - 1 generate
    inst: entity work.opentdc_delay
      port map (tap0 (i), tap0 (i + 1));
  end generate;

  --  Tap FF (+ synchronizer)
  process (clk_i) is
  begin
    if rising_edge(clk_i) then
      for i in tap1'range loop
        tap1 (i) <= tap0 (i);
        tap_o (i) <= tap1 (i);
      end loop;
    end if;
  end process;
end behav;
