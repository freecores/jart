-- Author : Julian Andres Guarin Reyes.
-- Project : JART, Just Another Ray Tracer.

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
	
	
-- The following HDL is compares 2 32 bit numbers instantiating a comparator.   
-- vd is one operand and k the other.
-- i is the result 1 if vd is grater or equal than k.

-- The comparator instantiation is called intersection, cause this block function is to decide wheter or not a ray intersects a sphere making the vd and k, 
-- comparison.

library ieee;
use ieee.std_logic_1164.all;



entity bl01 is
	port (
		vd:	in std_logic_vector (31 downto 0);
		k :	in std_logic_vector (31 downto 0);
		i : 	out std_logic
	);


end entity;
architecture rtl of bl01 is
	component compare_A15_16 is
	port
	(
		dataa		: in std_logic_vector(31 downto 0);
		datab		: in std_logic_vector(31 downto 0);
		AgeB		: out std_logic
	);
	end component;

begin

	intersection : compare_A15_16 port map ( dataa => vd, datab => k, AgeB => i);

end rtl;

