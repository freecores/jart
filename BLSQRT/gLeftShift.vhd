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

-- The following code is a 1 Clock Fixed Square Root. Where's the catch? , well I simulate it through a lot of values (not really a simulation, just an openoffice electronic sheet), and found the maximum error is 6%. This error could be huge in terms of precision, but reasonable in terms of 1 CLOCK (maybe 2 CLOCKS) of fxd sq root latency.library ieee;
use ieee.std_logic_1164.all;

-- Left Shifting : The most significant one must be shifted one place to the left, the hole it leaves must be filled with most significant bit (0 or 1) of the most significant bit pair with at least a one in it. 

entity gLeftShift is
	port	(	Sn	: in std_logic_vector (1 downto 0);	-- Sn(1) is the pair under test selector, Sn (0) is the next to the right pair selector.
			Din	: in std_logic_vector (2 downto 0); 	-- Dn(2 downto 1) is the pair under test, Dn(0) is the most significant bit of the next to the right pair selector.
			Dout	: out std_logic_vector (1 downto 0)	-- Dout (1 downto 0 ) is the new result of the pair under test.
	);
end entity gLeftShift;

architecture rtl of gLeftShift is 
begin

	shift:
	process (Sn,Din) is
	begin 

		if Sn(1)='1' then 
			Dout <= '1' & (Din(2) and Din(1));
		else 
			case Sn(0) is
			when '1' =>
				Dout	<= Din(2) & Din(0);	--The n-1 n-pair was selected.
			when others  =>
				Dout	<=  Din(2 downto 1) ;	--Nor this n-pair or the n-1 n-pair was selected......
			end case;
		end if;	
	end process;
 
end rtl;

