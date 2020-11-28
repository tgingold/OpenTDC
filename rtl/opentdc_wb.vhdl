-- Top-level with a wishbone bus
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opentdc_pkg.all;
use work.opentdc_comps.all;
use work.openfd_comps.all;

entity opentdc_wb is
  port (
    --  Control
    wb_clk_i : std_logic;
    wb_rst_i : std_logic;

    --  Wishbone
    wbs_stb_i : in  std_logic;
    wbs_cyc_i : in  std_logic;
    wbs_we_i  : in  std_logic;
    wbs_sel_i : in  std_logic_vector(3 downto 0);
    wbs_dat_i : in  std_logic_vector(31 downto 0);
    wbs_adr_i : in  std_logic_vector(31 downto 0);
    wbs_ack_o : out std_logic;
    wbs_dat_o : out std_logic_vector(31 downto 0);

    --  Tdc input signals
    inp_i : std_logic_vector(15 downto 0);

    --  Fd output signals
    out_o : out std_logic_vector(15 downto 0);

    --  Outputs enable
    oen_o : out std_logic_vector(15 downto 0);

    rst_time_n_i : std_logic);
end opentdc_wb;

architecture behav of opentdc_wb is
  --  Config (not generics to keep the same name).
  --  XX_MACROS is the number of hard macros in XX
  constant NTDC : natural := 2;
  constant NFD : natural := 3;

  constant FTDC : natural := 0;
  constant FFD : natural := NTDC;

  component wb_interface is
    port (
      --  Control
      wb_clk_i : std_logic;
      wb_rst_i : std_logic;

      --  Wishbone
      wbs_stb_i : in  std_logic;
      wbs_cyc_i : in  std_logic;
      wbs_we_i  : in  std_logic;
      wbs_sel_i : in  std_logic_vector(3 downto 0);
      wbs_dat_i : in  std_logic_vector(31 downto 0);
      wbs_adr_i : in  std_logic_vector(31 downto 0);
      wbs_ack_o : out std_logic;
      wbs_dat_o : out std_logic_vector(31 downto 0);

      --  TDCs
      
      tdc0_inp_i : std_logic;
      
      tdc1_rst_n : out std_logic;
      tdc1_bus_in : out dev_bus_in;
      tdc1_bus_out : dev_bus_out;

      tdc2_rst_n : out std_logic;
      tdc2_bus_in : out dev_bus_in;
      tdc2_bus_out : dev_bus_out;

      --  FDs
      fd0_out_o : out std_logic;
      
      fd1_rst_n : out std_logic;
      fd1_bus_in : out dev_bus_in;
      fd1_bus_out : dev_bus_out;

      fd2_rst_n : out std_logic;
      fd2_bus_in : out dev_bus_in;
      fd2_bus_out : dev_bus_out;

      fd3_rst_n : out std_logic;
      fd3_bus_in : out dev_bus_in;
      fd3_bus_out : dev_bus_out;

      --  Outputs enable
      oen_o : out std_logic_vector(15 downto 0);

      rst_time_n_i : std_logic);
  end component;

  component zero is
    port (e_o, n_o, s_o, w_o : out std_logic);
  end component;
  
  signal tdc_bus_in: dev_in_array (NTDC downto 1);
  signal tdc_bus_out: dev_out_array (NTDC downto 1);
  signal tdc_rst_n : std_logic_vector (NTDC downto 1);
  
  signal fd_bus_in: dev_in_array (NFD downto 1);
  signal fd_bus_out: dev_out_array (NFD downto 1);
  signal fd_rst_n : std_logic_vector (NFD downto 1);

begin
  i_itf: wb_interface
    port map (
      wb_clk_i => wb_clk_i,
      wb_rst_i => wb_rst_i,

      wbs_stb_i => wbs_stb_i,
      wbs_cyc_i => wbs_cyc_i,
      wbs_we_i  => wbs_we_i,
      wbs_sel_i => wbs_sel_i,
      wbs_dat_i => wbs_dat_i,
      wbs_adr_i => wbs_adr_i,
      wbs_ack_o => wbs_ack_o,
      wbs_dat_o => wbs_dat_o,

      tdc0_inp_i => inp_i(0),
    
      tdc1_rst_n => tdc_rst_n(1),
      tdc1_bus_in => tdc_bus_in(1),
      tdc1_bus_out => tdc_bus_out(1),

      tdc2_rst_n => tdc_rst_n(2),
      tdc2_bus_in => tdc_bus_in(2),
      tdc2_bus_out => tdc_bus_out(2),

      fd0_out_o => out_o(0),
    
      fd1_rst_n => fd_rst_n(1),
      fd1_bus_in => fd_bus_in(1),
      fd1_bus_out => fd_bus_out(1),

      fd2_rst_n => fd_rst_n(2),
      fd2_bus_in => fd_bus_in(2),
      fd2_bus_out => fd_bus_out(2),

      fd3_rst_n => fd_rst_n(3),
      fd3_bus_in => fd_bus_in(3),
      fd3_bus_out => fd_bus_out(3),

      oen_o => oen_o,

      rst_time_n_i => rst_time_n_i);


  i_tdc1: tdc_inline_1
    port map (
      clk_i => wb_clk_i,
      rst_n_i => tdc_rst_n(1),
      bus_in => tdc_bus_in(1),
      bus_out => tdc_bus_out(1),
      inp_i => inp_i(1));
  
  i_tdc2: tdc_inline_2
      port map (
        clk_i => wb_clk_i,
        rst_n_i => tdc_rst_n(2),
        bus_in => tdc_bus_in(2),
        bus_out => tdc_bus_out(2),
        inp_i => inp_i(2));
  
  --  fd1: macro (fd_hd)
  i_fd1: fd_hd
    port map (
      clk_i => wb_clk_i,
      rst_n_i => fd_rst_n(1),
      bus_in => fd_bus_in(1),
      bus_out => fd_bus_out(1),
      out1_o => out_o(1),
      out2_o => out_o(2));

  --  fd2: macro (fd_hs)
  i_fd2: fd_hs
    port map (
      clk_i => wb_clk_i,
      rst_n_i => fd_rst_n(2),
      bus_in => fd_bus_in(2),
      bus_out => fd_bus_out(2),
      out1_o => out_o(3),
      out2_o => out_o(4));

  --  fd3: macro (fd_ms)
  i_fd3: fd_hs
    port map (
      clk_i => wb_clk_i,
      rst_n_i => fd_rst_n(3),
      bus_in => fd_bus_in(3),
      bus_out => fd_bus_out(3),
      out1_o => out_o(5),
      out2_o => out_o(6));

  b_zero: block
    signal z_n, z_s, z_e, z_w : std_logic;
  begin
    i_zero: zero
      port map (
        n_o => z_n,
        s_o => z_s,
        e_o => z_e,
        w_o => z_w);
    
    out_o (15 downto 7) <= (others => z_w);
  end block;
end behav;
