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
	
	
-- This file is an instantiation of a minimun distance comparers row. The number of dot cells used is parameterizable.
library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity floor2Row is
	generic	(
			viw : integer := 32;	-- Vector input Width
			idColW : integer := 2;	-- ID Column width
			col	: integer := 4;	 	-- Number of Colums
	);
	port (	
			-- Input Control Signal
			-- Clk, Rst, the usual control signals.
			clk, rst, pipeOn: in std_logic;
				
			-- Input Values
			refvd	: in std_logic_vector (viw-1 downto 0);
			selvd	: out std_logic_vector (viw-1 downto 0);
			colvd	: in std_logic_vector (viw*col-1 downto 0);
			colid	: out std_logic_vector (idColW-1 downto 0);
			inter	: out std_logic_vector
	);
end entity;
				
architecture rtl of floor2Row is

	signal srefvd	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The minimun vd difussion nets.
	signal scolid	: std_logic_vector ((col+1)*idColW-1 downto 0); 		-- The column id difussion nets.
	signal sinter	: std_logic_vector ((col+1) - 1 downto 0);		-- The intersection on set, difussion net.
begin

	-- Conexiones hacia afuera!.
	
	sinter(0)<='0';
	scol(idColW-1 downto 0) <= (others=>'0');
	selvd <= srefvd ((col+1)*viw - 1 downto col*viw);
	colid <= scolid ((col+1)*idColW-1 downto col*idColW);
	inter <= sinter(col);

	-- Comparadores.
	compStages : for i in 0 to col-1 generate
	
		compCell : dComparisonCell 
			generic map ( W = viw, idColW = idColW, idCol=i )
			port map (
			
			clk			=> clk,
			rst			=> rst,
			ena			=> pipeOn,
			intd		=> sinter(i),
			intq		=> sinter(i+1),
			cIdd		=> scolid((i+1)*idColW - 1 downto i*idColW),
			cIdq		=> scolid((i+2)*idColW - 1 downto (i+1)*idColW),
			refvd		=> srefvd((i+1)*viw - 1 downto i*viw),
			colvd		=> colvd((i+1)*viw - 1 downto i*viw),
			selvd		=> srefvd((i+2)*viw - 1 downto (i+1)*viw)
			);

	end generate;


end rtl;
				
				