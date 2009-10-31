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
	
-- Ray Generator.....
-- The entity synthesizes 4 simmetrical rays each clock. The ena signal enables/disables the ray production.
-- The Ray Generator starts by generating after the first clock's rising edge with the ena signal set. 
-- The first four rays generated are the Rays passing through the center of the screen, in the 320x200 screen these rays are : (159,99)(160,99)(159,100)(160,100), after those rays the next four rays are (158,99)(161,99)(158,100)(161,100).

library ieee;	
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.powerGrid.all;


entity yu is 
	generic (
		VALSTARTX : integer := 34;
		VALSTARTY : integer := 1023;
		VALSTARTZ : integer := 9;
		TOP : integer := 1024;								-- Define the max counting number.. the number must be expressed as 2 power, cause the range of counting is going to be defined as TOP-1 downto TOP/2.
															-- However this is going to be by now, cause in the future the ray generation will GO on for higher resolution images , and perhaps it would be required a more extended range for the yu component.
		SCREENW : integer := 320 			--  resolution width is 320 
	);
	port (
		clk,rst,ena		: in std_logic;
		lineDone		: out std_logic; 					-- Finished image row. once a hundred and sixty times....
		ocntr			: out integer range 0 to SCREENW/2;
		ypos			: out integer range TOP/2 to TOP-1;
		zpos			: out integer range -TOP to TOP-1;
		zneg			: out integer range -TOP to TOP-1;
		xpos			: out integer range -TOP to TOP-1;
		xneg			: out integer range -TOP to TOP-1

	);
end entity;

architecture rtl of yu is 
	-- 1x16384 bits, true dual port, ROM Memory declaration.
	-- This memory uses 2 cycles.. a memory fetch cycle and a data to q memory cycle.
	component yurom
	port
	(
		address_a	: in std_logic_vector (13 downto 0);
		address_b	: in std_logic_vector (13 downto 0);
		clock		: in std_logic ;
		q_a			: out std_logic_vector (0 downto 0);
		q_b			: out std_logic_vector (0 downto 0)
	);

	end component;

	
	constant linefeed : integer range 0 to (SCREENW/2) := (SCREENW/2)-4;
	
	
	-- Support signals.
	signal s1addf0	: std_logic_vector (13 downto 0);	-- The function 0 is the function of the y component derivative.
	signal s1addf1	: std_logic_vector (13 downto 0);	-- The function 1 is the function of the y component integration curve initial constant.
	signal sf0		: std_logic_vector (0 downto 0);	-- Derivative function
	signal sf1		: std_logic_vector (0 downto 0);	-- Derivative curve, initial constant derivative function.
	signal cc		: integer range 0 to SCREENW/2;	
	signal fy : integer range TOP/2 to TOP-1;
	signal pivotCol,pivotRow	: std_logic;
	signal fz 	: integer range  -TOP to TOP-1;
	signal fx 	: integer range  -TOP to TOP-1;
begin

	-- Connect fy, to the output.
	ypos <= fy;
	xpos <= fx;
	xneg <= -fx;
	zpos <= fz;
	zneg <= -fz;
	ocntr<= cc;
	
	derivate : yurom 
	port map (
		address_a	=> s1addf0,	
		address_b 	=> s1addf1,	
		clock		=> clk,
		q_a			=> sf0,
		q_b			=> sf1
	);

	
	integrationControl : process (clk,rst,ena)
		variable f1 : integer range TOP/2 to TOP-1;
		
	begin
	
		if rst='0' then

			fy<=TOP/2;
			f1:=VALSTARTY;
			fz<=VALSTARTZ-2;
			fx<=0;
			pivotCol <= '0';
			pivotRow <= '0';
			
			
		elsif rising_edge(clk) and ena='1' then
		
			if cc=(SCREENW/2)-1 then
				
				-- Y component
				f1 := f1 - CONV_INTEGER('0'&sf1(0));
				fy <= f1;
				
				-- X component
				fx <= VALSTARTX;
				
				-- Z component
				fz <= fz+2+CONV_INTEGER('0'&pivotRow); -- Beware of the sign!
				pivotRow <= not (pivotRow);
			
			else
			
				-- Y Component
				fy <= fy-CONV_INTEGER('0'&sf0(0));
				
				-- X component
				fx <= fx+2+CONV_INTEGER('0'&pivotCol); -- Beware of the sign!
				pivotCol <= not(pivotCol);
				
			
			end if;
			
			
		end if;
		
	
	end process;
	
	counterControl : process (clk,rst,ena)
	begin
	
		if rst='0' then
		
			cc<=SCREENW/2-1;
			lineDone<='0';
		
		elsif rising_edge(clk) and ena='1' then 
			if cc=(SCREENW/2)-1 then
				lineDone<='1';
				cc<=0;
			else
				lineDone<='0';
				cc<=cc+1;
			end if;
		end if;
		
	end process;
		
	addressControl : process (clk,rst,ena)
	begin
		if rst='0' then 
			-- Right from the start.
			s1addf0	(13 downto 1) <= (others=>'0');		-- 00001.
			s1addf0 (0) <= '1';
			s1addf1	<= "11111010000000";	-- 3E80.	
		
		elsif rising_edge(clk) and ena='1' then

			s1addf0 <= s1addf0+1;
			-- Count f1 address (158)
			if cc=linefeed then
				s1addf1 <= s1addf1+1;
			end if;
			
		end if;
	
	end process;
	
	
	
	
	

end rtl;
	
	
		



