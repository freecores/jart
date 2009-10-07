
-- The Spheres Register Bank.

library ieee;
use ieee.std_logic_1164.all;


entity sphereRegisterBlock is
	generic (
		OPMODE	: integer := OP4; 		-- By default push out 4 spheres at same time.
		SZMODE	: integer := SZBETA;	-- By default the max sphere numbers is 2048, but could be .
	);
	port (
		-- The usual control signals.
		clk, ena: in std_logic; 
		
		-- Write enable signals, address bus.
		wen		: in std_logic_vector	(CIDSZADD(OPMODE(SZINDEX))*4-1 downto 0);	
		add		: in std_logic_vector	(REGSZADD(OPMODE)-SZMODE  downto 0);		
		
		-- incoming data from 32 bits width bus.
		datain	: in std_logic_vector	(BUSW-1 downto 0);	
		
		
		-- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
		Vx		: out std_logic_vector	(OPMODE*HBUSW-1 downto 0); 
		Vy		: out std_logic_vector	(OPMODE*HBUSW-1 downto 0); 
		Vz		: out std_logic_vector	(OPMODE*HBUSW-1 downto 0); 
		K		: out std_logic_vector	(OPMODE*BUSW-1 downto 0)
	);
	
end entity;
		


architecture rtl of sphereRegisterBlock is
	
	

begin

	-- OP1 : output to 1 column
	rb1x : if OPMODE=OP1 generate
		rop1_inst : rop1 
			generic map(
				SZMODE => SZMODE
			)
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
	end generate;
	
	-- OP2 : output to 2 columns
	rb2x : if OPMODE=OP2 generate 
		rop2_inst : rop2 
			generic map(
				SZMODE => SZMODE
			)
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
	end generate;
	
	-- OP24
	rb4x : if OPMODE=OP4 generate 
		rop4_inst : rop4 
			generic map(
				SZMODE => SZMODE
			)
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
	end generate;
	
	
	
 end rtl;		
		
		
	
