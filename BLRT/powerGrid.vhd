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

-- 16X50M Intersection Tests	

library ieee;
use ieee.std_logic_1164.all;

package powerGrid is

	-- Signed "less than"
	component sl32 
		port	(
					dataa	: in std_logic_vector (31 downto 0);
					datab	: in std_logic_vector (31 downto 0);
					AlB		: out std_logic
		);
		end component;
	
	-- Signed "greater than"
	component sge32 
		port	(
					dataa	: in std_logic_vector (31 downto 0);
					datab	: in std_logic_vector (31 downto 0);
					AgeB	: out std_logic
		);
		end component;

	-- Minimun distance Comparison
	component dComparisonCell
		generic	(	W 		: integer := 32;	-- V.D, minDistance and selectD Width 
					idColW	: integer := 2;		-- Column Sphere ID width. 1 = 2 columns max, 2= 4 colums max... and so on.
					idCol	: integer := 0		-- Column Id
		);
		port 	(
				clk		: in std_logic; 
				rst		: in std_logic;
				
				cIdd	: in	std_logic_vector (idColW - 1 downto 0);	-- This is the reference column identification input.
				cIdq	: out	std_logic_vector (idColW - 1 downto 0);	-- This is the sphere identification output.
				refvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection incoming from the previous cell.
				colvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection of the sphere position over the ray traced vector, a.k.a. V.D! .
				selvd	: out	std_logic_vector (W - 1 downto 0) 		-- This is the smallest value between refvd and colvd.
	)
	end component;
	
	-- Dot Product Calculation.
	component dotCell
		generic (	levelW	: integer := 18;	-- Actual Level Width
					nLevelW	: integer := 32);	-- Next Level Width
		port	(	
				clk			: in std_logic;
				rst			: in std_logic;
				
				-- Object control.
				nxtSphere	: in std_logic; -- This bit controls when the sphere center goes to the next row.
				-- First Side.
				vxInput		: in std_logic_vector(levelW-1 downto 0);
				vyInput		: in std_logic_vector(levelW-1 downto 0);
				vzInput		: in std_logic_vector(levelW-1 downto 0);

				-- Second Side (Opposite to the first one)
				vxOutput	: out std_logic_vector(levelW-1 downto 0);
				vyOutput	: out std_logic_vector(levelW-1 downto 0);
				vzOutput	: out std_logic_vector(levelW-1 downto 0);

				-- Third Side (Perpendicular to the first and second ones)
				dxInput		: in std_logic_vector(levelW-1 downto 0);
				dyInput		: in std_logic_vector(levelW-1 downto 0);
				dzInput		: in std_logic_vector(levelW-1 downto 0);
				
				--Fourth Side (Opposite to the third one)
				dxOutput	: in std_logic_vector(levelW-1 downto 0);
				dyOutput	: in std_logic_vector(levelW-1 downto 0);
				dzOutput	: in std_logic_vector(levelW-1 downto 0);
				
				--Fifth Side (Going to the floor right upstairs!)
				vdOutput	: out std_logic_vector(nLevelW-1 downto 0); -- Dot product.
				
	);
	end component;
	
	-- K discriminant comparison.
	component kComparisonCell 
		generic (	W 		: integer := 32;
					idW		: integer := 12	
				);
		port 	(		
					clk			: in std_logic;
					rst			: in std_logic;
		
					nxtRow	: in std_logic; -- Controls when the sphere goes to the next Row. 
					vdinput	: in std_logic_vector (W-1 downto 0);
					kinput	: in std_logic_vector (W-1 downto 0);
					koutput	: out std_logic_vector (W-1 downto 0);
					
					sDP			: out std_logic_vector (W-1 downto 0) -- Selected dot product.
					
					
		);
		end component;
		
