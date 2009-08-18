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



entity gMux is 
	port (
		rawSq	: in std_logic_vector(31 downto 1);	-- Square Root Raw Value
		ohSel	: in std_logic_vector(15 downto 0);	-- One Hot Selector
		sQ	: out std_logic_vector (15 downto 0)	-- Properly Selected Bits Square Root  
	);
end entity gMux;


architecture rtl of gMux is

begin
	
	gMux: 
	process (rawSq,ohSel)
	begin
		
		sQ <= X"0000" ;
		case ohSel is
			when X"8000" =>
				sQ <= rawSq(31 downto 16);
			when X"4000" =>
				if rawSq(30)='1' then
					sQ (14 downto 0) <= rawSq (30 downto 16);
				else
					sQ (14 downto 0) <= rawSq (29 downto 15);
				end if;
			when X"2000" =>
				if rawSq(28)='1' then
					sQ (13 downto 0) <= rawSq( 28 downto 15);
				else
					sQ (13 downto 0) <= rawSq (27 downto 14);
				end if;
			when X"1000" =>
				if rawSq(26)='1' then 
					sQ (12 downto 0) <= rawSq (26 downto 14);
				else
					sQ (12 downto 0) <= rawSq (25 downto 13);
				end if;
			when X"0800" =>
				if rawSq(24)='1' then
					sQ (11 downto 0) <= rawSq (24 downto 13);
				else
					sQ (11 downto 0) <= rawSq (23 downto 12);
				end if;
			when X"0400" =>
				if rawSq(22)='1' then 
					sQ (10 downto 0) <= rawSq (22 downto 12);
				else
					sQ (10 downto 0) <= rawSq (21 downto 11);
				end if;
			when X"0200" =>
				if rawSq(20)='1' then
					sQ (9 downto 0) <= rawSq (20 downto 11);
				else
					sQ (9 downto 0) <= rawSq (19 downto 10);
				end if;
			when X"0100" => 
				if rawSq(18)='1' then
					sQ (8 downto 0) <= rawSq (18 downto 10);
				else
					sQ (8 downto 0) <= rawSq (17 downto 9);
				end if;
			when X"0080" =>
				if rawSq(16)='1' then
					sQ (7 downto 0) <= rawSq (16 downto 9);
				else
					sQ (7 downto 0) <= rawSq (15 downto 8);
				end if;
			when X"0040" =>
				if rawSq(14)='1' then
					sQ (6 downto 0) <= rawSq (14 downto 8);
				else
					sQ (6 downto 0) <= rawSq (13 downto 7);
				end if;
			when X"0020" =>
				if rawSq(12)='1' then 
					sQ (5 downto 0) <= rawSq (12 downto 7);
				else
					sQ (5 downto 0) <= rawSq (11 downto 6);
				end if;
			when X"0010" =>
				if rawSq(10)='1' then
					sQ (4 downto 0) <= rawSq (10 downto 6);
				else
					sQ (4 downto 0) <= rawSq (9 downto 5);
				end if;
			when X"0008" =>
				if rawSq(8)='1' then 
					sQ (3 downto 0) <= rawSq (8 downto 5);
				else
					sQ (3 downto 0) <= rawSq (7 downto 4);
				end if;
			when X"0004" =>
				if rawSq(6)='1' then
					sQ (2 downto 0) <= rawSq (6 downto 4);
				else 
					sQ (2 downto 0) <= rawSq (5 downto 3);
				end if;
			when X"0002" =>
				if rawSq(4)='1' then
					sQ (1 downto 0) <= rawSq (4 downto 3);
				else
					sQ (1 downto 0) <= rawSq (3 downto 2);
				end if;
			when X"0001" => 
				if rawSq(2)='1' then 
					sQ (0) <= rawSq (2);
				else
					sQ (0) <= rawSq (1);
				end if;
			when others =>
				null;
		end case;
		
	end process;

	 


end rtl;




