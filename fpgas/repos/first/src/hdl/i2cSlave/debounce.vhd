------------------------------------------------------------
-- File      : debounce.vhd
------------------------------------------------------------
-- Author     : Peter Samarin <peter.samarin@gmail.com>
------------------------------------------------------------
-- Copyright (c) 2016 Peter Samarin
------------------------------------------------------------
-- Description: debouncing circuit that forwards only
-- signals that have been stable for the whole duration of
-- the counter
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------

-- No reset signal is used in this component. JL
entity debounce is
  generic (
    WAIT_CYCLES : integer := 5);
  port (
    signal_in  : in  std_logic;
    signal_out : out std_logic;
    clk        : in  std_logic);
end entity debounce;

------------------------------------------------------------

architecture arch of debounce is
  type state_t is (S_IDLE, S_CHECK_STABLE);
  
  signal state_reg     : state_t                          := S_IDLE;
  
  -- out_reg represents stable input signal after debounced;
  -- initial value for this signal, not connect the input signal to this out_reg fixedly
  signal out_reg       : std_logic                        := signal_in;
  
  -- signal_in_reg: represents last signal, eg before the state changes
  signal signal_in_reg : std_logic;
  signal counter       : integer range 0 to WAIT_CYCLES-1 := 0;
begin

  process (clk) is
  begin
    if rising_edge(clk) then
      case state_reg is
        when S_IDLE =>
          if out_reg /= signal_in then
            signal_in_reg <= signal_in;
            state_reg     <= S_CHECK_STABLE;
            counter       <= WAIT_CYCLES-1;
          end if;

        when S_CHECK_STABLE =>
          if counter = 0 then
            if signal_in = signal_in_reg then
              out_reg <= signal_in;
            end if;
            state_reg <= S_IDLE;
          else
            if signal_in /= signal_in_reg then
              state_reg <= S_IDLE;
            end if;
            counter <= counter - 1;
          end if;
      end case;
    end if;
  end process;

  -- output
  signal_out <= out_reg;

end architecture arch;
