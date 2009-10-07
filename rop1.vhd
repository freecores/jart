library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity rop1 is
	generic (
		SZMODE	: integer	:= SZBETA 	-- By default use the 50% of the max memory for sphere register block.
	);
	port (
		
		
		clk, ena: in std_logic; -- The usual control signals.
		wen		: in std_logic_vector	(3 downto 0);
		add		: in std_logic_vector	(REGSZADD(OP1)-SZMODE downto 0);
		datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
		Vx		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vy		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vz		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		K		: out std_logic_vector	(BUSW-1 downto 0)
	);
	
end entity;


architecture rtl of rop1 is 

begin 

	if SZMODE = SZALFA generate
	
		r8_inst : r8 
		port map (
			clk		=> clk,
			ena		=> ena,
			wen		=> wen,
			add		=> add,
			datain	=> datain,
			Vx		=> Vx,
			Vy		=> Vy,
			Vz		=> Vz,
			K		=> K
		);
	end generate
	if SZMODE = SZBETA generate
		r4_inst : r4 
		port map (
			clk		=> clk,
			ena		=> ena,
			wen		=> wen,
			add		=> add,
			datain	=> datain,
			Vx		=> Vx,
			Vy		=> Vy,
			Vz		=> Vz,
			K		=> K
		);
	end generate
	
			
			
			

end rtl;