-- Tap element
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity opentdc_tap is
  port (
    --  There is one clock input per dff, so that it can be balanced.
    clk0_i : std_logic;
    clk1_i : std_logic;

    --  Input signal.
    inp_i : std_logic;

    --  Delayed input signal.
    del_o : out std_logic;

    --  Synchronized (with clk*_i) value of inp_i.
    tap_o : out std_logic);
end opentdc_tap;

architecture behav of opentdc_tap is
begin
  inst_delay: entity work.opentdc_delay
    port map (inp_i, tap0);

  inst_sync: entity work.opentdc_sync
    port map (clk0_i, clk1_i, inp_i, tap_o);
end behav;
