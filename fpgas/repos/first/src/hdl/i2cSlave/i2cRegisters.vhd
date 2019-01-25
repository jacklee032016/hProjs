
-- 05.06.2018, JL


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- library work;
use work.cmnPkg.all;

entity i2cRegisters is

generic( 
	SLAVE_ADDR : std_logic_vector(7 downto 0) := b"0110_0000";	-- 0x68
	REG_COUNT  	: Integer  := 16 
);
port(
	reset		: in  std_logic;	-- 1 active
	clk       : in  std_logic;  
	--
	i_scl     : in std_logic;     
	i_sda     : in std_logic;  
	i_scl_oe  : out std_logic;
	i_sda_oe  : out std_logic;
	--  
	busy      : out std_logic;     
	wren      : out std_logic;
	rden      : out std_logic;
	wr_addr   : out std_logic_vector(7 downto 0);
	wr_dout		: out std_logic_vector(7 downto 0);
	
	--
	outRegs		: out vector8(REG_COUNT-1 downto 0) := (others=> (others=>'0')); -- output registers, get value from I2C master
	inRegs		: in vector8(REG_COUNT-1 downto 0)	-- registers input into this module from other modules
) ;
end i2cRegisters;


architecture i2cRegisterRtl of i2cRegisters is

-- type vector8 is array (natural range <>) of std_logic_vector(7 downto 0);

	constant REG_RESETS			: natural range 0 to 15 := 0;
	constant REG_TEST			: natural range 0 to 255 := 1;
	constant REG_STREAM_ENA		: natural range 0 to REG_COUNT := 2;

	-- '16#xx#' : for hexidecimal
	constant REG_MY_IP			: natural range 0 to REG_COUNT := 52;	-- 52, register address is decimal, not hexidecimal
	constant REG_DST_IP			: natural range 0 to REG_COUNT := 64;	-- 64

	constant REG_MY_MAC			: natural range 0 to REG_COUNT := 56;	-- 56
	constant REG_DST_MAC		: natural range 0 to REG_COUNT := 68;	-- 68

	constant REG_MY_VIDEO_PORT	: natural range 0 to REG_COUNT := 62;	-- 62
	constant REG_DST_VIDEO_PORT	: natural range 0 to REG_COUNT := 74;	-- 74

--------------------------------------------------------------------------------
-- DUT:
--------------------------------------------------------------------------------

	component I2cSlaveEnhanced is
		generic (
			SLAVE_ADDR : std_logic_vector(7 downto 0));
		port (
			scl		: in std_logic;
			sda		: in std_logic;
			scl_oe	: out std_logic;
			sda_oe	: out std_logic;
			clk		: in  std_logic;
			rst		: in  std_logic;
			
			-- User interface
			sof		: out    std_logic;
			eof		: out    std_logic;
			
			read_req         : out   std_logic;
			data_to_master   : in    std_logic_vector(7 downto 0);
			
			data_valid       : out   std_logic;
			data_from_master : out   std_logic_vector(7 downto 0)
		);
	end component;

	attribute keep: string; 

	type state_type is (ST_IDLE, ST_ADDRRESS, ST_WRITE, ST_READ);

	signal state	: state_type;

	signal	scl_oe  : std_logic;
	signal	sda_oe  : std_logic;

	signal  addr	: integer range 0 to 255;
	signal  addr_q	: integer range 0 to 255;
--	signal	rst		: std_logic;

	signal	data2Master 	: std_logic_vector(7 downto 0);
	signal	dataFromMaster 	: std_logic_vector(7 downto 0);

	attribute keep of data2Master   : signal is "true";
	attribute keep of dataFromMaster  : signal is "true";

	-- request signal from I2C bus
	signal	i2cReqRead		: std_logic;
	signal  i2cReqWrite		: std_logic;
	
	signal  wren_req		: std_logic;
	signal  rden_req		: std_logic;
	signal  wr_dout_req	: std_logic_vector(7 downto 0);

	signal	sof				: std_logic;
	signal	eof				: std_logic;

	signal  probe  :  std_logic_vector(30 downto 0) := (others=>'0');

	--type vector8 is array (natural range <>) of std_logic_vector(7 downto 0);
	-- registers for other modules in FPGA
	signal	regsFromOthers		: vector8(REG_COUNT-1 downto 0);
	
	-- out registers (internal): to MCU master
	signal	regsFromMaster		: vector8(REG_COUNT-1 downto 0) := (others=> (others=>'0'));


 
begin

--	rst <= not(rstn);

	wr_addr <= std_logic_vector( to_unsigned(addr_q, 8) );
	busy    <= '0';     
	wren    <= wren_req;
	rden    <= rden_req;
	wr_dout <= wr_dout_req;

--------------------------------------------------------------------------------
-- Register Bank:
--------------------------------------------------------------------------------

	SYNC_PROC: process (clk)
		begin
			
			-- RESET 
			--if (reset ='0') then			
			if (reset ='1') then
				addr <= 0;
				regsFromMaster(REG_RESETS) <= x"00";
				regsFromMaster(REG_TEST) <= x"03";
				regsFromMaster(REG_STREAM_ENA) <= x"01";
		
-- REG_MY_IP
-- 52+3 x"34+3"				x"37"		x"c0"
-- 52+2 x"34+2"				x"36"		x"a8"
-- 52+1 x"34+1"				x"35"		x"a8"
-- 52+0 x"34+0"				x"34"		x"33"
-- REG_DST_IP			 	: integer := 64; 	-- 4 bytes, destination IP address
-- ip_address_dst 	=> X"239_00_00_01" 	,-- 192.168.168.51 = X"c0_a8_a8_33"
-- 64+3	x"40+3" 			x"43" 		x"EF"
-- 64+2	x"40+2" 			x"42" 		x"00"
-- 64+1	x"40+1" 			x"41" 		x"00"
-- 64+0	x"40+0" 			x"40" 		x"01"
-- REG_DST_MAC			: integer := 68; 	-- 6 bytes, destination MAC address
-- 01-00-5E-00-00-01
-- 68+5	x"44+5" 			x"49"		x"01"
-- 68+4	x"44+4" 			x"48"		x"00"
-- 68+3	x"44+3" 			x"47"		x"5E"
-- 68+2	x"44+2" 			x"46"		x"00"
-- 68+1	x"44+1" 			x"45"		x"00"
-- 68+0	x"44+0" 			x"44"		x"01"
		
		
				regsFromMaster(REG_DST_IP+3) <= x"EF";--x"11";-- 239.00.00.01 = X"c0_a8_a8_33"
				regsFromMaster(REG_DST_IP+2) <= x"00";--x"22";
				regsFromMaster(REG_DST_IP+1) <= x"00";--x"33";
				regsFromMaster(REG_DST_IP+0) <= x"01";--x"44";
				regsFromMaster(REG_MY_IP+3) <= x"c0";--x"88";-- 192.168.168.51 = X"c0_a8_a8_33"
				regsFromMaster(REG_MY_IP+2) <= x"a8";--x"77";
				regsFromMaster(REG_MY_IP+1) <= x"a8";--x"66";
				regsFromMaster(REG_MY_IP+0) <= x"33";--x"55";

				-- MAC_destination 	<= x"cc_cc_cc_cc_cc_cc"	;
				regsFromMaster(REG_MY_MAC+5) <= x"88";
				regsFromMaster(REG_MY_MAC+4) <= x"88";
				regsFromMaster(REG_MY_MAC+3) <= x"88";
				regsFromMaster(REG_MY_MAC+2) <= x"88";
				regsFromMaster(REG_MY_MAC+1) <= x"88";
				regsFromMaster(REG_MY_MAC+0) <= x"88";
		
				regsFromMaster(REG_DST_MAC+5) <= x"01";--x"cc";-- 01-00-5E-00-00-01
				regsFromMaster(REG_DST_MAC+4) <= x"00";--x"cc";
				regsFromMaster(REG_DST_MAC+3) <= x"5E";--x"cc";
				regsFromMaster(REG_DST_MAC+2) <= x"00";--x"cc";
				regsFromMaster(REG_DST_MAC+1) <= x"00";--x"cc";
				regsFromMaster(REG_DST_MAC+0) <= x"01";--x"cc";
				
				-- DestinationPort 	<= x"0124"; --: in STD_LOGIC_VECTOR (15 downto 0)
				regsFromMaster(REG_MY_VIDEO_PORT+1) <= x"01";
				regsFromMaster(REG_MY_VIDEO_PORT+0) <= x"23";
				regsFromMaster(REG_DST_VIDEO_PORT+1) <= x"01";
				regsFromMaster(REG_DST_VIDEO_PORT+0) <= x"24";

				wren_req <= '0';
				rden_req <= '0';
				wr_dout_req <= (others=>'0');
				data2Master <= (others=>'0');
			elsif (rising_edge(clk)) then
				-- data_in <= inRegs(addr);
				-- current input data from MCU
				data2Master <= regsFromOthers(addr);

				for I in 0 to REG_COUNT-1 loop
					-- output data from master to external module of FPGA
					outRegs(I) <= regsFromMaster(I);

					case (I) is
						--when REG_X_ACTIVE to REG_PID_4 =>
						--	regsFromOthers(I) <= inRegs(I);
						--when REG_DATE_YEAR	 	=> regsFromOthers(I) <= DATE(39 downto 32) ;
						--when REG_DATE_MONTH	 	=> regsFromOthers(I) <= DATE(31 downto 24) ;
						--when REG_DATE_DAY	 	=> regsFromOthers(I) <= DATE(23 downto 16) ;
						--when REG_DATE_HOUR	 	=> regsFromOthers(I) <= DATE(15 downto 8) ;
						--when REG_DATE_MINUTE 	=> regsFromOthers(I) <= DATE(7 downto 0) ;
						--when REG_UNIT_VERSION   => regsFromOthers(I) <= UNIT_VERSION;
						--when REG_UNIT_REVISION  => regsFromOthers(I) <= UNIT_REVISION;
						--when REG_FPGA_MODEL  	=> regsFromOthers(I) <= FPGA_DEVICE_MODEL;
						when REG_TEST+8 to REG_TEST+23 =>
							regsFromOthers(I) <= inRegs(I);
						when others =>
							regsFromOthers(I) <= regsFromMaster(I);
					end case;
				end loop;
		
				wren_req <= '0';
				rden_req <= '0';
		
				case (state) is
					when ST_IDLE =>
						if (i2cReqRead='1') then
							state <= ST_READ;
							if (addr < REG_COUNT-1) then
								addr <= addr + 1;
							end if;
						elsif (i2cReqWrite='1') then	-- write address in IDLE state
							addr <= to_integer(unsigned(dataFromMaster));
							state <= ST_WRITE;
						end if;
			
					
					when ST_ADDRRESS => null;	-- when enter into ADDRESS state
		
					-- Master(MCU) want to read
					when ST_READ =>
						if (eof='1') then
							state <= ST_IDLE;
						elsif (sof='1') then
							state <= ST_IDLE;
						elsif (i2cReqRead='1') then
							rden_req <= '1';
							addr_q <= addr;
							state <= ST_READ;
							addr <= addr + 1;
						end if;
			
					-- master(MCU) write data to slave, and then to external module in FPGA
					when ST_WRITE =>
						if (eof='1') then
							state <= ST_IDLE;
						elsif (sof='1') then
							state <= ST_IDLE;
						elsif (i2cReqWrite='1') then
							wren_req <= '1';
							addr_q <= addr;
							wr_dout_req <= dataFromMaster;
							regsFromMaster(addr) <= dataFromMaster;
							state <= ST_WRITE;	-- continue write on next address
							addr <= addr + 1;
						end if;
			
				end case;
			end if;
	end process;


	-- -----------------------------------------------------
	--
	-- i2c:entity work.I2cSlaveEnhanced
	i2c: I2cSlaveEnhanced
		generic map (
			SLAVE_ADDR => SLAVE_ADDR )
		port map (
			scl		=> i_scl,
			sda		=> i_sda,
			scl_oe	=> scl_oe,
			sda_oe	=> sda_oe,
			clk		=> clk,
			rst		=> reset,
			
			-- User interface
			sof		=> sof,
			eof		=> eof,
			
			read_req			=> i2cReqRead,
			data_to_master		=> data2Master,
			data_valid			=> i2cReqWrite,
			data_from_master	=> dataFromMaster
		);

	i_sda_oe <= sda_oe;
	i_scl_oe <= scl_oe;


probe(0) <= i2cReqWrite;
probe(1) <= i2cReqRead;
probe(2) <= sof;
probe(3) <= eof;

probe(4) <= i_scl;
probe(5) <= i_sda;

probe(6) <= wren_req;

probe(14 downto 7)  <=  std_logic_vector( to_unsigned(addr, 8) );
probe(22 downto 15) <=  data2Master;
probe(30 downto 23) <=  dataFromMaster;


--dbg_i2c: ila_1p
--port map (
--  clk   	=> clk,
--  probe0 	=> probe
--);

end i2cRegisterRtl;

