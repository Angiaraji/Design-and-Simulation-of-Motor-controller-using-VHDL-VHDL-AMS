LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
use ieee.math_real.all;

ENTITY diode_E IS
  generic( idealityfactor:real:=1.1;
           thermalvoltage:real:=25.0e-3;
           saturationcurrent:real:=1.0e-9);
  PORT (
    TERMINAL anode, cathode : ELECTRICAL);

END diode_E;


architecture ideal of diode_E is

quantity u_d across i_d through anode to cathode;

begin

i_d == saturationcurrent*(exp(((u_d)/(idealityfactor*thermalvoltage))-1.0));

end ideal;
