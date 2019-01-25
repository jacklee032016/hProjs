README for simple projects
####################################


README for Golden Image 
=============================
April,23rd, 2018  Jack Lee

May,1st, Tuesday
	Add reset signal and RESET realteck switch chip, so golden image can be used to update image through ethernet;
										
Constrains and configuration
	set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]
	set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 0x0400000 [current_design]
	# internal CFG_MCLK (50MHz) for Watchdog, a version prescaled by 256(100 to 300 KHz), 5.12us per unit
	# about 1~2 second
	set_property BITSTREAM.CONFIG.TIMER_CFG 0x50000 [current_design]										

Functions of Golden Image:
	LED1:
			Link(U)	: 5 seconds
			Power(B): ON
	LED2:
			ACT(U)	: 1Hz
			SDI(B)	:	10HZ
	SPI Flash			

Test and Validation:
	Golden in address 0;
	ledTimeCtrl.bin:
			SDI/POWER	: ON
			ACT/Link	: 0.5Hz
			
			address 4M and 6M

	If erasing 4M sector, golden image will be displayed after a short delay; and ledTimeCtrl in address of 6M is not used;
	If ledTimeCtrl is there, blink quickly after poweron or reconfigure FPGA;


README for Update Image 
=============================
April,26th, 2018  Jack Lee

06.08, 2018, Friday
	Add RS232 <--> MCU USART1
	
										
05.09, 2018
	Support registers read/write:
			debug the problem of SLAVE_ADDR;
			debug the problem of RESET: from 0(active) --> 1(active);
			
			Debug the problem of RTK switch chip not work after i2c works;

05.06, 2018
	Support I2C read/write with fixed data: only command and data(RW), 2 bytes for communication;
	

04.26, 2018
----------------
* add 'fallback' feature in constaints;
* Add reset logic: 
   * signal reset is active(1) within reset period;
   * After reset period, LED_POWER is ON;
			
   * reset period:
					COUNT max 0xFFFFFF(16,777,215);
					Clock:27MHz;
					about 0.5 seconds;
					
	Reset Ethernet switch chip, then MCU can configure ethernet: 
			When reset is active, made ETH_RESET is low;
			After reset, ETH_RESET is high;

	LED status:
			LED-1: 
				Link	: Blink 0.5s;
				Power : ON;
			LED-2:	
				ACT		: blink 5s;
				SDI		: blink 10Hz;
