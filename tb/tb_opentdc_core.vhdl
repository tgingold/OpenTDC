library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_opentdc_core is
end;

architecture behav of tb_opentdc_core is
  constant period : time := 10 ns;

  signal clk_i        : std_logic;
  signal rst_n_i      : std_logic;
  signal restart_i    : std_logic;
  signal inp_i        : std_logic;
  signal trigger_o    : std_logic;
  signal coarse_o     : std_logic_vector(31 downto 0);
  signal fine_o       : std_logic_vector(15 downto 0);
  signal fine         : natural;
  signal cur_cycles : std_logic_vector(31 downto 0);

  signal done : boolean := false;

begin
  dut: entity work.opentdc_core
    generic map (
      length => 128)
    port map (
      clk_i        => clk_i,
      rst_n_i      => rst_n_i,
      cur_cycles_i => cur_cycles,
      restart_i    => restart_i,
      inp_i        => inp_i,
      trigger_o    => trigger_o,
      coarse_o     => coarse_o,
      fine_o       => fine_o);

  process
  begin
    clk_i <= '0';
    wait for period / 2;
    clk_i <= '1';
    wait for period / 2;
    if done then
      wait;
    end if;
  end process;

  --  Cur_cycles
  process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        cur_cycles <= (others => '0');
      else
        cur_cycles <= std_logic_vector(unsigned(cur_cycles) + 1);
      end if;
    end if;
  end process;

  fine <= to_integer(unsigned(fine_o));

  process
  begin
    rst_n_i <= '0';
    restart_i <= '0';
    inp_i <= '0';

    wait for 2 * period;
    wait until rising_edge(clk_i);
    rst_n_i <= '1';

    wait for 31417 ps;
    --  delay = 30ns + 1417ps
    --        = 3 cycles + 14.17 taps
    --  As a cycle is 100 taps, the 85 first ones are read as 1.

    inp_i <= '1';

    loop
      wait until rising_edge(clk_i);
      exit when trigger_o = '1';
    end loop;

    --  Read results
    report "coarse: " & to_hstring(coarse_o);
    report "fine: 0x" & to_hstring(fine_o) & " = " & natural'image(fine);
    --  See above for the value.
    assert coarse_o = x"0000_0003" report "bad coarse value" severity failure;
    assert fine = 85 report "bad fine value" severity failure;
    done <= true;
    wait;
  end process;
end behav;
