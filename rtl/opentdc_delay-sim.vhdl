--  Elementary delay, to be replaced by a specific implementation.
--  It should be balanced

architecture behav of opentdc_delay is
begin
  out_o <= inp_i after 100 ps;
end behav;
