library ieee;
use ieee.std_logic_1164.all;

entity PWM_driver_E is
  generic(
    pwm_bit : integer := 14
    );
  port(
    reset_n                         : in  std_logic;
    clk                             : in  std_logic;
    pwm_base_period                 : in  integer range 0 to 2**(pwm_bit)-1;
    pwm_duty_cycle                  : in  integer range 0 to 2**(pwm_bit)-1;
    pwm_control                     : in  std_logic_vector(7 downto 0);
    pwm_cycle_done                  : out std_logic;  -- new values at inputs are now used
    pwm_out1, pwm_out2, pwm_n_sleep : out std_logic);
end PWM_driver_E;

architecture rtl of PWM_driver_E is
--ADD SIGNALS

signal baseperiod_count : integer range 0 to 2**(pwm_bit)-1 := 1;
signal dutycycle_count  : integer range 0 to 2**(pwm_bit)-1 := 0;
signal flag : std_logic := '0';

begin

--ADD THE FUNCTIONALITY FOR THE PWM DRIVER

-- process for the counter

counter : process(clk,reset_n)

begin

if reset_n  = '0' then
        baseperiod_count <= 1;
        dutycycle_count <= 0;

elsif rising_edge(clk) then
        if baseperiod_count < pwm_base_period then
                baseperiod_count <= baseperiod_count + 1;
                dutycycle_count  <= dutycycle_count + 1;

        else
        --elsif dutycycle_count < pwm_duty_cycle  then
                baseperiod_count <= 1;
                dutycycle_count <= 0;

        end if;


        --else

                --flag <= '1';
        --end if;

end if;

end process counter;

-- process for pwm driver

pwm_driver : process(clk,reset_n,baseperiod_count,dutycycle_count)

begin

if reset_n = '0' then --reset check
        pwm_out1 <= 'Z';
        pwm_out2 <= 'Z';
        pwm_n_sleep <= '0';


--if flag = '1' then
elsif pwm_control(0) = '0' then -- enable -> 0

        pwm_out1 <= 'Z';
        pwm_out2 <= 'Z';
        pwm_n_sleep <= '0';






-- check for brake condition

elsif pwm_control(2) = '1' then
        pwm_out1 <= '1';
        pwm_out2 <= '1';

-- check for pwm behaviour

elsif pwm_control(1) = '0' then --normal behaviour

if  baseperiod_count < pwm_base_period then
        if dutycycle_count  < pwm_duty_cycle then
                pwm_out1 <= '1';
                pwm_out2 <= '1';
        else
                pwm_out1 <= '0';
                pwm_out2 <= '0';
        end if;
end if;


elsif pwm_control(1) = '1' then -- inverted behaviour

if  baseperiod_count < pwm_base_period then
        if dutycycle_count  < pwm_duty_cycle then
                pwm_out1 <= '1';
                pwm_out2 <= '0';
        else
                pwm_out1 <= '0';
                pwm_out2 <= '1';

        end if;
else

        --pwm_out1 <= '0';
        --pwm_out2 <= '0';
        pwm_n_sleep <= '1'; -- enable -> 1
end if;
end if;

end process pwm_driver;

pwm_cycle_done <= '1' when baseperiod_count = pwm_base_period and reset_n = '1' else '0';

end rtl;
