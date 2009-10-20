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
	
-- Unitary ray vector Y component integrator. In a memory block of 1x16384 bits, it is stored the FY' that represents the first derivate of FY, this function is the Y function along any horizontal line in the image.
-- The derivative is stored in this way: logic 0 means a 0 pendant and logic 1 means a -1 pendant. So a counter with enable / disable control it is everything we need, and of course a load input  to represent the initial value added to the integral.   

library ieee;	
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.powerGrid.all;


entity yu is 
	generic (
		TOP : integer := 1024;								-- Define the max counting number.. the number must be expressed as 2 power, cause the range of counting is going to be defined as TOP-1 downto TOP/2.
															-- However this is going to be by now, cause in the future the ray generation will GO on for higher resolution images , and perhaps it would be required a more extended range for the yu component.
		SCREENW : integer range 0 to 1023 := 320 			--  resolution width is 320 
	);
	port (
		clk,ena,rst		: in std_logic;
		lineDone		: out std_logic; 					-- Finished image row. once a hundred and sixty times....
		ypos			: out integer range TOP/2 to TOP-1
--		ocntr			: out integer range 0 to SCREENW/2 
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
	
	-- Some Initial Locks.
	signal sneglock	: std_logic;
begin

	derivate : yurom 
	port map (
		address_a	=> s1addf0,	
		address_b 	=> s1addf1,	
		clock		=> clk,
		q_a			=> sf0,
		q_b			=> sf1
	);

	integrate : process(clk,rst,ena)
	
		variable f0 : integer range TOP/2 to TOP-1;
		variable f1 : integer range TOP/2 to TOP-1;
		variable cc	: integer range 0 to SCREENW/2;	
	
	begin 
		
		if rst='0' then
			
			f0:=TOP-10;
			f1:=TOP-1;
			cc:=linefeed;
				
			-- Right from the start.
			s1addf0	(13 downto 1) <= (others=>'0');		-- 0000.
			s1addf0 (0) <= '1';
			s1addf1	<= "11111010000000";	-- 3E7F.	
			
			-- Locks
			sneglock<='0';
			
			
		elsif rising_edge(clk) and ena='1' then --ADD!
			
			
			-- Count f0 address
			if sneglock='1' then
				s1addf0 <= s1addf0+1;
			end if;
			
			-- Count f1 address (156)
			if cc=linefeed then
				s1addf1 <= s1addf1+1;
			end if;
			
			-- Unlock first stage f0 address (157)
			if cc=linefeed+1 then
				sneglock<='1';
			end if;
			
			-- Now, the integration function, cause we are at a new line..
			if cc = 0 then
				ypos <= f1;
				f0 := f1;
				lineDone <='1';
			else 
				lineDone <='0';
				ypos <= f0;
				if sf0(0)='1' then
					f0 := f0 - 1;
				end if;
			end if;	
			
			-- Count when reach linefeed +3 (159) then turn cc into 0, else turn it into cc+1!
			if cc=linefeed+3 then
			
				if sf1(0) = '1' then 
					f1 := f1 - 1;
				end if;
				cc:=0;
			else 
				cc:=cc+1;
			end if;
		
		end if;
		
	end process;
	
		

end rtl;
	
	
		



