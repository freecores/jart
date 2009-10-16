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
    -- along with JART (Just Another Ray Tracer).  If not, see <http://www.gnu.org/licenses/>.library ieee;
	
-- Zu synthesises the z and x components of the unitary vectors along an image vertical and/or horizontal line respectively. 
-- For the jart project Zu must be used with the following values:
-- When synthesising X , VALSTART must be 34, when synthesising Z, VALSTART must be 4. 	


library ieee;	
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity zu is 
	generic
	(
		VALSTART		: integer := 15
	);
	port (
	
		clk, rst, ena 	: in std_logic; -- The usual control signals
		clr				: in std_logic;
		zpos			: out integer range -1024 to 1023;
		zneg			: out integer range -1024 to 1023	
	);

end entity;

architecture rtl of zu is
	
begin

	process (clk,rst,ena,clr)
		variable pivot	: integer range 0 to 31;
		variable z 	: integer range  -1024 to 1023;
	begin
		
		if rst='0' then
		
			zpos<=VALSTART;
			zneg<=-VALSTART;
			z:=VALSTART;
			pivot:=0;
		
		elsif rising_edge(clk) and ena='1' then
				
			if clr='1' then
				z:=VALSTART;
				pivot:=0;
			elsif pivot = 0 then 
				z:=z+3;
				pivot:=1;
			else 
				z:=z+2;
				pivot:=0;
			end if;
			
			zpos <= z;
			zneg <=-z;
		end if;	
	
	end process;

end rtl;

		
		