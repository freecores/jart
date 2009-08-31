-- The Following code is a package header used to implement an scan out chain.


library ieee;
use ieee.std_logic_1164.all;

package scanPack is

	-- Scan Flip Flop
	component scanFF
		generic (	W		: integer := 8);	-- Word width
		port	(	
					-- Flip flop regular control
					rst 	: in std_logic;
					clk		: in std_logic;
					
					-- This signal selectes which data is to be load on ff q.
					scLoad	: in std_logic;
					
					-- These words are the ones to be selected by scLoad to be load on ff q.
					extData	: in std_logic_vector (W-1 downto 0);	-- External Data to be load in q when  scLoad is 1.
					dStage	: in std_logic_vector (W-1 downto 0);	-- Previous chain stage.
					
					qStage	: out std_logic_vector (W-1 downto 0)	-- ff q.
		);
	end component;
	
	component scanChain
		generic (	CHAINSIZE	: integer := 3;
					W			: integer := 1);
		port	(
			rst		: in std_logic;
			clk		: in std_logic;
			
			scLoad	: in std_logic; -- Enable data load.
			
			scIn	: in std_logic_vector (CHAINSIZE*W-1 downto 0); -- External data
			scOut	: out std_logic_vector (W - 1 downto 0)
		);
	end component;

end package;

		
					
					
					