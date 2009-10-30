-- Author : Julian Andres Guarin Reyes.
-- Project : JART, Just Another Ray Tracer.
-- email : jguarin2002 at gmail.com, j.guarin at javeriana.edu.co

-- This code was entirely written by Julian Andres Guarin Reyes.
-- The following code is licensed under GNU Public License
-- http://www.gnu.org/licenses/gpl-3.0.txt.

 -- This file is part of JART (Just Another Ray Tracer).

    -- JART (Just Another Ray Tracer) is free software: you can redistribute it and/or modify
    -- it under the terms of the GNU General Public License as published by
    -- the Free Software Foundation, either version 3 of the License, or
    -- (at your option) any later version.

    -- JART (Just Another Ray Tracer) is distributed in the hope that it will be useful,
    -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- GNU General Public License for more details.

    -- You should have received a copy of the GNU General Public License
    -- along with JART (Just Another Ray Tracer).  If not, see <http://www.gnu.org/licenses/>.

-- 16X50M Intersection Tests	

library ieee;
use ieee.std_logic_1164.all;

 


package powerGrid is

	-- R2 for size and width
	type SIZE_WIDTH is array (integer,integer) of integer;
	type DUPLA is array (0 to 2,1 downto 0) of integer; 
	
	-- Tuple for widths
	type WARRAY is array (0 to 2) of integer;
	
	-- Index 
	constant SZINDEX: integer :=0;	-- Size Description Index.
	constant WDINDEX: integer :=1;	-- Width description Index.
	
	-- Register file for spheres.
	-- OP1 : One sphere output per clock.
	-- OP2 : Two sphere output per clock.
	-- OP4 : Four sphere output per clock.
	constant OP4		: integer := 2;
	constant OP2		: integer := 1;
	constant OP1		: integer := 0;
	
	constant SZALFA		: integer := 1;
	constant SZBETA		: integer := 2;
	
	constant DBUSW		: integer := 64;
	constant BUSW		: integer := 32;
	constant HBUSW		: integer := 18;
	
	-- Size and Width depending upon the number of spheres to push out in one clock (OP1= One sphere, OP2 = Two spheres, OP4= Four spheres).
	constant REGSZADD	: WARRAY := (12,11,10);
	constant CIDSZADD	: DUPLA := ((1,0),(2,1),(4,2));
	
	
	-- Decimal Fix is a component used after normalization (unitary vector calculation), when you want to assure that your A(n,10) number is representing a (-1,1) number. For that matter and  precission issues, your unitary vector component may go beyond bounds, lower than -1 or greater than 1. After executing a square root or a division, where the result must be between -1 and 1, you can have little misscalculation, for example 1.0004+ or -1.0004-. There's no way to know how much the error is, but for sure we can minimize it. We can push up a 1.0004- to -1, and pull down a 1.0004+ to 0.999023.

    
	component decimalFix  
	generic
	(
		bigdecimal		: integer := 16; 
		litdecimal		: integer := 10;
		litinteger		: integer := 7
		
	);
	port (
	
		clk, rst, ena 	: in std_logic; -- The usual control signals
		inputsign,ovf	: in std_logic; -- Sign bit and overflow bit, the overflow bit is usually the less significant one in the integer bit set.
		outputsign		: out std_logic; -- Sign at output.
		inputdecimal	: in std_logic_vector (bigdecimal-1 downto 0); -- The 16 bit decimal (by default) decimal entering
		outputdecimal	: out std_logic_vector (litdecimal-1 downto 0) -- The 10 bit decimal at output.
		
		
		
	);

	end component;
	-- Unitary Ray Set. 
	-- Y component generation.
	component yu  
		generic (
		
		-- Define the max counting number.. the number must be expressed as 2 power, cause the range of counting is going to be defined as top-1 downto top/2.
		-- However this is going to be by now, cause in the future the ray generation will GO on for higher resolution images , and perhaps it would be required a more extended range for the yu component.
		TOP : integer := 1024;		
		SCREENW : integer := 320
		);
		port (
		clk,rst,ena		: in std_logic;
		lineDone		: out std_logic;
		ypos			: out integer range TOP/2 to TOP-1
		);
	end component;
	-- Z and X component generation
	component zu  
		generic
		(
		VALSTART		: integer := 9
		);
		port (
 
		clk,rst,ena 	: in std_logic; -- The usual control signals
		clr				: in std_logic;
		zpos			: out integer range -1024 to 1023;
		zneg			: out integer range -1024 to 1023	
		);
 	end component;

	
	-- Register blocks.....
	
	-- 8 x 512 x 32 
	component bt81
		port
		(
		address		: in std_logic_vector (11 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (31 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (31 downto 0)
		);
	end component;
	
	-- 4 x 512 x 32 
	component bt41
		port
		(
		address		: in std_logic_vector (10 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (31 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (31 downto 0)
		);
	end component;
	
	-- 2 x 512 x 32 
	component bt21
		port
		(
		address		: in std_logic_vector (9 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (31 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (31 downto 0)
		);
	end component;
	
	-- 1 x 512 x 32 
	component bt11
		port
		(
		address		: in std_logic_vector (8 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (31 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (31 downto 0)
		);
	end component;
	
	-- 8 x 512 x 18 
	component bt84
		port
		(
		address		: in std_logic_vector (11 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (17 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (17 downto 0)
		);
	end component;
	
	-- 4 x 512 x 18 
	component bt44
		port
		(
		address		: in std_logic_vector (10 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (17 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (17 downto 0)
		);
	end component;
	
	-- 2 x 512 x 18 
	component bt24
		port
		(
		address		: in std_logic_vector (9 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (17 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (17 downto 0)
		);
	end component;
	
	-- 1 x 512 x 18 
	component bt14
		port
		(
		address		: in std_logic_vector (8 downto 0);
		clken		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (17 downto 0);
		wren		: in std_logic ;
		q			: out std_logic_vector (17 downto 0)
		);
	end component;
	
	-- Register type 1 .
	component r1 
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			
			wen		: in std_logic_vector	(3 downto 0);
			add		: in std_logic_vector	(8 downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(BUSW-1 downto 0)
		);
	end component;
	-- Register type 2 .
	component r2 
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			
			wen		: in std_logic_vector	(3 downto 0);
			add		: in std_logic_vector	(9 downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(BUSW-1 downto 0)
		);
	end component;
	-- Register type 4
	component r4 
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			
			wen		: in std_logic_vector	(3 downto 0);
			add		: in std_logic_vector	(10 downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(BUSW-1 downto 0)
		);
	end component;-- Register type 8.
	component r8 
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			
			wen		: in std_logic_vector	(3 downto 0);
			add		: in std_logic_vector	(11 downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(BUSW-1 downto 0)
		);
	end component;
	
	
	-- Register Option mode 1
	component rop1 
		generic (
			SZMODE	: integer	:= SZBETA 	-- By default use the 50% of the max memory for sphere register block.
		);
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			wen		: in std_logic_vector	(3 downto 0);
			add		: in std_logic_vector	(REGSZADD(OP1)-SZMODE downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(2*BUSW-1 downto 0)
		);
	
	end component;
	
	-- Register Option mode 2
	component rop2 
		generic (
			SZMODE	: integer	:= SZBETA 	-- By default use the 50% of the max memory for sphere register block.
		);
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			wen		: in std_logic_vector	(7 downto 0);
			add		: in std_logic_vector	(REGSZADD(OP2)-SZMODE downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(2*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(2*BUSW-1 downto 0)
		);
	
	end component;

	-- Register Option mode 2
	component rop4 
		generic (
			SZMODE	: integer	:= SZBETA 	-- By default use the 50% of the max memory for sphere register block.
		);
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			wen		: in std_logic_vector	(15 downto 0);
			add		: in std_logic_vector	(REGSZADD(OP4)-SZMODE downto 0);
			datain	: in std_logic_vector	(BUSW-1 downto 0);-- incoming data from 32 bits width bus.
			Vx		: out std_logic_vector	(4*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(4*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(4*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(4*BUSW-1 downto 0)
		);
	
	end component;
	
	
	-- Sphere Register Block
	component sphereRegisterBlock 
		generic (
		
			OPMODE	: integer := OP4; 		-- By default push out 4 spheres at same time.
			SZMODE	: integer := SZBETA		-- By default the max sphere numbers is 2048, but could be 4096 with SZALFA.
			
			
		);
		port (
			
			
			clk, ena: in std_logic; -- The usual control signals.
			
			wen		: in std_logic_vector	(CIDSZADD(OP4,SZINDEX)-1 downto 0);	-- Write enable signals
			add		: in std_logic_vector	(REGSZADD(OPMODE)-SZMODE  downto 0);		-- Address bus
			
			datain	: in std_logic_vector	(BUSW-1 downto 0);	-- incoming data from 32 bits width bus.
			
			Vx		: out std_logic_vector	(OPMODE*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vy		: out std_logic_vector	(OPMODE*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			Vz		: out std_logic_vector	(OPMODE*HBUSW-1 downto 0); -- outcoming data to 54 bit width bus multiplexer selector and intersection test cube.
			K		: out std_logic_vector	(OPMODE*BUSW-1 downto 0)
			
		);
	
	end component;	
	
	-- A scan flip flop, aka selectable input ff.
	component scanFF 
		generic	(	
		W	: integer := 8);
		port 	(	
		clk,rst,ena,sel		: in std_logic; -- The usual  control signals
					
		d0,d1 	: in std_logic_vector (W-1 downto 0);	-- The two operands.
		q		: out std_logic_vector (W-1 downto 0)	-- The selected data.
						
		);
	end component;
	--A one stage pipe (1 Clk) a+b+c with w width bits in input as well as output.
	--As a fixed signed addtion we have:
	-- A(B,C) ====> B+C SIGNED BITS FORMAT : 1 bit for sign, B bits for integer part, C bits for decimal part. (FORMAT)
	-- A(15,20)*A(15,20) = A(15,20). (This component format)
	
	component p1ax
		generic ( 	
		-- The width of the operands and result.
		W 		: integer := 36 );
		port	(	
		-- The usual control signals.
		clk		:	 in std_logic;
		rst		:	 in std_logic;
		enable	:	 in std_logic;

		-- Operand A.
		dataa		:	 in std_logic_vector(W-1 downto 0);
		-- Operand B.
		datab		:	 in std_logic_vector(W-1 downto 0);
		-- Operand C
		datac		:	 in std_logic_vector(W-1 downto 0);
		-- Result.
		result		:	 out std_logic_vector(W-1 downto 0)
		);
	end component;
	
	-- A 1 stage pipe 18x18 multiplier. On Cycle III devices is a M-R (Multiplier, Register). (Should be generated using a synthesis tool....).
	-- As a fixed signed multiplication we have :
	-- A(B,C) ====> B+C SIGNED BITS FORMAT : 1 bit for sign, B bits for integer part, C bits for decimal part. (FORMAT)
	-- A(7,10)*A(7,10) = A(15,20). (This component format)
	
	component p1m18
		port	(
		-- Asynchronous clear signal.
		aclr		: in std_logic ;
		-- The usual control signals.
		clken		: in std_logic ;
		clock		: in std_logic ;
		
		-- Factor A.
		dataa		: in std_logic_vector (17 downto 0);
		-- Factor B.
		datab		: in std_logic_vector (17 downto 0);
		-- Product.
		result		: out std_logic_vector (35 downto 0)
		);
	end component;

	-- Signed "less than". dataa < datab
	component sl32 
		port	(
					
		dataa	: in std_logic_vector (31 downto 0);
		datab	: in std_logic_vector (31 downto 0);
		AlB		: out std_logic
		
		);
		end component;
	
	-- Signed "greater than". dataa >= datab.
	component sge32 
		port	(
		
		dataa	: in std_logic_vector (31 downto 0);
		datab	: in std_logic_vector (31 downto 0);
		AgeB	: out std_logic
		
		);
		end component;

	
	-- Dot Product Calculation Cell. 
	-- A 4 side cell along with an upper side. 
	-- V input flows through V output using a data flipflop, so turning V output in the next cell on the next row V Input. V input also flows upwards into the dotproduct 3 stage pipeline. 
	-- D input flows through D output using a data flipflop, so turning D output in the next column cell. D input also flows upwards into the dotproduct 3 stage. 
	component dotCell
		generic (
		
		-- Register V?, by default register the pass of V to the next grid. This should be NO when using a single grid cube or in the last grid of the grid array.
		RV	: string := "yes";
		-- Actual Level Width
		W0	: integer := 18;	
		-- Next Level Width
		W1	: integer := 32);	
		
		port	(	
		--The usual control signals
		clk			: in std_logic;
		rst			: in std_logic;
				
		-- This bit controls when the sphere center goes to the next row.
		nxtSphere	: in std_logic; 
		-- This bit controls when the ray goes to the next column.
		nxtRay		: in std_logic;	
				
		-- First Side.
		vxInput		: in std_logic_vector(W0-1 downto 0);
		vyInput		: in std_logic_vector(W0-1 downto 0);
		vzInput		: in std_logic_vector(W0-1 downto 0);

		-- Second Side (Opposite to the first one)
		vxOutput	: out std_logic_vector(W0-1 downto 0);
		vyOutput	: out std_logic_vector(W0-1 downto 0);
		vzOutput	: out std_logic_vector(W0-1 downto 0);

		-- Third Side (Perpendicular to the first and second ones)
		dxInput		: in std_logic_vector(W0-1 downto 0);
		dyInput		: in std_logic_vector(W0-1 downto 0);
		dzInput		: in std_logic_vector(W0-1 downto 0);
				
		--Fourth Side (Opposite to the third one)
		dxOutput	: out std_logic_vector(W0-1 downto 0);
		dyOutput	: out std_logic_vector(W0-1 downto 0);
		dzOutput	: out std_logic_vector(W0-1 downto 0);
				
		--Fifth Side (Going to the floor right upstairs!)
		vdOutput	: out std_logic_vector(W1-1 downto 0) -- Dot product.
				
		);
	end component;
	
	-- K discriminant comparison.
	-- The vdinput value is the calculation of the ray and the column's sphere dot product. This value should be compared to a sphere constant in order to find out whether the ray intersects
	-- or not the sphere. If vdinput is grather or equal than kinput there's an intersection or else when vdinput is less than kinput. If there's an intersection the block sets vdinput at vdoutput,
	-- whenever there's no intersection the output is asserted with the maximum positive distance in 32 bits : 0x7fffffff.
	component kComparisonCell 
		generic (	
		RK	: string	:= "yes";
		W1	: integer	:= 32	
		);
		port (		
		clk,rst		: in std_logic;
		scanOut		: in std_logic; -- This signals overrides the 'signed greater or equal than' internal function and allows vdinput to flow upwards.
		nxtSphere	: in std_logic; -- Controls when the sphere goes to the next Row. 
		pipeOn		: in std_logic; -- Enables / Disable the upwarding flow.
		kinput		: in std_logic_vector (W1-1 downto 0);
		koutputhor	: out std_logic_vector (W1-1 downto 0);
		koutputver	: out std_logic_vector (W1-1 downto 0);	-- K input  flowing to the next floor upstairs (but waits one clock). 
		vdinput		: in std_logic_vector (W1-1 downto 0);	-- V.D input.
		vdoutput	: out std_logic_vector (W1-1 downto 0)	-- Selected dot product.
		);
	end component;
	-- Minimun distance Comparison.
	-- The reference value, refvd, is the ray minimal intersection distance calculated in the moment of the comparison. 
	-- The column value, colvd, is the column sphere and ray intersection distance (if any or else the maximum distance is asserted).
	
	
	component dComparisonCell
		generic	(	
		-- V.D, minDistance and selectD Width 
		W1 		: integer := 32;	
		-- Column Sphere ID width. 1 = 2 columns max, 2= 4 colums max... and so on.
		IDW	: integer := 2;		
		-- Column Id
		idCol	: integer := 0		
		);
		port 	(
		-- The usual control signals.		
		clk, rst, pipeOn : in std_logic; 
		

		intd	: in	std_logic;
		intq	: out	std_logic;
		-- This is the reference column identification input.
		cIdd	: in	std_logic_vector (IDW - 1 downto 0);	
		-- This is the result column identification output.
		cIdq	: out	std_logic_vector (IDW - 1 downto 0);
		refk	: in	std_logic_vector (W1 - 1 downto 0); -- This is the columns sphere constant
		colk	: in	std_logic_vector (W1 - 1 downto 0); -- This is the reference sphere constant
		selk	: out 	std_logic_vector (W1 - 1 downto 0); -- This is the selected sphere constant		
		-- This is the reference projection incoming from the previous cell.
		refvd	: in	std_logic_vector (W1 - 1 downto 0); 		
		-- This is the sphere position over the ray traced vector projection.
		colvd	: in	std_logic_vector (W1 - 1 downto 0); 		
		-- This is the smallest value between refvd and colvd.
		selvd	: out	std_logic_vector (W1 - 1 downto 0) 		
		);
	end component;
	
	component floor0Row
		generic	(
		-- Floor Level Width (V.D width)
		W1 : integer := 32;
		-- Vector input Width		
		W0 : integer := 18;
		-- Number of Colums
		C	: integer := 4	 	
	);
	port (	
		-- The usual control signals. nxtRay should be 0 whenever I want to stop the entire machine.
		clk, rst, nxtRay : in std_logic;
		
		-- Clk, Rst, the usual control signals.
		-- enabled, the machine is running when this input is set.
		-- enabled, all the counters begin again.
		nxtSphere : in std_logic_vector (C-1 downto 0); 	
				 
				
		-- Input Values. 
		-- The ray input vector.
		iRayx: in std_logic_vector (W0 - 1 downto 0);
		iRayy: in std_logic_vector (W0 - 1 downto 0);
		iRayz: in std_logic_vector (W0 - 1 downto 0); 
		
		-- The spheres x position (sphere centers) input vectors.
		iSphrCenterx: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y position (sphere centers) input vectors.
		iSphrCentery: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres z position (sphere centers) input vectors.
		iSphrCenterz: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) output vectors.
		oSphrCenterx: out std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y positions (sphere centes) output vectors.
		oSphrCentery: out std_logic_vector (C*W0 - 1 downto 0);
		-- The spheres z positions (sphere centers) output vectors.		
		oSphrCenterz: out std_logic_vector (C*W0 - 1 downto 0);
			
		-- Output Values
		-- The ray output vector.
		oRayx: out std_logic_vector (W0 - 1 downto 0);
		oRayy: out std_logic_vector (W0 - 1 downto 0);
		oRayz: out std_logic_vector (W0 - 1 downto 0);
		
		-- The dot product result from each dot prod cell.
		vdOutput : out std_logic_vector (W1*C - 1 downto 0)  
		);
	end component;
	
	-- In this level the V.D results from floor 0 are compared whether they are greater or equal than column's sphere K constants, in order to find if there's an intersection per column or not.
	-- When any comparison is true, meaning VD value greater or equal than K, the outgoing value to floor2 level is the same VD, if not the outgoing value is 0x7fffffff (the maximum)
	-- distance value.
	
	component floor1Row
	generic	(
	
		-- Vector input Width	
		W1 : integer := 32;	
		-- Number of Colums
		C	: integer := 4	 	
	);
	port (	
	
		-- Input Control Signals, pipe on is one when raysr going on. 
		clk, rst	: in std_logic;
		pipeOn		: in std_logic;
			
		-- Clk, Rst, the usual control signals.
		nxtSphere	: in std_logic_vector (C-1 downto 0);

		-- VD Input / Output.
		vdInput	: in std_logic_vector (W1*C-1 downto 0);
		vdOutput: out std_logic_vector (W1*C-1 downto 0);
			
		-- K Input / Output.
		kInput	: in std_logic_vector (W1*C - 1 downto 0); 
		kOutput	: out std_logic_vector (W1*C - 1 downto 0)  
	);
	end component;
	
	-- This level takes the -on the moment smalles distance-- value per ray in the extreme left, and starts making comparisons from left to right, one comparison each clock and so on, searching for the smallest V.D value in the row incomung from the floor1 level. When the ray has finished crossing throguh all the spheres in the scene, the row extreme right value will be the smallest V.D found along with an ID of the sphere intersected. This is the goal of the intersection architecture : to find out which is the closest sphere intersected by a particular ray. 
	
	component floor2Row 
	generic	(
		-- Vector input Width
		W1 : integer := 32;	
		-- ID Column width
		IDW : integer := 2;	
		-- Number of Colums
		C	: integer := 4 	
	);
	port (	
		-- Input Control Signal
		-- Clk, Rst, the usual control signals.
		clk, rst, pipeOn: in std_logic;
				
		-- Input Values
		-- Reference VD, the "at the moment" smallest VD sphere ray projection value.
		refvd	: in std_logic_vector (W1-1 downto 0);
		
		-- The smallest VD, value found.
		selvd	: out std_logic_vector (W1-1 downto 0);
		
		-- The column's sphere ray projection value.
		colvd	: in std_logic_vector (W1*C-1 downto 0);
		-- The smallest VD projection value column id.
		colid	: out std_logic_vector (IDW-1 downto 0);
		-- The intersection signal (1 on intersection else 0).
		inter	: out std_logic
	);
	end component;
	
	component rayxsphereGrid 
	generic (
		-- Width of Column identificator.
		IDW	: integer := 2;
		-- Number of Columns.
		C	: integer := 4;	
		-- Input rays width.
		W0	: integer := 18;
		-- Dot products and spheres constant width
		W1	: integer := 32
		
		);
	port (
		-- The usual control signals.
		clk,rst		: in std_logic;
		
		-- Grid, rays and sphere flow through control signals.
		pipeOn		: in std_logic;
		nxtSphere	: in std_logic_vector (C-1 downto 0);
		
		-- R-F0
		-- Input Values. 
		-- The ray input vector.
		iRayx: in std_logic_vector (W0 - 1 downto 0);
		iRayy: in std_logic_vector (W0 - 1 downto 0);
		iRayz: in std_logic_vector (W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) input vectors.
		iSphrCenterx: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y position (sphere centers) input vectors.
		iSphrCentery: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres z position (sphere centers) input vectors.
		iSphrCenterz: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) output vectors.
		oSphrCenterx: out std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y positions (sphere centes) output vectors.
		oSphrCentery: out std_logic_vector (C*W0 - 1 downto 0);
		-- The spheres z positions (sphere centers) output vectors.		
		oSphrCenterz: out std_logic_vector (C*W0 - 1 downto 0);
		-- Output Values
		-- The ray output vector.
		oRayx: out std_logic_vector (W0 - 1 downto 0);
		oRayy: out std_logic_vector (W0 - 1 downto 0);
		oRayz: out std_logic_vector (W0 - 1 downto 0);
		
		-- R-F1
		-- K Input / Output.
		kInput	: in std_logic_vector (C*W1 - 1 downto 0); 
		kOutput	: out std_logic_vector (C*W1 - 1 downto 0);  
		
		--R-F2
		-- Input Values
		refvd	: in std_logic_vector (W1-1 downto 0);
		selvd	: out std_logic_vector (W1-1 downto 0);
		colid	: out std_logic_vector (IDW-1 downto 0);
		inter	: out std_logic
		);		
	end component;
	component gridCube
	generic ( 
		-- Depth
		D 	: integer := 4;
		-- ID width.
		IDW	: integer := 2;
		-- Number of Columns.
		C	: integer := 4;	
		-- Input rays width.
		W0	: integer := 18;
		-- Dot products and spheres constant width
		W1	: integer := 32	
		
		);
	port (
			-- The usual control signals.
		clk,rst	: in std_logic;
		
		-- Grid, rays and sphere flow through control signals.
		pipeOn			: in std_logic;
		-- The same column nxtSphere signal control..... regardless the Cube Depth.
		nxtSphere		: in std_logic_vector (C-1 downto 0);
		
		-- R-F0
		-- Input Values. 
		-- The ray input vector. 
		iRayx: in std_logic_vector (D*W0 - 1 downto 0);
		iRayy: in std_logic_vector (D*W0 - 1 downto 0);
		iRayz: in std_logic_vector (D*W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) input vectors.
		iSphrCenterx: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y position (sphere centers) input vectors.
		iSphrCentery: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres z position (sphere centers) input vectors.
		iSphrCenterz: in std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres x position (sphere centers) output vectors.
		oSphrCenterx: out std_logic_vector (C*W0 - 1 downto 0); 
		-- The spheres y positions (sphere centes) output vectors.
		oSphrCentery: out std_logic_vector (C*W0 - 1 downto 0);
		-- The spheres z positions (sphere centers) output vectors.		
		oSphrCenterz: out std_logic_vector (C*W0 - 1 downto 0);
		-- Output Values
		-- The ray output vector.
		oRayx: out std_logic_vector (D*W0 - 1 downto 0);
		oRayy: out std_logic_vector (D*W0 - 1 downto 0);
		oRayz: out std_logic_vector (D*W0 - 1 downto 0);
		
		-- R-F1
		-- K Input / Output.
		kInput	: in std_logic_vector (C*W1 - 1 downto 0); 
		kOutput	: out std_logic_vector (C*W1 - 1 downto 0);
		
		--R-F2
		-- Input Values
		refvd	: in std_logic_vector (D*W1-1 downto 0);
		selvd	: out std_logic_vector (D*W1-1 downto 0);
		colid	: out std_logic_vector (D*IDW-1 downto 0);
		inter 	: out std_logic_vector (D-1 downto 0)
		);
	end component;
	
	function mylog2( x : in integer; s: string) return integer;
	
end powerGrid;
package body powerGrid is 
	function mylog2(x: integer; s : string) return integer is
		variable accum : integer :=1;
		variable i	   : integer range 0 to 32 := 1;
	begin
		
		while (accum<=x) loop
			accum	:= accum*2;
			i		:= i+1;
		end loop;
		if s="unsigned" then
			return i-1;
		else
			return i;
		end if;
	end;

end package body;
