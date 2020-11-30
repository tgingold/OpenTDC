-- Time to Digital Conversion (TDC) core
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

-- Stupid macro that just outputs '0'.
-- The purpose is to avoid standard cells at the top-level in order to not have
-- to fill with taps (and thus make DRC much faster).

library ieee;
use ieee.std_logic_1164.all;

entity zero is
  port (e_o : out std_logic_vector(11 downto 0);
        n_o : out std_logic;
        n1_o : out std_logic;
        s_o, w_o : out std_logic;
        clk_i : std_logic;
        clk_o : out std_logic_vector(3 downto 0));
end zero;

architecture behav of zero is
begin
  e_o <= (others => '0');
  n_o <= '0';
  n1_o <= '1';
  s_o <= '0';
  w_o <= '0';
  clk_o <= (others => clk_i);
end behav;

