-- Delay element for sky130
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

architecture sky130 of opentdc_delay is
  --  This is a generic name, to be replaced by the sky130 delay cell.
  --  (You could use this yosys command: chtype -map sky130_delay gatename)
  component sky130_delay is
    port (X : out std_logic;
          A : in std_logic);
  end component;

  component \sky130_fd_sc_hd__clkbuf_1\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkbuf_2\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkbuf_4\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s15_1\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s15_2\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s18_1\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s18_2\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s25_1\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s25_2\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s50_1\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

  component \sky130_fd_sc_hd__clkdlybuf4s50_2\ is
    port (\X\ : out std_logic;
          \A\ : in std_logic);    
  end component;

begin
  g_any: if cell = 99 generate
    dly: sky130_delay
      port map (out_o, inp_i);
  end generate;

  g_clkbuf_1: if cell = 1 generate
    dly: \sky130_fd_sc_hd__clkbuf_1\
      port map (out_o, inp_i);
  end generate;

  g_clkbuf_2: if cell = 2 generate
    dly: \sky130_fd_sc_hd__clkbuf_2\
      port map (out_o, inp_i);
  end generate;

  g_clkbuf_4: if cell = 3 generate
    dly: \sky130_fd_sc_hd__clkbuf_4\
      port map (out_o, inp_i);
  end generate;

  g_clkdly15_1: if cell = 4 or cell = 0 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s15_1\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly15_2: if cell = 5 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s15_2\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly18_1: if cell = 6 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s18_1\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly18_2: if cell = 7 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s18_2\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly25_1: if cell = 8 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s25_1\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly25_2: if cell = 9 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s25_2\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly50_1: if cell = 10 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s50_1\
      port map (out_o, inp_i);
  end generate;
  
  g_clkdly50_2: if cell = 11 generate
    dly: \sky130_fd_sc_hd__clkdlybuf4s50_2\
      port map (out_o, inp_i);
  end generate;
end sky130;
