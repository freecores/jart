-- Author : Julian Andres Guarin Reyes.
-- Project : JART, Just Another Ray Tracer.

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
	
	
-- The following HDL is a dot product calculator.  V and D are the vectors to be processed. 
-- Vx,Vy,Vz,Dx,Dy,Dz are the vectors components.
-- vn_A7_10, vn_A7_10 are both signed fixed representations of vectorial components where 7 bits are for the integer part and
-- 10 bits are for the decimal part.
-- vd_A15_16 is the signed fixed representation of the V and D dot product operation, where 15 bits are for the integer part and 
-- 16 bits are for the decimal part. 


library ieee;
use ieee.std_logic_1164.all;

-- Fixed Point Representation :
-- 
-- A(7,10) signed 18 bits fixed point representation :
--	1 bit for sign
--	7 bits for integer part (128) numbers.
--	10 bits for decimal part (1024) numbers. 
-- Representation Range = -128, 128-(1/1024)
-- Decimal part Resolution : 1/1024 = 0.00098 aprox, 0.001


entity bl00 is 
	port (
		-- <vx, vy, vz> y <dx, dy, dz> fixed point A(7,10) => 18 bits de representacion.
		vx_A7_10	: in std_logic_vector (17 downto 0);
		vy_A7_10	: in std_logic_vector (17 downto 0);
		vz_A7_10	: in std_logic_vector (17 downto 0);
		

		dx_A7_10 : 	in std_logic_vector (17 downto 0);
		dy_A7_10 : 	in std_logic_vector (17 downto 0);
		dz_A7_10 : 	in std_logic_vector (17 downto 0);

		-- <vxdx + vydy + vzdz> fixed point A(15,6) => 32 bits de representacion.
		vd_A15_16 :	out std_logic_vector (31 downto 0)
	
	);
	
end entity;


architecture rtl of bl00 is 

	signal px :	std_logic_vector (31 downto 0); -- Producto A(15,20), se trunca despues a A(15,16)
	signal py :	std_logic_vector (31 downto 0); -- Producto A(15,20), se trunca despues a A(15,16)
	signal pz :	std_logic_vector (31 downto 0); -- Producto A(15,20), se trunca despues a A(15,16)
	signal s0 :	std_logic_vector (31 downto 0); -- Suma : A(15,16) + A(15,16) = A(15,16) = 31 bits de representacion. 
	
	

	component mult_A15_20 
	port
	(
		dataa		: in std_logic_vector(17 downto 0);
		datab		: in std_logic_vector(17 downto 0);
		result		: out std_logic_vector (35 downto 0)
	);
	end component;
	
	component add_A15_16
	port
	(
		dataa		: in std_logic_vector (31 downto 0);
		datab		: in std_logic_vector (31 downto 0);
		result 		: out std_logic_vector(31 downto 0)
	);
	end component;
	
	
	

begin
	-- Productos, trunco de una vez 4 bits para performance y espacio.
	vxdx : mult_A15_20 port map (dataa=>vx_A7_10, datab=> dx_A7_10, result(35 downto 4) => px);
	vydy : mult_A15_20 port map (dataa=>vy_A7_10, datab=> dy_A7_10, result(35 downto 4) => py);
	vzdz : mult_A15_20 port map (dataa=>vz_A7_10, datab=> dz_A7_10, result(35 downto 4) => pz); 
		
	-- Sumas de 32 bits A(21,10).

	add0 : add_A15_16 port map (dataa=> px, datab => py , result=>s0(31 downto 0));
	add1 : add_A15_16 port map (dataa=> s0, datab => pz , result=>vd_A15_16(31 downto 0));

end rtl;


