-- delay lines for simulation
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity delayline_9_hd is
  port (
    en_i: in  std_logic_vector(8 downto 0);
    inp_i: in  std_logic;
    out_o: out std_logic);
end;

architecture behav of delayline_9_hd is
begin
  inst: entity work.openfd_delayline
    generic map (plen => 9)
    port map (
      inp_i => inp_i,
      out_o => out_o,
      delay_i => en_i);
end behav;

