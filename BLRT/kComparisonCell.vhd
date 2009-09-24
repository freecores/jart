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
	generic (	W 		: integer := 32	);
	port (		
				clk,rst		: in std_logic;
	
				nxtSphere	: in std_logic; -- Controls when the sphere goes to the next Row. 
				pipeOn		: in std_logic; -- Enables / Disable the upwarding flow.
				kinput		: in std_logic_vector (W-1 downto 0);
				koutput		: out std_logic_vector (W-1 downto 0);
				
				vdinput		: in std_logic_vector (W-1 downto 0);	-- V.D input.
				vdoutput	: out std_logic_vector (W-1 downto 0)	-- Selected dot product.
				
				
	);
	end port;
end entity;


architecture rtl of kComparisonCell is 

	signal ssge32	: std_logic;	-- Signed "Greater or equal  than" signal.

begin

	comparison : sge32 port map (
		dataa	=> vdinput,
		datab 	=> kinput,
		AgeB	=> ssge32
		);

	-- When ssge32 (greater or equal signal) is set then V.D > kte, therefore intersection is confirmed and  V.D is to be shifted to the distance comparison grid.
	selector : process (rst,clk,ssg32,pipeOn)
	begin
			
		if rst='0' then
				
			-- At the beginning set the Maximum over Maximum distance.
			vdoutput <= '0' & (others =>'1');
				
		elsif rising_edge(clk) and pipeOn ='1' then 
				
			if ssge32 = '1' then -- If VD ids grater or equal than K .....
				vdoutput <= vdinput;
			else
				vdoutput <= '0' & (others =>'1');
			end if;
			
		end if;
		
	end process;
			
	-- Behavioral : When nxtSphere is set, the Sphere and its K constant should go the the next row

	kPipeStage : process (clk,rst,nxtSphere)
	begin
	
		if rst='0' then
			
			koutput <= (others => '0');
		
		elsif rising_edge(clk) and nxtSphere ='1' then
				
			koutput <= kinput;
			
		end if;
	
	end process;



end rtl;


	

	