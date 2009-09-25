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
-- A scan  out chain.

library ieee;
use ieee.std_logic_1164.all;
use work.scanPack.all;



entity scanChain is
	generic (	CHAINSIZE : integer := 4; 
				W : integer := 32);
	port (
	
			clk,rst,ena		: std_logic; -- The usual control signals.
			
			sel				: std_logic_vector (W-1 downto 0); -- Selection signals.
				
			d0				: in std_logic_vector(W-1 downto 0); -- Youngest Chain Data.
			q				: out std_logic_vector(W-1 downto 0); -- Oldest chain Data.
			d1				: in std_logic_vector (W*CHAINSIZE-1 downto 0); -- Unchained external data.
			
			chain			: out std_logic_vector (W*CHAINSIZE-1 downto 0); -- Chain data going out for selection function.
			
	);
			
	
end entity;

architecture rtl of scanChain is

	-- The Scan Chain.
	signal sd0	: std_logic_vector (((CHAINSIZE+1)*W)-1 downto 0);
	
begin
	-- Conectar la salida.
	q <= sd0 (((CHAINSIZE+1)*W)-1 downto CHAINSIZE*W);

	-- Conectar la cadena hacia afuera.
	chain <= sd0 (W*CHAINSIZE)-1 downto 0);
	
	theChain: for i in 0 to CHAINSIZE-1 generate
			
		scanStage : scanFF	
		
			generic map	(	W => W )
			port map 	( 	
							clk 	=> rst,
							rst 	=> clk,
							ena 	=> ena,
							sel		=> sel(i),
							d0 		=> sd0((i+1)*W-1 downto i*W),
							d1		=>  d1((i+1)*W-1 downto i*W),
							q 		=> sd0((i+2)*W-1 downto (i+1)*W)
			);
		
		
		

		
	end generate theChain;

end rtl;


















