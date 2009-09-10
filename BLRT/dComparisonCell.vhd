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

-- A single fixed minimun distance comparison cell.
library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.powerGrid.all;


entity dComparisonCell is
	generic	(	W 		: integer := 32;	-- V.D, minDistance and selectD Width 
				idColW	: integer := 2;		-- Column Sphere ID width. 1 = 2 columns max, 2= 4 colums max... and so on.
				idCol	: integer := 0		-- Column Id
	);
	
	
	port 	(
				clk		: in std_logic; 
				rst		: in std_logic;
				
				cIdd	: in	std_logic_vector (idColW - 1 downto 0);	-- This is the reference column identification input.
				cIdq	: out	std_logic_vector (idColW - 1 downto 0);	-- This is the sphere identification output.
				refvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection incoming from the previous cell.
				colvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection of the sphere position over the ray traced vector, a.k.a. V.D! .
				selvd	: out	std_logic_vector (W - 1 downto 0) 		-- This is the smallest value between refvd and colvd.
	)
	end port;
				
				
				
end entity;


architecture rtl of dComparisonCell is 

	signal ssl32 : std_logic;	-- This signal indicates if refvd is less than colvd

begin

	-- A less than B comparison, check if colvd is less than refvd, meaning the act V.D less than actual max V.D
	cl32			: sl32	port map (	dataa	=> colvd, 
										datab	=> refvd,
										AlB		=> sl32
										);
										
	-- A flip flop with 2 to 1 mux.
	selector		: scanFF	generic map (	W = 32	)
								port map	(	clk 	=> clk,
												rst 	=> rst,
												scLoad 	=> ssl32,
												extData => colvd,
												dStage	=> refvd,
												qStage 	=> selvd);
												
												
	colIdSelector : process (clk,rst)
	begin
	
		if rst = '0' then 
			
			--Set max Distance on reset and column identifier	
			cIdq <= CONV_STD_LOGIC_VECTOR(idCol,idColW);
			selvd(W-1) <= '0';
			selvd(W-2 downto 0) <= (others => '1');
			
		elsif rising_edge(clk) then 
		
			if ssl32 ='0' then
				
				-- If reference V.D. is less than column V.D then shift the reference id. 
				cIdq <= cIdd;
		
			else 
				
				--If column V.D. is less than
				cIdq <= CONV_STD_LOGIC(idCol,idColW);
			
		end if;
	
	
	end process;
	
	
	

end rtl;