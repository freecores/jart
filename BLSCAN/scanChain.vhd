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
		rst		: in std_logic;
		clk 	: in std_logic;
		
		scLoad	: in std_logic;	--Enable Shift.

		scIn	: in std_logic_vector ((CHAINSIZE*W)-1 downto 0); -- Los bits de entrada
		scOut	: out std_logic_vector (W - 1 downto 0)
	);
	
end entity;

architecture rtl of scanChain is

	-- The Scan Chain.
	signal sScan	: std_logic_vector ((CHAINSIZE*W)-1 downto 0);
	
begin
	-- Conectar la salida.
	scOut <= sScan ((CHAINSIZE*W)-1 downto ((CHAINSIZE-1)*W)); 
	

		

	theChain: for i in 0 to CHAINSIZE-1 generate
			
		scanStage0 : if (i=0) generate
			scanStageZero : scanFF 
				generic map	(	W => W )
				port map 	( 	rst => rst,
								clk => clk,	
								scLoad => scLoad,
								extData => scIn(W-1 downto 0),
								dStage => (others => '0'),
								qStage => sScan (W-1 downto 0));
		end generate scanStage0;
		scanStageN : if (i>0) generate
			scanStageX : scanFF
				generic map	(	W => W )
				port map 	( 	rst => rst,
								clk => clk,	
								scLoad => scLoad,
								extData => scIn((i+1)*W - 1 downto i*W),
								dStage => sScan (i*W - 1 downto (i-1)*W),
								qStage => sScan ((i+1)*W-1 downto i*W));
				
		end generate scanStageN;
			
									
	end generate theChain;

end rtl;


















