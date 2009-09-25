-- The Following code is a package header used to implement an scan out chain.


library ieee;
use ieee.std_logic_1164.all;

package scanPack is

	-- Scan Flip Flop
	component scanFF
		generic (	W		: integer := 8);	-- Word width
		port	(	
					clk,rst,ena,sel		: std_logic; -- The usual  control signals
					
					d0,d1				: std_logic_vector (W-1 downto 0);	-- The two operands.
					q					: std_logic_vector (W-1 downto 0)	-- The selected data.
		);
	end component;
	
	component scanChain
		generic (	CHAINSIZE	: integer := 3;
					W			: integer := 1);
		port	(
					clk,rst,ena		: std_logic; -- The usual control signals.
					
					sel				: std_logic_vector (W-1 downto 0); -- Selection signals.
						
					d0				: in std_logic_vector(W-1 downto 0); -- Youngest Chain Data.
					q				: out std_logic_vector(W-1 downto 0); -- Oldest chain Data.
					d1				: in std_logic_vector (W*CHAINSIZE-1 downto 0); -- Unchained external data.
					chain			: out std_logic_vector (W*CHAINSIZE-1 downto 0); -- Chain data going out for selection function.		
		);
	end component;

end package;

		
					
					
					