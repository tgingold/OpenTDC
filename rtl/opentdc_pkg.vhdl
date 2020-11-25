-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

package opentdc_pkg is
  --  tdc_bus:
  --  0: config/status
  --
  --  1: ref
  --     31-16: coarse
  --     15-0:  fine
  --
  --  2: 31-16: coarse
  --  3: 15-0:  find

  type tdc_bus_in is record
    adr : std_logic_vector(4 downto 2);
    dati : std_logic_vector(31 downto 0);
    sel : std_logic_vector (3 downto 0);

    --  A pulse when adr + dati/dato is valid.  The controller then waits
    --  for the corresponding ack.
    we : std_logic;
    re : std_logic;

    cycles_rst_n : std_logic;
  end record;

  type tdc_bus_out is record
    dato : std_logic_vector(31 downto 0);
    trig : std_logic;
    wack : std_logic;
    rack : std_logic;
  end record;
end opentdc_pkg;
