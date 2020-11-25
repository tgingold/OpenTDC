-- Testbench for opentdc_wb
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_proj is
end tb_proj;

architecture behav of tb_proj is
  constant cycle : time := 20 ns; --  50 Mhz

  signal wb_clk     : std_logic := '1';
  signal wb_rst     : std_logic;

  type wb32_master_out is record
    stb    : std_logic;
    cyc    : std_logic;
    we     : std_logic;
    sel    : std_logic_vector(3 downto 0);
    adr    : std_logic_vector(31 downto 0);
    dato   : std_logic_vector(31 downto 0);
  end record;

  type wb32_master_in is record
    dati   : std_logic_vector(31 downto 0);
    ack    : std_logic;
  end record;

  signal wbs_out : wb32_master_out;
  signal wbs_in  : wb32_master_in;

  signal inps : std_logic_vector(15 downto 0);
  signal outs : std_logic_vector(15 downto 0);

  alias inp1 : std_logic is inps (0);
  alias inp2 : std_logic is inps (1);
  alias out0 : std_logic is outs (0);

  signal rst_time_n : std_logic;

  signal fd0_time : time;

  signal done : std_logic := '0';

  procedure wb32_write32 (signal clk : std_logic;
                          signal wb_out : out wb32_master_out;
                          signal wb_in  : in  wb32_master_in;
                          addr : std_logic_vector(31 downto 0);
                          dat  : std_logic_vector(31 downto 0);
                          sel : std_logic_vector(3 downto 0) := "1111") is
  begin
    wb_out.cyc <= '1';
    wb_out.stb <= '1';
    wb_out.we <= '1';
    wb_out.sel <= sel;
    wb_out.adr <= addr;
    wb_out.dato <= dat;
    loop
      wait until rising_edge(clk);
      exit when wb_in.ack = '1';
    end loop;
    wb_out.cyc <= '0';
    wb_out.stb <= '0';
    wait until rising_edge(clk);
  end wb32_write32;

  procedure wb32_read32 (signal clk : std_logic;
                          signal wb_out : out wb32_master_out;
                          signal wb_in  : in  wb32_master_in;
                          addr : std_logic_vector(31 downto 0);
                          dat  : out std_logic_vector(31 downto 0)) is
  begin
    wb_out.cyc <= '1';
    wb_out.stb <= '1';
    wb_out.we <= '0';
    wb_out.sel <= "1111";
    wb_out.adr <= addr;
    loop
      wait until rising_edge(clk);
      exit when wb_in.ack = '1';
    end loop;
    dat := wb_in.dati;
    wb_out.cyc <= '0';
    wb_out.stb <= '0';
    wait until rising_edge(clk);
  end wb32_read32;
begin
  inps (inps'left downto 2) <= (others => '0');

  process
  begin
    --  Important: start at level 1, so that a rising_edge happen every
    --  CYCLE.
    wait for cycle / 2;
    wb_clk <= not wb_clk;
    if done = '1' then
      wait;
    end if;
  end process;

  wb_rst <= '1', '0' after 2 * cycle + cycle / 2;

  process (out0)
  begin
    fd0_time <= now;
  end process;

  process
    variable d32, d32_a : std_logic_vector (31 downto 0);
    variable fd0 : std_logic_vector (31 downto 0);
    variable ncycles : natural;
    variable ndelays : natural;
  begin
    done <= '0';

    rst_time_n <= '1';
    inp1 <= '0';
    inp2 <= '0';
    wbs_out.cyc <= '0';

    --  Wait until end of reset.
    loop
      wait until rising_edge(wb_clk);
      exit when wb_rst = '0';
    end loop;

    --  Read id
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0000", d32);
    assert d32 = x"54_64_63_01" report "(1) bad opentdc id" severity failure;

    --  Compute fd0 address
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_001c", d32);
    report "Nbr TDCs: " & natural'image(to_integer(unsigned(d32(23 downto 16))));
    report "Nbr FDs: " & natural'image(to_integer(unsigned(d32(31 downto 24))));
    fd0 := (31 downto 13 => '0') & std_logic_vector(unsigned(d32 (23 downto 16)) + 1) & b"000_00";

    --  Read cycles
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0004", d32);
    report "cycles=" & to_hstring(d32) & ", now=" & natural'image(now / cycle);
    assert unsigned(d32) < 18 report "(2) bad cycle value" severity failure;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0004", d32_a);
    assert unsigned(d32_a) > unsigned(d32)
      report "(3) cycles not increased" severity failure;

    --  Check status
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0008", d32);
    --  report "status=" & to_hstring(d32);
    assert (d32 and x"0000_0003") = x"0000_0000" report "(4) bad status" severity failure;

    --  Start tdc 0 and 1 (set restart bits).
    wb32_write32 (wb_clk, wbs_out, wbs_in, x"0000_0020", x"0005_0100");
    wb32_write32 (wb_clk, wbs_out, wbs_in, x"0000_0040", x"0305_0300");

    --  Trigger pulses.
    wait for 1130 ps;
    inp1 <= '1';
    wait until rising_edge(wb_clk);
    wait for 1530 ps;
    inp2 <= '1';
    wait until rising_edge(wb_clk);

    for i in 1 to 3 loop
      wait until rising_edge(wb_clk);
    end loop;

    --  Read status
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0008", d32);
    assert d32(1) = '1' report "(5) bad status" severity failure;

    --  Read tdc0
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0028", d32);
    report "tdc0 coarse=" & to_hstring(d32);
    d32_a := d32;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_002c", d32);
    report "tdc0 fine=" & natural'image(to_integer(unsigned(d32)));
    assert unsigned(d32) = 200 - 12
      report "(7) bad fine value for tdc0" severity failure;

    --  Read tdc1
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0048", d32);
    report "tdc1 coarse=" & to_hstring(d32);
    assert unsigned(d32) = unsigned (d32_a) + 1
      report "(8) bad coarse value" severity failure;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_004c", d32);
    report "tdc1 fine=" & natural'image(to_integer(unsigned(d32)));
    assert unsigned(d32) = 200 - 16
      report "(9) bad fine value for tdc1" severity failure;

    --  Read tdc1/ref
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0040", d32);
    assert (d32 and x"0003_0001") = x"0001_0001"
      report "(10) bad tdc1 status" severity failure;
    report "tdc1 status=" & to_hstring(d32);
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0044", d32);
    if false then --  No ref
    report "tdc1 ref=" & to_hstring(d32);
    assert unsigned(d32 (15 downto 0)) = 200 - 1
      report "(11) bad tdc1 ref fine time" severity failure;
    assert unsigned(d32 (31 downto 0)) > 10
      report "(12) bad tdc1 ref time" severity failure;
    end if;

    --  Read tdc1/scan
    for i in 0 to 4 loop  -- 5*32 = 160
      wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0050", d32);
      assert d32 = std_logic_vector(to_unsigned(i, 32))
        report "(13) bad tdc2 scan pos #" & natural'image(i) severity failure;
      wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0054", d32);
      assert d32 = x"ffff_ffff"
        report "(14) bad tdc2 scan val #" & natural'image(i) severity failure;
    end loop;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0050", d32);
    assert d32 = x"0000_0005"
      report "(15) bad tdc2 scan pos #5" severity failure;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0054", d32);
    assert d32 = x"01ff_ffff"
      report "(16) bad tdc2 scan val #5" severity failure;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0050", d32);
    assert d32 = x"0000_0006"
      report "(17) bad tdc2 scan pos #6" severity failure;
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0054", d32);
    assert d32 = x"0000_0000"
      report "(18) bad tdc2 scan val #6" severity failure;
    
    --  Program fd0.
    wb32_write32 (wb_clk, wbs_out, wbs_in, fd0 or x"0000_000c", x"0000_0027");
    d32 := std_logic_vector(to_unsigned(now / 20 ns, 32) + 7);
    wb32_write32 (wb_clk, wbs_out, wbs_in, fd0 or x"0000_0008", d32);
--  wb32_write32 (wb_clk, wbs_out, wbs_in, x"0000_000c", x"0001_0000", "1100");

    --  Check busy status (before the trigger).
    wb32_read32 (wb_clk, wbs_out, wbs_in, fd0 or x"0000_0000", d32_a);
    assert d32_a = x"0000_0001"
      report "(19) bad busy value for fd0" severity failure;

    wait on fd0_time for 5 * cycle;
    wait until rising_edge(wb_clk);
    ncycles := fd0_time / cycle;
    ndelays := (fd0_time - ncycles * cycle) / 100 ps;
    report "fd0 time=" & time'image(fd0_time);
    report "ncycles=" & natural'image(ncycles)
      & ", ndelays=" & natural'image(ndelays);
    report "fd0 coarse=" & to_hstring(d32) & "=" & natural'image(to_integer(unsigned(d32)));

    --  cur_cycle start when now = 2 cycles
    assert ncycles = to_integer(unsigned(d32) + 10)
      report "(20) bad coarse time for fd0" severity failure;
    assert ndelays = 39
      report "(21) bad fine time for fd0" severity failure;

    --  Check busy status (before the trigger).
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0008", d32_a);
    assert d32_a(16) = '0'
      report "(22) bad busy value for fd0" severity failure;

    --  Check register access
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0018", d32);
    assert d32 = x"10_20_30_40"
      report "(40) bad init value for areg" severity failure;
    wb32_write32 (wb_clk, wbs_out, wbs_in, x"0000_0018", x"01_02_03_04");

    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0000", d32);
    assert d32 = x"54_64_63_01" report "(40.1) bad opentdc id" severity failure;

    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0018", d32);
    assert d32 = x"01_02_03_04"
      report "(40.2) bad write value for areg" severity failure;

    wb32_write32 (wb_clk, wbs_out, wbs_in,
                  x"0000_0018", x"aa_21_bb_cc", "0100");
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0018", d32);
    assert d32 = x"01_21_03_04"
      report "(40.3) bad partial write value for areg" severity failure;

    --  OK
    report "Test OK" severity note;
    done <= '1';
    wait;
  end process;

  --  WB driver
  opentdc_wb_1: entity work.opentdc_wb
    port map (
      wb_clk_i     => wb_clk,
      wb_rst_i     => wb_rst,
      wbs_stb_i    => wbs_out.stb,
      wbs_cyc_i    => wbs_out.cyc,
      wbs_we_i     => wbs_out.we,
      wbs_sel_i    => wbs_out.sel,
      wbs_dat_i    => wbs_out.dato,
      wbs_adr_i    => wbs_out.adr,
      wbs_ack_o    => wbs_in.ack,
      wbs_dat_o    => wbs_in.dati,
      inp_i        => inps,
      out_o        => outs,
      rst_time_n_i => rst_time_n);
end behav;
