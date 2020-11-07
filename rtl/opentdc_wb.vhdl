library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    inp0_i : std_logic;
    inp1_i : std_logic;

    --  Fd output signals
    out0_o : out std_logic;

    rst_time_n_i : std_logic);
end opentdc_wb;

architecture behav of opentdc_wb is
  --  Regs for the bus interface.
  signal b_idle : std_logic;

  signal rst_n : std_logic;

  signal wb_ack : std_logic;

  signal cur_cycles : std_logic_vector(31 downto 0);

  type tdc_rec is record
    trigger : std_logic;
    restart : std_logic;
    coarse : std_logic_vector(31 downto 0);
    fine : std_logic_vector(15 downto 0);
  end record;

  --  TDCs
  signal tdc0, tdc1, tdcr : tdc_rec;
    
  --  fd0
  signal fd0_coarse : std_logic_vector(31 downto 0);
  signal fd0_fine   : std_logic_vector(15 downto 0);
  signal fd0_valid  : std_logic;
  signal fd0_busy  : std_logic;
begin
  rst_n <= not wb_rst_i;

  --  Wishbone slave.
  wbs_ack_o <= wb_ack;

  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      --  Restart is a pulse.
      tdc0.restart <= '0';
      tdc1.restart <= '0';
      tdcr.restart <= '0';

      if rst_n = '0' then
        wb_ack <= '0';
      else
        if wb_ack = '1' then
          --  Negate ack after one clock
          wb_ack <= '0';
        elsif wbs_stb_i = '1' and wbs_cyc_i = '1' then
          --  Start of a transaction
          wbs_dat_o <= x"00_00_00_00";
          case wbs_adr_i (9 downto 2) is
            when x"00" =>
              --  Id
              wbs_dat_o <= x"54_64_63_01";  -- 'Tdc\1'
            when x"01" =>
              wbs_dat_o <= cur_cycles;

            when x"02" =>
              -- status.
              wbs_dat_o (0) <= tdc0.trigger;
              wbs_dat_o (1) <= tdc1.trigger;
              wbs_dat_o (7) <= tdcr.trigger;
              wbs_dat_o (16) <= fd0_busy;
            when x"03" =>
              -- control.
              if wbs_we_i = '1' and wbs_sel_i (0) = '1' then
                tdc0.restart <= wbs_dat_i (0);
                tdc1.restart <= wbs_dat_i (1);
                tdcr.restart <= wbs_dat_i (7);
              end if;
              if wbs_we_i = '1' and wbs_sel_i (2) = '1' then
                fd0_valid <= wbs_dat_i (16);
              end if;
            when x"04" =>
              wbs_dat_o <= tdc0.coarse;
            when x"05" =>
              wbs_dat_o <= x"00_00" & tdc0.fine;

            when x"06" =>
              wbs_dat_o <= tdc1.coarse;
            when x"07" =>
              wbs_dat_o <= x"00_00" & tdc1.fine;

            when x"0e" =>
              wbs_dat_o <= tdcr.coarse;
            when x"0f" =>
              wbs_dat_o <= x"00_00" & tdcr.fine;

            when x"10" =>
              wbs_dat_o <= fd0_coarse;
              if wbs_we_i = '1' then
                fd0_coarse <= wbs_dat_i;
              end if;
            when x"11" =>
              wbs_dat_o (15 downto 0) <= fd0_fine;
              if wbs_we_i = '1' then
                fd0_fine <= wbs_dat_i(15 downto 0);
              end if;
            when others =>
              report "unhandled address";
              null;
          end case;
          wb_ack <= '1';
        end if;
      end if;
    end if;
  end process;

  --  Time counter.
  process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if rst_time_n_i = '0' or rst_n = '0' then
        cur_cycles <= (others => '0');
      else
        cur_cycles <= std_logic_vector(unsigned(cur_cycles) + 1);
      end if;
    end if;
  end process;

  --  TDC 0
  i_tdc0: entity work.opentdc_core
    generic map (
      length => 200)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      restart_i => tdc0.restart,
      inp_i => inp0_i,
      trigger_o => tdc0.trigger,
      coarse_o => tdc0.coarse,
      fine_o => tdc0.fine);

  --  TDC 1
  i_tdc1: entity work.opentdc_core
    generic map (
      length => 200)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      restart_i => tdc1.restart,
      inp_i => inp1_i,
      trigger_o => tdc1.trigger,
      coarse_o => tdc1.coarse,
      fine_o => tdc1.fine);

  --  TDC ref
  i_tdc_ref: entity work.opentdc_core
    generic map (
      length => 200)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      restart_i => tdcr.restart,
      inp_i => wb_clk_i,
      trigger_o => tdcr.trigger,
      coarse_o => tdcr.coarse,
      fine_o => tdcr.fine);

  --  FD0
  inst_fd0: entity work.openfd_core
    generic map (
      plen => 8)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      coarse_i     => fd0_coarse,
      fine_i       => fd0_fine,
      valid_i      => fd0_valid,
      busy_o       => fd0_busy,
      out_o        => out0_o);
end behav;
