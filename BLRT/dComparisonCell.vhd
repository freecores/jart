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
	generic	(	W		: integer := 32;	-- operands Width ( reference V.D and column V.D) 
				idColW	: integer := 2;		-- Column Sphere ID width. 1 = 2 columns max, 2= 4 colums max... and so on.
				idCol	: integer := 0 		-- Column Id
	);
	
	
	port 	(
				clk, rst, ena	: in std_logic; 
				
				intd : in std_logic; -- Reference intersection signal.
				intq : out std_logic;
				
				cIdd	: in	std_logic_vector (idColW - 1 downto 0);	-- This is the reference column identification input.
				cIdq	: out	std_logic_vector (idColW - 1 downto 0);	-- This is the sphere identification output.
				refvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection incoming from the previous cell.
				colvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection of the sphere position over the ray traced vector, a.k.a. V.D! .
				selvd	: out	std_logic_vector (W - 1 downto 0) 		-- This is the smallest value between refvd and colvd.
	);
				
end entity;


architecture rtl of dComparisonCell is 

	signal		ssl32 : std_logic;	-- This signal indicates if refvd is less than colvd
	signal 		qdist : std_logic_vector (idColW downto 0);
	
begin

	-- A less than B comparison, check if colvd is less than refvd, meaning the act V.D less than actual min V.D
	cl32			: sl32	port map (	dataa	=> colvd, 
										datab	=> refvd,
										AlB		=> ssl32
										);
										
	-- A flip flop with 2 to 1 mux.Selects between the smallest vd.
	selectorVD		: scanFF	generic map (	W = W	)
								port map	(	clk	=> clk,
												rst => rst,
												ena	=> ena,
												sel => ssl32,
												d0	=> refvd,
												d1	=> colvd,
												q 	=> selvd
											);
	-- Another flip flip with 2 to 1 mux. Selects the id and intersection signal of the smallest vd.
	selectorID		: scanFF	generic map	( 	W = idColW+1 )
								port map	(	clk => clk,
												rst	=> rst,
												ena	=> ena
												sel	=> ssl32,
												d0	=> cIdd&intd,
												d1	=> conv_std_logic_vector(idCol,idColW)&ssl32,
												q	=> qdist; 
												);
												
	cIdq <= qdist(idColw downto 1);
	intq <= qdist(0);
	

end rtl;