-- Model for TI DRV8837 motor driver (Calliope)

LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;

ENTITY motor_driver_E IS
 generic(resistoron : real := 1.0e-2;
            resistoroff : real := 10.0e+6;
            idealityfactor:real:=1.1;
        thermalvoltage:real:=25.0e-3;
        saturationcurrent:real:=1.0e-9);

  PORT (
    TERMINAL Out1, Out2, GROUND, VM, VCC : ELECTRICAL;
    SIGNAL IN1, IN2, nSLEEP : std_logic);

END motor_driver_E;

-- ARCHITECTURE to be filled by the students

architecture behaviour of motor_driver_E is

signal S1,S2,S3,S4:bit;

component resistor_E

GENERIC (
    resistoron : real := 1.0e-2;
    resistoroff : real := 10.0e+6);
        -- change entity to switchable resistor

  PORT (
    signal switchon : IN BIT;
    TERMINAL a,b : ELECTRICAL);

end component resistor_E;

component diode_E

generic( idealityfactor:real:=1.1;
           thermalvoltage:real:=25.0e-3;
           saturationcurrent:real:=1.0e-9);
  PORT (
    TERMINAL anode, cathode : ELECTRICAL);

end component diode_E;

begin

driverlogic : process(IN1,IN2,nSLEEP)

begin

if nsleep = '1' then
  if IN1 = '0' and IN2 = '0' then
        S1 <= '0';
        S2 <= '0';
        S3 <= '0';
        S4 <= '0';

  elsif IN1 = '0' and IN2 = '1' then
        S1 <= '0';
        S2 <= '1';
        S3 <= '1';
        S4 <= '0';

  elsif IN1 = '1' and IN2 = '0' then
        S1 <= '1';
        S2 <= '0';
        S3 <= '0';
        S4 <= '1';

  elsif IN1 = '1' and IN2 = '1' then
        S1 <= '0';
        S2 <= '1';
        S3 <= '0';
        S4 <= '1';

  end if;

  elsif nsleep = '0' then
        S1 <= '0';
        S2 <= '0';
        S3 <= '0';
        S4 <= '0';



end if;

end process driverlogic;


resistor1: entity work.resistor_E(simple)
generic map(resistoron => resistoron, resistoroff => resistoroff)
port map(a=> VM ,b=> Out1, switchon => S1);

resistor2: entity work.resistor_E(simple)
generic map(resistoron => resistoron, resistoroff => resistoroff)
port map(a=> Out1 ,b=> ground, switchon => S2);

resistor3: entity work.resistor_E(simple)
generic map(resistoron => resistoron, resistoroff => resistoroff)
port map(a=> VM ,b=> Out2, switchon => S3);

resistor4: entity work.resistor_E(simple)
generic map(resistoron => resistoron, resistoroff => resistoroff)
port map(a=> Out2 ,b=> ground, switchon => S4);

diode1: entity work.diode_E(ideal)
generic map(idealityfactor => idealityfactor, thermalvoltage => thermalvoltage, saturationcurrent => saturationcurrent)
port map(anode => Out1, cathode => VM);

diode2: entity work.diode_E(ideal)
generic map(idealityfactor => idealityfactor, thermalvoltage => thermalvoltage, saturationcurrent => saturationcurrent)
port map(anode => VM, cathode => ground);

diode3: entity work.diode_E(ideal)
generic map(idealityfactor => idealityfactor, thermalvoltage => thermalvoltage, saturationcurrent => saturationcurrent)
port map(anode => Out2, cathode => VM);

diode4: entity work.diode_E(ideal)
generic map(idealityfactor => idealityfactor, thermalvoltage => thermalvoltage, saturationcurrent => saturationcurrent)
port map(anode => ground, cathode => Out2);

end architecture behaviour;
