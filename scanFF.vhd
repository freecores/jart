-- Author : Julian Andres Guarin Reyes.
-- Project : JART, Just Another Ray Tracer.
-- email : jguarin2002 at gmail.com, j.guarin at javeriana.edu.co

-- This code was entirely written by Julian Andres Guarin Reyes.
-- The following code is licensed under GNU Public License
-- http://www.gnu.org/licenses/gpl-3.0.txt.

 -- This file is part of JART (Just Another Ray Tracer).

    -- JART (Just Another Ray Tracer) is free software: you can redistribute it and/or modify
    -- it under the terms of the GNU General Public License as published by
    -- the Free Software Foundation, either version 3 of the License, or
    -- (at your option) any later version.

    -- JART (Just Another Ray Tracer) is distributed in the hope that it will be useful,
    -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- GNU General Public License for more details.

    -- You should have received a copy of the GNU General Public License
    -- along with JART (Just Another Ray Tracer).  If not, see <http://www.gnu.org/licenses/>.

-- A scan flipflop hdl code. Note the logic function q <= (s0 and s ) or (s1 and ~s) its a mux with s as selector and s0 and s1 as selectable inputs.
library ieee;
use ieee.std_logic_1164.all;


entity scanFF is
	generic	(	W	: integer := 8);
	port 	(	
				clk,rst,ena,sel		: std_logic; -- The usual  control signals
				
				d0,d1				: std_logic_vector (W-1 downto 0);	-- The two operands.
				q					: std_logic_vector (W-1 downto 0)	-- The selected data.
					
	);
end entity;

architecture rtl of scanFF is 
begin

	dff_ena_sel : process (clk,rst,ena)
		
	begin
			
		if rst = '0' then
			q <= '0' & (others => '1');
		elsif rising_edge (clk) and ena = '1' then
			if sel='1' then 
				q <= d1;
			else 
				q <= d0;
			end if;
		end if;
	end process;
end rtl;

		


