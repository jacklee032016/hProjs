--
-- Support blink LED and access SPI Flash, Golden Image
-- April.22, 2018 Jack Lee
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

-- use work.pack1.all;


entity goldenMainCtrl is
    Port ( 
			CLK27MHZ_REFCLK_P : in STD_LOGIC;
			CLK27MHZ_REFCLK_N : in STD_LOGIC;

			-- MAX3232ECUE
			UART1_TXD : out STD_LOGIC;
			UART1_RXD : in STD_LOGIC;

			-- RTL8305H-CG Realteck Ethernet Switch Controller	
			ETH_RSTN : out STD_LOGIC;		-- Low to active
		   

		   
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

		   
			uC_SPICSn : in STD_LOGIC;-- SPI
			uC_SPISCK : in STD_LOGIC;-- SPI
			uC_MOSI : in STD_LOGIC;-- SPI
			uC_MISO : out STD_LOGIC;-- SPI
			uC_RXD2 : in STD_LOGIC;-- jp2
			uC_TXD2 : out STD_LOGIC;-- jp2
			uC_RXD : in STD_LOGIC;-- CPU DEBUG PORT P6
			uC_TXD : in STD_LOGIC-- CPU DEBUG PORT P6
		   
		);
		   
end goldenMainCtrl;

architecture Behavioral of goldenMainCtrl is

	signal   clk27m         : std_logic;
	signal   reset	        : std_logic;
	signal   reset_n        : std_logic;
	
	attribute dont_touch : string;
	attribute dont_touch of reset : signal is "true";

	-- signal   rst_cntr       : std_logic_vector(7 downto 0);
	signal sig1 : std_logic;
	
	signal rst_cntr : unsigned(23 downto 0) := x"000000";
	--attribute dont_touch : string;
	attribute dont_touch of rst_cntr : signal is "true";
	--attribute dont_touch : string;

	signal		clk27m_tmp     : std_logic;
	-- signal   led_cntr       : std_logic_vector(23 downto 0);
	signal   led_cntr       : unsigned(23 downto 0);
	signal   led_ctrl_act   : unsigned(23 downto 0);		-- count for LED_ACT 
	signal   led_cntr2       : unsigned(23 downto 0);
	signal		led_cntr3       : unsigned(23 downto 0);
	signal  cntr148test     : unsigned(25 downto 0);
    signal	test148       	: std_logic;

	-- Constants to create the frequencies needed:
	-- Formula is: (29 MHz / 100 Hz * 50% duty cycle)
	constant c_CNT_100HZ 	: natural := 145000;
	constant c_CNT_5SECONDS : natural := 72500000;
	constant c_CNT_10HZ  	: natural := 1450000;
	constant c_CNT_1HZ   	: natural := 14500000; -- So for 100 Hz: 29,000,000 / 100 * 0.5 = 145,000
	
	signal r_CNT_100HZ 		: natural range 0 to c_CNT_100HZ;
	signal r_CNT_5SECONDS  	: natural range 0 to c_CNT_5SECONDS;
	signal r_CNT_10HZ  		: natural range 0 to c_CNT_10HZ;
	signal r_CNT_1HZ   		: natural range 0 to c_CNT_1HZ;

	-- These signals will toggle at the frequencies needed:
	signal r_TOGGLE_100HZ 		: std_logic := '0';
	signal r_TOGGLE_5SECONDS	: std_logic := '0';
	signal r_TOGGLE_10HZ  		: std_logic := '0';
	signal r_TOGGLE_1HZ   		: std_logic := '0';

	
	begin

		i_drp_clk : IBUFDS
		port map
		(
			I  => CLK27MHZ_REFCLK_N,
			IB => CLK27MHZ_REFCLK_P,
			O  => clk27m_tmp
		);

		DRP_CLK_BUFG : BUFG 
		port map 
		(
			I    => clk27m_tmp,
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
            CFGMCLK => open,       -- 1-bit output: Configuration internal oscillator clock output
            EOS => open,    -- 1-bit output: Active high output signal indicating the End Of Startup.
            PREQ => open,          -- 1-bit output: PROGRAM request to fabric output
            CLK => CLK27M,            -- 1-bit input: User start-up clock input
            GSR => '0',            -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
            GTS => '0',            -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
            KEYCLEARB => '0',      -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
            PACK => '0',           -- 1-bit input: PROGRAM acknowledge input
            USRCCLKO => uC_SPISCK,    -- 1-bit input: User CCLK input, MCU SPI Clock
            USRCCLKTS => '0',      -- 1-bit input: User CCLK 3-state enable input
            USRDONEO => '1',       -- 1-bit input: User DONE pin output control
            USRDONETS => '0'       -- 1-bit input: User DONE 3-state enable output
        );

		p_100_HZ : process (clk27m) is
			begin
				if rising_edge(clk27m) then
					if r_CNT_100HZ = c_CNT_100HZ-1 then  -- -1, since counter starts at 0
						-- LED_POWER <= not LED_POWER; LED_POWER is output signal
						r_TOGGLE_100HZ <= not r_TOGGLE_100HZ;
						LED_POWER <= r_TOGGLE_100HZ;
						r_CNT_100HZ    <= 0;
					else
						r_CNT_100HZ <= r_CNT_100HZ + 1;
					end if;
					
				end if;
			end process p_100_HZ;
 
 
		p_5_seconds : process (clk27m) is
			begin
				if rising_edge(clk27m) then
					if r_CNT_5SECONDS = c_CNT_5SECONDS-1 then  -- -1, since counter starts at 0
						--LED_LINK <= not LED_LINK;
						r_TOGGLE_5SECONDS <= not r_TOGGLE_5SECONDS;
						LED_LINK <= r_TOGGLE_5SECONDS;
						r_CNT_5SECONDS <= 0;
					else
						r_CNT_5SECONDS <= r_CNT_5SECONDS + 1;
					end if;
				end if;
			end process p_5_seconds;
    
		p_10_HZ : process (clk27m) is
			begin
				if rising_edge(clk27m) then
					if r_CNT_10HZ = c_CNT_10HZ-1 then  -- -1, since counter starts at 0
						--LED_ACT <= not LED_ACT;
						r_TOGGLE_10HZ <= not r_TOGGLE_10HZ;
						LED_ACT <= r_TOGGLE_10HZ;
						r_CNT_10HZ    <= 0;
					else
						r_CNT_10HZ <= r_CNT_10HZ + 1;
					end if;
					
					if rst_cntr = x"FFFFFF" then
						reset <= '0';
					else
						rst_cntr <= rst_cntr+1;
						reset <= '1';
					end if;

				end if;
			end process p_10_HZ;
    
		p_1_HZ : process (clk27m) is
			begin
				if rising_edge(clk27m) then
					if r_CNT_1HZ = c_CNT_1HZ-1 then  -- -1, since counter starts at 0
						--LED_SDI <= not LED_SDI;
						r_TOGGLE_1HZ <= not r_TOGGLE_1HZ;
						LED_SDI <= r_TOGGLE_1HZ;
						r_CNT_1HZ    <= 0;
					else
						r_CNT_1HZ <= r_CNT_1HZ + 1;
					end if;
				end if;
			end process p_1_HZ;


		ETH_RSTN <= not reset;
			
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
