--
-- Support blink LED and access SPI Flash
-- April.18, 2018 Jack Lee
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

-- use work.pack1.all;


entity ledTimeCtrl is
    Port ( 
           CLK27MHZ_REFCLK_P : in STD_LOGIC;
           CLK27MHZ_REFCLK_N : in STD_LOGIC;

			-- MAX3232ECUE
           UART1_TXD : out STD_LOGIC;
           UART1_RXD : in STD_LOGIC;
		   
		   -- LEDS
           LED_POWER : out STD_LOGIC;
           LED_LINK : out STD_LOGIC;
           LED_SDI : out STD_LOGIC;
           LED_ACT : out STD_LOGIC;
		   -- SWITCHES
           SW_GPIOB3 : in STD_LOGIC;
           SW_GPIOB2 : in STD_LOGIC;
           SW_GPIOB1 : in STD_LOGIC;

		   -- 63-000039-A Flash 512Mbits
           FLASH_D : inout STD_LOGIC_VECTOR (3 downto 0);
           FLASH_FCS_B : out STD_LOGIC;
           -- FLASH_CLK : out STD_LOGIC;

		   
           uC_SPICSn : in STD_LOGIC;-- SPI
           uC_SPISCK : in STD_LOGIC;-- SPI
           uC_MOSI : in STD_LOGIC;-- SPI
           uC_MISO : out STD_LOGIC;-- SPI
           uC_RXD2 : in STD_LOGIC;-- jp2
           uC_TXD2 : out STD_LOGIC;-- jp2
           uC_RXD : in STD_LOGIC;-- CPU DEBUG PORT P6
           uC_TXD : in STD_LOGIC-- CPU DEBUG PORT P6
		   
		   );
		   
end ledTimeCtrl;

architecture Behavioral of ledTimeCtrl is

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
	signal   led_cntr       : unsigned(23 downto 0);
	signal   led_ctrl_act   : unsigned(23 downto 0);		-- count for LED_ACT 
	signal   led_cntr2       : unsigned(23 downto 0);
	signal		led_cntr3       : unsigned(23 downto 0);
	signal  cntr148test     : unsigned(25 downto 0);
    signal	test148       	: std_logic;

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


		
	-- use this primitive, so FLASH_CLK is not used
    iStartUp : STARTUPE2
        generic map (
            PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
            SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation.
        )
    
        port map (
            CFGCLK => open,        -- 1-bit output: Configuration main clock output
            CFGMCLK => open,       -- 1-bit output: Configuration internal oscillator clock output, for watchdog etc.
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
				if led_cntr < MAX_COUNT/2 then
					led_cntr <= led_cntr + 1;
					LED_LINK <= '1';
				elsif led_cntr < MAX_COUNT then
					LED_LINK <= '0';
					led_cntr <= led_cntr + 1;
				else
					LED_LINK <= '1';
					led_cntr <= x"000000";
					led_ctrl_act <= led_ctrl_act + 1;
				end if;
				
				if led_ctrl_act < 5 then
					LED_ACT <= '1';
				elsif led_ctrl_act < 10 then
					LED_ACT <= '0';
				else
					led_ctrl_act <= x"000000";
					LED_ACT <= '1';
				end if;
				
			end if;
		end process;

		
		-- 2**25 = 33554432
		--LED_POWER 	<= '1';-- when led_cntr > 33554432 else '0';
		LED_POWER 	<= '0'; -- when led_cntr1 > 33554432 else '0';
		LED_SDI 	<= '1' when led_cntr > 13500000 else '0';--not reset;
		-- LED_ACT 	<= '1' when led_cntr1 == 0 else '1';

		-- LED_LINK 	<= '1' when led_cntr1 > 33554432 else '0';
		-- LED_SDI 		<= test148;--'1' when led_cntr1 > 33554432 else '0';--not reset;
		-- LED_ACT 		<= CH1_CARRIER_DETECT;--reset;

	
		-- this 2 pins connect to JP2 (JTAG for MCU)
		-- UART1_TXD <= uC_RXD2;
		-- uC_TXD2 <= UART1_RXD;

		-- added for spi 
		-- not used: connec uC_SPISCK to USRCCLKO after configuration
		-- FLASH_CLK <= uC_SPISCK;

		FLASH_FCS_B <= uC_SPICSn;
		FLASH_D(0) <= uC_MOSI;
		uC_MISO <= FLASH_D(1);
		FLASH_D(1) <= 'Z';
		FLASH_D(2) <= 'Z';
		FLASH_D(3) <= 'Z';

end Behavioral;
