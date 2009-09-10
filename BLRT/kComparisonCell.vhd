library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity kComparisonCell is
	generic (	W 		: integer := 32;
				idW		: integer := 12	
			);
	port (		
				clk		: in std_logic;
				rst		: in std_logic;
	
				
				vdinput	: in std_logic_vector (W-1 downto 0);
				kinput	: in std_logic_vector (W-1 downto 0);
				koutput	: out std_logic_vector (W-1 downto 0);
				
				sDP		: out std_logic_vector (W-1 downto 0); -- Selected dot product.
				
				
	);
	end port;
end entity;


architecture rtl of kComparisonCell is 

	signal sge32	: std_logic;	-- Greater or equal signal

begin

	-- Instantiation of the compare.
	discriminantCompare : ge32 port map (
		dataa	 => vdinput,
		datab	 => kinput,
		AgeB	 => sge32
	);


	-- When sge32 (greater or equal signal) is set then V.D > kte, thus intersection is confirmed and shifting V.D to the distance comparison grid.
	
	intersectionSelector : for i in 0 to W-1 generate

		selector : process (rst,clk)
		begin
			
			if rst='0' then
				
				-- At the beginning set the Maximum over Maximum distance.
				if i = W-1 then
					sDP (i) <= '0';
				else 
					sDP (i) <= '1';
				end if;
				
			elsif rising_edge(clk) then 
				
				if i = W-1 then
					sDP (i) <= sge32 and vdinput(i);
				else
					sDP (i) <= (sge32 and vdinput(i)) or not(sge32);
				end if;
			
			end if;
		
		end process;
			
	end generate; 

	kPipeStage : process (clk,rst)
	begin
	
		if rst='0' then
			
			koutput <= (others => '0');
		
		elsif rising_edge(clk) then
			
			koutput <= kinput;
		
		end if;
	
	end process;



end rtl;


	

	