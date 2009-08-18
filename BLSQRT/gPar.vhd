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

-- The following code is a 1 Clock Fixed Square Root. Where's the catch? , well I simulate it through a lot of values (not really a simulation, just an openoffice electronic sheet), and found the maximum error is 6%. This error could be huge in terms of precision, but reasonable in terms of 1 CLOCK (maybe 2 CLOCKS) of fxd sq root latency.

library ieee;
use ieee.std_logic_1164.all;

entity gPar is 
	generic (	W	: integer:=32);
	port	(	radical	: in std_logic_vector (W-1 downto 0);
			rad_2	: out std_logic_vector ((W/2)-1 downto 0)
	);
end entity gPar;

architecture rtl of gPar is
begin
	orArray : 
	for index in 0 to (W/2)-1 generate
		rad_2(index) <= radical(index*2) or radical(index*2+1);
	end generate;
end rtl;
		
