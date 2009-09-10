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

-- This is a discriminant proof cell.	
	
library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity kComparisonCell is
	generic (	W 		: integer := 32;
				idW		: integer := 12	
			);
	port (		
				clk			: in std_logic;
				rst			: in std_logic;
	
				nxtRow	: in std_logic; -- Controls when the sphere goes to the next Row. 
				vdinput	: in std_logic_vector (W-1 downto 0);
				kinput	: in std_logic_vector (W-1 downto 0);
				koutput	: out std_logic_vector (W-1 downto 0);
				
				sDP			: out std_logic_vector (W-1 downto 0) -- Selected dot product.
				
				
	);
	end port;
end entity;


architecture rtl of kComparisonCell is 

	signal ssge32	: std_logic;	-- Greater or equal signed signal.

begin

	-- Instantiation of the compare.
	discriminantCompare : ge32 port map (
		dataa	 => vdinput,
		datab	 => kinput,
		AgeB	 => ssge32
	);


	-- When ssge32 (greater or equal signal) is set then V.D > kte, therefore intersection is confirmed and  V.D is to be shifted to the distance comparison grid.
	
	intersectionSelector : for i in 0 to W-1 generate

		selector : process (rst,clk)
		begin
			
			if rst='0' then
				
				-- At the beginning set the Maximum over Maximum distance.
				if i = W-1 then
					sDP (i) <= '0';
				else 
					sDP (i) <= '1';
				end if;
				
			elsif rising_edge(clk) then 
				
				if i = W-1 then
					sDP (i) <= ssge32 and vdinput(i);
				else
					sDP (i) <= (ssge32 and vdinput(i)) or not(ssge32);
				end if;
			
			end if;
		
		end process;
			
	end generate; 

	kPipeStage : process (clk,rst)
	begin
	
		if rst='0' then
			
			koutput <= (others => '0');
		
		elsif rising_edge(clk) and nxtRow='1' then
			
			koutput <= kinput;
			
		else -- Avoid Latch Inference
		
			koutput <= koutput;
		
		end if;
	
	end process;



end rtl;


	

	