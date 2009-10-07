library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity r2 is
	port (
		
		
		clk, ena: in std_logic; -- The usual control signals.
		
		wen		: in std_logic_vector	(3 downto 0);
		add		: in std_logic_vector	(9 downto 0);
		datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
		Vx		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vy		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vz		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		K		: out std_logic_vector	(BUSW-1 downto 0)
	);
	
end entity;



architecture rtl of r8 is

begin 
	
	-- K Register
	bt21_inst : bt21 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(0),
			q	 	=> K
		);
	-- 	Vx, Vy, VZ registers
	bt24x : bt24 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(3),
			q	 	=> Vx
		);
	bt24y : bt24 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(2),
			q	 	=> Vy
		);
	bt24z : bt24 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(1),
			q	 	=> Vz
		);
	

end;
