library ieee;
use ieee.std_logic_1164.all;

entity opentdc is
  --  We suppose there is at least 40 I/O pins.
  --  We divide them into 5 groups (of 8 pins):
  --   data input
  --   data output
  --   control
  --   tdc signals
  --   misc
  port (
    --  Data input
    dat_i : std_logic_vector(7 downto 0);

    --  Data output
    dat_o : out std_logic_vector(7 downto 0);

    --  Control (6/8)
    clk_i : std_logic;
    rst_n_i : std_logic;
    bus_i : std_logic_vector(1 downto 0); -- 00: idle, 01: addr, 10: rd, 11: wr
    ack_o : out std_logic;
    rst_time_n_i : std_logic;

    --  Tdc signals
    inp_i : std_logic);
end opentdc;

architecture behav of opentdc is
  --  Regs for the bus interface.
  signal b_idle : std_logic;

  --  Wishbone
  signal wb_adr  : std_logic_vector(7 downto 0);
  signal wb_dati : std_logic_vector(7 downto 0);
  signal wb_dato : std_logic_vector(7 downto 0);
  signal wb_stb  : std_logic;
  signal wb_cyc  : std_logic;
  signal wb_we   : std_logic;
  signal wb_ack  : std_logic;

  signal cur_cycles : std_logic_vector(31 downto 0);

  --  tdc0
  signal tdc0_trigger : std_logic;
  signal tdc0_restart : std_logic;
  signal tdc0_coarse : std_logic_vector(31 downto 0);
  signal tdc0_fine : std_logic_vector(15 downto 0);
begin
  --  Bus interface
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wb_adr <= (others => '0');
        b_idle <= '1';
      else
        case bus_i is
          when "00" =>
            b_idle <= '1';
          when "01" =>
            if b_idle = '0' then
              wb_adr <= dat_i;
            end if;
            b_idle <= '0';
          when "10" | "11" =>
            b_idle <= '0';
          when others =>
            null;
        end case;
      end if;
    end if;
  end process;

  --  Wishbone master
  b_wb: block
    type wb_state_t is (IDLE, TFR, ACK1, ACK0);
    signal wb_state : wb_state_t;
  begin
    process (clk_i)
    begin
      if rising_edge(clk_i) then
        if rst_n_i = '0' then
          ack_o <= '0';
          wb_stb <= '0';
          wb_cyc <= '0';
          wb_state <= IDLE;
          dat_o <= (others => '0');
        else
          case wb_state is
            when IDLE =>
              if bus_i (1) = '1' then
                --  Request
                wb_stb <= '1';
                wb_cyc <= '1';
                wb_dati <= dat_i;
                wb_we <= bus_i (0);
                wb_state <= TFR;
              end if;
            when TFR =>
              if wb_ack = '1' then
                ack_o <= '1';
                wb_cyc <= '0';
                wb_stb <= '0';
                dat_o <= wb_dato;
                wb_state <= ACK1;
              end if;
            when ACK1 =>
              --  2 cycles of ack.
              wb_state <= ACK0;
            when ACK0 =>
              ack_o <= '0';
              wb_state <= IDLE;
          end case;
        end if;
      end if;
    end process;
  end block;

  --  Wishbone slave.
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wb_ack <= '0';
        tdc0_restart <= '0';
      else
        --  Restart is a pulse.
        tdc0_restart <= '0';

        if wb_ack = '1' then
          --  Negate ack after one clock
          wb_ack <= '0';
        elsif wb_stb = '1' and wb_cyc = '1' then
          wb_dato <= x"00";
          case wb_adr is
            when x"00" =>
              --  Id
              wb_dato <= x"54";  -- 'T'
            when x"01" =>
              wb_dato <= x"64";  -- 'd'
            when x"02" =>
              wb_dato <= x"63";  -- 'c'
            when x"03" =>
              wb_dato <= x"01";
            when x"04" =>
              -- status.
              wb_dato (0) <= tdc0_trigger;
            when x"05" =>
              --  control.
              if wb_we = '1' then
                tdc0_restart <= wb_dati (0);
              end if;
            when x"08" =>
              wb_dato <= tdc0_coarse(31 downto 24);
            when x"09" =>
              wb_dato <= tdc0_coarse(23 downto 16);
            when x"0a" =>
              wb_dato <= tdc0_coarse(15 downto 8);
            when x"0b" =>
              wb_dato <= tdc0_coarse(7 downto 0);
            when x"0c" =>
              wb_dato <= tdc0_fine(15 downto 8);
            when x"0d" =>
              wb_dato <= tdc0_fine(7 downto 0);
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
