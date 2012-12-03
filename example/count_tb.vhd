--  Binrzaehler Testbench
--  File: count_tb.vhd
--  created by F. Winkler: 30/10/2012 
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;       -- empfohlen fr Neuentwicklungen
--use IEEE.std_logic_arith.all;     -- veraltet, 
--use IEEE.std_logic_unsigned.all;  -- veraltet

entity count_tb is
end count_tb;

architecture arch_count_tb of count_tb is

-- component deklaration
------------------------
component count is
	generic (
		N: INTEGER:=8				-- Anzahl Zaehlerbits
	);
    port (
        Clk:     in STD_LOGIC;		-- Zaehltakt
        Up_Down: in STD_LOGIC;		-- 1: UP, 0: down (Zaehlen)
        Enable:  in STD_LOGIC;		-- 1: synchrones Zaehlen freigeben
        Load:    in STD_LOGIC;		-- 1: synchrones Laden freigeben
        Reset:   in STD_LOGIC;		-- 1: asynchrones Reset
        Data_in: in  UNSIGNED (N-1 downto 0); -- Eingang
        Data_out:out UNSIGNED (N-1 downto 0);-- Ausgang
		  Clk_out: out STD_LOGIC      -- Clock ref out
    );
end component count;

-- constant definition
----------------------
constant CLK_PERIOD: TIME := 20 ns;	-- clock period (50 MHz)
constant COUNT_BITS: INTEGER := 4;	-- 4 bit counter

-- signal deklaration
---------------------
signal	Clk:	    STD_LOGIC;		-- Zaehltakt
signal	Up_Down:  STD_LOGIC;		-- 1: UP, 0: down (Zaehlen)
signal	Enable:	 STD_LOGIC;		-- 1: synchrones Zaehlen freigeben
signal	Load:	    STD_LOGIC;		-- 1: synchrones Laden freigeben
signal	Reset:	 STD_LOGIC;		-- 1: asynchrones Reset
signal	Data_in:  UNSIGNED (COUNT_BITS-1 downto 0); -- Eingang
signal	Data_out: UNSIGNED (COUNT_BITS-1 downto 0);-- Ausgang
signal	Data_msb: STD_LOGIC;		-- MSB bit


-- architecture begin
---------------------

begin

-- clock generator
------------------
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
	Data_in <= (Others => '0');
	wait for 3 * CLK_PERIOD;

	Reset <= '0';			-- Count up
	wait for 5 * CLK_PERIOD;

	Data_in <= TO_UNSIGNED(6, COUNT_BITS);
	Enable <= '0';	
	Load <= '1';			-- Load 6
	wait for CLK_PERIOD;

	Up_Down <= '0';			-- Count down
	wait for CLK_PERIOD;

	Enable <= '1';
	wait for 20 * CLK_PERIOD;

	Enable <= '0';			-- Stop
		
	wait;				-- wait forever
end process;

-- Device under Test
DUT: count 
	generic map (COUNT_BITS)
	port map
	(
--	chip	   Board
--	count.vhd  count_tb.vhd	
	CLK 	=> CLK,		-- Zaehltakt
	Up_Down => Up_Down,	-- 1: UP, 0: down (Zaehlen)
	Enable	=> Enable,	-- 1: synchrones Zaehlen freigeben
	Load	=> Load,	-- 1: synchrones Laden freigeben
	Reset	=> Reset,	-- 1: asynchrones Reset
	Data_in	=> Data_in,	-- Eingang
	Data_out=> Data_out	-- Ausgang
	);
	
-- MSB Test

Data_msb <= Data_out(COUNT_BITS-1);
 
end arch_count_tb;

-- configuration (optional, for Simulation only)
----------------------------------
--
--configuration count_test of count_tb is
--	for arch_count_tb
--	end for;
-- end configuration;
