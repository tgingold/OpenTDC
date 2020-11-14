--  Elementary delay, to be replaced by a specific implementation.
--  It should be balanced
--
-- SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
-- SPDX-License-Identifier: Apache-2.0

architecture behav of opentdc_delay is
begin
  out_o <= inp_i after 100 ps;
end behav;
