library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity p1ax is 
	generic (	W	: integer := 36 );
	
	port	(	
				clk,rst,enable		: in std_logic;	-- The usual control signals.
				dataa,datab,datac	: in std_logic_vector (W-1 downto 0);
				result				: out std_logic_vector (W-1 downto 0)
	);
	
end entity;

architecture rtl of p1ax is 

	signal sdresult	: std_logic_vector (W-1 downto 0);


begin
	
	sdresult <= dataa+datab+datac;

	process (clk,rst,enable)
	begin
	
		if rst = '0' then
			
			result <= (others =>'0');
			
		elsif rising_edge(clk) and enable ='1' then
			
			result <= sdresult;
		
		end if;
	
	end process;
	
	
	
	
end rtl;



-
	
					



