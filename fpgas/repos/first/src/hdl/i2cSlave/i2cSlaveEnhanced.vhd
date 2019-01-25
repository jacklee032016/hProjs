------------------------------------------------------------
-- File      : I2C_slave.vhd
------------------------------------------------------------
-- Author    : Peter Samarin <peter.samarin@gmail.com>
------------------------------------------------------------
-- Copyright (c) 2016 Peter Samarin
------------------------------------------------------------

-- 05.06, 2018, work with update module; J.L.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------

entity I2cSlaveEnhanced is
  generic (
    SLAVE_ADDR : std_logic_vector(7 downto 0));		-- change as 8-bit slave address
  port (
	---- change as following signals
    --scl              : inout std_logic;
    --sda              : inout std_logic;
	
	-- one direction signals
	scl				: in std_logic;
    sda				: in std_logic;
    scl_oe			: out std_logic;
    sda_oe			: out std_logic;

    clk				: in std_logic;
    rst				: in std_logic;
	
    ---- User interface
	-- export START/STOP condition of I2C 
	sof				: out std_logic;
    eof				: out std_logic;

	-- master read data from slave
    read_req         : out   std_logic;
    data_to_master   : in    std_logic_vector(7 downto 0);	-- data from external module, and send to master
	
	-- master write data to slave
    data_valid       : out   std_logic;
    data_from_master : out   std_logic_vector(7 downto 0));	-- data to external modeule, get from master
end entity I2cSlaveEnhanced;

------------------------------------------------------------
architecture arch of I2cSlaveEnhanced is
	-- declaration part of architecture: declare all signals (registers), eg. static structure of curcuit, 
	-- how many D-FF, latch, and value stored in them. J.L.
	
  -- this assumes that system's clock is much faster than SCL
  constant DEBOUNCING_WAIT_CYCLES : integer   := 4;
  
  type state_t is (S_IDLE, S_GET_ADDR_CMD,
                   S_ANSWER_ACK_START, S_WRITE,
                   S_READ, S_READ_ACK_START,
                   S_READ_ACK_GOT_RISING, S_READ_STOP);
  -- I2C state management
  signal state_reg          : state_t              := S_IDLE;
  signal cmd_reg            : std_logic            := '0';
  signal bits_processed_reg : integer range 0 to 8 := 0;
  signal continue_reg       : std_logic            := '0';

  signal scl_reg			: std_logic := '1';
  signal sda_reg			: std_logic := '1';
  signal scl_debounced		: std_logic := '1';
  signal sda_debounced		: std_logic := '1';
  

  -- Helpers to figure out next state
  signal start_reg			: std_logic := '0';
  signal stop_reg			: std_logic := '0';
  signal scl_rising_reg		: std_logic := '0';
  signal scl_falling_reg	: std_logic := '0';

  -- Address and data received from master
  signal addr_reg             : std_logic_vector(6 downto 0) := (others => '0');
  signal data_reg             : std_logic_vector(6 downto 0) := (others => '0');
  signal data_from_master_reg : std_logic_vector(7 downto 0) := (others => '0');

  signal scl_prev_reg : std_logic := '1';
  -- Slave writes on scl
  signal scl_wen_reg  : std_logic := '0';	-- always 0, so scl_o_reg always never output
  signal scl_o_reg    : std_logic := '0';	
  signal sda_prev_reg : std_logic := '1';
  -- Slave writes on sda
  signal sda_wen_reg  : std_logic := '0';
  signal sda_o_reg    : std_logic := '0';

  -- User interface
  signal data_valid_reg     : std_logic                    := '0';
  signal read_req_reg       : std_logic                    := '0';
  signal data_to_master_reg : std_logic_vector(7 downto 0) := (others => '0');

  
  begin

	-- debounce SCL and SDA
	SCL_debounce : entity work.debounce
		generic map (
			WAIT_CYCLES => DEBOUNCING_WAIT_CYCLES)
		port map (
			clk        => clk,
			signal_in  => scl_reg,
			signal_out => scl_debounced);

	-- it might not make sense to debounce SDA, since master
	-- and slave can both write to it...
	SDA_debounce : entity work.debounce
		generic map (
			WAIT_CYCLES => DEBOUNCING_WAIT_CYCLES)
		port map (
			clk        => clk,
			signal_in  => sda_reg,
			signal_out => sda_debounced);

			
	-- process detecting START/STOP condition: start_reg and stop_reg
	process (clk) is
	begin
		if rising_edge(clk) then
			-- save SCL in registers that are used for debouncing
			scl_reg <= scl;
			sda_reg <= sda;

			-- Delay debounced SCL and SDA by 1 clock cycle
			scl_prev_reg   <= scl_debounced;
			sda_prev_reg   <= sda_debounced;
	  
			-- Detect rising and falling SCL
			scl_rising_reg <= '0';
			if scl_prev_reg = '0' and scl_debounced = '1' then
				scl_rising_reg <= '1';
			end if;
			scl_falling_reg <= '0';
			if scl_prev_reg = '1' and scl_debounced = '0' then
				scl_falling_reg <= '1';
			end if;

			-- Detect I2C START condition
			start_reg <= '0';
			stop_reg  <= '0';
			if scl_debounced = '1' and scl_prev_reg = '1' and
				sda_prev_reg = '1' and sda_debounced = '0' then
				start_reg <= '1';
				stop_reg  <= '0';
			end if;

			-- Detect I2C STOP condition
			if scl_prev_reg = '1' and scl_debounced = '1' and
				sda_prev_reg = '0' and sda_debounced = '1' then
				start_reg <= '0';
				stop_reg  <= '1';
			end if;

		end if;
	end process;

	----------------------------------------------------------
	-- I2C state machine
	----------------------------------------------------------
	process (clk) is
	begin
		if rising_edge(clk) then
			-- Default assignments
			sda_o_reg      <= '0';
			sda_wen_reg    <= '0';
			-- User interface
			data_valid_reg <= '0';
			read_req_reg   <= '0';

			case state_reg is

				when S_IDLE =>
					if start_reg = '1' then
						state_reg  <= S_GET_ADDR_CMD;
						bits_processed_reg <= 0;
					end if;

				
				when S_GET_ADDR_CMD =>
					if scl_rising_reg = '1' then
						if bits_processed_reg < 7 then
							bits_processed_reg             <= bits_processed_reg + 1;
							addr_reg(6-bits_processed_reg) <= sda_debounced;
						elsif bits_processed_reg = 7 then
							bits_processed_reg <= bits_processed_reg + 1;
							cmd_reg            <= sda_debounced;
						end if;
					end if;

					if bits_processed_reg = 8 and scl_falling_reg = '1' then
						bits_processed_reg <= 0;
						if addr_reg = SLAVE_ADDR(7 downto 1) then  -- check req address
							state_reg <= S_ANSWER_ACK_START;
							if cmd_reg = '1' then  -- issue read request 
								read_req_reg       <= '1';
								data_to_master_reg <= data_to_master;
							end if;
						else
							assert false
							report ("I2C: target/slave address mismatch (data is being sent to another slave).")
							severity note;
							state_reg <= S_IDLE;
						end if;
					end if;

					
				----------------------------------------------------
				-- I2C acknowledge to master
				----------------------------------------------------
				when S_ANSWER_ACK_START =>
					sda_wen_reg <= '1';
					sda_o_reg   <= '0';
					if scl_falling_reg = '1' then
						if cmd_reg = '0' then
							state_reg <= S_WRITE;
						else
							state_reg <= S_READ;
						end if;
					end if;

				----------------------------------------------------
				-- WRITE
				----------------------------------------------------
				when S_WRITE =>
					if scl_rising_reg = '1' then
						bits_processed_reg <= bits_processed_reg + 1;
						if bits_processed_reg < 7 then
							data_reg(6-bits_processed_reg) <= sda_debounced;
						else
							data_from_master_reg <= data_reg & sda_debounced;
							data_valid_reg       <= '1';
						end if;
					end if;

					if scl_falling_reg = '1' and bits_processed_reg = 8 then
						state_reg          <= S_ANSWER_ACK_START;
						bits_processed_reg <= 0;
					end if;

				----------------------------------------------------
				-- READ: send data to master
				----------------------------------------------------
				when S_READ =>
					sda_wen_reg <= '1';
					sda_o_reg   <= data_to_master_reg(7-bits_processed_reg);
					if scl_falling_reg = '1' then
						if bits_processed_reg < 7 then
							bits_processed_reg <= bits_processed_reg + 1;
						elsif bits_processed_reg = 7 then
							state_reg          <= S_READ_ACK_START;
							bits_processed_reg <= 0;
						end if;
					end if;

					
				----------------------------------------------------
				-- I2C read master acknowledge
				----------------------------------------------------
				when S_READ_ACK_START =>
					if scl_rising_reg = '1' then
						state_reg <= S_READ_ACK_GOT_RISING;
						if sda_debounced = '1' then  -- nack = stop read
							continue_reg <= '0';
						else  -- ack = continue read
							continue_reg       <= '1';
							read_req_reg       <= '1';  -- request reg byte
							data_to_master_reg <= data_to_master;
						end if;
					end if;

				when S_READ_ACK_GOT_RISING =>
					if scl_falling_reg = '1' then
						if continue_reg = '1' then
							if cmd_reg = '0' then
								state_reg <= S_WRITE;
							else
								state_reg <= S_READ;
							end if;
						else
							state_reg <= S_READ_STOP;
						end if;
					end if;

				-- Wait for START or STOP to get out of this state
				when S_READ_STOP =>
					null;

				-- Wait for START or STOP to get out of this state
				when others =>
					assert false
					report ("I2C: error: ended in an impossible state.")
					severity error;
					state_reg <= S_IDLE;
			end case;

			--------------------------------------------------------
			-- Reset counter and state on start/stop
			--------------------------------------------------------
			if start_reg = '1' then
				state_reg          <= S_GET_ADDR_CMD;
				bits_processed_reg <= 0;
			end if;

			if stop_reg = '1' then
				state_reg          <= S_IDLE;
				bits_processed_reg <= 0;
			end if;

			if rst = '1' then
				state_reg <= S_IDLE;
			end if;
		end if;
	end process;

	----------------------------------------------------------
	-- I2C interface
	----------------------------------------------------------
	-- sda <= sda_o_reg when sda_wen_reg = '1' else 'Z';
	-- scl <= scl_o_reg when scl_wen_reg = '1' else 'Z';
	
	sda_oe <= not(sda_o_reg) when sda_wen_reg = '1' else '0';
	scl_oe <= not(scl_o_reg) when scl_wen_reg = '1' else '0';
	
	sof    <= start_reg;
	eof    <= stop_reg;
 

 
	----------------------------------------------------------
	-- User interface
	----------------------------------------------------------
	-- Master writes
	data_valid       <= data_valid_reg;
	data_from_master <= data_from_master_reg;
	
	-- Master reads
	read_req         <= read_req_reg;
	
end architecture arch;