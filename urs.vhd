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
	
-- Unitary Ray Set generator. 
-- This file is the description of    

library ieee;	
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.powerGrid.all;

entity urs is 
	generic (
		GRIDS	: integer := 2;		-- The number of grids.
		TOP		: integer := 1024;	-- Range.
		SCREENH	: integer := 200;	-- Screen Height Resolution.
		SCREENW	: integer := 320	-- Screen Width Resolution.
	);
	
	port (	
		clk,rst,ena			: in std_logic; 					-- The usual control signals
		y					: out integer range TOP/2 to TOP-1;
		xn, xp, zp, zn,yp	: out std_logic_vector (mylog2(TOP-1,"signed")*GRIDS-1 downto 0); -- Signed
		urs					: out std_logic
		
	);

end entity;


architecture rtl of urs is 
	
	constant localwidth0 : integer := mylog2(TOP-1,"signed"); -- 0 to 9 value. 10 sign.
	

	signal szpos,szneg,sxpos,sxneg		: integer range -TOP to TOP-1;
	signal sypos						: integer range 0 to TOP-1;
	signal slockd,slockq				: std_logic; 
	signal grid_enable					: std_logic_vector (GRIDS-1 downto 0);
	
	-- slockd : marks whenever a screen line has been finished.
	-- slockq : indicates if ycompo has already started.
	
begin

	xcompo : zu
	generic map (
		VALSTART => 34	-- Value required for X component.
	)
	port map (
		clk		=> clk,
		rst 	=> rst,
		ena 	=> ena and slockq,
		clr		=> slockd,
		zpos 	=> sxpos, 
		zneg 	=> sxneg	 

	);
	
	zcompo : zu 
	port map (
		clk		=> clk,
		rst		=> rst,
		ena		=> slockd,
		clr		=> slockd and not(slockq),
		zpos	=> szpos,
		zneg	=> szneg
		
	);
	

	ycompo : yu 
	generic map (
		
		TOP 	=> TOP,
		SCREENW	=> SCREENW
	)
	port map(
		clk		=> clk,
		rst		=> rst,
		ena		=> ena,
		lineDone=> slockd,
		ypos	=> sypos
	);
	
	process (clk,rst,ena)
		variable colcounter		: integer range 0 to (SCREENW/2)-1;
		variable linecounter	: integer range 0 to (SCREENH/2)-1;
		variable gridindex		: integer range 0 to GRIDS-1;
	begin
	
		if rst ='0' then
			
			
			slockq 		<='0';	
			urs			<='0';						
			linecounter := 0;
			gridindex	:= 0;
			
		elsif rising_edge(clk) and ena='1' then
			y <= sypos;
			-- Calculate the locked 
			if slockq = '1' then -- If we already load the initial ypos value, then we must be unlocked!
				if slockd = '1' then
					if linecounter = (SCREENW/2)-1 then
						urs <= '1'; -- Finished the URS.
					else
						linecounter:=linecounter+1;
					end if;
					
				end if;
					
			else	
			
				slockq <= slockd or slockq;	
			
			end if;
					
			-- Calculate the enable. (One Hot Deco)
			for i in 0 to GRIDS-1 loop	
				if i = gridindex then
					grid_enable(i)<='1';
				else
					grid_enable(i)<='0';
				end if;
			end loop;
			gridindex:=gridindex+1;
		
		end if;
	
	end process;			


	rowExits : for i in 0 to GRIDS-1 generate
	
		process (clk,rst,grid_enable(i))		
		begin 
			if rst = '0'  then			
				xp(localwidth0*(i+1)-1 downto (i*localwidth0))<= (others=>'0');
				xn(localwidth0*(i+1)-1 downto (i*localwidth0))<= (others=>'0');
				zp(localwidth0*(i+1)-1 downto (i*localwidth0))<= (others=>'0');
				zn(localwidth0*(i+1)-1 downto (i*localwidth0))<= (others=>'0');
				yp(localwidth0*(i+1)-1 downto (i*localwidth0))<= (others=>'0');
			elsif rising_edge (clk) and grid_enable(i) = '1' then			
				xp(localwidth0*(i+1)-1 downto (i*localwidth0)) <= CONV_STD_LOGIC_VECTOR (sxpos,localwidth0);
				zp(localwidth0*(i+1)-1 downto (i*localwidth0)) <= CONV_STD_LOGIC_VECTOR (szpos,localwidth0);
				xn(localwidth0*(i+1)-1 downto (i*localwidth0)) <= CONV_STD_LOGIC_VECTOR (sxneg,localwidth0);
				zn(localwidth0*(i+1)-1 downto (i*localwidth0)) <= CONV_STD_LOGIC_VECTOR (szneg,localwidth0);
				yp(localwidth0*(i+1)-1 downto (i*localwidth0)) <= CONV_STD_LOGIC_VECTOR (sypos,localwidth0);				
			end if;			
		end process;
	end generate rowExits;
	-- Result Intercalation.
					
					
							
				
		
	
end rtl;

		

