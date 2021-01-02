library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_digital_top_E is
  generic(message_length : integer   := 17;
          pwm_bit        : integer   := 14;
          address_length : integer   := 2);
  port (                                -- general signals
    reset_n                         : in  std_logic;
    clk                             : in  std_logic;
    -- SPI interface
    sclk                            : in  std_logic;
    cs_n                            : in  std_logic;
    din                             : in  std_logic;
    -- PWM output
    pwm_out1, pwm_out2, pwm_n_sleep : out std_logic);
end entity PWM_digital_top_E;

architecture struct of PWM_digital_top_E is

--ADD DECLARATION FOR THE NECESSARY COMPONENTS

component SPI

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
end component SPI;

component PWM_controller_E

port(                                 -- general inputs
    reset_n         : in  std_logic;
    clk             : in  std_logic;
    -- from SPI controller
    new_data        : in  std_logic;    -- new data available
    regnr           : in  std_logic_vector (address_length-1 downto 0);  -- register address
    regcontent      : in  std_logic_vector (pwm_bit-1 downto 0);  -- register write value
    regwrite_n      : in  std_logic;    -- write access?
    -- from/to pwm_driver
    pwm_cycle_done  : in  std_logic;    -- new values at inputs are now used
    pwm_control     : out std_logic_vector(7 downto 0);
    pwm_base_period : out integer range 0 to 2**(pwm_bit)-1;
    pwm_duty_cycle  : out integer range 0 to 2**(pwm_bit)-1
    );
end component PWM_controller_E;

component PWM_driver_E

port(
    reset_n                         : in  std_logic;
    clk                             : in  std_logic;
    pwm_base_period                 : in  integer range 0 to 2**(pwm_bit)-1;
    pwm_duty_cycle                  : in  integer range 0 to 2**(pwm_bit)-1;
    pwm_control                     : in  std_logic_vector(7 downto 0);
    pwm_cycle_done                  : out std_logic;  -- new values at inputs are now used
    pwm_out1, pwm_out2, pwm_n_sleep : out std_logic);

end component PWM_driver_E;


--ADD NECESSARY SIGNALS

--begin

signal new_data,regwrite_n,pwm_cycle_done : std_logic;
signal regcontent : std_logic_vector(13 downto 0);
signal regnr : std_logic_vector(1 downto 0);
signal pwm_control : std_logic_vector(7 downto 0);
signal pwm_base_period, pwm_duty_cycle : integer range 0 to 2**(pwm_bit)-1;


--ADD INSTANCES OF THE DIFFERENT COMPONENTS
begin

module1 : SPI

port map(reset_n,clk,sclk,cs_n,din,new_data,regnr,regcontent,regwrite_n);

module2 : PWM_controller_E

port map(reset_n,clk,new_data,regnr,regcontent,regwrite_n,pwm_cycle_done,pwm_control,pwm_base_period,pwm_duty_cycle);

module3 : PWM_driver_E

port map(reset_n,clk,pwm_base_period,pwm_duty_cycle,pwm_control,pwm_cycle_done,pwm_out1,pwm_out2,pwm_n_sleep);


end struct;
