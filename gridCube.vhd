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

	
-- This is it!!!!! The following code represents the whole blocks gathered all together.
-- This block represents a processing cube. The cube's height is always 3 (floor 0 to floor 2). The cube width
-- is the number of spheres under intersection test each clock. The cube depth represents the number or rays under
-- intersection test each clock. 

-- Details on the cube outputs interpretation, can be found at BlackBook.pdf


library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity gridCube	is 
	generic ( 
		-- Depth
		D 	: integer := 4;
		-- ID width.
		IDW	: integer := 2;
		-- Number of Columns.
		C	: integer := 4;	
		-- Input rays width.
		W0	: integer := 18;
		-- Dot products and spheres constant width
		W1	: integer := 32;	IDW	: integer := 2;
		
		);
	port (
			-- The usual control signals.
		clk,rst	: in std_logic;
		
		-- Grid, rays and sphere flow through control signals.
		pipeOn			: in std_logic;
		-- The same column nxtSphere signal control..... regardless the Cube Depth.
		nxtSphere		: in std_logic_vector (C-1 downto 0);
		
		-- R-F0
		-- Input Values. 
		-- The ray input vector. 
		iRayx: in std_logic_vector (D*W0 - 1 downto 0);
		iRayy: in std_logic_vector (D*W0 - 1 downto 0);
		iRayz: in std_logic_vector (D*W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) input vectors.
		iSphrCenterx: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y position (sphere centers) input vectors.
		iSphrCentery: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres z position (sphere centers) input vectors.
		iSphrCenterz: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) output vectors.
		oSphrCenterx: out std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y positions (sphere centes) output vectors.
		oSphrCentery: out std_logic_vector (C*W0 - 1 downto 0);
		-- The spheres z positions (sphere centers) output vectors.		
		oSphrCenterz: out std_logic_vector (C*W0 - 1 downto 0);
		-- Output Values
		-- The ray output vector.
		oRayx: out std_logic_vector (D*W0 - 1 downto 0);
		oRayy: out std_logic_vector (D*W0 - 1 downto 0);
		oRayz: out std_logic_vector (D*W0 - 1 downto 0);
		
		-- R-F1
		-- K Input / Output.
		kInput	: in std_logic_vector (C*W1 - 1 downto 0); 
		kOutput	: out std_logic_vector (C*W1 - 1 downto 0)  
		
		--R-F2
		-- Input Values
		refvd	: in std_logic_vector (D*W1-1 downto 0);
		selvd	: out std_logic_vector (D*W1-1 downto 0);
		colid	: out std_logic_vector (D*IDW-1 downto 0);
		inter 	: out std_logic_vector (D-1 downto 0)
		);
end entity;

architecture rtl of gridCube is

	-- Difussion nets for sphere constant and center .
	signal sK	: std_logic_vector ((D+1)*C*W1 - 1 downto 0);
	signal sVx	: std_logic_vector ((D+1)*C*W0 - 1 downto 0);
	signal sVy	: std_logic_vector ((D+1)*C*W0 - 1 downto 0);
	signal sVz	: std_logic_vector ((D+1)*C*W0 - 1 downto 0);
	
	

begin

	-- External connections : K constant.
	sK (C*W1-1 downto 0) <= kInput;
	kOutput <= sK ((D+1)*C*W1-1 downto D*C*W1-1);
	
	-- External connections : Sphere Center.
	sVx (C*W0-1 downto 0) <= iSphereCenterx;
	sVy (C*W0-1 downto 0) <= iSphereCentery;
	sVz (C*W0-1 downto 0) <= iSphereCenterz;
	oRayx <= sVx ((D+1)*C*W0-1 downto D*C*W0-1);
	oRayy <= sVy ((D+1)*C*W0-1 downto D*C*W0-1);
	oRayz <= sVz ((D+1)*C*W0-1 downto D*C*W0-1);	
	

	gridArray: for i in 0 to D-1 generate
	
		gridn: rayxsphereGrid
		generic map (
		IDW = IDW,
		C	= C,
		W0	= W0,
		W1	= W1 );
		port map (
		clk				=> clk,
		rst				=> rst,
		pipeOn			=> pipeOn,
		nxtSphere		=> nxtSphere,
		iRayx			=> iRayx ((i+1)*W0-1 downto i*W0),
		iRayy			=> iRayy ((i+1)*W0-1 downto i*W0),
		iRayz			=> iRayz ((i+1)*W0-1 downto i*W0),
		iSphrCenterx	=> sVx((i+1)*C*W0-1 downto i*C*W0),
		iSphrCentery	=> sVy((i+1)*C*W0-1 downto i*C*W0),
		iSphrCenterz	=> sVz((i+1)*C*W0-1 downto i*C*W0),
		oSphrCenterx	=> sVx((i+2)*C*W0-1 downto (i+1)*C*W0),
		oSphrCentery	=> sVy((i+2)*C*W0-1 downto (i+1)*C*W0),
		oSphrCenterz	=> sVz((i+2)*C*W0-1 downto (i+1)*C*W0),
		oRayx			=> oRayx ((i+1)*W0-1 downto i*W0),
		oRayy			=> oRayy ((i+1)*W0-1 downto i*W0),
		oRayz			=> oRayz ((i+1)*W0-1 downto i*W0),
		kInput			=> sK((i+1)*C*W1-1 downto i*C*W1),
		kOutput			=> sK((i+2)*C*W1-1 downto (i+1)*C*W1),
		refvd			=> refvd((i+1)*W1-1 downto i*W1),
		selvd			=> selvd((i+1)*W1-1 downto i*W1),
		colid			=> colid((i+1)*IDW-1 downto i*IDW),
		inter			=> inter(i)
		);
	end generate;

end rtl;
		