library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;

entity dotCell is
	generic (	levelW	: integer := 18;	-- Actual Level Width
				nLevelW	: integer := 32);	-- Next Level Width
	port	(	clk		: in std_logic;
				rst		: in std_logic;
				
				-- Object control.
				nxtSphere	: in std_logic; -- This bit controls when the sphere center goes to the next row.
				-- First Side.
				vxInput		: in std_logic_vector(levelW-1 downto 0);
				vyInput		: in std_logic_vector(levelW-1 downto 0);
				vzInput		: in std_logic_vector(levelW-1 downto 0);

				-- Second Side (Opposite to the first one)
				vxOutput		: out std_logic_vector(levelW-1 downto 0);
				vyOutput		: out std_logic_vector(levelW-1 downto 0);
				vzOutput		: out std_logic_vector(levelW-1 downto 0);

				-- Third Side (Perpendicular to the first and second ones)
				dxInput		: in std_logic_vector(levelW-1 downto 0);
				dyInput		: in std_logic_vector(levelW-1 downto 0);
				dzInput		: in std_logic_vector(levelW-1 downto 0);
				
				--Fourth Side (Opposite to the third one)
				dxOutput		: in std_logic_vector(levelW-1 downto 0);
				dyOutput		: in std_logic_vector(levelW-1 downto 0);
				dzOutput		: in std_logic_vector(levelW-1 downto 0);
				
				--Fifth Side (Going to the floor right upstairs!)
				vdOutput		: out std_logic_vector(nLevelW-1 downto 0); -- Dot product.
				
	)
	end port;
end entity;


architecture rtl of rtCell is 


	signal svd	: std_logic_vector (nLevelW - 1 downto 0);
	
begin

	-- The Dotprod Machine
	vd	: dp18 port map (
		clock0	=> clk,
		dataa_0	=> dxInput,
		dataa_1 => dyInput,
		dataa_2 => dzInput,
		datab_0	=> vxInput,
		datab_1 => vyInput,
		datab_2 => vzInput,
		result	=> svd
		);
		
	-- Ray PipeLine
	rayPipeStage : process (clk,rst)
	begin	
		if rst = '0' then
			-- There is no ray load yet.
			dxOutput <= (others => '0');
			dyOutput <= (others => '0');
			dzOutput <= (others => '0');
			
		elsif rising_edge (clk) then
		
			-- Set 
			dxOutput <= dxInput;
			dyOutput <= dyInput;
			dzOutput <= dzInput;
			
		end if;
		
	end process;

	-- Sphere Pipe Line
	spherePipeStage : process (clk,rts)
	begin
		if rst = '0' then

		-- There is no object center yet.
			vxOutput <= (others => '0');
			vyOutput <= (others => '0');
			vzOutput <= (others => '0');
			
		elsif rising_edge (clk) and nxtSphere ='1' then
		
			-- Shift sphere to the next row.
			vxOutput <= vxInput;
			vyOutput <= vyInput;
			vzOutput <= vzInput;
			
		end if;
		
	end process;
	
	-- Upper Level
	vdPipeStage	: process (clk,rst)
	begin
	
		if rst='0' then
			
			vdOutput <= (others => '0');
			
		elsif rising_edge(clk) then
			
			vdOutput  <= svd;
		
		end if;
		
	end process;
	
		
end rtl;




	
	