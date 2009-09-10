library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.powerGrid.all;


entity dComparisonCell is
	generic	(	W 		: integer := 32;	-- V.D, minDistance and selectD Width 
				idColW	: integer := 2;		-- Column Sphere ID width. 1 = 2 columns max, 2= 4 colums max... and so on.
				idCol	: integer := 0		-- Column Id
	);
	
	
	port 	(
				clk		: in std_logic; 
				rst		: in std_logic;
				
				cIdd	: in	std_logic_vector (idColW - 1 downto 0);	-- This is the reference column identification input.
				cIdq	: out	std_logic_vector (idColW - 1 downto 0);	-- This is the sphere identification output.
				refvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection incoming from the previous cell.
				colvd	: in	std_logic_vector (W - 1 downto 0); 		-- This is the projection of the sphere position over the ray traced vector, a.k.a. V.D! .
				selvd	: out	std_logic_vector (W - 1 downto 0) 		-- This is the smallest value between refvd and colvd.
	)
	end port;
				
				
				
end entity;


architecture rtl of dComparisonCell is 

	signal sl32 : std_logic;	-- This signal indicates if refvd is less than colvd

begin

	-- A less than B comparison, check if colvd is less than refvd, meaning the act V.D less than actual max V.D
	cl32			: l32	port map (	dataa	=> colvd, 
										datab	=> refvd,
										AlB		=> sl32
										);
										
	-- A flip flop with 2 to 1 mux.
	selector		: scanFF	generic map (	W = 32	)
								port map	(	clk 	=> clk,
												rst 	=> rst,
												scLoad 	=> sl32,
												extData => colvd,
												dStage	=> refvd,
												qStage 	=> selvd);
												
												
	colIdSelector : process (clk,rst)
	begin
	
		if rst = '0' then 
			
			--Set max Distance on reset and column identifier	
			cIdq <= CONV_STD_LOGIC_VECTOR(idCol,idColW);
			selvd(W-1) <= '0';
			selvd(W-2 downto 0) <= (others => '1');
			
		elsif rising_edge(clk) then 
		
			if sl32 ='0' then
				
				-- If reference V.D. is less than column V.D then shift the reference id. 
				cIdq <= cIdd;
		
			else 
				
				--If column V.D. is less than
				cIdq <= CONV_STD_LOGIC(idCol,idColW);
			
		end if;
	
	
	end process;
	
	
	

end rtl;