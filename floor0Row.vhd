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
			W1 : integer := 32;	-- Next Level Width (V.D width)
			W0 : integer := 18;	-- Vector input Width
			C	: integer := 4	 	-- Number of Colums
	);
	port (	-- Input Control Signal
			clk, rst, nxtRay : in std_logic;
			-- Clk, Rst, the usual control signals.
			-- enabled, the machine is running when this input is set.
			-- enabled, all the counters begin again.
			nxtSphere : in std_logic_vector (C-1 downto 0); 	
				 
				
			-- Input Values
			iRayx: in std_logic_vector (W0 - 1 downto 0);
			iRayy: in std_logic_vector (W0 - 1 downto 0);
			iRayz: in std_logic_vector (W0 - 1 downto 0); -- The ray input vector.
			iSphrCenterx: in std_logic_vector (C*W0 - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			iSphrCentery: in std_logic_vector (C*W0 - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			iSphrCenterz: in std_logic_vector (C*W0 - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCenterx: out std_logic_vector (C*W0 - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCentery: out std_logic_vector (C*W0 - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCenterz: out std_logic_vector (C*W0 - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
				
			-- Output Values
			oRayx: out std_logic_vector (W0 - 1 downto 0);-- The ray output vector.
			oRayy: out std_logic_vector (W0 - 1 downto 0);-- The ray output vector.
			oRayz: out std_logic_vector (W0 - 1 downto 0);-- The ray output vector.
			vdOutput : out std_logic_vector (W1*C - 1 downto 0) -- The dot product emerging from each dot prod cell. 
	);
end entity;
				
architecture rtl of floor0Row is

	signal sRayx	: std_logic_vector ((C+1)*W0 - 1 downto 0);	-- The ray difussion nets.
	signal sRayy	: std_logic_vector ((C+1)*W0 - 1 downto 0);	-- The ray difussion nets.
	signal sRayz	: std_logic_vector ((C+1)*W0 - 1 downto 0);	-- The ray difussion nets.
	
begin

	theCells : for i in 0 to C-1 generate
	
		dotCellx : dotCell 
		generic map (
			RV => "no"
		)
		port map (
			
			clk			=> clk,
			rst			=> rst,
			nxtSphere	=> nxtSphere(i),
			nxtRay		=> nxtRay,
			vxInput		=> iSphrCenterx((i+1)*W0-1 downto i*W0),
			vyInput		=> iSphrCentery((i+1)*W0-1 downto i*W0),
			vzInput		=> iSphrCenterz((i+1)*W0-1 downto i*W0),
			vxOutput	=> oSphrCenterx((i+1)*W0-1 downto i*W0),
			vyOutput	=> oSphrCentery((i+1)*W0-1 downto i*W0),
			vzOutput	=> oSphrCenterz((i+1)*W0-1 downto i*W0),
			dxInput		=> sRayx ((i+1)*W0-1 downto i*W0),
			dyInput		=> sRayy ((i+1)*W0-1 downto i*W0),
			dzInput		=> sRayz ((i+1)*W0-1 downto i*W0),
			dxOutput	=> sRayx ((i+2)*W0-1 downto (i+1)*W0),
			dyOutput	=> sRayy ((i+2)*W0-1 downto (i+1)*W0),
			dzOutput	=> sRayz ((i+2)*W0-1 downto (i+1)*W0),
			vdOutput	=> vdOutput((i+1)*W1-1 downto i*W1)
			);

	end generate;

	-- Connect the first and last rays.
	sRayx (W0-1 downto 0)	<= iRayx;
	sRayy (W0-1 downto 0) 	<= iRayy;
	sRayz (W0-1 downto 0) 	<= iRayz;
	oRayx 					<= sRayx ((C+1)*W0 - 1 downto C*W0);
	oRayy					<= sRayy ((C+1)*W0 - 1 downto C*W0);
	oRayz					<= sRayz ((C+1)*W0 - 1 downto C*W0);

end rtl;
				
				