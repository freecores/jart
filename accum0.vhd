-- Author : Julian Andres Guarin Reyes.
-- Project : JART, Just Another Ray Tracer, CopyRight (C) Julian Andres Guarin Reyes, 2009.
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

-- Selectable operator adder.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity accum0 is
	generic (WIDTH : integer range 1 to 32);
	port (
	
		clk		: in std_logic;
		rst 	: in std_logic;
		
		inAccum	: in std_logic_vector (WIDTH-1 downto 0);
		inSum0	: in std_logic_vector (WIDTH-1 downto 0);
		inSum1	: in std_logic_vector (WIDTH-1 downto 0);
		
		ldAccum	: in std_logic;
		ldSum0	: in std_logic;
		ldSum1	: in std_logic;
		
		enable	: in std_logic;
		sel		: in std_logic;

		outAccum	: out std_logic_vector (WIDTH-1 downto 0)
	);
end accum0;
		
entity rtl of accum0 is

	signal sAccum : std_logic_vector (WIDTH-1 downto 0);
	signal sS0 : std_logic_vector (WIDTH-1 downto 0);
	signal sS1 : std_logic_vector (WIDTH-1 downto 0);
	

begin

	-- Conectar la salida del flip flop afuera
	outAccum <= sAccum;
	
	process (clk, rst)
	begin 
	
		if rst='0' then
		
			sAccum	<= (others => '0');
			sS0		<= (others => '0');
			sS1		<= (others => '0');
		
		elsif rising_edge(clk) then
		
			-- Acumulator.
			if ldAccum <='1' then
				sAccum <= inAccum;
				
			elsif enable <='1' then 
				sAccum <= sS1 + sAccum;
			else
				sAccum <= sS0 + sAccum;
			end if;
			
			-- Cargar el operador 0
			if ldSum0 <= '1' then
				sS0 <= inSum0;
			end if;
			
			-- Cargar el operador 1
			if ldSum1 <= '1' then
				sS1 <= inSum1;
			end if;
			
			
				
		end if;
	
	
	
	end process;

	



end rtl;