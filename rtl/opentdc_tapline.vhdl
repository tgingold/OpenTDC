library ieee;
use ieee.std_logic_1164.all;

entity opentdc_tapline is
  generic (
    length : natural := 100);
  port (
    --  There is one clock input per dff, so that it can be balanced.
    clks_i : std_logic_vector (2 * length - 1 downto 0);

    --  Input signal.
    inp_i : std_logic;

    tap_o : out std_logic_vector(length downto 0));
end opentdc_tapline;

architecture behav of opentdc_tapline is
  signal tap0, tap1, tap2 : std_logic_vector(length downto 0);
begin
  tap0 (0) <= inp_i;
  gen: for i in 0 to length - 1 generate
    --  Delay line
    inst: entity work.opentdc_delay
      port map (tap0 (i), tap0 (i + 1));

    --  1st FF
    process (clks_i (2*i)) is
    begin
      if rising_edge(clks_i (2 * i)) then
        tap1 (i) <= tap0 (i);
      end if;
    end process;

    --  2nd FF (for synchronizer)
    process (clks_i(2*i + 1)) is
    begin
      if rising_edge(clks_i (2 * i + 1)) then
        tap_o (i) <= tap1 (i);
      end if;
    end process;
  end generate;
end behav;
