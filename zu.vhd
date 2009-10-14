library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity zu is 
	generic
	(
		VALSTART		: integer := 2
	);
	port (
	
		clk, rst, ena 	: in std_logic; -- The usual control signals
		clr				: in std_logic;
		zpos			: out integer range 0 to 1023
		
	);

end entity;

architecture rtl of zu is
	
begin

	process (clk,rst,ena,clr)
		variable pivot	: integer range 0 to 15;
		variable z	 	: integer range 0 to 1023;
	begin
		
		if rst='0' then
		
			zpos<=VALSTART;
			z:=VALSTART;
			pivot:=1;
		
		elsif rising_edge(clk) and ena='1' then
				
			if clr='1' then
				z:=VALSTART;
				pivot:=0;
			elsif pivot=4 then 
				z:=z+2;
			elsif pivot=9 then
				z:=z+1;
			else
				z:=z+3;
			end if;
			
			if pivot = 9 then
				pivot := 0;
			else
				pivot:=pivot+1;
			end if;
			zpos <= z;
		
		end if;	
	
	end process;

end rtl;

		
		