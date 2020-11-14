-- Synchronizer
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity opentdc_sync is
  port (
    --  There is one clock input per dff, so that it can be balanced.
    clk0_i : std_logic;
    clk1_i : std_logic;

    --  Input signal.
    inp_i : std_logic;

    --  Synchronized (with clk*_i) value of inp_i.
    out_o : out std_logic);
end opentdc_sync;

architecture behav of opentdc_sync is
  signal inp_d : std_logic;
begin
  --  1st FF
  process (clk0_i) is
  begin
    if rising_edge(clk0_i) then
      inp_d <= inp_i;
    end if;
  end process;

  --  2nd FF (for synchronizer)
  process (clk1_i) is
  begin
    if rising_edge(clk1_i) then
      out_o <= inp_d;
    end if;
  end process;
end behav;
