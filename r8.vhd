library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity r8 is
	port (
		
		
		clk, ena: in std_logic; -- The usual control signals.
		
		wen		: in std_logic_vector	(3 downto 0);
		add		: in std_logic_vector	(11 downto 0);
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
	bt81_inst : bt81 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(0),
			q	 	=> K
		);
	-- 	Vx, Vy, VZ registers
	bt84x : bt84 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(3),
			q	 	=> Vx
		);
	bt84y : bt84 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(2),
			q	 	=> Vy
		);
	bt84z : bt84 
		port map (
			address => add,
			clken	=> ena,
			clock	=> clk,
			data	=> datain,
			wren	=> wen(1),
			q	 	=> Vz
		);
	

end;
