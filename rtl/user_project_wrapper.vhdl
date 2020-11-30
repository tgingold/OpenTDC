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

entity user_project_wrapper is
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

    --  LA (Logic analyzer)
    user_clock2 : std_logic;
    la_data_in : std_logic_vector(127 downto 0);
    la_data_out : out std_logic_vector(127 downto 0);
    la_oen : std_logic_vector(127 downto 0);

    --  Unused
    analog_io : std_logic_vector(30 downto 0);

    --  Tdc input signals
    io_in : std_logic_vector(37 downto 0);

    --  Fd output signals
    io_out : out std_logic_vector(37 downto 0);

    --  Outputs enable
    io_oeb : out std_logic_vector(37 downto 0));
end user_project_wrapper;

architecture behav of user_project_wrapper is
  --  Config (not generics to keep the same name).
  --  XX_MACROS is the number of hard macros in XX
  constant NTDC : natural := 2;
  constant NFD : natural := 3;

  constant FTDC : natural := 0;
  constant FFD : natural := NTDC;

  --  IO pad usage
  constant FIN : natural := 21;
  constant FOUT : natural := 12;

  --  TODO: add blackbox for direct binding in ghdl.

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

      --  Downstream interface
      down_rst_n_o : out std_logic;
      down_bus_in : out dev_bus_in;
      down_bus_out : dev_bus_out;
      down_adr_o : out std_logic_vector (4 downto 0);

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

  component wb_extender is
    port (
      clk_i        :     std_logic;
      up_rst_n_i   :     std_logic;
      up_bus_in    :     dev_bus_in;
      up_bus_out   : out dev_bus_out;
      up_adr_i     :     std_logic_vector (4 downto 0);
      down_rst_n_o : out std_logic;
      down_bus_in : out dev_bus_in;
      down_bus_out : dev_bus_out;
      down_adr_o : out std_logic_vector (4 downto 0);
      dev0_rst_n   : out std_logic;
      dev0_bus_in  : out dev_bus_in;
      dev0_bus_out :     dev_bus_out;
      dev1_rst_n   : out std_logic;
      dev1_bus_in  : out dev_bus_in;
      dev1_bus_out :     dev_bus_out;
      dev2_rst_n   : out std_logic;
      dev2_bus_in  : out dev_bus_in;
      dev2_bus_out :     dev_bus_out;
      dev3_rst_n   : out std_logic;
      dev3_bus_in  : out dev_bus_in;
      dev3_bus_out :     dev_bus_out);
  end component wb_extender;

  component zero is
    port (e_o : out std_logic_vector(11 downto 0);
          n_o : out std_logic;
          n1_o : out std_logic;
          s_o, w_o : out std_logic;
          clk_i : std_logic;
          clk_o : out std_logic_vector(3 downto 0));
  end component;

  component rescue_top is
    port (
      clk_i : std_logic;
      la_data_in : std_logic_vector(127 downto 0);
      la_data_out : out std_logic_vector(127 downto 0);
      la_oen : std_logic_vector(127 downto 0);

      tdc_inp_i : std_logic;
      fd_out_o : out std_logic;
      fd_oen_o : out std_logic);
  end component;

  signal tdc_bus_in: dev_in_array (NTDC downto 1);
  signal tdc_bus_out: dev_out_array (NTDC downto 1);
  signal tdc_rst_n : std_logic_vector (NTDC downto 1);

  signal fd_bus_in: dev_in_array (NFD downto 1);
  signal fd_bus_out: dev_out_array (NFD downto 1);
  signal fd_rst_n : std_logic_vector (NFD downto 1);

  signal down0_rst_n : std_logic;
  signal down0_bus_in : dev_bus_in;
  signal down0_bus_out : dev_bus_out;
  signal down0_adr : std_logic_vector (4 downto 0);

  signal down2_rst_n : std_logic;
  signal down2_bus_in : dev_bus_in;
  signal down2_bus_out : dev_bus_out;
  signal down2_adr : std_logic_vector (4 downto 0);

  signal down3_rst_n : std_logic;
  signal down3_bus_in : dev_bus_in;
  signal down3_bus_out : dev_bus_out;
  signal down3_adr : std_logic_vector (4 downto 0);

  signal down4_rst_n : std_logic;
  signal down4_bus_in : dev_bus_in;
  signal down4_bus_out : dev_bus_out;
  signal down4_adr : std_logic_vector (4 downto 0);

  signal lp_data : std_logic_vector (31 downto 0);

  signal rst_time_n : std_logic;

  signal itf2_bus_rst_n : std_logic_vector(3 downto 0);
  signal itf2_bus_in: dev_in_array (3 downto 0);
  signal itf2_bus_out: dev_out_array (3 downto 0);

  signal itf3_bus_rst_n : std_logic_vector(3 downto 0);
  signal itf3_bus_in: dev_in_array (3 downto 0);
  signal itf3_bus_out: dev_out_array (3 downto 0);

  signal itf4_bus_rst_n : std_logic_vector(3 downto 0);
  signal itf4_bus_in: dev_in_array (3 downto 0);
  signal itf4_bus_out: dev_out_array (3 downto 0);

  signal wio_out : std_logic_vector(37 downto 0);

  signal clk_b : std_logic_vector (3 downto 0);

  --  Cannot use gates in top-level (no rails).
  signal one : std_logic;
  signal gnd : std_logic;
begin
  rst_time_n <= io_in(37);

  i_itf0: wb_interface
    port map (
      wb_clk_i => clk_b(0),
      wb_rst_i => wb_rst_i,

      wbs_stb_i => wbs_stb_i,
      wbs_cyc_i => wbs_cyc_i,
      wbs_we_i  => wbs_we_i,
      wbs_sel_i => wbs_sel_i,
      wbs_dat_i => wbs_dat_i,
      wbs_adr_i => wbs_adr_i,
      wbs_ack_o => wbs_ack_o,
      wbs_dat_o => wbs_dat_o,

      down_rst_n_o => down0_rst_n,
      down_bus_in  => down0_bus_in,
      down_bus_out => down0_bus_out,
      down_adr_o   => down0_adr,

      tdc0_inp_i => io_in(31),

      tdc1_rst_n => tdc_rst_n(1),
      tdc1_bus_in => tdc_bus_in(1),
      tdc1_bus_out => tdc_bus_out(1),

      tdc2_rst_n => tdc_rst_n(2),
      tdc2_bus_in => tdc_bus_in(2),
      tdc2_bus_out => tdc_bus_out(2),

      fd0_out_o => wio_out(FOUT + 0),

      fd1_rst_n => fd_rst_n(1),
      fd1_bus_in => fd_bus_in(1),
      fd1_bus_out => fd_bus_out(1),

      fd2_rst_n => fd_rst_n(2),
      fd2_bus_in => fd_bus_in(2),
      fd2_bus_out => fd_bus_out(2),

      fd3_rst_n => fd_rst_n(3),
      fd3_bus_in => fd_bus_in(3),
      fd3_bus_out => fd_bus_out(3),

      oen_o => io_oeb (FOUT + 15 downto FOUT),

      rst_time_n_i => rst_time_n);


  i_tdc0_1: tdc_inline_1
    port map (
      clk_i => clk_b(0),
      rst_n_i => tdc_rst_n(1),
      bus_in => tdc_bus_in(1),
      bus_out => tdc_bus_out(1),
      inp_i => io_in(30));

  i_tdc0_2: tdc_inline_2
      port map (
        clk_i => clk_b(0),
        rst_n_i => tdc_rst_n(2),
        bus_in => tdc_bus_in(2),
        bus_out => tdc_bus_out(2),
        inp_i => io_in(29));

  --  fd1: macro (fd_hd)
  i_fd0_1: fd_hd
    port map (
      clk_i => clk_b(0),
      rst_n_i => fd_rst_n(1),
      bus_in => fd_bus_in(1),
      bus_out => fd_bus_out(1),
      out1_o => wio_out(FOUT + 1),
      out2_o => wio_out(FOUT + 2));

  --  fd2: macro (fd_hs)
  i_fd0_2: fd_hs
    port map (
      clk_i => clk_b(0),
      rst_n_i => fd_rst_n(2),
      bus_in => fd_bus_in(2),
      bus_out => fd_bus_out(2),
      out1_o => wio_out(FOUT + 3),
      out2_o => wio_out(FOUT + 4));

  --  fd3: macro (fd_ms)
  i_fd0_3: fd_ms
    port map (
      clk_i => clk_b(0),
      rst_n_i => fd_rst_n(3),
      bus_in => fd_bus_in(3),
      bus_out => fd_bus_out(3),
      out1_o => wio_out(FOUT + 5),
      out2_o => wio_out(FOUT + 6));

  --  Extender 2

  i_itf2 : wb_extender
    port map (
      clk_i => clk_b(1),
      up_rst_n_i => down0_rst_n,
      up_bus_in  => down0_bus_in,
      up_bus_out => down0_bus_out,
      up_adr_i   => down0_adr,

      down_rst_n_o => down2_rst_n,
      down_bus_in  => down2_bus_in,
      down_bus_out => down2_bus_out,
      down_adr_o   => down2_adr,

      dev0_rst_n   => itf2_bus_rst_n(0),
      dev0_bus_in  => itf2_bus_in(0),
      dev0_bus_out => itf2_bus_out(0),

      dev1_rst_n   => itf2_bus_rst_n(1),
      dev1_bus_in  => itf2_bus_in(1),
      dev1_bus_out => itf2_bus_out(1),

      dev2_rst_n   => itf2_bus_rst_n(2),
      dev2_bus_in  => itf2_bus_in(2),
      dev2_bus_out => itf2_bus_out(2),

      dev3_rst_n   => itf2_bus_rst_n(3),
      dev3_bus_in  => itf2_bus_in(3),
      dev3_bus_out => itf2_bus_out(3));


  i_tdc2_0: tdc_inline_3
    port map (
      clk_i => clk_b(1),
      rst_n_i => itf2_bus_rst_n(0),
      bus_in => itf2_bus_in(0),
      bus_out => itf2_bus_out(0),
      inp_i => io_in(28));

  i_tdc2_1: tdc_inline_3
    port map (
      clk_i => clk_b(1),
      rst_n_i => itf2_bus_rst_n(1),
      bus_in => itf2_bus_in(1),
      bus_out => itf2_bus_out(1),
      inp_i => io_in(27));

  i_fd2_2: fd_inline_1
    port map (
      clk_i => clk_b(1),
      rst_n_i => itf2_bus_rst_n(2),
      bus_in  => itf2_bus_in(2),
      bus_out => itf2_bus_out(2),
      out_o  => wio_out(FOUT + 7));

  i_fd2_3: fd_hd_25_1
    port map (
      clk_i => clk_b(1),
      rst_n_i => itf2_bus_rst_n(3),
      bus_in => itf2_bus_in(3),
      bus_out => itf2_bus_out(3),
      out_o => wio_out(FOUT + 8));

  --  Extender 3

  i_itf3 : wb_extender
    port map (
      clk_i => clk_b(2),
      up_rst_n_i => down2_rst_n,
      up_bus_in  => down2_bus_in,
      up_bus_out => down2_bus_out,
      up_adr_i   => down2_adr,

      down_rst_n_o => down3_rst_n,
      down_bus_in  => down3_bus_in,
      down_bus_out => down3_bus_out,
      down_adr_o   => down3_adr,

      dev0_rst_n   => itf3_bus_rst_n(0),
      dev0_bus_in  => itf3_bus_in(0),
      dev0_bus_out => itf3_bus_out(0),

      dev1_rst_n   => itf3_bus_rst_n(1),
      dev1_bus_in  => itf3_bus_in(1),
      dev1_bus_out => itf3_bus_out(1),

      dev2_rst_n   => itf3_bus_rst_n(2),
      dev2_bus_in  => itf3_bus_in(2),
      dev2_bus_out => itf3_bus_out(2),

      dev3_rst_n   => itf3_bus_rst_n(3),
      dev3_bus_in  => itf3_bus_in(3),
      dev3_bus_out => itf3_bus_out(3));


  i_tdc3_0: tdc_inline_1
    port map (
      clk_i => clk_b(2),
      rst_n_i => itf3_bus_rst_n(0),
      bus_in  => itf3_bus_in(0),
      bus_out => itf3_bus_out(0),
      inp_i   => io_in(26));

  i_tdc3_1: tdc_inline_3
    port map (
      clk_i => clk_b(2),
      rst_n_i => itf3_bus_rst_n(1),
      bus_in  => itf3_bus_in(1),
      bus_out => itf3_bus_out(1),
      inp_i   => io_in(25));

  i_fd3_2: fd_hs
    port map (
      clk_i => clk_b(2),
      rst_n_i => itf3_bus_rst_n(2),
      bus_in  => itf3_bus_in(2),
      bus_out => itf3_bus_out(2),
      out1_o  => wio_out(FOUT + 9),
      out2_o  => wio_out(FOUT + 10));

  i_fd3_3: fd_hd_25_1
    port map (
      clk_i => clk_b(2),
      rst_n_i => itf3_bus_rst_n(3),
      bus_in  => itf3_bus_in(3),
      bus_out => itf3_bus_out(3),
      out_o   => wio_out(FOUT + 11));

  --  Extender 4

  i_itf4 : wb_extender
    port map (
      clk_i => clk_b(3),
      up_rst_n_i => down3_rst_n,
      up_bus_in  => down3_bus_in,
      up_bus_out => down3_bus_out,
      up_adr_i   => down3_adr,

      down_rst_n_o => down4_rst_n,
      down_bus_in  => down4_bus_in,
      down_bus_out => down4_bus_out,
      down_adr_o   => down4_adr,

      dev0_rst_n   => itf4_bus_rst_n(0),
      dev0_bus_in  => itf4_bus_in(0),
      dev0_bus_out => itf4_bus_out(0),

      dev1_rst_n   => itf4_bus_rst_n(1),
      dev1_bus_in  => itf4_bus_in(1),
      dev1_bus_out => itf4_bus_out(1),

      dev2_rst_n   => itf4_bus_rst_n(2),
      dev2_bus_in  => itf4_bus_in(2),
      dev2_bus_out => itf4_bus_out(2),

      dev3_rst_n   => itf4_bus_rst_n(3),
      dev3_bus_in  => itf4_bus_in(3),
      dev3_bus_out => itf4_bus_out(3));


  i_tdc4_0: tdc_inline_2
    port map (
      clk_i => clk_b(3),
      rst_n_i => itf4_bus_rst_n(0),
      bus_in  => itf4_bus_in(0),
      bus_out => itf4_bus_out(0),
      inp_i   => io_in(24));

  i_tdc4_1: tdc_inline_3
    port map (
      clk_i => clk_b(3),
      rst_n_i => itf4_bus_rst_n(1),
      bus_in  => itf4_bus_in(1),
      bus_out => itf4_bus_out(1),
      inp_i   => io_in(23));

  i_fd4_2: fd_ms
    port map (
      clk_i => clk_b(2),
      rst_n_i => itf4_bus_rst_n(2),
      bus_in  => itf4_bus_in(2),
      bus_out => itf4_bus_out(2),
      out1_o   => wio_out(FOUT + 12),
      out2_o   => wio_out(FOUT + 13));

  i_fd4_3: fd_hd_25_1
    port map (
      clk_i => clk_b(3),
      rst_n_i => itf4_bus_rst_n(3),
      bus_in  => itf4_bus_in(3),
      bus_out => itf4_bus_out(3),
      out_o   => wio_out(FOUT + 14));

  --  Loop to avoid freeze
  lp_data <= (others => one);

  down4_bus_out <= (dato => lp_data,
                    wack => down4_bus_in.we,
                    rack => down4_bus_in.re,
                    trig => gnd);

  inst_rescue: rescue_top
    port map (
      clk_i => user_clock2,
      la_data_in => la_data_in,
      la_data_out => la_data_out,
      la_oen => la_oen,

      tdc_inp_i => io_in(12),
      fd_out_o => wio_out (FOUT + 16),
      fd_oen_o => io_oeb (FOUT + 16));

  b_zero: block
    signal z_n, z_s, z_e, z_w : std_logic;
  begin
    i_zero: zero
      port map (
        n_o => z_n,
        n1_o => one,
        s_o => z_s,
        e_o => io_oeb(FOUT - 1 downto 0),
        w_o => z_w,
        clk_i => wb_clk_i,
        clk_o => clk_b);

    gnd <= z_n;
    wio_out (FOUT - 1 downto 0) <= (others => z_s);
    wio_out (FOUT + 15 downto FOUT + 15) <= (others => z_n);
    wio_out (wio_out'left downto FOUT + 17) <= (others => z_w);
    io_out <= wio_out;
    io_oeb (37 downto FOUT + 17) <= (others => z_w);
  end block;
end behav;
