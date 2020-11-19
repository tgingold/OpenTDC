-- Fine Delay (FD) delay line
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity openfd_delayline is
  generic (
    cell : natural := 0;
    --  log2(nbr_taps).  This is also the number of significant bits of
    --  fine_i
    plen : natural := 7);
  port (
    inp_i : std_logic;
    out_o : out std_logic;

    delay_i : std_logic_vector(plen - 1 downto 0));
end openfd_delayline;

architecture behav of openfd_delayline is
  signal taps : std_logic_vector (plen downto 0);
begin
  taps (plen) <= inp_i;

  g_taps: for i in plen - 1 downto 0 generate
    signal sub_taps : std_logic_vector (2**i downto 0);
  begin
    sub_taps(2**i) <= taps(i + 1);

    g_subtaps: for j in 2**i downto 1 generate
    begin
      inst_tap: entity work.opentdc_delay
        generic map (
          cell => cell)
        port map (
          inp_i => sub_taps (j),
          out_o => sub_taps (j - 1));
    end generate g_subtaps;

    taps (i) <= sub_taps(0) when delay_i (i) = '1' else taps (i + 1);
  end generate g_taps;

  out_o <= taps (0);
end behav;
