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
	
-- A single dot product cell.

library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity dotCell is
	generic (	levelW	: integer := 18;	-- Actual Level Width
				nLevelW	: integer := 32);	-- Next Level Width
	port	(	clk		: in std_logic;
				rst		: in std_logic;
				
				-- Object control.
				nxtSphere	: in std_logic; -- This signal controls when the sphere center goes to the next row.
				nxtRay		: in std_logic; -- This signal controls when the ray goes to the next column.
				
				-- First Side.
				vxInput		: in std_logic_vector(levelW-1 downto 0);
				vyInput		: in std_logic_vector(levelW-1 downto 0);
				vzInput		: in std_logic_vector(levelW-1 downto 0);

				-- Second Side (Opposite to the first one)
				vxOutput		: out std_logic_vector(levelW-1 downto 0);
				vyOutput		: out std_logic_vector(levelW-1 downto 0);
				vzOutput		: out std_logic_vector(levelW-1 downto 0);

				-- Third Side (Perpendicular to the first and second ones)
				dxInput		: in std_logic_vector(levelW-1 downto 0);
				dyInput		: in std_logic_vector(levelW-1 downto 0);
				dzInput		: in std_logic_vector(levelW-1 downto 0);
				
				--Fourth Side (Opposite to the third one)
				dxOutput		: out std_logic_vector(levelW-1 downto 0);
				dyOutput		: out std_logic_vector(levelW-1 downto 0);
				dzOutput		: out std_logic_vector(levelW-1 downto 0);
				
				--Fifth Side (Going to the floor right upstairs!)
				vdOutput		: out std_logic_vector(nLevelW-1 downto 0) -- Dot product.
				
	);
	
end entity;


architecture rtl of dotCell is 


	signal s36vd	: std_logic_vector (2*LevelW-1 downto 0);
	signal s36m0	: std_logic_vector (2*levelW-1 downto 0);
	signal s36m1	: std_logic_vector (2*levelW-1 downto 0);
	signal s36m2	: std_logic_vector (2*levelW-1 downto 0);
	
	signal pAdd	: std_logic_vector (levelW-1 downto 0);
	
	
begin

	-- The Dotprod Machine
	
	-- 18x18 1 stage pipe Multipliers.
	m0	: p1m18 port map (
		aclr 	=> not(rst),
		clken 	=> nxtRay,
		clock 	=> clk,
		dataa	=> vxInput,
		datab	=> dxInput,
		result	=> s36m0
		);
	m1	: p1m18 port map (
		aclr 	=> not(rst),
		clken 	=> nxtRay,
		clock 	=> clk,
		dataa	=> vyInput,
		datab	=> dyInput,
		result	=> s36m1
		);
	m2	: p1m18 port map (
		aclr 	=> not(rst),
		clken 	=> nxtRay,
		clock 	=> clk,
		dataa	=> vzInput,
		datab	=> dzInput,
		result	=> s36m2
		);
		
	--  36 bits a+b+c 1 stage pipe Adder. 
	a0	: p1ax	generic map ( W = 36 )
				port map (
		clk		=> clk,
		rst		=> rst,
		enable	=> nxtRay,
		dataa	=> s36m0,
		datab	=> s36m1,
		datac	=> s36m2,
		result	=> s36vd
		);
		
	-- Truncate the less signifcative 4 bits 35 downto 4.
	vdOutput <= s36vd (2*levelW-1 downto 2*levelW-nLevelW);
		
	-- Ray PipeLine
	rayPipeStage : process (clk,rst,nxtRay)
	begin	

		if rst = '0' then
			-- There is no ray load yet.
			dxOutput <= (others => '0');
			dyOutput <= (others => '0');
			dzOutput <= (others => '0');
			
		elsif rising_edge (clk) and nxtRay='1' then
		
			-- Set 
			dxOutput <= dxInput;
			dyOutput <= dyInput;
			dzOutput <= dzInput;
			
		end if;
		
	end process;

	-- Sphere Pipe Line
	spherePipeStage : process (clk,rst,nxtSphere)
	begin
		if rst = '0' then

		-- There is no object center yet.
			vxOutput <= (others => '0');
			vyOutput <= (others => '0');
			vzOutput <= (others => '0');
			
		elsif rising_edge (clk) and nxtSphere ='1' then
		
			-- Shift sphere to the next row.
			vxOutput <= vxInput;
			vyOutput <= vyInput;
			vzOutput <= vzInput;
			
		end if;
		
	end process;
	
	
		
end rtl;




	
	