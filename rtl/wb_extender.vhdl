-- Top-level with a wishbone bus
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;

entity wb_extender is
  port (
    --  Control
    clk_i : std_logic;

    --  Upstream
    up_rst_n_i : std_logic;
    up_bus_in : dev_bus_in;
    up_bus_out : out dev_bus_out;
    up_adr_i : std_logic_vector (4 downto 0);

    --  Downstream
    down_rst_n_o : out std_logic;
    down_bus_in : out dev_bus_in;
    down_bus_out : dev_bus_out;
    down_adr_o : out std_logic_vector (4 downto 0);

    --  Devices

    dev0_rst_n : out std_logic;
    dev0_bus_in : out dev_bus_in;
    dev0_bus_out : dev_bus_out;

    dev1_rst_n : out std_logic;
    dev1_bus_in : out dev_bus_in;
    dev1_bus_out : dev_bus_out;

    dev2_rst_n : out std_logic;
    dev2_bus_in : out dev_bus_in;
    dev2_bus_out : dev_bus_out;

    dev3_rst_n : out std_logic;
    dev3_bus_in : out dev_bus_in;
    dev3_bus_out : dev_bus_out);
end wb_extender;

architecture behav of wb_extender is
  signal ubus_in : dev_bus_in;
  signal ubus_out : dev_bus_out;
  signal uadr : std_logic_vector (4 downto 0);
  signal tfr : std_logic;
begin
  process (clk_i)
  begin
    if up_rst_n_i = '0' then
      ubus_in <= null_dev_bus_in;
      up_bus_out <= null_dev_bus_out;
      dev0_rst_n <= '0';
      dev1_rst_n <= '0';
      dev2_rst_n <= '0';
      dev3_rst_n <= '0';
      down_rst_n_o <= '0';
    elsif rising_edge(clk_i) then
      ubus_in <= up_bus_in;
      up_bus_out <= ubus_out;
      uadr <= up_adr_i;
      dev0_rst_n <= '1';
      dev1_rst_n <= '1';
      dev2_rst_n <= '1';
      dev3_rst_n <= '1';
      down_rst_n_o <= '1';
    end if;
  end process;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      dev0_bus_in <= null_dev_bus_in;
      dev1_bus_in <= null_dev_bus_in;
      dev2_bus_in <= null_dev_bus_in;
      dev3_bus_in <= null_dev_bus_in;
      down_bus_in <= null_dev_bus_in;
      ubus_out <= null_dev_bus_out;

      if up_rst_n_i = '0' then
        tfr <= '0';
      else
        if tfr = '1' or (ubus_in.we = '1' or ubus_in.re = '1') then
          --  Transfer in progress or start of a transfer.
          if uadr (4 downto 2) = "000" then
            case uadr (1 downto 0) is
              when "00" =>
                dev0_bus_in <= ubus_in;
                ubus_out <= dev0_bus_out;
                tfr <= not (dev0_bus_out.wack or dev0_bus_out.rack);
              when "01" =>
                dev1_bus_in <= ubus_in;
                ubus_out <= dev1_bus_out;
                tfr <= not (dev1_bus_out.wack or dev1_bus_out.rack);
              when "10" =>
                dev2_bus_in <= ubus_in;
                ubus_out <= dev2_bus_out;
                tfr <= not (dev2_bus_out.wack or dev2_bus_out.rack);
              when "11" =>
                dev3_bus_in <= ubus_in;
                ubus_out <= dev3_bus_out;
                tfr <= not (dev3_bus_out.wack or dev3_bus_out.rack);
              when others =>
                tfr <= '0';
            end case;
          else
            --  For downstream.
            down_bus_in <= ubus_in;
            ubus_out <= down_bus_out;
            down_adr_o <= std_logic_vector(unsigned(uadr) - "100");
            tfr <= not (down_bus_out.wack or down_bus_out.rack);
          end if;
        end if;
      end if;
    end if;
  end process;
end behav;
