--  Binrzaehler wrapper r LED und Tasten
--  File: count_led_wrapper.vhd
--  created by F. Winkler: 30/10/2012 
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;       -- empfohlen fuer Neuentwicklungen
--use IEEE.std_logic_arith.all;
--use IEEE.std_logic_unsigned.all;  -- veraltet

entity count_led_wrapper is
    port (
        Clk: in STD_LOGIC;			-- Zaehltakt
		  DIPs: in STD_LOGIC_VECTOR (3 downto 0);	-- Schalter
        LEDs: out STD_LOGIC_VECTOR (7 downto 0) -- LED Ausgang
    );
end count_led_wrapper;

architecture arch_count_led_wrapper of count_led_wrapper is

constant BITS: INTEGER:=32;				-- aktuelle Zhlerbitbreite
signal  I_Data_in:  UNSIGNED (BITS-1 downto 0); -- Eingang
signal  I_Data_out: UNSIGNED (BITS-1 downto 0);-- Ausgang
signal  I_LEDs:     STD_LOGIC_VECTOR (7 downto 0);-- LEDs
signal  I_Up_Down:  STD_LOGIC;		      -- 1: UP, 0: down (Zaehlen)
signal  I_Enable:   STD_LOGIC;		      -- 1: synchrones Zaehlen freigeben
signal  I_Load:     STD_LOGIC;			  -- 1: synchrones Laden freigeben
signal  I_Reset:    STD_LOGIC;		      -- 1: asynchrones Reset
signal  Clk_out:    STD_LOGIC;             -- Clock ref out

component count is
	generic (
		N: INTEGER:=32				-- Anzahl Zaehlerbits
	);
    port (
        Clk: in STD_LOGIC;			-- Zaehltakt
        Up_Down: in STD_LOGIC;		-- 1: UP, 0: down (Zaehlen)
        Enable: in STD_LOGIC;		-- 1: synchrones Zaehlen freigeben
        Load: in STD_LOGIC;			-- 1: synchrones Laden freigeben
        Reset: in STD_LOGIC;		-- 1: asynchrones Reset
        Data_in: in UNSIGNED (N-1 downto 0); -- Eingang
        Data_out: out UNSIGNED (N-1 downto 0);-- Ausgang
		  Clk_out: out STD_LOGIC      -- Clock ref out
    );
end component count;

begin


-- counter Instanz
------------------
counter: count 
	generic map (BITS)
	port map
	(
--	chip	=> wrapper
--	count.vhd  count_led_wrapper.vhd	
	Clk 	=> Clk,		-- Zaehltakt
	Up_Down => I_Up_Down,	-- 1: UP, 0: down (Zaehlen)
	Enable	=> I_Enable,	-- 1: synchrones Zaehlen freigeben
	Load	=> I_Load,		-- 1: synchrones Laden freigeben
	Reset	=> I_Reset,		-- 1: asynchrones Reset
	Data_in	=> I_Data_in,	-- Eingang
	Data_out=> I_Data_out,	-- Ausgang
	Clk_out => open			-- Taktausgang (nicht genutzt) 
	);
	
-- Test Data in (simple constant 0 or 2**24)
-- I_Data_in <= (OTHERS=>'0'); 
-- for std_logic_arith:
-- I_Data_in <= CONV_UNSIGNED(16777216,BITS);
-- for numerric_std:
I_Data_in <= TO_UNSIGNED(16777216,BITS); --(==2**24)



-- Test outputs (only 8 bits)
-----------------------------
-- for std_logic_arith:
-- LEDs <=  CONV_STD_LOGIC_VECTOR(I_Data_out(BITS-1 downto (BITS-1)-8),8);
-- for numeric_std:
LEDs <=  STD_LOGIC_VECTOR(I_Data_out(BITS-1 downto BITS-8));

-- Test Inputs
---------------
I_Reset   <= DIPs(0);
I_Load    <= DIPs(1);
I_Enable  <= DIPs(2);
I_Up_Down <= DIPs(3);



end arch_count_led_wrapper;
