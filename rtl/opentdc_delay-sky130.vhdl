architecture sky130 of opentdc_delay is
  --  This is a generic name, to be replaced by the sky130 delay cell.
  --  (You could use this yosys command: chtype -map sky130_delay gatename)
  component sky130_delay is
    port (X : out std_logic;
          A : in std_logic);
  end component;
begin
  dly: sky130_delay
    port map (out_o, inp_i);
end sky130;
