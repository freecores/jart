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
	
	
-- This file is an instantiation of a dot cells row. The number of dot cells used is parameterizable.
library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity floor0Row is
	generic	(
			nlw : integer := 32;	-- Next Level Width (V.D width)
			viw : integer := 18;	-- Vector input Width
			col	: integer := 4;	 	-- Number of Colums
	);
	port (	-- Input Control Signal
			clk, rst, nxtRay : in std_logic;
			-- Clk, Rst, the usual control signals.
			-- enabled, the machine is running when this input is set.
			-- enabled, all the counters begin again.
			nxtSphere : in std_logic_vector (col-1 downto 0); 	
				 
				
			-- Input Values
			iRayx: in std_logic_vector (viw - 1 downto 0);
			iRayy: in std_logic_vector (viw - 1 downto 0);
			iRayz: in std_logic_vector (viw - 1 downto 0); -- The ray input vector.
			iSphrCenterx: in std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			iSphrCentery: in std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			iSphrCenterz: in std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCenterx: out std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCentery: out std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCenterz: out std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
				
			-- Output Values
			oRayx: out std_logic_vector (viw - 1 downto 0);-- The ray output vector.
			oRayy: out std_logic_vector (viw - 1 downto 0);-- The ray output vector.
			oRayz: out std_logic_vector (viw - 1 downto 0);-- The ray output vector.
			vdOutput : out std_logic_vector (nlw*col - 1 downto 0) -- The dot product emerging from each dot prod cell. 
	);
end entity;
				
architecture rtl of floor0Row is

	signal sRayx	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The ray difussion nets.
	signal sRayy	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The ray difussion nets.
	signal sRayz	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The ray difussion nets.
	
begin

	theCells : for i in 0 to col-1 generate
	
		dotCellx : dotCell port map (
			
			clk			=> clk,
			rst			=> rst,
			nxtSphere	=> nxtSphere(i),
			nxtRay		=> nxtRay,
			vxInput		=> iSphrCenterx((i+1)*viw-1 downto i*viw),
			vyInput		=> iSphrCentery((i+1)*viw-1 downto i*viw),
			vzInput		=> iSphrCenterz((i+1)*viw-1 downto i*viw),
			vxOutput	=> oSphrCenterx((i+1)*viw-1 downto i*viw),
			vyOutput	=> oSphrCentery((i+1)*viw-1 downto i*viw),
			vzOutput	=> oSphrCenterz((i+1)*viw-1 downto i*viw),
			dxInput		=> sRayx ((i+1)*viw-1 downto i*viw),
			dyInput		=> sRayx ((i+1)*viw-1 downto i*viw),
			dzInput		=> sRayx ((i+1)*viw-1 downto i*viw),
			dxOutput	=> sRayx ((i+2)*viw-1 downto (i+1)*viw),
			dyOutput	=> sRayx ((i+2)*viw-1 downto (i+1)*viw),
			dzOutput	=> sRayx ((i+2)*viw-1 downto (i+1)*viw),
			vdOutput	=> vdOutput((i+1)*view-1 downto i*viw)
			);

	end generate;

	-- Connect the first and last rays.
	sRayx (viw-1 downto 0)	<= iRayx;
	sRayy (viw-1 downto 0) 	<= iRayy;
	sRayz (viw-1 downto 0) 	<= iRayz;
	oRayx 					<= sRayx ((col+1)*viw - 1 downto col*viw);
	oRayy					<= sRayy ((col+1)*viw - 1 downto col*viw);
	oRayz					<= sRayz ((col+1)*viw - 1 downto col*viw);

end rtl;
				
				