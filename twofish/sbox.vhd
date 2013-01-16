library     ieee;
use         ieee.std_logic_1164.all;
use         ieee.numeric_std.all;

entity Sbox is
    generic (
        WIDTH : INTEGER := 8
    );
    port (
        reset: in std_logic;
        set: in std_logic;
        clk: in std_logic;

        input: in std_logic_vector((WIDTH - 1) downto 0);
        output: out std_logic_vector((WIDTH - 1) downto 0)
    );
end entity Sbox;

architecture SboxArch of Sbox is
    constant TABLE_SIZE  : integer := 2 ** WIDTH;
    type lookuptable is array(0 to (TABLE_SIZE - 1 )) of std_logic_vector((WIDTH - 1) downto 0);
    signal counter: integer range 0 to (TABLE_SIZE - 1);
begin
    process(clk)
      variable table: lookuptable;
    begin

      -- default values
      counter <= 'X';
      output <= ( others => 'X' ); 
        
      if clk = '1' and clk'event then

        if reset = '1' then
          counter <= 0;
          
        elsif set = '1' then
          table(counter) := input;
          counter <= (counter + 1) mod TABLE_SIZE;
          
        else -- set should be 1
          output <= table(to_integer(unsigned(input)));

        end if;
      end if;
    end process;
end architecture SboxArch;

