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
	
	
-- This file is an instantiation of a k comparison cells row. The number of dot cells used is parameterizable.
library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity floor1Row is
	generic	(
			viw : integer := 32;	-- Vector input Width
			col	: integer := 4;	 	-- Number of Colums
	);
	port (	
			-- Input Control Signal
			clk, rst	: in std_logic;
			pipeOn		: in std_logic;
			
			-- Clk, Rst, the usual control signals.
			nxtSphere	: in std_logic_vector (col-1 downto 0);

			-- VD Input / Output.
			vdInput	: in std_logic_vector (viw*col-1 downto 0);
			vdOutput: out std_logic_vector (viw*col-1 downto 0);
			
			-- K Input / Output.
			kInput	: in std_logic_vector (viw*col - 1 downto 0); -- The dot product emerging from each dot prod cell. 
			kOutput	: out std_logic_vector (viw*col - 1 downto 0) -- The dot product emerging from each dot prod cell. 
	);
end entity;


architecture rtl of floor1Row is
begin

	theCells : for i in 0 to col-1 generate
	
		kComparisonCellx : kComparisonCell port map (
			
			clk			=> clk,
			rst			=> rst,
			nxtSphere	=> nxtSphere,
			pipeOn		=> pipeOn,
			vdInput		=> vdInput ((i+1)*viw-1 downto i*viw),
			kinput		=> kInput ((i+1)*viw-1 downto i*viw),
			koutput		=> kOutput ((i+1)*viw-1 downto i*viw),
			vdoutput	=> vdOutput ((i+1)*viw-1 downto i*viw)
			);
	
	end generate;



end rtl;


