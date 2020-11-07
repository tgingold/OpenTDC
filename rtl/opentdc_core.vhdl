--  TDC core
library ieee;
use ieee.std_logic_1164.all;

entity opentdc_core is
  generic (
    length : natural := 1024);
  port (
    clk_i : std_logic;
    rst_n_i : std_logic;

    --  Current time (in cycles).
    cur_cycles_i : std_logic_vector(31 downto 0);

    --  If true, acquire the next trigger.
    --  If false, pause once triggered.
    restart_i : std_logic;

    --  Input signal.
    inp_i : std_logic;

    --  Set if a pulse has been detected.
    trigger_o : out std_logic;

    coarse_o  : out std_logic_vector(31 downto 0);
    fine_o    : out std_logic_vector(15 downto 0));
end opentdc_core;

--  This core is made of 2 submodules, so that it is easy to harden
--  the tapline.
architecture behav of opentdc_core is
  signal tap : std_logic_vector(length downto 0);
  signal tap_clks : std_logic_vector(2*length - 1 downto 0);
begin
  --  Drive the clocks of the tap line.
  tap_clks <= (others => clk_i);
  
  inst_tap_line: entity work.opentdc_tapline
    generic map (
      length => length)
    port map (
      clks_i => tap_clks,
      inp_i => inp_i,
      tap_o => tap);

  inst_time: entity work.opentdc_time
    generic map (
      length => length)
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      cur_cycles_i => cur_cycles_i,
      restart_i => restart_i,
      tap_i => tap,
      trigger_o => trigger_o,
      coarse_o => coarse_o,
      fine_o => fine_o);
end behav;
