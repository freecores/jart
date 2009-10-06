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
	generic	(	
		W1	: integer := 32;	-- operands Width ( reference V.D and column V.D) 
		IDW	: integer := 2;		-- Column Sphere ID width. 1 = 2 columns max, 2= 4 colums max... and so on.
		C	: integer := 0 		-- Column Id
	);
	
	
	port 	(
				-- The usual control signals.
		clk, rst, pipeOn	: in std_logic; 
			
		-- Scan signals (not so usual)
		-- scanOut disables the main comparison functionality of the cell and turns it into a scan shift.
		-- when scanOut is set (1), scan shift mode is on, scanCommand commands what scan action is taking place,
		-- when scanCommand is set (1), a scan load action is taking place, when is not set (0) a scan shift is taking place.
		scanOut, scanCommand	: in std_logic;
			
		-- Reference intersection signal.
		intd : in std_logic; 
		intq : out std_logic;
		
		cIdd	: in	std_logic_vector (IDW - 1 downto 0);	-- This is the reference column identification input.
		cIdq	: out	std_logic_vector (IDW - 1 downto 0);	-- This is the sphere identification output.
		
		refk	: in	std_logic_vector (W1 - 1 downto 0); -- This is the columns sphere constant
		colk	: in	std_logic_vector (W1 - 1 downto 0); -- This is the reference sphere constant
		selk	: out 	std_logic_vector (W1 - 1 downto 0); -- This is the selected sphere constant
		
		refvd	: in	std_logic_vector (W1 - 1 downto 0);	-- This is the projection incoming from the previous cell.
		colvd	: in	std_logic_vector (W1 - 1 downto 0);	-- This is the projection of the sphere position over the ray traced vector, a.k.a. V.D! .
		selvd	: out	std_logic_vector (W1 - 1 downto 0)	-- This is the smallest value between refvd and colvd.
	);
				
end entity;


architecture rtl of dComparisonCell is 

	signal		sena	: std_logic;	-- This signal enables the scan ff.
	signal		ssl32	: std_logic;	-- This signal indicates if refvd is less than colvd
	signal 		qdist	: std_logic_vector (IDW+W1 downto 0);
	
begin

	-- A less than B comparison, check if colvd is less than refvd, meaning the act V.D less than actual min V.D
	cl32: sl32	
	port map (	
		dataa	=> colvd, 
		datab	=> refvd,
		AlB		=> ssl32
	);
										
	-- A flip flop with 2 to 1 mux.Selects between the smallest vd.
	selectorVD: scanFF generic map ( W => W1)
	port map (	
		clk	=> clk,
		rst => rst,
		ena	=> pipeOn or scanOut,
		sel => (ssl32 and not(scanOut))or(scanCommand and scanOut),
		d0	=> refvd,
		d1	=> colvd,
		q 	=> selvd
	);
	-- Another flip flip with 2 to 1 mux. Selects the column id the intersection signal of the smallest vd and the selected K.
	selectorID: scanFF	
	generic map	( 	
		W => W1+IDW+1 
	)
	port map (	
		clk => clk,
		rst	=> rst,
		ena	=> pipeOn or scanOut,
		sel	=> (ssl32 and not(scanOut))or(scanCommand and scanOut),
		d0	=> refk&cIdd&intd,
		d1	=> colk&conv_std_logic_vector(C,IDW)&ssl32,
		q	=> qdist 
	);
												
	selk <= qdist(IDW + W1 downto IDW+1);
	cIdq <= qdist(IDW downto 1);
	intq <= qdist(0);
	

end rtl;