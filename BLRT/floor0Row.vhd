-- This is a template for generate a grid row in the JART control.

-- The question is : ¿ Should I use all tiles of the row registered? Well for sure there are two possibilities :
-- 1 . Dont register them: But for there is going to be a maximun number of columns where porpagation times are going to be
-- too high in order to substain a one clock upwards pipe. It depends upon the platform you are using how many columns you can implement in the row without registering them.

-- Ray Difussion Pipe Longitude (
-- Row Ray Difussion Time ( RRDT ) in clks: 2 + log 2 (Number of Columns) clks. 
-- An excellent difussion Time, but the max number of columns its limited by the platform specs.
-- Even it is an excellent time is not much of gain because this time is the same time of the pipe longitude, thus a result each clock is achieved anyway.

 

-- 2. Register them 

library ieee;
use ieee.std_logic_1164.all;
use work.powerGrid.all;


entity floor0Row is
	generic	(
			nlw : integer := 32;	-- Next Level Width (V.D width)
			viw : integer := 18;	-- Vector input Width
			col	: integer := 4;	 	-- Number of Colums
	);
	port (	-- Input Control Signal
			clk, rst, nxtRay, nxtSphere	: in std_logic;
			-- Clk, Rst, the usual control signals.
			-- enabled, the machine is running when this input is set.
			-- enabled, all the counters begin again.
				
				 
				
			-- Input Values
			iRayx: in std_logic_vector (viw - 1 downto 0);
			iRayy: in std_logic_vector (viw - 1 downto 0);
			iRayz: in std_logic_vector (viw - 1 downto 0); -- The ray input vector.
			iSphrCenterx: in std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			iSphrCentery: in std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			iSphrCenterz: in std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCenterx: out std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCentery: out std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
			oSphrCenterz: out std_logic_vector (col*viw - 1 downto 0); -- The spheres positions (sphere centers) input vectors.
				
			-- Output Values
			oRayx: out std_logic_vector (viw - 1 downto 0);-- The ray output vector.
			oRayy: out std_logic_vector (viw - 1 downto 0);-- The ray output vector.
			oRayz: out std_logic_vector (viw - 1 downto 0);-- The ray output vector.
			vdOutput : out std_logic_vector (nlw*col - 1 downto 0) -- The dot product emerging from each dot prod cell. 
	);
end entity;
				

				
architecture rtl of floor0Row is

	signal sRayx	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The ray difussion nets.
	signal sRayy	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The ray difussion nets.
	signal sRayz	: std_logic_vector ((col+1)*viw - 1 downto 0);	-- The ray difussion nets.
	
begin

	theCells : for i in 0 to col-1 generate
	
		dotCellx : dotCell port map (
			
			clk			=> clk,
			rst			=> rst,
			nxtSphere	=> nxtSphere,
			nxtRay		=> nxtRay,
			vxInput		=> iSphrCenterx((i+1)*viw-1 downto i*viw),
			vyInput		=> iSphrCentery((i+1)*viw-1 downto i*viw),
			vzInput		=> iSphrCenterz((i+1)*viw-1 downto i*viw),
			vxOutput	=> oSphrCenterx((i+1)*viw-1 downto i*viw),
			vyOutput	=> oSphrCentery((i+1)*viw-1 downto i*viw),
			vzOutput	=> oSphrCenterz((i+1)*viw-1 downto i*viw),
			dxInput		=> sRayx ((i+1)*viw-1 downto i*viw),
			dyInput		=> sRayx ((i+1)*viw-1 downto i*viw),
			dzInput		=> sRayx ((i+1)*viw-1 downto i*viw),
			dxOutput	=> sRayx ((i+2)*viw-1 downto (i+1)*viw),
			dyOutput	=> sRayx ((i+2)*viw-1 downto (i+1)*viw),
			dzOutput	=> sRayx ((i+2)*viw-1 downto (i+1)*viw),
			vdOutput	=> vdOutput((i+1)*view-1 downto i*viw)
			);

	end generate;

	-- Connect the first and last rays.
	sRayx (viw-1 downto 0)	<= iRayx;
	sRayy (viw-1 downto 0) 	<= iRayy;
	sRayz (viw-1 downto 0) 	<= iRayz;
	oRayx 					<= sRayx ((col+1)*viw - 1 downto col*viw);
	oRayy					<= sRayy ((col+1)*viw - 1 downto col*viw);
	oRayz					<= sRayz ((col+1)*viw - 1 downto col*viw);

end rtl;
				
				