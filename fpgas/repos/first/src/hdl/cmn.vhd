-- fichier work.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cmnPkg is

	constant logic_0    : std_logic := '0';
	constant logic_1    : std_logic := '1';

	constant UNIT_VERSION   : std_logic_vector(7 downto 0) := X"81"; -- MSB = 1 for TX unit / 0 for RX unit
	constant UNIT_REVISION  : std_logic_vector(7 downto 0) := X"05"; -- 


-- constant HEADER_SIZE  : integer := 4;
-- constant DWORD_PER_FRAME  : integer := 150;


	constant sdidepth    : integer := 20; -- sdi bus width (may be 10 or 20)
	constant hdmidepth   : integer := 10; -- hdmi bus width (may be 10 or 20)

constant synccar     : std_logic_vector(29 downto 0) := B"0000000000_0000000000_1111111111"; -- 000h 000h 3ffh
constant synccar_2x  : std_logic_vector(59 downto 0) := B"0000000000_0000000000_0000000000_0000000000_1111111111_1111111111"; -- 000h 000h 000h 000h 3ffh 3ffh

constant sync_anc    : std_logic_vector(29 downto 0) := B"1111111111_1111111111_0000000000"; -- 3ffh 3ffh 000h

-- SDI rate match clock divider D for Xilinx Artix 7
constant autorate : std_logic_vector(2 downto 0) := B"000";     -- static setting for D divider
constant rate6G   : std_logic_vector(2 downto 0) := B"001";     -- Div by 1
constant rate3G   : std_logic_vector(2 downto 0) := B"010";     -- Div by 2
constant rateHD   : std_logic_vector(2 downto 0) := B"011";     -- Div by 4
constant rateSD   : std_logic_vector(2 downto 0) := B"100";     -- Div by 8

constant div_rate6G   : std_logic_vector(2 downto 0) := B"001";     -- Div by 1
constant div_rate3G   : std_logic_vector(2 downto 0) := B"010";     -- Div by 2
constant div_rateHD   : std_logic_vector(2 downto 0) := B"011";     -- Div by 4
constant div_rateSD   : std_logic_vector(2 downto 0) := B"100";     -- Div by 8

constant TX_MODE_6G   : std_logic_vector(1 downto 0) := B"11";
constant TX_MODE_3G   : std_logic_vector(1 downto 0) := B"10";
constant TX_MODE_HD   : std_logic_vector(1 downto 0) := B"00";
constant TX_MODE_NONE : std_logic_vector(1 downto 0) := B"01";

constant RX_MODE_6G   : std_logic_vector(1 downto 0) := B"11";
constant RX_MODE_3G   : std_logic_vector(1 downto 0) := B"10";
constant RX_MODE_HD   : std_logic_vector(1 downto 0) := B"00";
constant RX_MODE_NONE : std_logic_vector(1 downto 0) := B"01";

constant MULT_1000    : std_logic := '0';
constant MULT_1001    : std_logic := '1';


constant COMP_RATIO_1_TO_1   : std_logic_vector(1 downto 0) := B"00";   -- Mux  ch 1
constant COMP_RATIO_2_TO_1   : std_logic_vector(1 downto 0) := B"01";   -- Mux  ch 1,2
constant COMP_RATIO_3_TO_1   : std_logic_vector(1 downto 0) := B"10";   -- Mux  ch 1,2,3
constant COMP_RATIO_4_TO_1   : std_logic_vector(1 downto 0) := B"11";   -- Mux  ch 1,2,3,4


-- ----------------------------------------------------------------------------------------
-- FPGA model
constant DEVICE_NONE        : std_logic_vector(7 downto 0) := X"00";
constant DEVICE_XC7A35_484  : std_logic_vector(7 downto 0) := X"01";
constant DEVICE_XC7A50_484  : std_logic_vector(7 downto 0) := X"02";
constant DEVICE_XC7A75_484  : std_logic_vector(7 downto 0) := X"03";
constant DEVICE_XC7A100_484  : std_logic_vector(7 downto 0) := X"04";
constant DEVICE_XC7A200_S484  : std_logic_vector(7 downto 0) := X"05";
constant DEVICE_XC7A200_F484  : std_logic_vector(7 downto 0) := X"06";

constant DEVICE_XC7A75_676      : std_logic_vector(7 downto 0) := X"07";
constant DEVICE_XC7A100_676     : std_logic_vector(7 downto 0) := X"08";

constant DEVICE_XC7A15_484      : std_logic_vector(7 downto 0) := X"09";

constant FPGA_DEVICE_MODEL      : std_logic_vector(7 downto 0) := DEVICE_XC7A75_676;


constant logo       : integer := 0; -- 1 => code is present
constant timeoutmax : integer := 127; -- time in sec to turn off logo


type payload_ident is record
   -- b1
   byte_1   : std_logic_vector(7 downto 0);
   -- b2
   byte_2   : std_logic_vector(7 downto 0);
   -- b3
   byte_3   : std_logic_vector(7 downto 0);
   -- b4
   byte_4   : std_logic_vector(7 downto 0);
end record;

type vector8 is array (natural range <>) of std_logic_vector(7 downto 0);
type vector16 is array (natural range <>) of std_logic_vector(15 downto 0);
type vector32 is array (natural range <>) of std_logic_vector(31 downto 0);
type vector64 is array (natural range <>) of std_logic_vector(63 downto 0);

COMPONENT alignment2
Port ( 
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		din : in STD_LOGIC_VECTOR (63 downto 0);
		dv_in : in STD_LOGIC;
		-- be_in : in integer range 1 to 8;
		-- be_out : in integer range 1 to 8;
		be_in_bits : in unsigned (7 downto 0);
		be_out_bits : in unsigned (7 downto 0);
		nb_bytes : in unsigned (15 downto 0);
		dout : out STD_LOGIC_VECTOR (63 downto 0);
		dv_out : out STD_LOGIC
	);
END COMPONENT;

component test port (
		CLK : in STD_ULOGIC;
		GSR : in STD_ULOGIC;
		GTS : in STD_ULOGIC);
end component;

component redge2x_async
generic ( init    : STD_LOGIC := '0';
          tapsel  : Integer  := 0    );
port (reset_n : in STD_LOGIC;
         clk   : in STD_LOGIC;
         ena   : in STD_LOGIC;      
         i     : in STD_LOGIC;
         q     : out STD_LOGIC;
         rise  : out STD_LOGIC;
         fall  : out STD_LOGIC);
end component;


component redge4x_async
generic ( init    : STD_LOGIC := '0';
          tapsel  : Integer  := 0    );
port (reset_n : in STD_LOGIC;
         clk   : in STD_LOGIC;
         ena   : in STD_LOGIC;      
         i     : in STD_LOGIC;
         q     : out STD_LOGIC;
         rise  : out STD_LOGIC;
         fall  : out STD_LOGIC);
end component;


component ksz8863_cfg
generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"1010_0000");
port (
    rstn      : in  std_logic;    
    clk      : in  std_logic;  
    i_scl     : in std_logic;     
    i_sda     : in std_logic;  
    i_sda_oe  : out std_logic  
) ;
end component;


component bm78spp_cfg
generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"1010_0000");
port (
    rstn      : in  std_logic;    
    clk      : in  std_logic;  
    i_scl     : in std_logic;     
    i_sda     : in std_logic;  
    i_sda_oe  : out std_logic
) ;
end component;


component ksz8863_init
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;




component i2c_reg
generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"0110_0000");
port (
  rstn      : in  std_logic;    
	clk      : in  std_logic;  
	i_scl     : in std_logic;     
	i_sda     : in std_logic;  
	i_sda_oe  : out std_logic;  
	busy      : out std_logic;     
	wren     : out std_logic;     
	wr_addr  : out std_logic_vector(7 downto 0);
	--
	o_reg_00  : out std_logic_vector(7 downto 0);
	o_reg_01  : out std_logic_vector(7 downto 0);
	o_reg_02  : out std_logic_vector(7 downto 0);
	i_stat_03 : in  std_logic_vector(7 downto 0);
	i_stat_04 : in  std_logic_vector(7 downto 0);
	i_stat_05 : in  std_logic_vector(7 downto 0);
	i_stat_06 : in  std_logic_vector(7 downto 0);
	i_stat_07 : in  std_logic_vector(7 downto 0);
	i_stat_08 : in  std_logic_vector(7 downto 0);
	i_stat_09 : in  std_logic_vector(7 downto 0);
	i_stat_10 : in  std_logic_vector(7 downto 0);
	i_stat_11 : in  std_logic_vector(7 downto 0);
	i_stat_12 : in  std_logic_vector(7 downto 0);
	i_stat_13 : in  std_logic_vector(7 downto 0);
	i_stat_14 : in  std_logic_vector(7 downto 0);
	i_stat_15 : in  std_logic_vector(7 downto 0);
	i_stat_16 : in  std_logic_vector(7 downto 0);
	i_stat_17 : in  std_logic_vector(7 downto 0);
	i_stat_18 : in  std_logic_vector(7 downto 0);
	i_stat_19 : in  std_logic_vector(7 downto 0);
	i_stat_20 : in  std_logic_vector(7 downto 0);
	i_stat_21 : in  std_logic_vector(7 downto 0);
	i_stat_22 : in  std_logic_vector(7 downto 0);
	i_stat_23 : in  std_logic_vector(7 downto 0);
	i_stat_24 : in  std_logic_vector(7 downto 0);
	i_stat_25 : in  std_logic_vector(7 downto 0);
	i_stat_26 : in  std_logic_vector(7 downto 0);
	i_stat_27 : in  std_logic_vector(7 downto 0);
	i_stat_28 : in  std_logic_vector(7 downto 0);
	i_stat_29 : in  std_logic_vector(7 downto 0);
	i_stat_30 : in  std_logic_vector(7 downto 0);
	i_stat_31 : in  std_logic_vector(7 downto 0);
	
	o_reg_32  : out std_logic_vector(7 downto 0);
	o_reg_33  : out std_logic_vector(7 downto 0);
	o_reg_34  : out std_logic_vector(7 downto 0);
	o_reg_35  : out std_logic_vector(7 downto 0);
	o_reg_36  : out std_logic_vector(7 downto 0);
	o_reg_37  : out std_logic_vector(7 downto 0);
	o_reg_38  : out std_logic_vector(7 downto 0);
	o_reg_39  : out std_logic_vector(7 downto 0);
	o_reg_40  : out std_logic_vector(7 downto 0);
	o_reg_41  : out std_logic_vector(7 downto 0);
	o_reg_42  : out std_logic_vector(7 downto 0);
	o_reg_43  : out std_logic_vector(7 downto 0)
) ;
end component;


component i2c_reg_B
generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"0110_0010");
port (
  rstn      : in  std_logic;    
	clk      : in  std_logic;  
	i_scl     : in std_logic;     
	i_sda     : in std_logic;  
	i_sda_oe  : out std_logic;  
	busy      : out std_logic;     
	wren     : out std_logic;     
	wr_addr  : out std_logic_vector(7 downto 0);
	--
	o_reg_00  : out std_logic_vector(7 downto 0);
	o_reg_01  : out std_logic_vector(7 downto 0);
	o_reg_02  : out std_logic_vector(7 downto 0);
	o_reg_03  : out std_logic_vector(7 downto 0);
	o_reg_04  : out std_logic_vector(7 downto 0);
	o_reg_05  : out std_logic_vector(7 downto 0);
	o_reg_06  : out std_logic_vector(7 downto 0);
	o_reg_07  : out std_logic_vector(7 downto 0);
	i_stat_08 : in  std_logic_vector(7 downto 0);
	i_stat_09 : in  std_logic_vector(7 downto 0);
	i_stat_10 : in  std_logic_vector(7 downto 0);
	i_stat_11 : in  std_logic_vector(7 downto 0);
	i_stat_12 : in  std_logic_vector(7 downto 0);
	i_stat_13 : in  std_logic_vector(7 downto 0);
	i_stat_14 : in  std_logic_vector(7 downto 0);
	i_stat_15 : in  std_logic_vector(7 downto 0);
	i_stat_16 : in  std_logic_vector(7 downto 0);
	i_stat_17 : in  std_logic_vector(7 downto 0);
	i_stat_18 : in  std_logic_vector(7 downto 0);
	i_stat_19 : in  std_logic_vector(7 downto 0);
	i_stat_20 : in  std_logic_vector(7 downto 0);
	i_stat_21 : in  std_logic_vector(7 downto 0);
	i_stat_22 : in  std_logic_vector(7 downto 0);
	i_stat_23 : in  std_logic_vector(7 downto 0);
	i_stat_24 : in  std_logic_vector(7 downto 0);
	i_stat_25 : in  std_logic_vector(7 downto 0);
	i_stat_26 : in  std_logic_vector(7 downto 0);
	i_stat_27 : in  std_logic_vector(7 downto 0);
	i_stat_28 : in  std_logic_vector(7 downto 0);
	i_stat_29 : in  std_logic_vector(7 downto 0);
	i_stat_30 : in  std_logic_vector(7 downto 0);
	i_stat_31 : in  std_logic_vector(7 downto 0);
	
	o_reg_32  : out std_logic_vector(7 downto 0);
	o_reg_33  : out std_logic_vector(7 downto 0);
	o_reg_34  : out std_logic_vector(7 downto 0);
	o_reg_35  : out std_logic_vector(7 downto 0);
	o_reg_36  : out std_logic_vector(7 downto 0);
	o_reg_37  : out std_logic_vector(7 downto 0);
	o_reg_38  : out std_logic_vector(7 downto 0);
	o_reg_39  : out std_logic_vector(7 downto 0);
	o_reg_40  : out std_logic_vector(7 downto 0);
	o_reg_41  : out std_logic_vector(7 downto 0);
	o_reg_42  : out std_logic_vector(7 downto 0);
	o_reg_43  : out std_logic_vector(7 downto 0)
) ;
end component;


component i2c_reg_K is
   generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"0110_1000");
	 port(
      rstn      : in  std_logic;    
      clk       : in  std_logic;  
      i_scl     : in std_logic;     
      i_sda     : in std_logic;  
      i_sda_oe  : out std_logic;
      --  
      busy      : out std_logic;     
      wren      : out std_logic;
      wr_addr   : out std_logic_vector(7 downto 0);
      --
      o_reg_00  : out std_logic_vector(7 downto 0);
      o_reg_01  : out std_logic_vector(7 downto 0);
      o_reg_02  : out std_logic_vector(7 downto 0);
      o_reg_03  : out std_logic_vector(7 downto 0);
      o_reg_04  : out std_logic_vector(7 downto 0);
      o_reg_05  : out std_logic_vector(7 downto 0);
      o_reg_06  : out std_logic_vector(7 downto 0);
      o_reg_07  : out std_logic_vector(7 downto 0);

  		i_reg_00 : in  std_logic_vector(7 downto 0);
      i_reg_01 : in  std_logic_vector(7 downto 0);
      i_reg_02 : in  std_logic_vector(7 downto 0);
      i_reg_03 : in  std_logic_vector(7 downto 0);
      i_reg_04 : in  std_logic_vector(7 downto 0);
      i_reg_05 : in  std_logic_vector(7 downto 0);
      i_reg_06 : in  std_logic_vector(7 downto 0);
      i_reg_07 : in  std_logic_vector(7 downto 0)      
      ) ;
end component;


component i2c_mdio_cl56 is
generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"0110_0100");
port(
  rstn      : in  std_logic;    
  clk       : in  std_logic;
  --  
  scl      : in std_logic;     
  sda       : in std_logic;  
  sda_oe    : out std_logic;
  --
  mdc       : out std_logic;
  --
  mdio_in   : in std_logic;
  mdio_out  : out std_logic;
  mdio_oe   : out std_logic
) ;
end component;


component ql_i2cs_rom is
   generic( DEVICE_ID:  std_logic_vector(7 downto 0) := b"1010_0000"  );
   port(
      resetn : in  std_logic;    -- Active low asynchronous reset.
      scl    : in  std_logic;  -- I2C shared clock signal input path.
      sda    : in  std_logic;     -- I2C shared data signal input path.
      sda_oe  : out std_logic   
   ) ;
end component;


component TX_speed_detect
generic (rate : std_logic_vector(2 downto 0) := autorate );
port (
   -- Global Rstn
   rstn :  in std_logic;
   -- clock
   clk  :  in std_logic; 
   -- data in
   dinp  : in std_logic_vector(19 downto 0);  -- LSB is rx first
   -- data out
   doutp  : inout std_logic_vector(19 downto 0);  -- LSB is rx first
   -- rx loss of signal 
   rxlos : in std_logic; 
   -- clock 27M for control only
   clk27M   : in std_logic;
   
   rst_full   : out std_logic;     -- reset all
   rstpcs    : out std_logic;  -- reset rx pcs
   
   sync_out  : out std_logic;    -- sync out, for test only
   vsync_out  : out std_logic;   -- vsync out, for test only
   -- syncdet, for test only
   syncdet  : out std_logic;
   -- data out
   locked   : out std_logic;
   speed    : out std_logic_vector(2 downto 0);
     
   eav   : out std_logic;
   sav   : out std_logic;
   sync_lock : out std_logic;
 
   sav_pos  : out STD_LOGIC_VECTOR(15 downto 0);
   eav_pos  : out STD_LOGIC_VECTOR(15 downto 0)
);
end component;


component video_sdi_gen_v2	
port (
   -- Global Rstn
  rstn :  in std_logic;
  -- clock
  clk  :  in std_logic;
  -- timeout
  mute : in std_logic;
  mode : in std_logic_vector(1 downto 0);   -- SDI mode
  -- data out
  data_out  : out std_logic_vector(19 DOWNTO 0);  -- LSB is rx first
  
  hsync    : out std_logic;
  vsync    : out std_logic   
);
end component;


component video_crc
  port (
    rstn : in std_logic;
    clk : in std_logic; 
    din : in std_logic_vector(9 downto 0);
    crc_en : in std_logic;
    crc_out : out std_logic_vector(17 downto 0)
     );
end component;


component compressor_20to64_V1
port (
    -- Global Rstn
    rstn :  in std_logic;
    -- clock
    clk  :  in std_logic;
    -- data in slave
    s_tvalid  : in std_logic;     -- data available
    s_tready  : out std_logic;    -- data available
    s_tdata   : in std_logic_vector(19 DOWNTO 0);    --
     
    -- data out master
    m_tvalid  : out std_logic;
    m_tready  : in std_logic;
    m_tdata   : out std_logic_vector(65 DOWNTO 0)
);
end component;


component decompressor_64to20_V1
--generic(synclength : integer := 16);	-- must be >=4
port (
    -- Global Rstn
    rstn  :  in std_logic;
    -- clock
    clk   :  in std_logic;
    -- data in
    s_tvalid  : in std_logic;     -- data available
    s_tready  : out std_logic;    -- data available
    s_tdata   : in std_logic_vector(65 DOWNTO 0);    -- 
    -- data out path
    m_tvalid  : out std_logic;
    m_tready  : in std_logic;
    m_tdata   : out std_logic_vector(19 DOWNTO 0)
);
end component;


component compressor_mux_xaui_V1 is
generic(dwidth : integer := 64;
        synclength : integer := 16);	
port (
   -- Global Rstn
   rstn :  in std_logic;
   -- clock
   clk  :  in std_logic;
   -- 
   cfg  : in std_logic_vector(1 DOWNTO 0);  -- 0 = channel #1 / 1 = mux channel #1,#2 / 2 = mux channel #3,#4 / 3 = mux channel #1,#2,#3,#4
   --
   colorbar : in  std_logic_vector(19 DOWNTO 0);
   colorbar_ena : out std_logic;
   test_pattern : in  std_logic;
   --
   rdy_ctl   : in std_logic;
--   rden_ctl  : out std_logic;
   ctrl_code : in  std_logic_vector(47 DOWNTO 0);
   --
   s_burst_rdy_A    : in std_logic;   -- there is enough data in fifo for a data burst 
   s_burst_rdy_B    : in std_logic; 
   s_burst_rdy_C    : in std_logic; 
   s_burst_rdy_D    : in std_logic; 
   --  
   -- data in
   s_tready_A    : out std_logic; 
   s_tvalid_A    : in std_logic; 
   s_tdata_A     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_A   : out std_logic;
    --
   s_tready_B    : out std_logic; 
   s_tvalid_B    : in std_logic; 
   s_tdata_B     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_B   : out std_logic;
    --
   s_tready_C    : out std_logic; 
   s_tvalid_C    : in std_logic; 
   s_tdata_C     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_C   : out std_logic;
    --
   s_tready_D    : out std_logic; 
   s_tvalid_D    : in std_logic; 
   s_tdata_D     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_D   : out std_logic;
   --
   -- XAUI interface
   --   
   data_out  : out std_logic_vector(dwidth-1 DOWNTO 0);
   data_ctl : out std_logic_vector(7 DOWNTO 0)
);
end component;

component compressor_mux_xaui_V2 is
generic(dwidth : integer := 64;
        synclength : integer := 16);	
port (
   -- Global Rstn
   rstn :  in std_logic;
   -- clock
   clk  :  in std_logic;
   -- 
   cfg  : in std_logic_vector(1 DOWNTO 0);  -- 0 = channel #1 / 1 = mux channel #1,#2 / 2 = mux channel #3,#4 / 3 = mux channel #1,#2,#3,#4
   --
   colorbar : in  std_logic_vector(19 DOWNTO 0);
   colorbar_ena : out std_logic;
   test_pattern : in  std_logic;
   --
   rdy_ctl   : in std_logic;
--   rden_ctl  : out std_logic;
   cmd_code : in  std_logic_vector(55 DOWNTO 0);
   ctrl_code : in  std_logic_vector(47 DOWNTO 0);
   --
   s_burst_rdy_A    : in std_logic;   -- there is enough data in fifo for a data burst 
   s_burst_rdy_B    : in std_logic; 
   s_burst_rdy_C    : in std_logic; 
   s_burst_rdy_D    : in std_logic; 
   --  
   -- data in
   s_tready_A    : out std_logic; 
   s_tvalid_A    : in std_logic; 
   s_tdata_A     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_A   : out std_logic;
    --
   s_tready_B    : out std_logic; 
   s_tvalid_B    : in std_logic; 
   s_tdata_B     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_B   : out std_logic;
    --
   s_tready_C    : out std_logic; 
   s_tvalid_C    : in std_logic; 
   s_tdata_C     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_C   : out std_logic;
    --
   s_tready_D    : out std_logic; 
   s_tvalid_D    : in std_logic; 
   s_tdata_D     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_D   : out std_logic;
   --
   -- XAUI interface
   --   
   data_out  : out std_logic_vector(dwidth-1 DOWNTO 0);
   data_ctl : out std_logic_vector(7 DOWNTO 0)
);
end component;

component compressor_mux_xaui_V3
generic(dwidth : integer := 64;
        synclength : integer := 16);	-- must be >=4
port (
   -- Global Rstn
   rstn  :  in std_logic;
   -- clock
   clk   :  in std_logic;
   -- 
   cfg   : in std_logic_vector(1 DOWNTO 0);  -- 0 = channel #1 / 1 = mux channel #1,#2 / 2 = mux channel #1,#2,#3 / 3 = mux channel #1,#2,#3,#4
   rxff_rd_cnt_A   : in std_logic_vector(15 DOWNTO 0);  
   --
   colorbar     : in  std_logic_vector(19 DOWNTO 0);
   colorbar_ena : out std_logic;
   test_pattern : in  std_logic;
   --
   rdy_ctl      : in std_logic;
--   rden_ctl     : out std_logic;
   ctrl_code    : in  std_logic_vector(47 DOWNTO 0);
   cmd_code     : in  std_logic_vector(55 DOWNTO 0);  
   --
   s_burst_rdy_A    : in std_logic;   -- there is enough data in fifo for a data burst 
   s_burst_rdy_B    : in std_logic; 
   s_burst_rdy_C    : in std_logic; 
   s_burst_rdy_D    : in std_logic; 
     
   -- data in
   s_tready_A    : out std_logic; 
   s_tvalid_A    : in std_logic; 
   s_tdata_A     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_A   : out std_logic;
   
   s_tready_B    : out std_logic; 
   s_tvalid_B    : in std_logic; 
   s_tdata_B     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_B   : out std_logic;

   s_tready_C    : out std_logic; 
   s_tvalid_C    : in std_logic; 
   s_tdata_C     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_C   : out std_logic;

   s_tready_D    : out std_logic; 
   s_tvalid_D    : in std_logic; 
   s_tdata_D     : in std_logic_vector(dwidth+1 DOWNTO 0);
   psync_D   : out std_logic;

   --
   s_burst_rdy_sio : in std_logic;   -- there is enough data in fifo for a data burst 
   s_tready_sio    : out std_logic; 
   s_tvalid_sio    : in std_logic; 
   s_tdata_sio     : in std_logic_vector(dwidth-1 DOWNTO 0);
  
   --
   -- XAUI interface, 64 bit interface with byte enable
   --   
   data_out  : out std_logic_vector(dwidth-1 DOWNTO 0);
   data_ctl : out std_logic_vector(7 DOWNTO 0)
   );
end component;

component hamming_decode_4b
Port ( 
  data_in  : in STD_LOGIC_VECTOR (7 downto 0);
  --
  data_out : out STD_LOGIC_VECTOR (3 downto 0);
  --
  corrected   : out STD_LOGIC;
  error   : out STD_LOGIC
);
end component;


component xaui
port (
  dclk : IN STD_LOGIC;
  reset : IN STD_LOGIC;
  clk156_out : OUT STD_LOGIC;
  refclk_p : IN STD_LOGIC;
  refclk_n : IN STD_LOGIC;
  clk156_lock : OUT STD_LOGIC;
  xgmii_txd : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  xgmii_txc : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  xgmii_rxd : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  xgmii_rxc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  xaui_tx_l0_p : OUT STD_LOGIC;
  xaui_tx_l0_n : OUT STD_LOGIC;
  xaui_tx_l1_p : OUT STD_LOGIC;
  xaui_tx_l1_n : OUT STD_LOGIC;
  xaui_tx_l2_p : OUT STD_LOGIC;
  xaui_tx_l2_n : OUT STD_LOGIC;
  xaui_tx_l3_p : OUT STD_LOGIC;
  xaui_tx_l3_n : OUT STD_LOGIC;
  xaui_rx_l0_p : IN STD_LOGIC;
  xaui_rx_l0_n : IN STD_LOGIC;
  xaui_rx_l1_p : IN STD_LOGIC;
  xaui_rx_l1_n : IN STD_LOGIC;
  xaui_rx_l2_p : IN STD_LOGIC;
  xaui_rx_l2_n : IN STD_LOGIC;
  xaui_rx_l3_p : IN STD_LOGIC;
  xaui_rx_l3_n : IN STD_LOGIC;
  signal_detect : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  debug : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  configuration_vector : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
  status_vector : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
end component;



component sdigenparallel	
generic(depth : integer := 20);
port (
  rstn  :	in std_logic;    -- Global Rstn
  clk   :   in std_logic;       -- clock 
  den   :   in std_logic;       -- data enable 
  dinp  : in std_logic_vector(depth-1 DOWNTO 0);     -- data in -- LSB is sent first
  dout  : out std_logic_vector(depth-1 DOWNTO 0)     -- data out 
);
end component;


component video_sdi_gen	
generic(format : integer := 2); -- 2 = HD(1980i60) 1 = 3G(1980p60)
port (
  -- Global Rstn
  rstn :  in std_logic;
  -- clock
  clk  :  in std_logic;
  -- timeout
  mute : in std_logic;
  -- data out
  data_out  : out std_logic_vector(19 DOWNTO 0)  -- LSB is rx first
);
end component;

component decompressor_xaui_v1
generic(dwidth : integer := 64;
        synclength : integer := 16);	-- must be >= 4
port (
    rstn 	  : in std_logic;   -- Global Rstn
    clk     : in std_logic;    -- clock
    --
    test    : in std_logic;    -- 
--    mode    : in std_logic_vector(1 DOWNTO 0);  -- sdi mode
    --
    config  : in std_logic_vector(1 DOWNTO 0);  -- 0 = channel #1 / 1 = mux channel #1,#2 / 2 = mux channel #3,#4 / 3 = mux channel #1,#2,#3,#4
    --
    data_in  : in std_logic_vector(dwidth-1 DOWNTO 0);  -- Xaui data in
    data_ctl : in std_logic_vector(7 DOWNTO 0);        -- Xaui CTL code 
    --
    ctrl_code   : out std_logic_vector(47 downto 0);
    wr_ctl      : out std_logic;
    --  
    dout_A 		: out std_logic_vector(dwidth +1 DOWNTO 0);   -- data stream out
    wren_A    : out std_logic;
    psync_A   : out std_logic;
    --  
    dout_B    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_B    : out std_logic;
    psync_B   : out std_logic;
    --  
    dout_C    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_C    : out std_logic;
    psync_C   : out std_logic;
    --  
    dout_D    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_D    : out std_logic;
    psync_D   : out std_logic;
    
    state_error_count   : out unsigned(15 DOWNTO 0);
    
    tp_i   : in std_logic_vector(7 DOWNTO 0)
);
end component;

component decompressor_xaui_v2
generic(dwidth : integer := 64;
        synclength : integer := 16);	-- must be >= 4
port (
    rstn 	  : in std_logic;   -- Global Rstn
    clk     : in std_logic;    -- clock
    --
    test    : in std_logic;    -- 
--    mode    : in std_logic_vector(1 DOWNTO 0);  -- sdi mode
    --
    config  : in std_logic_vector(1 DOWNTO 0);  -- 0 = channel #1 / 1 = mux channel #1,#2 / 2 = mux channel #3,#4 / 3 = mux channel #1,#2,#3,#4
    --
    data_in  : in std_logic_vector(dwidth-1 DOWNTO 0);  -- Xaui data in
    data_ctl : in std_logic_vector(7 DOWNTO 0);        -- Xaui CTL code 
    --
    cmd_code   : out std_logic_vector(55 downto 0);
    ctrl_code   : out std_logic_vector(47 downto 0);
    wr_ctl      : out std_logic;
    --  
    dout_A 		: out std_logic_vector(dwidth +1 DOWNTO 0);   -- data stream out
    wren_A    : out std_logic;
    psync_A   : out std_logic;
    --  
    dout_B    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_B    : out std_logic;
    psync_B   : out std_logic;
    --  
    dout_C    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_C    : out std_logic;
    psync_C   : out std_logic;
    --  
    dout_D    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_D    : out std_logic;
    psync_D   : out std_logic;
    
    state_error_count   : out unsigned(15 DOWNTO 0);
    
    tp_i   : in std_logic_vector(7 DOWNTO 0)
);
end component;


component decompressor_xaui_v3
generic(dwidth : integer := 64;
        synclength : integer := 16);	-- must be >= 4
port (
    rstn 	  : in std_logic;   -- Global Rstn
    clk     : in std_logic;    -- clock
    --
    test    : in std_logic;    -- 
--    mode    : in std_logic_vector(1 DOWNTO 0);  -- sdi mode
    --
    config  : in std_logic_vector(1 DOWNTO 0);  -- 0 = channel #1 / 1 = mux channel #1,#2 / 2 = mux channel #3,#4 / 3 = mux channel #1,#2,#3,#4
    --
    data_in  : in std_logic_vector(dwidth-1 DOWNTO 0);  -- Xaui data in
    data_ctl : in std_logic_vector(7 DOWNTO 0);        -- Xaui CTL code 
    --
    cmd_code   : out std_logic_vector(55 downto 0);
    ctrl_code   : out std_logic_vector(47 downto 0);
    wr_ctl      : out std_logic;
    --  
    dout_A 		: out std_logic_vector(dwidth +1 DOWNTO 0);   -- data stream out
    wren_A    : out std_logic;
    psync_A   : out std_logic;
    --  
    dout_B    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_B    : out std_logic;
    psync_B   : out std_logic;
    --  
    dout_C    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_C    : out std_logic;
    psync_C   : out std_logic;
    --  
    dout_D    : out std_logic_vector(dwidth +1 DOWNTO 0);   -- data out
    wren_D    : out std_logic;
    psync_D   : out std_logic;

    --  
    tdata_sio     : out std_logic_vector(dwidth-1 DOWNTO 0);   -- data out
    tvalid_sio   : out std_logic;
    tready_sio   : in std_logic;
    
    state_error_count   : out unsigned(15 DOWNTO 0);
    
    tp_i   : in std_logic_vector(7 DOWNTO 0)
);
end component;

component xaui_dword_align	
port ( 
  rstn :  in std_logic;        -- Global Rstn   
  clk  :  in std_logic;        -- clock
  --
  data_in    : in std_logic_vector(63 DOWNTO 0);
  ctrl_in    : in std_logic_vector(7 DOWNTO 0);
  --
  data_out   : out std_logic_vector(63 DOWNTO 0);
  ctrl_out   : out std_logic_vector(7 DOWNTO 0);
  --
  idx        : out std_logic_vector(2 DOWNTO 0);
  sof        : out std_logic   -- start of frame
);
end component;


component xaui_align	
port ( 
  rstn :  in std_logic;        -- Global Rstn   
  clk  :  in std_logic;        -- clock
  --
  data_in    : in std_logic_vector(63 DOWNTO 0);
  ctrl_in    : in std_logic_vector(7 DOWNTO 0);
  --
  data_out   : out std_logic_vector(63 DOWNTO 0);
  ctrl_out   : out std_logic_vector(7 DOWNTO 0);
  --
  idx        : out std_logic;
  sof        : out std_logic   -- start of frame
);
end component;


component sdi_rx_encode 
port (
  -- Global Rstn
  reset_n       :  in std_logic;
  resetpcs_in   :  in std_logic;
  
  -- clock
  clk27m     :  in std_logic;
  xaui_clk   :  in std_logic;
  sdi_clk    :  in std_logic;
   
  -- data in
  s_tready   : out std_logic;
  s_tvalid   : in std_logic;    -- data available
  s_tdata    : in std_logic_vector(19 DOWNTO 0);  -- LSB is rx first
  
  -- data out path
  m_tready   : in  std_logic;
  m_tvalid   : out std_logic;
  m_tdata    : out std_logic_vector(65 DOWNTO 0);   -- bit 65,64 are for alignment resync purpose
  
  --
  reset_full   : out std_logic;
  resetpcs_o   : out std_logic;
  speed_det    : out std_logic_vector(2 downto 0);
  locked       : out std_logic;
  led_stat     : out std_logic_vector(1 downto 0);
  sync_lock    : out std_logic;
  
  hsync        : out std_logic;
  vsync        : out std_logic;

  sdi_aligned_out		: out std_logic_vector(19 DOWNTO 0); 
  sdi_aligned_out_dv	: out std_logic; 

  read_count   : out std_logic_vector(15 downto 0);

  probe0      : out std_logic_vector(19 DOWNTO 0);
  probe1      : out std_logic_vector(19 DOWNTO 0)
);
end component;



component sdi_tx_decode 
port (
  -- Global Rstn
  reset_n   :  in std_logic;
  
  -- clock
  xaui_clk  :  in std_logic;
  sdi_clk   :  in std_logic;
   
  -- data in
  s_tready   : out std_logic;    -- data available
  s_tvalid   : in std_logic;    -- data available
  s_tdata   : in std_logic_vector(65 DOWNTO 0);  -- LSB is rx first
  
  -- data out path
  do_valid  : out std_logic;
  do_data   : out std_logic_vector(19 DOWNTO 0);   -- bit 65,64 are for alignment resync purpose
  
  -- control signals
  tx_mode   : in std_logic_vector(1 DOWNTO 0);   -- bit 65,64 are for alignment resync purpose
  test_pattern  : in std_logic;
  led_stat      : out std_logic_vector(1 DOWNTO 0);
  sync_lock       : out std_logic;
  
  read_count   : out std_logic_vector(15 downto 0);
  
  tp_o  : out std_logic_vector(7 downto 0)
);
end component;


component led_status
generic (
    K_6G_CODE_BLUE_RX      : std_logic_vector(15 downto 0) := b"1100110011000000";
    K_3G_CODE_BLUE_RX      : std_logic_vector(15 downto 0) := b"1100110000000000";
    K_HD_CODE_BLUE_RX      : std_logic_vector(15 downto 0) := b"1100000000000000";

    K_6G_CODE_RED_RX       : std_logic_vector(15 downto 0) := b"1100110011000000";
    K_3G_CODE_RED_RX       : std_logic_vector(15 downto 0) := b"1100110000000000";
    K_HD_CODE_RED_RX       : std_logic_vector(15 downto 0) := b"1100000000000000";

    K_NONE_CODE_BLUE_RX    : std_logic_vector(15 downto 0) := b"0000000000000000";
    K_NONE_CODE_RED_RX     : std_logic_vector(15 downto 0) := b"0000000000000000";
    --
    K_6G_CODE_BLUE_TX      : std_logic_vector(15 downto 0) := b"1000100010000000";
    K_3G_CODE_BLUE_TX      : std_logic_vector(15 downto 0) := b"1000100000000000";
    K_HD_CODE_BLUE_TX      : std_logic_vector(15 downto 0) := b"1000000000000000";

    K_6G_CODE_RED_TX       : std_logic_vector(15 downto 0) := b"1000100010000000";
    K_3G_CODE_RED_TX       : std_logic_vector(15 downto 0) := b"1000100000000000";
    K_HD_CODE_RED_TX       : std_logic_vector(15 downto 0) := b"1000000000000000";

    K_NONE_CODE_BLUE_TX    : std_logic_vector(15 downto 0) := b"0000000000000000";
    K_NONE_CODE_RED_TX     : std_logic_vector(15 downto 0) := b"0000000000000000"
);
  port (
    rstn :  in std_logic;
    clk:     in  std_logic;
    ena   :  in  std_logic;
    unit_mode  :  in  std_logic;    -- 0: TX   1: RX
    
    rx_override   :  in  std_logic; -- software override
    rx_error_n   :  in  std_logic;
    rx_code      :  in  std_logic_vector(1 downto 0); -- display code
    rx_s_red     :  in  std_logic;
    rx_s_blue    :  in  std_logic;

    tx_override   :  in  std_logic; -- software override
    tx_error_n   :  in  std_logic;
    tx_code      :  in  std_logic_vector(1 downto 0); -- display code for tx mode
    tx_s_red     :  in  std_logic;
    tx_s_blue    :  in  std_logic;
                                            
    red       :  out std_logic;
    blue      :  out std_logic
);                                                                 
end component;


component led_status_act
generic (
    K_C_CODE_BLUE      : std_logic_vector(15 downto 0) := b"1100110011000000";
    K_B_CODE_BLUE      : std_logic_vector(15 downto 0) := b"1100110000000000";
    K_A_CODE_BLUE      : std_logic_vector(15 downto 0) := b"1100000000000000";

    K_C_CODE_RED       : std_logic_vector(15 downto 0) := b"1100110011000000";
    K_B_CODE_RED       : std_logic_vector(15 downto 0) := b"1100110000000000";
    K_A_CODE_RED       : std_logic_vector(15 downto 0) := b"1100000000000000";

    K_NONE_CODE_BLUE    : std_logic_vector(15 downto 0) := b"0000000000000000";
    K_NONE_CODE_RED     : std_logic_vector(15 downto 0) := b"0000000000000000"
);
  port (
    rstn :  in std_logic;
    clk:     in  std_logic;
    ena   :  in  std_logic;
    
    override   :  in  std_logic; -- software override
    error     :  in  std_logic;
    code      :  in  std_logic_vector(1 downto 0); -- display code for tx mode
    s_red     :  in  std_logic;
    s_blue    :  in  std_logic;
                                            
    red       :  out std_logic;
    blue      :  out std_logic
);                                                                 
end component;


component uart_rx_w is
generic (width : integer := 8);
Port (  
  rstn   : in std_logic;
  clk    : in std_logic;
  baud_8_x : in std_logic;
  dout : out std_logic_vector(width-1 downto 0);
  data_strobe : out std_logic;
  serial_in : in std_logic
);
end component;


component uart_tx_w is
generic (width : integer := 8);
Port ( 	
  rstn   : in std_logic;
  clk    : in std_logic;
  baud_8_x   : in std_logic;
  din    : in std_logic_vector(width-1 downto 0);
  wren   : in std_logic;
  serial_out  : out std_logic 
);
end component;


component sdi_receive	
port ( 
  rstn     :  in std_logic;        -- Global Rstn   
  clk27m   :  in std_logic;        -- clock
  clk_sdi   :  in std_logic;        -- clock
  tp       : in std_logic;     -- test pattern
  rx_los   : in std_logic;     -- loss of sync
  
  rst_full   : out std_logic;
  resetpcs  : out std_logic;    -- reset serdes modules
  speed_det  : out std_logic_vector(2 downto 0);  -- speed detection code
  locked   : out std_logic;
  led_stat   : out std_logic_vector(1 downto 0);
  sync_lock  : out std_logic;
  
  sdi_in   : in std_logic_vector(19 DOWNTO 0);    -- data in  -- LSB is rx first\   
  sdi_out  : out std_logic_vector(19 DOWNTO 0);    -- data out -- LSB is aligned on 0 or 10
  m_tvalid : out std_logic;
  
  sync_out  : out std_logic;
  vsync_out : out std_logic
);
end component;


component sdidescparallel 	
generic(depth : integer := 20);
port (
  -- Global Rstn
  rstn :	in std_logic;
  -- clock
  clk :	in std_logic; 
  -- data in,  LSB is sent first
  dinp  : in std_logic_vector(depth-1 downto 0); 
  -- data out
  dout  : out std_logic_vector(depth-1 downto 0) 
);
end component;


component sdialign 	
port (
  -- Global Rstn
  rstn :  in std_logic;
  -- clock
  clk  :  in std_logic;
  -- mode
  mode : in std_logic_vector(2 DOWNTO 0);
  -- Locked status. to prevent updates when locked   
  locked   : in std_logic;
  -- data in
  sdi_inp  : in std_logic_vector(19 DOWNTO 0);  -- LSB is rx first
  -- data out
  sdi_out  : out std_logic_vector(19 DOWNTO 0);  -- LSB is aligned on 0 or 10
  test : out std_logic
);
end component;


component compressor 
generic(synclength : integer := 8);	-- must be >=4
port (
  -- Global Rstn
  rstn :  in std_logic;
  -- clock
  clk  :  in std_logic; 
  -- data in
  data_in  : in std_logic_vector(19 downto 0);  -- LSB is rx first
  -- guard band
  gben : out std_logic;
  -- video period
  videoen : out std_logic;
  -- data out
  data_out : out std_logic_vector(23 downto 0) 
);
end component;



component hdmi_gen 	
port (
   -- Global Rstn
   rstn :  in std_logic;
   -- clock
   clk  :  in std_logic;
   -- display enable
   videoen : out std_logic; 
   -- data enable 
   dataen : out std_logic;
   -- to guard band encoder 
   gben : out std_logic; 
   -- data out ch 0,1,2
   data_ch0  : out std_logic_vector(7 downto 0);  -- blue channel
   data_ch1  : out std_logic_vector(7 downto 0);  -- green channel
   data_ch2  : out std_logic_vector(7 downto 0)   -- red channel
   );
end component;



COMPONENT TX_fifo_DC
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(65 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(65 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;


COMPONENT RX_fifo_DC
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(65 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(65 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
  );
END COMPONENT;


COMPONENT axis_fifo_1K
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    m_axis_aresetn : IN STD_LOGIC;
    --
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_tuser : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    --     
    m_axis_aclk : IN STD_LOGIC;
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_tuser : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- 
    axis_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT; 


COMPONENT tx_axis_fifo_4k
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    m_axis_aresetn : IN STD_LOGIC;
    --
    s_axis_aclk   : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_tuser  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    --     
    m_axis_aclk   : IN STD_LOGIC;
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata  : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_tuser  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- 
    axis_data_count    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT; 

COMPONENT rx_axis_fifo_2k
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    m_axis_aresetn : IN STD_LOGIC;
    --
    s_axis_aclk    : IN STD_LOGIC;
    s_axis_tvalid  : IN STD_LOGIC;
    s_axis_tready  : OUT STD_LOGIC;
    s_axis_tdata   : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_tuser   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    --     
    m_axis_aclk    : IN STD_LOGIC;
    m_axis_tvalid  : OUT STD_LOGIC;
    m_axis_tready  : IN STD_LOGIC;
    m_axis_tdata   : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_tuser   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- 
    axis_data_count    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT; 





component ila_fifo
PORT (
  clk : IN STD_LOGIC;
  probe0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  probe1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
);
END component;

component ila_serdes
PORT (
  clk : IN STD_LOGIC;
  probe0 : IN STD_LOGIC_VECTOR(39 DOWNTO 0)
);
END component;

-- component ila_tx_dec
-- PORT (
  -- clk : IN STD_LOGIC;
  -- probe0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  -- probe1 : IN STD_LOGIC_VECTOR(65 DOWNTO 0);
  -- probe2 : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
  -- probe3 : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
-- );
-- END component;

COMPONENT ila_tx_dec

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(65 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
	probe3 : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
);
END COMPONENT  ;

COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    probe_in1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

component sdi_serdes
generic (
    FXDCLK_FREQ             : integer := 27000000;    -- Frequency in Hz of fixed frequency clock connected to clk port
    DRPCLK_PERIOD           : integer := 37;          -- Period of drpclk in ns, always round down
    PLLLOCK_TIMEOUT_PERIOD  : integer := 2000000;     -- Period of PLLLOCK timeout in ns, defaults to 2ms
    RESET_TIMEOUT_PERIOD    : integer := 500000;      -- Period of GTP RESTDONE timeout in ns, defaults to 500us
    TIMEOUT_CNTR_BITWIDTH   : integer := 18;          -- Width in bits of timeout counter
    RETRY_CNTR_BITWIDTH     : integer := 8            -- Width in bits of the retry counter
);    
port (   
--    reset           : in std_logic;  
--    soft_reset_i    : in std_logic;     
    reset_serdes_i  : in std_logic;
    resetpcs_rx     : in std_logic;
    resetpcs_tx     : in std_logic;
    --
    rx_reset_o        : out std_logic;
    tx_reset_o        : out std_logic;
    --
    pll_0_reset     : out std_logic;
    pll_1_reset     : out std_logic;
    
    clk27m          : in std_logic;      -- clock    
    pll0clk_in      : in std_logic;      -- clock
    pll0refclk_in   : in std_logic;      -- clock
    pll1clk_in      : in std_logic;      -- clock
    pll1refclk_in   : in std_logic;      -- clock 

    pll_0_lock   : in std_logic;        -- lock status from pll
    pll_1_lock   : in std_logic;
    
    rx_refclk_stable  : in std_logic;
    tx_refclk_stable  : in std_logic;
    
    rxsysclksel     : in std_logic_vector(1 downto 0);

--    rxrate          : in  std_logic_vector(2 downto 0);

    rxmode          : in  std_logic_vector(1 DOWNTO 0);
    rx_m            : out std_logic;
    sdi_rxdata      : out  std_logic_vector(19 downto 0);
    rxoutclk        : out  std_logic;
    
    txmode          : in  std_logic_vector(1 DOWNTO 0);
    tx_m            : in std_logic;
    sdi_txdata      : in  std_logic_vector(19 downto 0);
    txoutclk        : out  std_logic;
    
    sdi_in_n        : in std_logic;  
    sdi_in_p        : in std_logic;  
    
    sdi_out_n       : out std_logic;  
    sdi_out_p       : out std_logic;  

   
    rxuserrdy       : in  std_logic;
    txuserrdy       : in  std_logic;  

    rxbyteisaligned     : out std_logic;
    rxbyterealign       : out std_logic;
    rxcommadet          : out std_logic;
    
    tx_change_done       : out std_logic;
    tx_change_fail       : out std_logic;
    tx_change_fail_code  : out std_logic_vector(2 downto 0);

    rx_change_done       : out std_logic;
    rx_change_fail       : out std_logic;
    rx_change_fail_code  : out std_logic_vector(2 downto 0);

    Offset_ppm          : in std_logic_vector(21 downto 0)
);
end component;

COMPONENT ila_2

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
	probe2 : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
);
END COMPONENT  ;

component a7gtp_sdi_wrapper_common
generic (
    -- Simulation attributes
    WRAPPER_SIM_GTRESET_SPEEDUP   : string :=  "false"     -- Set to "true" to speed up sim reset
);
port (
    GTGREFCLK0_IN   : in    std_logic;
    GTGREFCLK1_IN   : in    std_logic;
    GTEASTREFCLK0_IN   : in    std_logic;
    GTEASTREFCLK1_IN   : in    std_logic;
    GTREFCLK1_IN   : in    std_logic;
    GTWESTREFCLK0_IN   : in    std_logic;
    GTWESTREFCLK1_IN   : in    std_logic;

    PLL0OUTCLK_OUT   : out    std_logic;
    PLL0OUTREFCLK_OUT   : out    std_logic;
    PLL0LOCK_OUT   : out    std_logic;
    PLL0LOCKDETCLK_IN   : in    std_logic;
    PLL0REFCLKLOST_OUT   : out    std_logic;
    PLL0RESET_IN   : in    std_logic;
    PLL0REFCLKSEL_IN   : in    std_logic_vector(2 downto 0);
    PLL1OUTCLK_OUT   : out    std_logic;
    PLL1OUTREFCLK_OUT   : out    std_logic;
    PLL1LOCK_OUT   : out    std_logic;
    PLL1LOCKDETCLK_IN   : in    std_logic;
    PLL1REFCLKLOST_OUT   : out    std_logic;
    PLL1RESET_IN   : in    std_logic;
    PLL1REFCLKSEL_IN   : in    std_logic_vector(2 downto 0);
    GTREFCLK0_IN   : in    std_logic
);
end component;



component a7gtp_sdi_wrapper_b_GT
generic
(
    -- Simulation attributes
    GT_SIM_GTRESET_SPEEDUP    : string := "FALSE"; -- Set to "TRUE" to speed up sim reset
    EXAMPLE_SIMULATION        : integer  := 0;     -- Set to 1 for simulation
    TXSYNC_OVRD_IN            : bit    := '0';
    TXSYNC_MULTILANE_IN       : bit    := '0'; 
    mComma_value             : bit_vector(9 downto 0) :=   "1011001100";
    pComma_value             : bit_vector(9 downto 0) :=   "1101010100"
);
port 
(
  RST_IN         : in   std_logic;          -- Connect to System Reset
  DRP_BUSY_OUT   : out  std_logic;          -- Indicates that the DRP bus is not accessible to the User
  RXPMARESETDONE : out  std_logic;          
  TXPMARESETDONE : out  std_logic;          
    ---------------------------- Channel - DRP Ports  --------------------------
    drpaddr_in                              : in   std_logic_vector(8 downto 0);
    drpclk_in                               : in   std_logic;
    drpdi_in                                : in   std_logic_vector(15 downto 0);
    drpdo_out                               : out  std_logic_vector(15 downto 0);
    drpen_in                                : in   std_logic;
    drprdy_out                              : out  std_logic;
    drpwe_in                                : in   std_logic;
    ------------------------------- Clocking Ports -----------------------------
    rxsysclksel_in                          : in   std_logic_vector(1 downto 0);
    txsysclksel_in                          : in   std_logic_vector(1 downto 0);
    ------------------------ GTPE2_CHANNEL Clocking Ports ----------------------
    pll0clk_in                              : in   std_logic;
    pll0refclk_in                           : in   std_logic;
    pll1clk_in                              : in   std_logic;
    pll1refclk_in                           : in   std_logic;
    ------------------------------- Loopback Ports -----------------------------
    loopback_in                             : in   std_logic_vector(2 downto 0);
    ----------------------------- PCI Express Ports ----------------------------
    rxrate_in                               : in   std_logic_vector(2 downto 0);
    --------------------- RX Initialization and Reset Ports --------------------
    eyescanreset_in                         : in   std_logic;
    rxuserrdy_in                            : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    eyescandataerror_out                    : out  std_logic;
    eyescantrigger_in                       : in   std_logic;
    ------------------------- Receive Ports - CDR Ports ------------------------
    rxcdrhold_in                            : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    rxdata_out                              : out  std_logic_vector(19 downto 0);
    rxusrclk_in                             : in   std_logic;
    rxusrclk2_in                            : in   std_logic;
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gtprxn_in                               : in   std_logic;
    gtprxp_in                               : in   std_logic;
    ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
    rxbufreset_in                           : in   std_logic;
    rxbufstatus_out                         : out  std_logic_vector(2 downto 0);
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    rxbyteisaligned_out                     : out  std_logic;
    rxbyterealign_out                       : out  std_logic;
    rxcommadet_out                          : out  std_logic;
    rxmcommaalignen_in                      : in   std_logic;
    rxpcommaalignen_in                      : in   std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    dmonitorout_out                         : out  std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    rxlpmhfhold_in                          : in   std_logic;
    rxlpmlfhold_in                          : in   std_logic;
    ------------ Receive Ports - RX Fabric ClocK Output Control Ports ----------
    rxratedone_out                          : out  std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    rxoutclk_out                            : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gtrxreset_in                            : in   std_logic;
    rxlpmreset_in                           : in   std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    rxresetdone_out                         : out  std_logic;
    ------------------------ TX Configurable Driver Ports ----------------------
    txpostcursor_in                         : in   std_logic_vector(4 downto 0);
    txprecursor_in                          : in   std_logic_vector(4 downto 0);
    --------------------- TX Initialization and Reset Ports --------------------
    gttxreset_in                            : in   std_logic;
    txuserrdy_in                            : in   std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    txdata_in                               : in   std_logic_vector(19 downto 0);
    txusrclk_in                             : in   std_logic;
    txusrclk2_in                            : in   std_logic;
    --------------------- Transmit Ports - PCI Express Ports -------------------
    txrate_in                               : in   std_logic_vector(2 downto 0);
    ---------------------- Transmit Ports - TX Buffer Ports --------------------
    txbufstatus_out                         : out  std_logic_vector(1 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gtptxn_out                              : out  std_logic;
    gtptxp_out                              : out  std_logic;
    txdiffctrl_in                           : in   std_logic_vector(3 downto 0);
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    txoutclk_out                            : out  std_logic;
    txoutclkfabric_out                      : out  std_logic;
    txoutclkpcs_out                         : out  std_logic;
    txratedone_out                          : out  std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    txpcsreset_in                           : in   std_logic;
    txpmareset_in                           : in   std_logic;
    txresetdone_out                         : out  std_logic;
    
    tx_ppm_step_size				: in std_logic_vector(4 downto 0)
);
end component;



-- introdiced by Vitali
component a7gtp_sdi_wrapper_new_support
generic
(
    -- Simulation attributes
    EXAMPLE_SIM_GTRESET_SPEEDUP    : string    := "FALSE";    -- Set to TRUE to speed up sim reset
    STABLE_CLOCK_PERIOD            : integer   := 37 
);
port
(
    SOFT_RESET_TX_IN                        : in   std_logic;
    SOFT_RESET_RX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    Q0_CLK0_GTREFCLK_PAD_N_IN               : in   std_logic;
    Q0_CLK0_GTREFCLK_PAD_P_IN               : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_N_IN               : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_P_IN               : in   std_logic;

    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;
 
    GT0_TXUSRCLK_OUT                        : out  std_logic;
    GT0_TXUSRCLK2_OUT                       : out  std_logic;
    GT0_RXUSRCLK_OUT                        : out  std_logic;
    GT0_RXUSRCLK2_OUT                       : out  std_logic;

    --_________________________________________________________________________
    --GT0  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
    gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
    gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
    gt0_drpen_in                            : in   std_logic;
    gt0_drprdy_out                          : out  std_logic;
    gt0_drpwe_in                            : in   std_logic;
    ------------------------------- Loopback Ports -----------------------------
    gt0_loopback_in                         : in   std_logic_vector(2 downto 0);
    ----------------------------- PCI Express Ports ----------------------------
    gt0_rxrate_in                           : in   std_logic_vector(2 downto 0);
    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in                     : in   std_logic;
    gt0_rxuserrdy_in                        : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                : out  std_logic;
    gt0_eyescantrigger_in                   : in   std_logic;
    ------------------------- Receive Ports - CDR Ports ------------------------
    gt0_rxcdrhold_in                        : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    gt0_rxdata_out                          : out  std_logic_vector(19 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtprxn_in                           : in   std_logic;
    gt0_gtprxp_in                           : in   std_logic;
    ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
    gt0_rxbufreset_in                       : in   std_logic;
    gt0_rxbufstatus_out                     : out  std_logic_vector(2 downto 0);
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt0_dmonitorout_out                     : out  std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    gt0_rxlpmhfhold_in                      : in   std_logic;
    gt0_rxlpmlfhold_in                      : in   std_logic;
    ------------ Receive Ports - RX Fabric ClocK Output Control Ports ----------
    gt0_rxratedone_out                      : out  std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    gt0_rxoutclkfabric_out                  : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                        : in   std_logic;
    gt0_rxlpmreset_in                       : in   std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    gt0_rxresetdone_out                     : out  std_logic;
    ------------------------ TX Configurable Driver Ports ----------------------
    gt0_txpostcursor_in                     : in   std_logic_vector(4 downto 0);
    gt0_txprecursor_in                      : in   std_logic_vector(4 downto 0);
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                        : in   std_logic;
    gt0_txuserrdy_in                        : in   std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt0_txdata_in                           : in   std_logic_vector(19 downto 0);
    --------------------- Transmit Ports - PCI Express Ports -------------------
    gt0_txrate_in                           : in   std_logic_vector(2 downto 0);
    ---------------------- Transmit Ports - TX Buffer Ports --------------------
    gt0_txbufstatus_out                     : out  std_logic_vector(1 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt0_gtptxn_out                          : out  std_logic;
    gt0_gtptxp_out                          : out  std_logic;
    gt0_txdiffctrl_in                       : in   std_logic_vector(3 downto 0);
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt0_txoutclkfabric_out                  : out  std_logic;
    gt0_txoutclkpcs_out                     : out  std_logic;
    gt0_txratedone_out                      : out  std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt0_txpcsreset_in                       : in   std_logic;
    gt0_txpmareset_in                       : in   std_logic;
    gt0_txresetdone_out                     : out  std_logic;

    --____________________________COMMON PORTS________________________________
   GT0_PLL0RESET_OUT  : out std_logic;
         GT0_PLL0OUTCLK_OUT  : out std_logic;
         GT0_PLL0OUTREFCLK_OUT  : out std_logic;
         GT0_PLL0LOCK_OUT  : out std_logic;
         GT0_PLL0REFCLKLOST_OUT  : out std_logic;    
         GT0_PLL1LOCK_OUT  : out std_logic;
         GT0_PLL1REFCLKLOST_OUT  : out std_logic;    
         GT0_PLL1OUTCLK_OUT  : out std_logic;
         GT0_PLL1OUTREFCLK_OUT  : out std_logic;

        sysclk_in : in std_logic
);
end component;





component GTP_picxo_0
  PORT (
    RESET_I : IN STD_LOGIC;
    REF_CLK_I : IN STD_LOGIC;
    TXOUTCLKPCS_I : IN STD_LOGIC;
    TXOUTCLK_I : IN STD_LOGIC;
    DRPEN_O : OUT STD_LOGIC;
    DRPWEN_O : OUT STD_LOGIC;
    DRPDO_I : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRPDATA_O : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRPADDR_O : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    DRPRDY_I : IN STD_LOGIC;
    RSIGCE_I : IN STD_LOGIC;
    VSIGCE_I : IN STD_LOGIC;
    VSIGCE_O : OUT STD_LOGIC;
    ACC_STEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    G1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    G2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    R : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    V : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    CE_DSP_RATE : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    C_I : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    P_I : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    N_I : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    OFFSET_PPM : IN STD_LOGIC_VECTOR(21 DOWNTO 0);
    OFFSET_EN : IN STD_LOGIC;
    HOLD : IN STD_LOGIC;
    DON_I : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    DRP_USER_REQ_I : IN STD_LOGIC;
    DRP_USER_DONE_I : IN STD_LOGIC;
    DRPEN_USER_I : IN STD_LOGIC;
    DRPWEN_USER_I : IN STD_LOGIC;
    DRPADDR_USER_I : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    DRPDATA_USER_I : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRPRDY_USER_O : OUT STD_LOGIC;
    DRPBUSY_O : OUT STD_LOGIC;
    ACC_DATA : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    ERROR_O : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
    VOLT_O : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
    DRPDATA_SHORT_O : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    CE_PI_O : OUT STD_LOGIC;
    CE_PI2_O : OUT STD_LOGIC;
    CE_DSP_O : OUT STD_LOGIC;
    OVF_PD : OUT STD_LOGIC;
    OVF_AB : OUT STD_LOGIC;
    OVF_VOLT : OUT STD_LOGIC;
    OVF_INT : OUT STD_LOGIC
  );
END component;



component GTP_picxo_v2 IS
  PORT (
    RESET_I : IN STD_LOGIC;
    REF_CLK_I : IN STD_LOGIC;
    ACC_STEP  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    OFFSET_PPM : IN STD_LOGIC_VECTOR(21 DOWNTO 0);
    OFFSET_EN : IN STD_LOGIC;
    
    ACC_DATA : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    ERROR_O  : OUT STD_LOGIC_VECTOR(20 DOWNTO 0)
  );
END component;



component a7gtp_sdi_control is
generic (
    FXDCLK_FREQ :           integer := 27000000;-- Frequency in Hz of fixed frequency clock connected to clk port
    DRPCLK_PERIOD :         integer := 13;      -- Period of drpclk in ns, always round down
    PLLLOCK_TIMEOUT_PERIOD :integer := 2000000; -- Period of PLLLOCK timeout in ns, defaults to 2ms
    RESET_TIMEOUT_PERIOD :  integer := 500000;  -- Period of GTP RESTDONE timeout in ns, defaults to 500us
    TIMEOUT_CNTR_BITWIDTH : integer := 19;      -- Width in bits of timeout counter
    RETRY_CNTR_BITWIDTH :   integer := 8);      -- Width in bits of the retry counter
port (
-- TX related signals
    txusrclk :              in  std_logic;                              -- TXUSRCLK2 clock signal
    txmode :                in  std_logic_vector(1 downto 0);           -- TX mode select: 00=HD, 01=SD, 10=3G  (synchronous to txusrclk)
    tx_full_reset :         in  std_logic;                              -- Causes full reset sequence of the GTP, including PLL
    gttxreset_in :          in  std_logic;                              -- Causes GTTXRESET sequence
    tx_refclk_stable :      in  std_logic;                              -- Assert High when PLL reference clock is stable
    tx_pll_lock :           in  std_logic;                              -- Connect to PLL{0|1}LOCK output of GTP
    tx_m :                  in  std_logic;                              -- TX bit rate select (0=1000/1000, 1=1000/1001)
    txsysclksel_m_0 :       in  std_logic_vector(1 downto 0);           -- Value to output on TXSYSCLKSEL when tx_m is 0
    txsysclksel_m_1 :       in  std_logic_vector(1 downto 0);           -- Value to output on TXSYSCLKSEL when tx_m is 1
    txresetdone :           in  std_logic;                              -- Connect to the TXRESETDONE port of the GTP
    txratedone :            in  std_logic;                              -- Connect to the TXRATEDONE port of the GTP
    gttxreset_out :         out std_logic;                              -- Connect to GTTXRESET input of GTP
    tx_pll_reset :          out std_logic;                              -- Connect to PLL{0|1}RESET port of the GTP
    txrate :                out std_logic_vector(2 downto 0);           -- Connect to TXRATE input of GTP
    txsysclksel :           out std_logic_vector(1 downto 0);           -- Connect to TXSYSCLKSEL port of GTP when doing dynamic clock source switching
    txslew :                out std_logic := '0';                       -- Slew rate control for SDI cable driver
    tx_change_done :        out std_logic;                              -- 1 when txrate or txsysclksel changes are completed successfully
    tx_change_fail :        out std_logic;                              -- 1 when txrate or txsysclksel changes fail to complete
    tx_change_fail_code :   out std_logic_vector(2 downto 0);           -- TX change failure code

-- RX related signals
    rxusrclk :              in  std_logic;                              -- Connect to same clock as drives the GTP RXUSRCLK2
    fxdclk :                in  std_logic;                              -- Used for RX bit rate detection (usually same clock as drpclk)
    rxmode :                in  std_logic_vector(1 downto 0);           -- RX mode select: 00=HD, 01=SD, 10=3G (synchronous to rxusrclk)
    rx_full_reset :         in  std_logic;                              -- Causes full reset sequence of the GTP including PLL
    gtrxreset_in :          in  std_logic;                              -- Causes GTRXRESET sequence
    rx_refclk_stable :      in  std_logic;                              -- Assert High when PLL reference clock is stable
    rx_pll_lock :           in  std_logic;                              -- Connect to PLL{0|1}LOCK output of GTP
    rxresetdone :           in  std_logic;                              -- Connect to RXRESETDONE port of the GTP
--    rxratedone :            in  std_logic;                              -- Connect to RXRATEDONE port of the GTP
    gtrxreset_out :         out std_logic;                              -- Connect to GTRXRESET input of GTP
    rx_pll_reset :          out std_logic;                              -- Connect to PLL{0|1}RESET port of GTP
    rx_fabric_reset :       out std_logic;                              -- Connect to rx_rst input of SDI core
--    rxrate :                out std_logic_vector(2 downto 0) := "011";  -- Connect to RXRATE port of GTP
    rxcdrhold :             out std_logic;                              -- Connect to RXCDRHOLD port of GTP
    rx_m :                  out std_logic;                              -- Indicates received bit rate: 1 = /1.001 rate, 0 = /1 rate
    rx_change_done :        out std_logic;                              -- 1 when rx_mode change has completed successfully
    rx_change_fail :        out std_logic;                              -- 1 when rx_mode change failed
    rx_change_fail_code :   out std_logic_vector(2 downto 0);           -- RX change failure code

-- SD-SDI DRU signals
--    dru_rst :               in  std_logic;                              -- Sync reset input for DRU
--    data_in :               in  std_logic_vector(19 downto 0);          -- 11X oversampled data input vector
--    sd_data :               out std_logic_vector(9 downto 0) := (others => '0');-- Recovered SD-SDI data
--    sd_data_strobe :        out std_logic;                              -- Asserted high when an output data word is ready
--    recclk_txdata :         out std_logic_vector(19 downto 0);          -- Optional output port for recovering a clock using transmitter


-- DRP signals -- The DRP is used to change the RXCDR_CFG attribute depending
-- on the RX SDI mode. Connect these signal to the DRP of the GTP associated
-- with the SDI RX. Even if the RX section of the GTP is not used, these signals
-- must be properly connected to the GTP.

    drpclk :                in  std_logic;                              -- Connect to GTP DRP clock
    drpbusy :               in  std_logic;                              -- Connect to GTP DRP_BUSY port
    drprdy :                in  std_logic;                              -- Connect to GTP DRPRDY port
    drpaddr :               out std_logic_vector(8 downto 0);           -- Connect to GTP DRPADDR port
    drpdi :                 out std_logic_vector(15 downto 0);          -- Connect to GTP DRPDI port
    drpdo :                 in std_logic_vector(15 downto 0);          -- Connect to GTH DRPDI port  **GHT**
    drpen :                 out std_logic;                              -- Connect to GTP DRPEN port
    drpwe :                 out std_logic);                             -- Connect to GTP DRPWE port
end component;

COMPONENT ila_rxencode
PORT (
	clk : IN STD_LOGIC;
	
	
	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(19 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
end component;

COMPONENT ila_rxencode2
PORT (
	clk : IN STD_LOGIC;
	
	
	probe0 : IN STD_LOGIC_VECTOR(9 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
end component;

component edid_prom_top
PORT (
    spo        : OUT STD_LOGIC_VECTOR(8-1 downto 0);
    a          : IN  STD_LOGIC_VECTOR(8-1 downto 0) := (OTHERS => '0')
);
end component;


component measure_clk is
   generic (REFCLK_FREQ:  integer); -- Reference clock in Hz
   port (
      reset    : in std_logic;
      lock   :     in std_logic;
      refclk   : in  std_logic;          -- reference clock 27 mhz 
      recvclk  : in  std_logic;          -- recovered clock
      freq     : out std_logic_vector(19 downto 0)         -- number of cycles in 1 mSec perion
   );
end component;

component measure_period is
  port (
        reset     : in std_logic;
        clk       : in  std_logic;          -- reference clock 
        ena       : in  std_logic;          -- enable control 
        sync      : in  std_logic;          -- sync period to measure                                            
        period    : out std_logic_vector(15 downto 0) );         -- number of clk cycles per sync                                                                 
end component;


component bt656_xyz_correct is
    Port ( xyz_in  : in STD_LOGIC_VECTOR (2 downto 0);
           protect : in STD_LOGIC_VECTOR (3 downto 0);
           --
           xyz_out : out STD_LOGIC_VECTOR (2 downto 0);
           protect_out : out STD_LOGIC_VECTOR (3 downto 0);
           --
           error   : out STD_LOGIC
         );
end component;


component hamming_encode_4b
    Port ( data_in  : in STD_LOGIC_VECTOR (3 downto 0);
           --
           data_out : out STD_LOGIC_VECTOR (7 downto 0)
         );
end component;

component framing_detect 	
generic (rate : std_logic_vector(2 downto 0) := rate3G );  -- 11 automatic
port ( 
		rstn     : in  std_logic;   -- Global Rstn
		clk      : in  std_logic;   -- clock 
		--
		dinp     : in  std_logic_vector(19 downto 0);  -- data in,  LSB is rx first
		doutp    : out std_logic_vector(19 downto 0);  -- data out,  LSB is rx first
		--
		sync_lock : out std_logic;
		--
		Hsync     : out std_logic;
		Vsync     : out std_logic
);
end component;





component sdi_to_sync is	
port ( 
   rstn     : in  std_logic;   -- Global Rstn
   clk      : in  std_logic;   -- clock
   -- 
   dinp     : in  std_logic_vector(19 downto 0);  -- data in,  LSB is rx first
   doutp    : inout std_logic_vector(19 downto 0);  -- data out,  LSB is rx first
   --
   vde        : out std_logic;
   hsync      : out std_logic;      -- sync out, for test only
   vsync      : out std_logic; 
   fs_out     : out std_logic;
   -- 
   sav        : out std_logic;
   eav        : out std_logic;
   --
   mode_421w_out : out std_logic_vector(2 downto 0)
   );
end component;

component hdmi_frame
port (
   rstn   : in std_logic;
   clk    : in std_logic; 
   
   data     : in std_logic_vector(19 downto 0);
   
   vde      : in std_logic;
   hsync    : in std_logic;
   vsync    : in std_logic;
   field    : in std_logic;
   sav      : in std_logic;
   eav      : in std_logic;
   
   hdmi_d0  : out std_logic_vector(7 downto 0);
   hdmi_d1  : out std_logic_vector(7 downto 0);
   hdmi_d2  : out std_logic_vector(7 downto 0);
   videoen  : out std_logic;
   gben     : out std_logic;
   dataen   : out std_logic
);
end component;

constant DEV_TYPE_TX  : std_logic := '1'; 
constant DEV_TYPE_RX  : std_logic := '0'; 


component DDC_MS is
   generic ( DEV_TYPE: STD_LOGIC := DEV_TYPE_TX );	  	-- 0 : Rx  1: TX, 
	port (
		reset_n 	: in STD_LOGIC;
		clk 		: in STD_LOGIC;   -- 33 Mhz
		ena 		: in STD_LOGIC;   -- 33 Mhz
		
		SDA_IO		: inout	STD_LOGIC;
		
		SDA_rx		: out	STD_LOGIC;	-- readback from monitor
		SDA_tx		: in	STD_LOGIC;	-- signal to transmit to monitor
		
		SCL_IO		: inout	STD_LOGIC;
		
		SCL_rx		: out	STD_LOGIC;	-- 
		SCL_tx		: in	STD_LOGIC	-- signal to transmit to monitor		
);
end component;


component fcnt_24b
	port (
		rstn :  in std_logic;
		clk:     in  std_logic;
		clr:     in  std_logic;
		ena:     in  std_logic;
																						
		count:   out unsigned(15 downto 0);
		cout :   out std_logic
);                                                                 
end component;

component fcnt_16b
  generic ( init : integer );
	port (
		rstn :  in std_logic;
		clk:     in  std_logic;
		clr:     in  std_logic;
		ena:     in  std_logic;
																						
		count:   out unsigned(15 downto 0);
		cout :   out std_logic
);                                                                 
end component;

component fcnt_dn_16b
	port (
		rstn :  in std_logic;
		clk:    in  std_logic;
		
		ena:    in  std_logic;
		ld:     in  std_logic;
		din:    in unsigned(15 downto 0);
																						
		count:   out unsigned(15 downto 0);
		cout :   out std_logic
);                                                                 
end component;

component fcnt_dn_8b
	port (
		rstn :  in std_logic;
		clk:    in  std_logic;
		
		ena:    in  std_logic;
		ld:     in  std_logic;
		din:    in unsigned(7 downto 0);
																						
		count:   out unsigned(7 downto 0);
		cout :   out std_logic
);                                                                 
end component;


component user_ready
	generic (init : integer := 7);
	port (
		rst 		: in std_logic;
		clk			: in  std_logic;																					
		userrdy :   out std_logic
);                                                                 
end component;

component serial_io is
generic ( 
  REFCLK_FREQ      : integer := 27000000  );	
port (
  rstn  : in std_logic;
  clk   : in  std_logic;
  ena   : in  std_logic;
  
  -- slave stream for serial io output    
  s_tvalid  : in std_logic;     -- data available
  s_tready  : out std_logic;    -- data available
  s_tdata   : in std_logic_vector(63 DOWNTO 0);    --
   
  -- master stream for serial io output    
  m_tvalid  : out std_logic;
  m_tready  : in std_logic;
  m_tdata   : out std_logic_vector(63 DOWNTO 0);  --
      
  serial_in_rdy : out std_logic;
  --
  serial_out  : out std_logic;
  serial_in   : in std_logic
);                                                                 
end component;

component i2c_module is
generic( 
	DEVICE_ID  :  std_logic_vector(7 downto 0) := b"0110_1000";
	rcount  : Integer  := 16 );
port(
	rstn      : in  std_logic;    
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
  wr_dout   : out std_logic_vector(7 downto 0);
	--
	o_reg  : out vector8(rcount-1 downto 0);
	i_reg  : in vector8(rcount-1 downto 0)
) ;
end component;
component debounce
  generic (
    WAIT_CYCLES : integer := 5);
  port (
    signal_in  : in  std_logic;
    signal_out : out std_logic;
    clk        : in  std_logic);
end component;

component i2c_module_mdio is
generic( DEVICE_ID  :  std_logic_vector(7 downto 0) := b"0110_0100");
port(
    rstn      : in  std_logic;    
    clk       : in  std_logic;
    --  
    scl     : in std_logic;     
    sda     : in std_logic;  
    sda_oe  : out std_logic;
    scl_oe  : out std_logic;
    --  
    --
    mdc       : out std_logic;
    --
    mdio_in   : in std_logic;
    mdio_out  : out std_logic;
    mdio_oe   : out std_logic
) ;
end component;


component i2c_to_drp is
generic(DEVICE_ID :  std_logic_vector(7 downto 0) := b"0110_0100");
port(
    rstn      : in  std_logic;    
    clk       : in  std_logic;
    --  
    scl     	: in std_logic;     
    sda     	: in std_logic;  
    sda_oe  	: out std_logic;
    scl_oe  	: out std_logic;
    --
		drp_do		: inout std_logic_vector(15 downto 0);
    drp_di		: in std_logic_vector(15 downto 0);
    drp_daddr	: inout std_logic_vector(6 downto 0);
    --
    drp_drdy	: in std_logic  := '0';
    drp_den		: inout std_logic := '0';
    drp_dwe		: inout std_logic := '0';    
    drp_rst		: inout std_logic := '0'    
) ;
end component;


  function to_std( a: boolean )  return std_logic;

  function to_std_vect( b: std_logic; size: integer ) RETURN  std_logic_vector;

  function Reverse (x : std_logic_vector) return std_logic_vector;

-- end of packet 
end cmnPkg;



package body cmnPkg is

	function to_std( a: boolean )  return std_logic is
		begin
			if (a = TRUE) then
				return '1';
			else
				return '0';
			end if;              
		end to_std;

	FUNCTION to_std_vect  ( b : std_logic; size : integer ) RETURN  std_logic_vector IS
		VARIABLE result : std_logic_vector ( size-1 downto 0 );
		BEGIN
			FOR i IN result'RANGE LOOP
				result(i) := b;
			END LOOP;
		RETURN result;
	END; 

function Reverse (x : std_logic_vector) return std_logic_vector is
alias alx  : std_logic_vector (x'length - 1 downto 0) is x;
variable y : std_logic_vector (alx'range);
begin
    for i in alx'range loop
        y(i) := alx (alx'left - i);
    end loop;

    return y;
end;


type rtp_header_rec is record
   Seq_msb  : std_logic_vector(15 downto 0);
   ssrc       : std_logic_vector(31 downto 0);
   timestamp  : std_logic_vector(31 downto 0);
   Seq_lsb  : std_logic_vector(15 downto 0);
   PT       : std_logic_vector(6 downto 0);
   M        : std_logic;
   CC       : std_logic_vector(3 downto 0);
   X        : std_logic;
   P        : std_logic;
   V        : std_logic_vector(1 downto 0);
end record;


type rtp_payload_info_rec is record     -- 48 bit field
   Offset   : std_logic_vector(14 downto 0);
   cont     : std_logic;
   LinNum   : std_logic_vector(14 downto 0);
   F        : std_logic;
   length   : std_logic_vector(15 downto 0);
end record;


type rtp_audio_header_rec is record
   ssrc       : std_logic_vector(31 downto 0);
   timestamp  : std_logic_vector(31 downto 0);
   Seq_lsb  : std_logic_vector(15 downto 0);
   PT       : std_logic_vector(6 downto 0);
   M        : std_logic;
   CC       : std_logic_vector(3 downto 0);
   X        : std_logic;
   P        : std_logic;
   V        : std_logic_vector(1 downto 0);
end record;


end cmnPkg;
 