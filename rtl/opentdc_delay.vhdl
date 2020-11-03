--  Elementary delay, to be replaced by a specific implementation.
--  It should be balanced

library ieee;
use ieee.std_logic_1164.all;

entity opentdc_delay is
  port (
    inp_i : std_logic;
    out_o : out std_logic);
end opentdc_delay;
