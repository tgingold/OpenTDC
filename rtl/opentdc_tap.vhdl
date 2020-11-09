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
  signal tap0, tap1 : std_logic;
begin
  --  Delay line
  inst: entity work.opentdc_delay
    port map (inp_i, tap0);

  del_o <= tap0;

  --  1st FF
  process (clk0_i) is
  begin
    if rising_edge(clk0_i) then
      tap1 <= inp_i;
    end if;
  end process;

  --  2nd FF (for synchronizer)
  process (clk1_i) is
  begin
    if rising_edge(clk1_i) then
      tap_o <= tap1;
    end if;
  end process;
end behav;
