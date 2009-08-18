-- Autor
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
 
entity uart is
	port(
		
		rst			: in  std_logic;                      -- reset control signal
		clk			: in  std_logic;                      -- 100 MHz on PLL
		
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

end entity;
 
 
architecture rtl of uart is
 
	-------------------------------------------------------------------------------
	-- Ticks 
	-------------------------------------------------------------------------------
	--constant T50MHZ_54NS	: integer := 27;    --  27 T50MHZ_540NS, 1 16 avo de bit
	constant TBIT			: integer := 434/4;	--   15 1 bit
	constant THALF_BIT		: integer := 217/4;	--  7 1/2 bit
	-------------------------------------------------------------------------------
	-- Maquinas de Estado
	-------------------------------------------------------------------------------
	type tTxStateMachine is (WAITING_LOAD_TX,SET_STARTBIT_TX,SET_NBIT_TX,FINISH_TX);
	type tRxStateMachine is (WAIT_START_BIT,HOLD_STARTBIT_RX,WAIT_FOR_NEW_BIT_RX,SAMPLE_BIT_RX,SAMPLE_STOPBIT_RX);--,RX_OVF,DEBUGGING_RX);
	signal sTxState      : tTxStateMachine;
	signal sRxState      : tRxStateMachine;
	-------------------------------------------------------------------------------
	-- Baud Rate Signals : Bit 16th bit16, Bit half bit2, Entire Bit bit1.
	-------------------------------------------------------------------------------
	signal bit2   : std_logic;                      -- 1/2 BAUDIO
	signal bit1   : std_logic;                      -- 1 BAUDIO
	-------------------------------------------------------------------------------
	-- Registros de Transmision
	-------------------------------------------------------------------------------
	signal sTxDataInReg     : std_logic_vector(7 downto 0);  -- Registro de precarga de salida
	signal sShiftTxData   	: std_logic_vector(9 downto 0);  -- Registro de corrimiento de salida
	
	-------------------------------------------------------------------------------
	-- Registros de Recepcion
	-------------------------------------------------------------------------------
	signal sShiftRxData     : std_logic_vector(7 downto 0);	-- Registro de corrimiento de llegada.
	signal sSyncRxCounter   : std_logic;                    -- Señal de sincronizacion para el contador de medio bit.
	signal sEnableTxCounter	: std_logic;					-- Señal de sincronizacion para conteo de un bit entero en la transmision.						
	signal sRx0, sRx1		: std_logic;					-- Señal Rx Registrada
 
begin
 
	------------------------------------------------------------------------------
	--             Countador Principal de Transmision                        --- 
	-------------------------------------------------------------------------------
	txCntr:
	process(rst,clk)
		variable counter : integer range 0 to 1023;
	begin
		if rst = '0' then
		
			bit1 <= '0';
			counter := 0;
		
		elsif rising_edge(clk) then

			bit1 <= '0';
			if sEnableTxCounter ='0' then
				counter := 0;
			elsif counter = TBIT then 
				bit1 <= '1';
				counter := 0;
			else
				counter := counter + 1;
			end if;
			
		end if;
	end process;
 
 

	------------------------------------------------------------------------------
	-- Countador Principal de Transmision  (115200 bps : 1/2 Baudio con 8 Ticks => 1 Tick / 54 ns)
	-- Adicionalmente este contador usa la señal sSyncRxCounter, para resetearlo.
	-------------------------------------------------------------------------------
	rxCntr:
	process(rst, clk)
		variable counter : integer range 0 to 1023;
	begin
	
		if rst = '0' then
			bit2 <= '0';
			counter := 0;
		elsif rising_edge(clk) then
			bit2 <= '0';
			if sSyncRxCounter = '1' then
				counter:=0;
				
			elsif counter = THALF_BIT then 
				-- Reset el contador y marcar medio bit.
				bit2 <= '1';
				counter := 0;
			else
				counter := counter + 1;
			end if;
		end if;
	
	end process;  
 
 
	-------------------------------------------------------------------------------
	-- Maquina de estado de transmision
	-------------------------------------------------------------------------------
	txFSM:
	process(rst, clk)
		variable counter : integer range 0 to 15;
	begin
		if rst = '0' then
		
			-- Seleccionar estado de espera.
			sTxState		<= WAITING_LOAD_TX;
			
			-- Registro de corrimiento en 1. De esa manera se pone automaticamente la linea de transmision en 1.
			sShiftTxData    <= (others => '1');
			
			-- Deshabilitar el contador de transmision (canal libre).
			sEnableTxCounter <= '0';			
		
		elsif rising_edge(clk) then
		
			case sTxState is
			
				when WAITING_LOAD_TX =>
					
					if TxLoad = '1' then
					
						-- Cargar Dato
						sTxDataInReg <= TxDataIn;						
						
						-- Siguiente estado : Cargar bit 
						sTxState  <= SET_STARTBIT_TX;
			
						-- Habilitar el contador de Tx  (canal ocupado)
						sEnableTxCounter <= '1';				
					
					end if;
 
				when SET_STARTBIT_TX =>
					
					if bit1 = '1' then -- Esperar a que transcurra el tiempo de un bit.
				
						-- 0 avo bit
						counter := 1;

						-- Colocar el startbit
						sShiftTxData(9 downto 0) <= '1' & sTxDataInReg(7 downto 0) & '0'; -- Enviar START BIT 
               
						-- Pasar a esperar tbit para colocar el siguiente bit de datos en la linea tx
						sTxState <= SET_NBIT_TX; -- Cargar siguiente dato 
					
					end if;
 
				when SET_NBIT_TX =>
             
					if bit1 = '1' then -- Paso un bit
						
						-- Contar el numero de datos enviados
						counter := counter + 1; -- Calcular el numero de datos - 1 enviados
						
						-- Correr el registro de y transmitir el ultimo bit.
						sShiftTxData(9 downto 0) <= '1' & sShiftTxData(9 downto 1);
						
						if counter = 10 then -- 10 bits enviados parar.
							
							-- Ir al estado de finalizacion de la transmision
							sTxState <= FINISH_TX;

							
               
						end if;
					
					end if;
 
				when FINISH_TX => -- stop bit
					
					if bit1 = '1' then
						
						-- Estado Ocioso 
						sTxState <= WAITING_LOAD_TX;
						
						-- Deshabilitar el contador de transmision y declarar el canal de transmision libre.
						sEnableTxCounter <= '0';
             
					end if;             
 
				when others =>
				
					-- Si no se sabe el estado entonces ir a finish para liberar el canal.
					sTxState <= FINISH_TX;
			
			end case;
    
		end if;
	
	end process;
 
	-- Declarar el canal como ocupado o desocupado si el contador de transmision está encendido o apagado respectivamente
	TxBusy <= sEnableTxCounter;
	Tx <= sShiftTxData(0);
 
 
  -------------------------------------------------------------------------------
  -- Reception process
  -------------------------------------------------------------------------------
	rxFSM: process(rst, clk)
		variable counter : integer range 0 to 127;
	begin
		if rst = '0' then
			
			RxDataOut <= (others => '1');
			RxRdy <= '0';
			sShiftRxData <= (others => '1'); 
			sRxState <= WAIT_START_BIT;
			sRx0<='1';
			sRx1<='1';
			
		elsif rising_edge(clk) then
 
 
			
			RxRdy <= '0';	
			sSyncRxCounter <='0';
 			
			-- Doble FF para la sincronizaciòn de Rx. Esto no funciona muy bien con PLL.
			-- Preguntar a Alejandra.
			sRx0 <= Rx;
			sRx1 <= sRx0;
			
			case sRxState is
				
				when WAIT_START_BIT =>  -- Wait start bit
					
					if (sRx1 and not(sRx0))='1' then -- Si hay un Flanco de bajada
						
						-- Siguiente estado : esperar que pase el bit de start
						sRxState <= HOLD_STARTBIT_RX;
						
						-- Sincronizacion contador
						sSyncRxCounter <='1';
						
						
						-- Vamos en el primer bit.
						counter := 0;
						
					end if;
					
					
 
				when HOLD_STARTBIT_RX =>
             
					if bit2 = '1' then -- Nos encontramos en la mitad del baudio del start bit. Ahora lo muestreamos sin cargarlo ;)                  
               
						sRxState <= WAIT_FOR_NEW_BIT_RX; -- Siguiente estado es detectar nuevo bit.
             	
					end if;
 
 
				when WAIT_FOR_NEW_BIT_RX => 
             
					if bit2 = '1' then -- En este momento nos encontramos en el comienzo de un bit.
					
						if counter = 8 then -- Si hemos leido el OCTAVO bit entonces el que sigue es el NOVENO bit  (STOP BIT)
						
							sRxState <= SAMPLE_STOPBIT_RX; -- Ir al estado de lectura del stop bit.					
               
						else                        
                 
							sRxState <= SAMPLE_BIT_RX;-- Ir al estado de carga de un bit de datos.
               
						end if;
             
					end if;
 
       
				when SAMPLE_BIT_RX =>
             
					if bit2 = '1' then -- Nos encontramos en la mitad de un baudio. Muestrear el bit correspondiente.
               
						--Contar el numero de bits leidos.
						counter := counter + 1;
						
						--Cargar el bit que se encuentra en la linea RX (después del flip flop para evitar metaestabilidad)
						sShiftRxData(7 downto 0) <= sRx0 & sShiftRxData(7 downto 1); 
               
						-- Siguiente estado : Detectar nuevo baudio.
						sRxState <= WAIT_FOR_NEW_BIT_RX;
						
					end if;
 
 
        
				when SAMPLE_STOPBIT_RX =>
             
					if bit2 = '1' then -- Estamos en la mitad del stop bit.
               
						-- Cargar el dato del shift register al buffer de salida.
						RxDataOut <= sShiftRxData;
						
						-- Siguiente estado: Ocioso, esperando por un start bit.
						sRxState <= WAIT_START_BIT;
						
						-- Avisar que está listo el dato.
						RxRdy <='1';
             
					end if;
 
        
				when others => 
					
					sRxState <= WAIT_START_BIT;
      
			end case;
    
		end if;
  
	end process;
 
end rtl;

