LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;

ENTITY resistor_E IS

  GENERIC (
    resistoron : real := 1.0e-2;
    resistoroff : real := 10.0e+6);
        -- change entity to switchable resistor

  PORT (
    signal switchon : IN BIT;
    TERMINAL a,b : ELECTRICAL);

END resistor_E;

ARCHITECTURE simple OF resistor_E IS

  QUANTITY u_r ACROSS i_r THROUGH a TO b;

BEGIN  -- simple

IF switchon = '1' use
        i_r == u_r/resistoron;
else
        i_r == u_r/resistoroff;
end use;

break ON switchon;
END simple;
