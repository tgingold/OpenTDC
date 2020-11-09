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

    tap_o : out std_logic_vector(length - 1 downto 0));
end opentdc_tapline;

architecture behav of opentdc_tapline is
  signal tap0 : std_logic_vector(length downto 0);
begin
  tap0 (0) <= inp_i;

  gen: for i in 0 to length - 1 generate
    inst_tap: entity work.opentdc_tap
      port map (
        clk0_i => clks_i (2*i),
        clk1_i => clks_i (2*i + 1),
        inp_i => tap0 (i),
        del_o => tap0 (i + 1),
        tap_o => tap_o (i));
  end generate;
end behav;
