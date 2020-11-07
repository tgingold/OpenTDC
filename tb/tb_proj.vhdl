library ieee;
use ieee.std_logic_1164.all;

entity tb_proj is
end tb_proj;

architecture behav of tb_proj is
  signal wb_clk     : std_logic := '0';
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
  
  signal inp0       : std_logic;
  signal inp1       : std_logic;
  signal rst_time_n : std_logic;

  signal done : std_logic := '0';
  
  procedure wb32_write32 (signal clk : std_logic;
                          signal wb_out : out wb32_master_out;
                          signal wb_in  : in  wb32_master_in;
                          addr : std_logic_vector(31 downto 0);
                          dat  : std_logic_vector(31 downto 0)) is
  begin
    wb_out.cyc <= '1';
    wb_out.stb <= '1';
    wb_out.we <= '1';
    wb_out.sel <= "1111";
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
  --  Assume 50 Mhz
  process
  begin
    wb_clk <= '0';
    wait for 10 ns;
    wb_clk <= '1';
    wait for 10 ns;
    if done = '1' then
      wait;
    end if;
  end process;

  wb_rst <= '1', '0' after 40 ns;

  process
    variable d32 : std_logic_vector (31 downto 0);
  begin
    done <= '0';
    
    rst_time_n <= '1';
    inp0 <= '0';
    inp1 <= '0';
    wbs_out.cyc <= '0';

    --  Wait until end of reset.
    loop
      wait until rising_edge(wb_clk);
      exit when wb_rst = '0';
    end loop;

    --  Read id
    wb32_read32 (wb_clk, wbs_out, wbs_in, x"0000_0000", d32);
    assert d32 = x"54_64_63_01" report "bad opentdc id" severity failure;

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
      inp0_i       => inp0,
      inp1_i       => inp1,
      rst_time_n_i => rst_time_n);
end behav;
