-- Delay element (entity)
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

entity opentdc_delay is
  port (
    inp_i : std_logic;
    out_o : out std_logic);
end opentdc_delay;
