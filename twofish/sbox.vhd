library     ieee;
use         ieee.std_logic_1164.all;
use         ieee.numeric_std.all;

entity SBOX is
    generic (
        WIDTH : INTEGER := 2
    );
    port (
        RESET: in std_logic;
        SET: in std_logic;
        CLK: in std_logic;


        INPUT: in std_logic_vector((WIDTH - 1) downto 0);
        OUTPUT: out std_logic_vector((WIDTH - 1) downto 0)
    );
end entity SBOX;

architecture SBOX_ARCH of SBOX is
    constant TABLE_SIZE  : INTEGER := 2 ** WIDTH;
    type LOOKUPTABLE is array(0 to (TABLE_SIZE - 1 )) of std_logic_vector((WIDTH - 1) downto 0);
    signal COUNTER: INTEGER;
begin
    process(CLK)
    variable TABLE: LOOKUPTABLE;
    begin
        if CLK = '1' and CLK'event then
            if RESET = '1' then
                COUNTER <= 0;
            elsif SET = '0' then
               OUTPUT <= TABLE(to_integer(unsigned(INPUT)));
            else
                TABLE(COUNTER) := INPUT;
                COUNTER <= (COUNTER + 1) mod TABLE_SIZE;
            end if;
        end if;
    end process;
end architecture SBOX_ARCH;

