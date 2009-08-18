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

-- The following code is a 1 Clock Fixed Square Root. Where's the catch? , well I simulate it through a lot of values (not really a simulation, just an openoffice electronic sheet), and found the maximum error is 6%. This error could be huge in terms of precision, but reasonable in terms of 1 CLOCK (maybe 2 CLOCKS) of fxd sq root latency.

library ieee;
use ieee.std_logic_1164.all;

 
-- This is package file in order to mantain smaller code files.
package gsqrt is
	
	-- Indicador ONE HOT del bit mas significativo
	component gMsb
		generic (	W	: integer:=16);
		port	(	DataIn	: in std_logic_vector (2*W-1 downto 0);
				Sel	: out std_logic_vector (W-1 downto 0)
		);
	end component;

	-- Indica la presencia de algun 1 en un par de bits.
	component gPar
		generic ( 	W	: integer:=32);
		port	(	radical	: in std_logic_vector (W-1 downto 0);
				rad_2	: out std_logic_vector ((W/2)-1 downto 0)
		);
	end component;

	-- Calcula el corrimiento del 1 mas significativo a la izquierda y rellena el espacio que se deja.
	component gLeftShift 
		port	(	Sn	: in std_logic_vector ( 1 downto 0 );
				Din	: in std_logic_vector ( 2 downto 0 );
				Dout	: out std_logic_vector ( 1 downto 0 )
		);
	end component;
	
	-- El codificador de prioridad indica cuantas lugares se debe correr las comas. 
	component gMux
		port	(	rawSq	: in std_logic_vector (31 downto 1);
				ohSel	: in std_logic_vector (15 downto 0);	--One Hot Selector
				sQ	: out std_logic_vector (15 downto 0)
		);
	end component;
	

end package;
