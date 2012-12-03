-- TestBench Template 
-- 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY count_led_wrapper_tb IS
  END count_led_wrapper_tb;

  ARCHITECTURE behavior OF count_led_wrapper_tb IS 

  -- Component Declaration
    COMPONENT count_led_wrapper is
    port (
        Clk: in STD_LOGIC;			-- Zaehltakt
		  DIPs: in STD_LOGIC_VECTOR (3 downto 0);	-- Schalter
        LEDs: out STD_LOGIC_VECTOR (7 downto 0) -- LED Ausgang
    ); 
	 END COMPONENT count_led_wrapper;

          SIGNAL Clk :  std_logic;
          SIGNAL DIPs :  std_logic_vector(3 downto 0);
          SIGNAL LEDs :  std_logic_vector(7 downto 0);         

-- constant definition
----------------------
constant CLK_PERIOD: TIME := 20 ns;	-- clock period (50 MHz)
constant COUNT_BITS: INTEGER := 4;	-- 4 bit counter

-- signal deklaration
---------------------
signal	Up_Down:  STD_LOGIC;		-- 1: UP, 0: down (Zaehlen)
signal	Enable:	 STD_LOGIC;		-- 1: synchrones Zaehlen freigeben
signal	Load:	    STD_LOGIC;		-- 1: synchrones Laden freigeben
signal	Reset:	 STD_LOGIC;		-- 1: asynchrones Reset

begin

-- Component Instantiation
 UUT: count_led_wrapper
		  PORT MAP(
              Clk => Clk,
              DIPs => DIPs,
				  LEDs => LEDs
          );


--  Test Bench Statements
	
DIPs(3) <= Up_Down;
DIPs(2) <= Enable;
DIPs(1) <= Load;
DIPs(0) <= Reset;

-- clock generator
-----------------

clockgen: Process
begin
	if Clk = '0' then
		Clk <= '1';
	else
		Clk <= '0';
	end if;
	wait for CLK_PERIOD/2;
end process;

-- Pattern Generator

pattern: Process
begin
	Reset <= '1';			-- Reset
	Up_Down <= '1';
	Enable <= '1';
	Load <= '0';
	wait for 3 * CLK_PERIOD;

	Reset <= '0';			-- Count up
	
	wait until (LEDs(2 downto 0) = "111");
	
	Enable <= '0';	
	Load <= '1';			-- Load 6
	wait for CLK_PERIOD;

	Up_Down <= '0';			-- Count down
	wait for CLK_PERIOD;

	Enable <= '1';
		
	wait;				-- wait forever
end process;

 
end behavior; 
