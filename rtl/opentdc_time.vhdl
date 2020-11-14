-- Time core of a TDC: sample time in case of a pulse
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity opentdc_time is
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

    --  taps input
    tap_i : std_logic_vector(length - 1 downto 0);

    --  Set if a pulse has been detected.
    trigger_o : out std_logic;

    coarse_o  : out std_logic_vector(31 downto 0);
    fine_o    : out std_logic_vector(15 downto 0));
end opentdc_time;

architecture behav of opentdc_time is
  function ffs (v : std_logic_vector) return natural
  is
    alias av : std_logic_vector(v'length - 1 downto 0) is v;
    constant m : integer := av'length / 2;
  begin
    if v'length <= 1 then
      return 0;
    else
      if av (m) = av(0) then
        return m + ffs (av (av'left downto m));
      else
        return ffs (av (m - 1 downto 0));
      end if;
    end if;
  end ffs;

  signal pulse : std_logic;
  signal trigger : std_logic;
begin
  --  FF at the input to detect pulses (longer than the cycle).
  process (clk_i) is
  begin
    if rising_edge(clk_i) then
      pulse <= tap_i(0);
    end if;
  end process;

  --  Pulse detector.
  process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        trigger <= '0';
      elsif (pulse xor tap_i (0)) = '1'
        and (restart_i = '1' or trigger = '0')
      then
        --  A pulse is detected
        --   and not yet triggered or restarted
        trigger <= '1';
        coarse_o <= std_logic_vector(unsigned(cur_cycles_i) - 2);
        fine_o <= std_logic_vector(to_unsigned(ffs (tap_i), 16));
      elsif restart_i = '1' then
        trigger <= '0';
      end if;
    end if;
  end process;

  trigger_o <= trigger;

end behav;
