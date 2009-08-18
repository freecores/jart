-- Autor Julian Andres Guarin
-- Control Principal
library ieee;
use ieee.std_logic_1164.all;


entity rt is 
	port (
		rst	: in std_logic;
		clk : in std_logic;
		Rx	: in std_logic;
		Tx	: out std_logic;
		Led	: in std_logic_vector (3 downto 0)
	);
end entity;


architecture rtl of rt is

	component uart
	port (
		rst			: in  std_logic;                      -- reset control signal
		clk			: in  std_logic;                      -- 50MHZ
		
		-- Reception channel
		Rx 			: in  std_logic;                      -- Linea de entrada RS232
		RxDataOut	: out std_logic_vector(7 downto 0);   -- Buffer de salida
		RxRdy		: out std_logic;                      -- Bandera para indicar que el dato esta listo 
		
		
		-- Transmition channel
		Tx 			: out std_logic;                      -- Linea de salida RS232
		TxDataIn	: in  std_logic_vector(7 downto 0);   -- Buffer de entrada 
		TxLoad     	: in  std_logic;                      -- Señal de carga
		TxBusy      : out std_logic                      -- Bandera de Canal ocupado
	);
	end component;
	
	signal sRxRdy	: signal std_logic;						-- Salida señal lista. 
	signal sRxBuff	: signal std_logic_vector (7 downto 0);	-- Buffer de almacenamiento (entrada)
	signal sTxBuff	: signal std_logic_vector (7 downto 0); --Buffer de almacenamiento (salida)						-- 
	signal sTxLoad	: signal std_logic;						-- Señal de carga hacia afuera
	signal sTxBusy	: signal std_logic;						-- Indicador de Bus Ocupado
	
begin
	-- Serial Interface
	serialIo : uart port map (	rst	=> rst,
							clk	=> clk,
							Rx	=> Rx,
							RxDataOut	=> sRxBuff,
							RxRdy	=> sRxRdy,
							Tx	=> Tx,
							TxDataIn	=> sTxBuff,
							TxLoad	=> sTxLoad,
							TxBusy	=> sTxBusy );
							
							
	loopback : process ( rst, clk)
	begin
	
		if rst='0' then
			Led(3) <= '0';
		elsif rising_edge(clk) and RxRdy='1' then
			Led(3) <= '1';
		end if;
	
	end process;
	



end rtl;
	

