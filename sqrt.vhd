
-- A 1 clock x 4 stage pipe square root.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.powerGrid.all;

entity sqrt is

	generic (
		W2 : integer := 64
		
	);
	port
	(
		clk,rst,ena : in std_logic;
		
		radical		: in std_logic_vector (W2-1 downto 0);
		root		: out std_logic_vector ((W2/2)-1 downto 0)
	);
end entity;


architecture rtl of sqrt is
	
	constant WP				: integer:= W2/2;
	constant WP_2			: integer:= WP/2;	
	

	signal sa0,sb0,sx0,sy0,sb0_1 		: std_logic_vector (WP-1 downto 0);
	signal sa1,sb1,sx1,sy1,sb1_1,muxs1	: std_logic_vector (WP-1 downto 0);
	signal sa2,sb2,sx2,sy2				: std_logic_vector (WP-1 downto 0);	
	signal localenc1					: integer range 0 to WP-1;
	signal localenc2					: integer range 0 to WP-1;
	signal sho							: std_logic;
	signal a,b,x,y						: std_logic_vector ((W2/2)-1 downto 0);
	signal decoder 						: integer range 0 to (W2/2)-1;
	signal ab,xy						: std_logic_vector (W2-1 downto 0);
	
	
	begin 
	
	-- Logic function signals ...... if some day there's a paper of how this logic circuit works, it will be easier to comprehend this block of code
	sb0_1<=sa0(WP-2 downto 0) & '0';
	signalization : for i in 0 to WP-1 generate
	
		-- Stage 0. Functions for A,B,X and preliminar Y.
		sb0(i)<=radical(i*2);
		sa0(i)<=radical(i*2+1);
		sx0(i)<=sb0(i) or sa0(i);
		sy0(i)<=sb0(i) and sa0(i);
		
		-- Stage 1 : Function for signal Y.
		muxs1(i) <= sy1(i) or (not(sx1(i)) and sb1_1(i));
		
		-- Stage 3 :
		ab(i*2) 	<= b(i);
		ab(i*2+1)	<= a(i);
		xy(i*2)		<= y(i);
		xy(i*2+1)	<= x(i);
		
		
	end generate signalization;
	
	
	
	
	stages: process (rst,clk,ena,sx0,sx1,localenc2)
		variable localenc0	: integer range 0 to WP-1;
	begin
	
		-- Highest signifcant pair enconder : look for the bit pair with the most significant bit.
		localenc0 := WP-1;
		stg0henc: while localenc0>0 loop
			
			exit when (sx0(localenc0)='1');
			localenc0:=localenc0-1;
		end loop;
		
		
	
		
		-- Clocking process;
		if rst='0' then
			-- Stage 1
			sa1<=(others => '0');
			sb1<=(others => '0');
			sx1<=(others => '0');
			sy1<=(others => '0');
			sb1_1<=(others => '0');

			
			-- Stage 2
			sx2<=(others => '0');
			sa2<=(others => '0');
			sb2<=(others => '0');
			sy2<=(others => '0');
			
			
			--Stage 3
			x<=(others => '0');
			y<=(others => '0');
			a<=(others => '0');
			b<=(others => '0');
			
			--Stage 4
			root <= (others=>'0');
			
			
					
		elsif rising_edge(clk) and ena='1' then
			
			-- Stage01 
			sa1<=sa0;
			sb1<=sb0;
			sx1<=sx0;
			sy1<=sy0;
			sb1_1<=sb0_1;
			localenc1<=localenc0;
			
			
			-- Stage12
			sx2<=sx1;
			sa2<=sa1;
			sb2<=sb1;
			sy2<= muxs1;			
			localenc2<=localenc1;
			
			-- Stage 23 Shift 1 bit to right if the high bit in the highest significant pair is set.
			if sa2(localenc2)='1' then
				-- Shift Right
				a <= '0' & sb2(WP-1 downto 1);
				b <= sa2;
				x <= '0' & sy2(WP-1 downto 1);
				y <= sx2;
				
			else
				-- Leave me alone
				x <= sx2;
				y <= sy2;
				a <= sa2;
				b <= sb2;
			end if;
			
			decoder<=localenc2;
			sho<=sa2(localenc2);
			
			-- stage34
			for i in 0 to WP-1 loop 
				if i>decoder then
					root(i)<='0';
				elsif decoder-i>2 then
					root(i)<=ab(decoder+i+1);
				elsif decoder-i=2 then
					root(i)<=(ab(decoder+i+1) and not(sho)) or (xy(decoder+i+1) and sho);
				else
					root(i)<=xy(decoder+i+1);
				end if;
			end loop;
						
		end if;

	end process stages;
	
	
	
end rtl;
	