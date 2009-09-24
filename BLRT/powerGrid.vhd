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

	--A one stage pipe a+b+c with w width bits in input as well as output.
	component p1ax
		generic ( 	W 		: integer := 36 );
		port	(	clk		:	 in std_logic;
					rst		:	 in std_logic;
					enable		:	 in std_logic;
					dataa		:	 in std_logic_vector(W-1 downto 0);
					datab		:	 in std_logic_vector(W-1 downto 0);
					datac		:	 in std_logic_vector(W-1 downto 0);
					result		:	 out std_logic_vector(W-1 downto 0)
		);
	end component;
	
	-- A 1 stage pipe 18x18 multiplier. On Cycle III devices is a M-R (Multiplier, Register). (Should be generated using a synthesis tool....).
	component p1m18
		port	(
				aclr		: in std_logic ;
				clken		: in std_logic ;
				clock		: in std_logic ;
				dataa		: in std_logic_vector (17 downto 0);
				datab		: in std_logic_vector (17 downto 0);
				result		: out std_logic_vector (35 downto 0)
		);
	end component;

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
				cIdq	: out	std_logic_vector (idColW - 1 downto 0);	-- This is the result column identification output.
				refvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the reference projection incoming from the previous cell.
				colvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the sphere position over the ray traced vector projection.
				selvd	: out	std_logic_vector (W - 1 downto 0) 		-- This is the smallest value between refvd and colvd.
		);
	end component;
	
	-- Dot Product Calculation Cell. 
	-- A 4 side cell along with an upper side. 
	-- V input flows through V output using a data flipflop, so turning V output in the next cell on the next row V Input. V input also flows upwards into the dotproduct 3 stage pipeline. 
	-- D input flows through D output using a data flipflop, so turning D output in the next column cell. D input also flows upwards into the dotproduct 3 stage. 
	component dotCell
		generic (	levelW	: integer := 18;	-- Actual Level Width
					nLevelW	: integer := 32);	-- Next Level Width
		port	(	
				clk			: in std_logic;
				rst			: in std_logic;
				
				-- Object control.
				nxtSphere	: in std_logic; -- This bit controls when the sphere center goes to the next row.
				nxtRay		: in std_logic;	-- This bit controls when the ray goes to the next column.
				
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
				vdOutput	: out std_logic_vector(nLevelW-1 downto 0) -- Dot product.
				
		);
	end component;
	
	-- K discriminant comparison.
	component kComparisonCell 
		generic (	W 		: integer := 32;
				);
		port 	(		
					clk			: in std_logic;
					rst			: in std_logic;
		
					nxtSphere	: in std_logic; -- Controls when the sphere goes to the next Row. 
					pipeOn		: in std_logic; -- Enables / Disables the upwarding flow.
					vdinput	: in std_logic_vector (W-1 downto 0);
					kinput	: in std_logic_vector (W-1 downto 0);
					koutput	: out std_logic_vector (W-1 downto 0);
					
					vdoutput: out std_logic_vector (W-1 downto 0) -- Selected dot product.					
		);
	end component;
		
end powerGrid;