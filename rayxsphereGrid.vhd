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


library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity rayxsphereGrid is 
	generic (
	-- Width of Column identificator.
	IDW	: integer := 2;
	-- Number of Columns.
	C	: integer := 4;	
	-- Input rays width.
	W0	: integer := 18;
	-- Dot products and spheres constant width
	W1	: integer := 32;
	
	);
	port (
	-- The usual control signals.
	clk,rst	: in std_logic;
	
	-- Grid, rays and sphere flow through control signals.
	pipeOn			: in std_logic;
	nxtSphere		: in std_logic_vector (C-1 downto 0);
	
	-- R-F0
	-- Input Values. 
	-- The ray input vector.
	iRayx: in std_logic_vector (W0 - 1 downto 0);
	iRayy: in std_logic_vector (W0 - 1 downto 0);
	iRayz: in std_logic_vector (W0 - 1 downto 0); 
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
	oRayx: out std_logic_vector (W0 - 1 downto 0);
	oRayy: out std_logic_vector (W0 - 1 downto 0);
	oRayz: out std_logic_vector (W0 - 1 downto 0);
	
	-- R-F1
	-- K Input / Output.
	kInput	: in std_logic_vector (C*W1 - 1 downto 0); 
	kOutput	: out std_logic_vector (C*W1 - 1 downto 0)  
	
	--R-F2
	-- Input Values
	refvd	: in std_logic_vector (W1-1 downto 0);
	selvd	: out std_logic_vector (W1-1 downto 0);
	colid	: out std_logic_vector (IDW-1 downto 0);
	inter	: out std_logic
	);
end entity;

architecture rtl of rayxsphereGrid is

	-- Signal to connect outgoing floor0 vd and ingoing floor1 vd.
	signal svdf0f1	: std_logic_vector (C*W1-1 downto 0);
	signal svdf1f2	: std_logic_vector (C*W1-1 downto 0);
begin
	RF0 : floor0Row 
	generic map(
	nlw=W1,
	viw=W0,
	col=C );
	port map(
	clk				=> clk,
	rst				=> rst,
	nxtRay			=> pipeOn,
	nxtSphere		=> nxtSphere,
	iRayx			=> iRayx,
	iRayy			=> iRayy,
	iRayz			=> iRayz,
	iSphrCenterx	=> iSphrCenterx,
	iSphrCentery	=> iSphrCentery,
	iSphrCenterz	=> iSphrCenterz,
	oSphrCenterx	=> oSphrCenterx,
	oSphrCentery	=> oSphrCentery,
	oSphrCenterz	=> oSphrCenterz,
	oRayx			=> oRayx,
	oRayy			=> oRayy,
	oRayz			=> oRayz,
	vdOutput		=> svdf0f1
	);
	RF1 : floor1Row
	generic map (
	viw = W1,
	col = C );
	port map (
	clk				=> clk,
	rst				=> rst,
	pipeOn			=> pipeOn,
	nxtSphere		=> nxtSphere,
	vdInput			=> svdf0f1,
	vdOutput		=> svdf1f2,
	kInput			=> kInput,
	kOutput			=> kOutput
	);
	RF2 : floor2Row
	generic map (
	viw = W1,
	idColW = IDW,
	col = C );
	port map (
	clk				=> clk,
	rst				=> rst,
	pipeOn			=> pipeOn,
	refvd			=> refvd,
	selvd			=> selvd,
	colvd			=> svdf1f2,
	colid			=> colid,
	inter			=> inter
	);
		
end rtl;