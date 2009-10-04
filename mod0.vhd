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

-- Reminder 0 detector with load.

	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity mod0 is 
	generic (WIDTH : integer range 1 to 32);
	port (
		
		clk		: in std_logic,	--Clock
		rst		: in std_logic,	--Reset
		icload	: in std_logic_vector (WIDTH-1 downto 0),	-- Input data to load in the counter register
		imload	: in std_logic_vector (WIDTH-1 downto 0),	-- Output data to load in the module register (a comparison register)
		cload	: in std_logic,	--Signal to load in the counter 
		mload	: in std_logic,	--Signal to load in the module,
		enable	: in std_logic,	--Signal to start counting,
		mod0	: out std_logic_vector -- Counter Value.
	);
end clearableCounter;

architecture rtl of clearableCounter is

	signal sCounter	:  std_logic_vector (WIDTH-1 downto 0);	-- Register where the counting takes place
	signal sModule	:  std_logic_vector (WIDTH-1 downto 0);	-- Register where the module is stored
	


begin

	
	process (clk,rst) 
	begin
	
		if rst='0' then 
		
			sCounter	<=  (others => '1');
			sModule		<=	(others	=> '0');
			mod0		<=		'1';
		elsif rising_edge (clk) then
			
			-- Load a new module
			if mload <='1' then 
				sModule <= imload;
			end if;
			
			-- Load a new counter
			if cload <='1' then 
				sCounter <= icload;
			end if;
			
			-- Count Up and Detect Module.
			if enable <='1' then 
			
				sCounter <= sCounter + 1;
				if sCounter = sModule then
					mod0 <= '1';
				else
					mod0 <= '0';
				end if;
			
			end if;
	
	end process;

end rtl;
		
		