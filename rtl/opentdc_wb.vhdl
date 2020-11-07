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

    rst_time_n_i : std_logic);
end opentdc_wb;

architecture behav of opentdc_wb is
  --  Regs for the bus interface.
  signal b_idle : std_logic;

  signal rst_n : std_logic;

  signal wb_ack : std_logic;

  signal cur_cycles : std_logic_vector(31 downto 0);

  --  tdc0
  signal tdc0_trigger : std_logic;
  signal tdc0_restart : std_logic;
  signal tdc0_coarse : std_logic_vector(31 downto 0);
  signal tdc0_fine : std_logic_vector(15 downto 0);

  --  tdc1
  signal tdc1_trigger : std_logic;
  signal tdc1_restart : std_logic;
  signal tdc1_coarse : std_logic_vector(31 downto 0);
  signal tdc1_fine : std_logic_vector(15 downto 0);

  --  tdc ref
  signal tdcr_trigger : std_logic;
  signal tdcr_restart : std_logic;
  signal tdcr_coarse : std_logic_vector(31 downto 0);
  signal tdcr_fine : std_logic_vector(15 downto 0);
begin
  rst_n <= not wb_rst_i;

  --  Wishbone slave.
  wbs_ack_o <= wb_ack;

  process (wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then
      --  Restart is a pulse.
      tdc0_restart <= '0';
      tdc1_restart <= '0';
      tdcr_restart <= '0';

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
              wbs_dat_o (0) <= tdc0_trigger;
              wbs_dat_o (1) <= tdc1_trigger;
              wbs_dat_o (7) <= tdcr_trigger;
            when x"03" =>
              -- control.
              if wbs_we_i = '1' and wbs_sel_i (0) = '1' then
                tdc0_restart <= wbs_dat_i (0);
                tdc1_restart <= wbs_dat_i (1);
                tdcr_restart <= wbs_dat_i (7);
              end if;

            when x"04" =>
              wbs_dat_o <= tdc0_coarse;
            when x"05" =>
              wbs_dat_o <= x"00_00" & tdc0_fine;

            when x"06" =>
              wbs_dat_o <= tdc1_coarse;
            when x"07" =>
              wbs_dat_o <= x"00_00" & tdc1_fine;

            when x"0e" =>
              wbs_dat_o <= tdcr_coarse;
            when x"0f" =>
              wbs_dat_o <= x"00_00" & tdcr_fine;
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
      restart_i => tdc0_restart,
      inp_i => inp0_i,
      trigger_o => tdc0_trigger,
      coarse_o => tdc0_coarse,
      fine_o => tdc0_fine);

  --  TDC 1
  i_tdc1: entity work.opentdc_core
    generic map (
      length => 200)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      restart_i => tdc1_restart,
      inp_i => inp1_i,
      trigger_o => tdc1_trigger,
      coarse_o => tdc1_coarse,
      fine_o => tdc1_fine);

  --  TDC ref
  i_tdc_ref: entity work.opentdc_core
    generic map (
      length => 200)
    port map (
      clk_i => wb_clk_i,
      rst_n_i => rst_n,
      cur_cycles_i => cur_cycles,
      restart_i => tdcr_restart,
      inp_i => wb_clk_i,
      trigger_o => tdcr_trigger,
      coarse_o => tdcr_coarse,
      fine_o => tdcr_fine);

end behav;
