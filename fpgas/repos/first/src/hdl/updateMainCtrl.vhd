--
-- add ethernet switch reset, 04.26,2018 
-- Support blink LED and access SPI Flash
-- April.18, 2018 Jack Lee
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

use work.cmnPkg.all;


entity updateMainCtrl is
    Port ( 
		CLK27MHZ_REFCLK_P : in STD_LOGIC;
		CLK27MHZ_REFCLK_N : in STD_LOGIC;

		-- MAX3232ECUE
		UART1_TXD : out STD_LOGIC;
		UART1_RXD : in STD_LOGIC;

		-- LEDS
		LED_LINK : out STD_LOGIC;  -- LED1, Up
		LED_POWER : out STD_LOGIC; -- LED1, Bottom
		LED_ACT : out STD_LOGIC;   -- LED2, Up
		LED_SDI : out STD_LOGIC;   -- LED2, Bottom 

		-- SWITCHES
		SW_GPIOB3 : in STD_LOGIC;
		SW_GPIOB2 : in STD_LOGIC;
		SW_GPIOB1 : in STD_LOGIC;

		-- 63-000039-A Flash 512Mbits
		FLASH_D : inout STD_LOGIC_VECTOR (3 downto 0);
		FLASH_FCS_B : out STD_LOGIC;
		-- FLASH_CLK : out STD_LOGIC;

		-- RTL8305H-CG Realteck Ethernet Switch Controller
		RMII_TXCLK : in STD_LOGIC;
		RMII_RXCLK : in STD_LOGIC;

		RMII_TXD : in STD_LOGIC_VECTOR (3 downto 0);
		RMII_TXCTL : in STD_LOGIC;
		RMII_CRS : in STD_LOGIC;
		RMII_COL : in STD_LOGIC;
		RMII_RXD : in STD_LOGIC_VECTOR (3 downto 0);
		RMII_RXCTL : in STD_LOGIC;

		ETH_RSTN : out STD_LOGIC;		-- Low to active

		-- J3 jumper 42-000213+214-A

		SFP_FAULT : in STD_LOGIC;
		SFP_DIS : out STD_LOGIC;
		SFP_ABS : in STD_LOGIC;
		SFP_RS0 : out STD_LOGIC;
		SFP_RS1 : out STD_LOGIC;
		SFP_RX_LOS : in STD_LOGIC;

		-- 25MHz VCO 52-000042-A
		ETH_25M : in STD_LOGIC;

		-- MCU signals
		uC_SPICSn : in STD_LOGIC;-- SPI
		uC_SPISCK : in STD_LOGIC;-- SPI
		uC_MOSI : in STD_LOGIC;-- SPI
		uC_MISO : out STD_LOGIC;-- SPI

		
		uC_RXD2 : out STD_LOGIC;-- jp2; MCU input, output of FPGA
		uC_TXD2 : in STD_LOGIC;-- jp2; MCU output, input of FPGA


		uC_SDA : inout STD_LOGIC;
		uC_SCL : inout STD_LOGIC;

		uC_RXD : in STD_LOGIC;-- CPU DEBUG PORT P6
		uC_TXD : in STD_LOGIC-- CPU DEBUG PORT P6
	);
		   
end updateMainCtrl;

architecture Behavioral of updateMainCtrl is

	-- array of 8 bits vector
--	type vector8 is array (natural range <>) of std_logic_vector(7 downto 0);

	-- register size
	constant REG_MAP_SIZE_OCTET	: integer := 250;--16;


	signal   clk27m         : std_logic;
	signal   reset	        : std_logic;
	signal   reset_n        : std_logic;
	
	attribute dont_touch : string;
	attribute dont_touch of reset : signal is "true";

	-- signal   rst_cntr       : std_logic_vector(7 downto 0);
	signal sig1 : std_logic;
	
	signal rst_cntr : unsigned(23 downto 0);
	--attribute dont_touch : string;
	attribute dont_touch of rst_cntr : signal is "true";
	--attribute dont_touch : string;

	signal   CLK27M_tmp     : std_logic;
	-- signal   led_cntr       : std_logic_vector(23 downto 0);
	
	-- signal   led_cntr       : unsigned(23 downto 0);
	--signal   led_ctrl_act   : unsigned(23 downto 0);		-- count for LED_ACT 

    signal  led_ctrl_link 		: natural;
    signal  led_ctrl_act 		: natural;
    signal  led_ctrl_sdi        : natural;
    
	signal  cntr148test     : unsigned(25 downto 0);
    signal	test148       	: std_logic;

	signal	i2cReadReg		: std_logic;
	signal	i2cDataValid	: std_logic;
	
	signal	i2sReadData		: std_logic_vector(7 downto 0) := b"1011_0101";
	signal	i2sWriteData	: std_logic_vector(7 downto 0) := b"1111_1111";

	
	signal ctrl_stat_i		: vector8(REG_MAP_SIZE_OCTET-1 downto 0); 
	signal ctrl_stat_o		: vector8(REG_MAP_SIZE_OCTET-1 downto 0); 
	
	
	signal i_scl_oe_A      		: STD_LOGIC;
	signal i_sda_oe_A      		: STD_LOGIC;
	
	signal uartTxData			: std_logic_vector(7 downto 0) := "10101010";
	signal uartTxCmd			: std_logic := '1';
	signal uartTxReady			: std_logic;

	-- declaration of component in architecture
	-- component I2C_slave 
	-- generic (
	--	SLAVE_ADDR : std_logic_vector(6 downto 0));
	-- port (
	--	scl              : inout std_logic;
	--	sda              : inout std_logic;
	--	clk              : in    std_logic;
	--	rst              : in    std_logic;
		-- User interface
	--	read_req         : out   std_logic;
	--	data_to_master   : in    std_logic_vector(7 downto 0);
	--	data_valid       : out   std_logic;
	--	data_from_master : out   std_logic_vector(7 downto 0)
	--);
	--END COMPONENT;

	
	begin

		i_drp_clk : IBUFDS
		port map
		(
			I  => CLK27MHZ_REFCLK_N,
			IB => CLK27MHZ_REFCLK_P,
			O  => CLK27M_tmp
		);

		DRP_CLK_BUFG : BUFG 
		port map 
		(
			I    => CLK27M_tmp,
			O    => clk27m 
		);

		------ simplest test
		
		i2cslaveSimplest : entity work.I2C_slave
		generic map (
		 	SLAVE_ADDR => b"0111_0000"  -- 8 bits addree, means 0x60/0x61
        )
		PORT MAP (
			reset	=> reset,
			clk	=> clk27m,
			scl	=> uC_SCL,
			sda	=> uC_SDA,  
			
			read_req => i2cReadReg,
			data_to_master => i2sReadData,
	
			-- master write data to slave
			data_valid => i2cDataValid,
			data_from_master => i2sWriteData
		);

		i2cslave : entity work.i2cRegisters
		generic map (
			SLAVE_ADDR => b"0110_0000",  -- 8 bits address, means 0x60/0x61
			REG_COUNT  => REG_MAP_SIZE_OCTET 
        )
		PORT MAP (
			reset	=> reset,
			clk		=> clk27m,
			
			i_scl	=> uC_SCL,     
			i_sda	=> uC_SDA,  
			i_scl_oe	=> i_scl_oe_A,
			i_sda_oe	=> i_sda_oe_A,
			
			--  	
			busy	=> open,
			wren	=> open,
			rden	=> open,--?
			wr_addr	=> open,
			wr_dout	=> open,
			
			--
			outRegs => ctrl_stat_o,	-- use rcount for register count
			inRegs => ctrl_stat_i	-- readback register
		);
		
		uC_SDA <= '0' when (i_sda_oe_A='1') else 'Z';
		uC_SCL <= '0' when (i_scl_oe_A='1') else 'Z';

		
	-- use this primitive, so FLASH_CLK is not used
		iStartUp : STARTUPE2
			generic map (
				PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
				SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation.
			)
    
			port map (
				CFGCLK => open,        -- 1-bit output: Configuration main clock output
				CFGMCLK => open,       -- 1-bit output: Configuration internal oscillator clock output
				EOS => open,    -- 1-bit output: Active high output signal indicating the End Of Startup.
				PREQ => open,          -- 1-bit output: PROGRAM request to fabric output
				CLK => CLK27M,            -- 1-bit input: User start-up clock input
				GSR => '0',            -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
				GTS => '0',            -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
				KEYCLEARB => '0',      -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
				PACK => '0',           -- 1-bit input: PROGRAM acknowledge input
				USRCCLKO => uC_SPISCK,    -- 1-bit input: User CCLK input
				USRCCLKTS => '0',      -- 1-bit input: User CCLK 3-state enable input
				USRDONEO => '1',       -- 1-bit input: User DONE pin output control
				USRDONETS => '0'       -- 1-bit input: User DONE 3-state enable output
			);


		process(clk27m)
			constant MAX_COUNT : natural := 27000000;  -- 27MHZ clock
		begin
			if (clk27m'event and clk27m='1') then
			     if led_ctrl_sdi < MAX_COUNT/10 then
			         led_ctrl_sdi <= led_ctrl_sdi + 1;
			         LED_SDI <= '1';
			     elsif led_ctrl_sdi < MAX_COUNT/5 then
			         led_ctrl_sdi <= led_ctrl_sdi + 1;
			         LED_SDI <= '0';
			     else
			         led_ctrl_sdi <= 0;
			     end if;
			                  
				if led_ctrl_link < MAX_COUNT/2 then
					led_ctrl_link <= led_ctrl_link + 1;
					LED_LINK <= '1';
				elsif led_ctrl_link < MAX_COUNT then
					LED_LINK <= '0';
					led_ctrl_link <= led_ctrl_link + 1;
				else
					LED_LINK <= '1';
					-- led_cntr <= x"000000";
					led_ctrl_link <= 0;
					led_ctrl_act <= led_ctrl_act + 1;
				end if;
				
				if led_ctrl_act < 5 then
					LED_ACT <= '1';
				elsif led_ctrl_act < 10 then
					LED_ACT <= '0';
				else
					-- led_ctrl_act <= x"000000";
					led_ctrl_act <= 0;
					LED_ACT <= '1';
				end if;
				
				if rst_cntr = x"FFFFFF" then
					reset <= '0';
				else
					rst_cntr <= rst_cntr+1;
					reset <= '1';
				end if;
				
			end if;
		end process;

		--- when start, reset is 1, so ETH_RSTN is low, make rtk reset;
		--  after count to max, reset is 0, so ETH_RTSN is high, rtk can be initialized by MCU
		ETH_RSTN <= not reset;
		LED_POWER <= not reset;
		
		-- LED_SDI 	<= '1' when led_cntr > 13500000/2 else '0';--not reset;
		-- LED_ACT 	<= '1' when led_cntr1 == 0 else '1';

		-- LED_LINK 	<= '1' when led_cntr1 > 33554432 else '0';
		-- LED_SDI 		<= test148;--'1' when led_cntr1 > 33554432 else '0';--not reset;
		-- LED_ACT 		<= CH1_CARRIER_DETECT;--reset;

	

		-- added for spi 
		-- not used: connec uC_SPISCK to USRCCLKO after configuration
		-- FLASH_CLK <= uC_SPISCK;

		FLASH_FCS_B <= uC_SPICSn;
		FLASH_D(0) <= uC_MOSI;
		uC_MISO <= FLASH_D(1);
		FLASH_D(1) <= 'Z';
		FLASH_D(2) <= 'Z';
		FLASH_D(3) <= 'Z';
		
		simple_uart_tx: ENTITY work.suart(str_arch)
			port map(
				clk => clk27m,
				reset => reset,
				
				-- RX
				rx_empty => open,
				-- rd_uart => open,
				r_data => open,
				rx => UART1_RXD,
				
				-- TX				
				wr_uart => uartTxCmd,
				w_data => uartTxData,
				tx_full => open, 
				tx => UART1_TXD
			);
		
		-- case 2:	cross TX/RX
		-- UART1_TXD <= UART1_RXD;
		
		-- case 3: MCU-->FPGA-->RS232: this 2 pins connect to JP2 (JTAG for MCU)
		-- UART1_TXD <= uC_TXD2;
		-- uC_RXD2 <= UART1_RXD;

end Behavioral;
