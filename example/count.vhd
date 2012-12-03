--  Binrzaehler
--  File: count.VHD
--  created by F. Winkler: 30/10/2012 
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;       -- empfohlen fr Neuentwicklungen
--use IEEE.std_logic_arith.all;     -- veraltet, 
--use IEEE.std_logic_unsigned.all;  -- veraltet

entity count is
	generic (
		N: INTEGER:=32				-- Anzahl Zaehlerbits
	);
    port (
        Clk:     in STD_LOGIC;			-- Zaehltakt
        Up_Down: in STD_LOGIC;			-- 1: UP, 0: down (Zaehlen)
        Enable:  in STD_LOGIC;			-- 1: synchrones Zaehlen freigeben
        Load:    in STD_LOGIC;			-- 1: synchrones Laden freigeben
        Reset:   in STD_LOGIC;			-- 1: asynchrones Reset
        Data_in: in  UNSIGNED (N-1 downto 0); -- Eingang
        Data_out:out UNSIGNED (N-1 downto 0);-- Ausgang
		Clk_out: out STD_LOGIC      	-- Clock ref out
    );
end count;

architecture arch_count of count is

subtype Zahl is UNSIGNED (N-1 downto 0); -- Subtype Beispiel
signal Z: Zahl;							  

begin
zaehl: Process(Clk, Reset)
	variable D: Zahl;
	begin
	if Reset = '1' then
		Z <= Zahl'(OTHERS=>'0');
	elsif Clk='1' and Clk'event then
		if Enable ='1' then
			if UP_Down ='1' then
				D := TO_UNSIGNED(1,N); -- integer 1 zu unsigned
			else
				D := (Others =>'1');	-- Komplement(1) Addieren		
			end if;
			Z <= Z + D;				  -- der Addierer
		elsif Load = '1' then
			Z <= Data_in;
		else
			Null;					-- Z wird gespeichert!
		end if; 
	end if;
end process;

Data_out <= Z;						-- Data_out ohne Zusatzspeicher
Clk_out <= Clk;
  
end arch_count;
