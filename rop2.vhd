library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity rop2 is
	generic (
		SZMODE	: integer	:= SZBETA 	-- By default use the 50% of the max memory for sphere register block.
	);
	port (
		
		
		clk, ena: in std_logic; -- The usual control signals.
		wen		: in std_logic_vector	(7 downto 0);
		add		: in std_logic_vector	(REGSZADD(OP2)-SZMODE downto 0);
		datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
		Vx		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vy		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vz		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		K		: out std_logic_vector	(2*BUSW-1 downto 0)
	);
	
end entity;


architecture rtl of rop1 is 

begin 

	if SZMODE = SZALFA generate
	
		for i in generate 0 to 1 generate
			r4_inst : r4 
			port map (
				clk		=> clk,
				ena		=> ena,
				wen		=> wen((i+1)*4-1 downto i*4),
				add		=> add,
				datain	=> datain,
				Vx		=> Vx((i+1)*HBUSW-1 downto i*HBUSW),
				Vy		=> Vy((i+1)*HBUSW-1 downto i*HBUSW),
				Vz		=> Vz((i+1)*HBUSW-1 downto i*HBUSW),
				K		=> K((i+1)*HBUSW-1 downto i*HBUSW)
			);
		end generate

	end generate;
	
	if SZMODE = SZBETA generate
		for i in generate 0 to 1 generate
			r2_inst : r2 
			port map (
				clk		=> clk,
				ena		=> ena,
				wen		=> wen((i+1)*4-1 downto i*4),
				add		=> add,
				datain	=> datain,
				Vx		=> Vx((i+1)*HBUSW-1 downto i*HBUSW),
				Vy		=> Vy((i+1)*HBUSW-1 downto i*HBUSW),
				Vz		=> Vz((i+1)*HBUSW-1 downto i*HBUSW),
				K		=> K((i+1)*HBUSW-1 downto i*HBUSW)
			);
		end generate
	end generate
	
			
			
			

end rtl;