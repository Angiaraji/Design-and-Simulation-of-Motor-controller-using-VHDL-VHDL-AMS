LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;

ENTITY motorcontroller IS
    generic(message_length : integer   := 24;
            pwm_bit        : integer   := 21;
            address_length : integer   := 2);
    port (
      -- general signals
      reset_n                         : in  std_logic;
      clk                             : in  std_logic;
      -- SPI interface
      sclk                            : in  std_logic;
      cs_n                            : in  std_logic;
      din                             : in  std_logic;
      -- Analog connections
      TERMINAL Out1, Out2, GROUND, VM, VCC : ELECTRICAL);
END motorcontroller;

ARCHITECTURE struct OF motorcontroller IS

-- student work

component PWM_digital_top_E is
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

end component PWM_digital_top_E;

component motor_driver_E is
   generic(resistoron : real := 1.0e-2;
            resistoroff : real := 10.0e+6;
            idealityfactor:real:=1.1;
        thermalvoltage:real:=25.0e-3;
        saturationcurrent:real:=1.0e-9);

  PORT (
    TERMINAL Out1, Out2, GROUND, VM, VCC : ELECTRICAL;
    SIGNAL IN1, IN2, nSLEEP : std_logic);
end component motor_driver_E;

signal pwm_out1,pwm_out2,pwm_n_sleep:std_logic;


BEGIN


pwm_gen:PWM_digital_top_E
Port map (reset_n,clk,sclk,cs_n,din,pwm_out1, pwm_out2, pwm_n_sleep);

DAC:motor_driver_E
Port map (IN1=>pwm_out1,IN2=>pwm_out2,nSLEEP=>pwm_n_sleep,Out1=>Out1,Out2=>Out2,GROUND=>GROUND,VM=>VM,VCC=>VCC);

END struct;
