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
	

-- *****************************************************************************************
-- This Block is the entire ray sphere intersection unit. An intersection unit is governed by the expression:

-- V.D +- ((V.D)^2 - (V^2-R^2))^2
-- So theres a root square.... if this root square has a non complex value, then a ray sphere intersection exists.
-- After several ray tracing algorithm performance simulations, I found that the most repeated operation is dot product and comparison. This are two operations that are performed when solving the root square inner expression. This expression is called discriminant. 
-- That result can be interpreted as follows : the performance improvement or decay comes through when more or less discriminants are solved by time unit.
-- We assume that V^2 - R^2 is a contant because V is the position of the shpere in terms of the observer and R is the sphere's radius neither of those change in the frame calculation, we are going to call the root square of this expression the constant Ks.


-- We have then the inequality:
--	(V.D)^2 - (V^2-R^2) >= 0	(1)
--	(V.D)^2>=(V^2-R^2) 		(2)  
--	(V.D)>=(V^2-R ^2)^(1/2)	(3)
--	(V.D)>=Ks				(4)

-- Assuming that there are more "no intersections" than "intersections" for all the V.D>=Ks pairs, is then a good stategy to use the (4) inequality instead of the (2) inequality because this way thre is a saving in time and silicon space, due of the lack of need an additional multiplication V.D x V.D.
-- ******************************************************************************************************
-- Using the altera quartus ii simulator, it was concluded that a combinatorial propagation time is larger than a 50 MHz frecuency period of about 25 - 32 ns. The obvious solution was to split the dot product and the comparison in a two stage pipe:

--				(V.D)->	FF->	(V.D>=Ks?)->	1/0 
--				Stage1		Stage2		Result.

-- This Block of code is devoted to instantiate the dot product, the comparison and to separate this operations in a two stage pipeline


library ieee;
use ieee.std_logic_1164.all;




entity bl02 is
	port (
		-- Global control. 50 MHZ clk.
		rst:	in std_logic;
		clk:	in std_logic;
		
		-- Centro Esfera
		Vx :	in std_logic_vector (17 downto 0);
		Vy :	in std_logic_vector (17 downto 0);
		Vz :	in std_logic_vector (17 downto 0);
		
		-- Direccion Rayo
		Dx :	in std_logic_vector (17 downto 0);
		Dy :	in std_logic_vector (17 downto 0);
		Dz :	in std_logic_vector (17 downto 0);
		
		-- Sqrt(V² - r²)
		K :	in std_logic_vector (31 downto 0);
		
		-- Producto punto 
		VD :	out std_logic_vector (31 downto 0);
		
		-- Interseccion
		Iok : 	out std_logic
		
	);
	
end entity;
		
			
		
		
architecture rtl of bl02 is 

	-- Component Headers (perhaps they should be on a package file).

	component bl00 
	port (
			-- <vx, vy, vz> y <dx, dy, dz> fixed point A(10,7) => 18 bits de representacion.
		vx_A7_10	: in std_logic_vector (17 downto 0);
		vy_A7_10	: in std_logic_vector (17 downto 0);
		vz_A7_10	: in std_logic_vector (17 downto 0);
		

		dx_A7_10 	: in std_logic_vector (17 downto 0);
		dy_A7_10 	: in std_logic_vector (17 downto 0);
		dz_A7_10 	: in std_logic_vector (17 downto 0);

		-- <vxdx + vydy + vzdz> fixed point A(23,8) => 32 bits de representacion.
		vd_A15_16 :	out std_logic_vector (31 downto 0)
	
	);
	end component;
	
	component bl01 
	port (
		vd		: in std_logic_vector(31 downto 0);
		k		: in std_logic_vector(31 downto 0);
		i		: out std_logic
	);
	end component;
	
	
	
	-- V.D pipe signals in order to achieve 50 MHZ.
	signal vd_d :	std_logic_vector (31 downto 0);
	signal vd_q :	std_logic_vector (31 downto 0);
	

begin

	--Stage 1 : Instantiate Dot Product.
	dotprod : bl00 port map(
			vx_A7_10 => Vx, 
			vy_A7_10 => Vy, 
			vz_A7_10 => Vz, 
			dx_A7_10 => Dx,
 			dy_A7_10 => Dy,
			dz_A7_10 => Dz,
			vd_A15_16 => vd_d
			);
			
	--Stage 2 : Instantiate Comparison.		
	compare : bl01 port map(vd => vd_q, k => K, i => Iok);
	
	pipe : process (rst,clk)
	begin
		if rst = '1' then
			
			-- De esta manera siempre sera el numero mas pequeño cuando haya reset.
			vd_q (30 downto 0) <= (others => '0');
			vd_q (31) <= '1';
		
		elsif rising_edge(clk) then
			
			-- Pipe.
			vd_q <= vd_d;
		
		end if;
	end process;

	-- Conectar el Pipe 0 a la salida en VD.
	VD <= vd_d;

end rtl;
	
