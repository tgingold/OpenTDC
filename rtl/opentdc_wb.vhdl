library ieee;
use ieee.std_logic_1164.all;

entity opentdc_wb is
  port (
    --  Control
    clk_i : std_logic;
    rst_n_i : std_logic;
    rst_time_n_i : std_logic;

    --  Wishbone
    wb_adr_i : in  std_logic_vector(7 downto 0);
    wb_dat_i : in  std_logic_vector(31 downto 0);
    wb_dat_o : out std_logic_vector(31 downto 0);
    wb_sel_i : in  std_logic_vector(3 downto 0);
    wb_stb_i : in  std_logic;
    wb_cyc_i : in  std_logic;
    wb_we_i  : in  std_logic;
    wb_ack_o : out std_logic;

    --  Tdc signals
    inp0_i : std_logic);
end opentdc_wb;

architecture behav of opentdc_wb is
  --  Regs for the bus interface.
  signal b_idle : std_logic;

  signal wb_ack : std_logic;

  signal cur_cycles : std_logic_vector(31 downto 0);

  --  tdc0
  signal tdc0_trigger : std_logic;
  signal tdc0_restart : std_logic;
  signal tdc0_coarse : std_logic_vector(31 downto 0);
  signal tdc0_fine : std_logic_vector(15 downto 0);
begin
  --  Wishbone slave.
  wb_ack_o <= wb_ack;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wb_ack_o <= '0';
        tdc0_restart <= '0';
      else
        --  Restart is a pulse.
        tdc0_restart <= '0';

        if wb_ack = '1' then
          --  Negate ack after one clock
          wb_ack <= '0';
        elsif wb_stb_i = '1' and wb_cyc_i = '1' then
          --  Start of a transaction
          wb_dat_o <= x"00_00_00_00";
          case wb_adr_i is
            when x"00" =>
              --  Id
              wb_dat_o <= x"54_64_63_01";  -- 'Tdc\1'
            when x"01" =>
              -- status.
              wb_dat_o (0) <= tdc0_trigger;
            when x"02" =>
              -- control.
              if wb_we_i = '1' and wb_sel_i (0) = '1' then
                tdc0_restart <= wb_dat_i (0);
              end if;
            when x"04" =>
              wb_dat_o <= tdc0_coarse;
            when x"05" =>
              wb_dat_o <= x"00_00" & tdc0_fine;
            when others =>
              null;
          end case;
          wb_ack <= '1';
        end if;
      end if;
    end if;
  end process;

  --  Time counter.
  process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if rst_time_n_i = '0' or rst_n_i = '0' then
        cur_cycles <= (others => '0');
      else
        cur_cycles <= std_logic_vector(unsigned(cur_cycles) + 1);
      end if;
    end if;
  end process;

  --  TDC
  i_tdc0: entity work.opentdc_core
    generic map (
      length => 90)
    port map (
      clk_i => clk_i,
      rst_n_i => rst_n_i,
      cur_cycles_i => cur_cycles,
      restart_i => tdc0_restart,
      inp_i => inp_i,
      trigger_o => tdc0_trigger,
      coarse_o => tdc0_coarse,
      fine_o => tdc0_fine);

end behav;
