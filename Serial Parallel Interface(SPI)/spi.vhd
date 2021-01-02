-------------------------------------------------------------------------------
-- Title      : DHS ADC
-- Project    : Motor-Controller(Serial parallel interface)
-------------------------------------------------------------------------------
-- File       : spi.vhd
-- Author     : Rajarajeswari Angia Krishnan
-- Company    : TU-Chemmnitz
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI is
  generic(message_length : integer   := 17;
          pwm_bit        : integer   := 14;
          address_length : integer   := 2);

  port (                                -- general signals
    reset_n    : in  std_logic;
    clk        : in  std_logic;
    -- SPI interface
    sclk       : in  std_logic;
    cs_n       : in  std_logic;
    din        : in  std_logic;
    -- internal interface
    new_data   : out std_logic;         -- new data available
    regnr      : out std_logic_vector (address_length-1 downto 0);  -- register address
    regcontent : out std_logic_vector (pwm_bit-1 downto 0);  -- register write value
    regwrite_n : out std_logic          -- write access?
    );
end entity SPI;

architecture RTL of SPI is
  --ADD TYPE FOR STATE MACHINE

type state is (S1,S2,S3,S4); -- chip select low, counter, new data, chip select high

  --ADD SIGNALS

signal current_state : state;
signal next_state    : state;
signal count         : integer range 0 to 17;
signal set_count     : std_logic;
signal regnr_S       : std_logic_vector (address_length-1 downto 0);  -- register address
signal regcontent_S  : std_logic_vector (pwm_bit-1 downto 0);  -- register write value
signal parallel_out  : std_logic_vector(message_length-1 downto 0);
signal regwrite_n_S  : std_logic;         -- write access?


begin

--ADD PROCESSES FOR THE STATE MACHINE WHIC CONTROLS THE SPI, COUNTER FOR SPI
--AND OUTPUT REGISTERS

-- counter synchronous to SPI clock?

-- process for counter

counter : process(sclk,clk,reset_n)

begin
        if reset_n ='0' then
        count <= 0;
        current_state <= S1;

        elsif (clk'event and clk = '1')  then
        current_state <= next_state;

                if set_count='1' then
                count <= 0;
                end if;

        elsif (sclk'event and sclk = '0') then

                if (count < 17) then
                count <= count + 1;

                else

                count <= 0;
                end if;

        end if;

end process counter;

-- process for state transition

state_transition : process(current_state,count,cs_n)

begin

        set_count <= '0';
        next_state <= current_state;

case current_state is

        when S1 => if cs_n = '0' then next_state <= S2;
                   set_count <='1';
                   end if;

        when S2 => if count = 17 then next_state <= S3;
                   end if;

        when S3 => next_state <= S4;

        when S4 => if cs_n = '1' then next_state <= S1;
                   end if;

        when others => next_state <= S1;

end case;
end process state_transition;

-- process for serial in parallel out (sipo)

sipo : process(clk,sclk,current_state,din,reset_n)

begin

        if reset_n ='0' then
                parallel_out <= (others => '0');
                regnr_S <= (others => '0');
                regwrite_n_S <= '1';
                regcontent_S <= (others => '0');
                new_data <= '0';


        elsif reset_n ='1' then

                if current_state = S1 then
                        parallel_out <= (others =>'0');

                elsif current_state = S2 then
                        if sclk'event and sclk = '0' then
                        parallel_out <= parallel_out (15 downto 0) & din;
                        end if;

                elsif current_state = S3 then
                        new_data <= '1';
                        regnr_S <= parallel_out (16 downto 15);
                        regwrite_n_S <= parallel_out (14);
                        regcontent_S <= parallel_out(13 downto 0);

                elsif current_state = S4 then
                        new_data <= '0';

                end if;
        end if;

end process sipo;


regnr <= regnr_S;
regwrite_n <= regwrite_n_S;
regcontent <= regcontent_S;


end architecture RTL;
