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
use work.gsqrt.all;

entity blsqrt is
	port (
		radicando_U22_10	: in std_logic_vector (31 downto 0);
		raizCuadrada_U11_5	: out std_logic_vector (15 downto 0)
	);
end entity;

architecture rtl of blsqrt is

	signal sOhSelector	: std_logic_vector (15 downto 0);
	signal sRawSq		: std_logic_vector (31 downto 0);
	

begin

	-- Seleccionar el bit mas significativo
	priorityEncoder : giraldoMsb port map (	DataIn => radicando_U22_10,
						Sel	=> sOhSelector);

	-- Calcular el valor crudo de los pares
	msbPairShifting :
	for index in 1 to 15 generate
		leftShifting 	: giraldoLeftShift port map (	Sn => sOhSelector(index downto index-1),
								Din => radicando_U22_10 (index*2+1 downto index*2-1),
								Dout => sRawSq(index*2+1 downto index*2));
	end generate;
	lsbPairShifting	: giraldoLeftShift port map (	Sn => sOhSelector (1) & '0',
							Din => radicando_U22_10 (1 downto 0) & '0',
							Dout => sRawSq (1 downto 0));
	-- Realizar el corrimento y multiplexacion para obtener el resultado final.
	fixation	: giraldoMux port map (	rawSq => sRawSq(31 downto 1),
						ohSel => sOhSelector,
						sQ => raizCuadrada_U11_5);

  

end rtl;




























