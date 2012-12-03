library     ieee;
use         ieee.std_logic_1164.all;
use         ieee.numeric_std.all;

entity SBOX is
    generic (
        WIDTH : INTEGER := 2
    );
    port (
        SET: in std_logic;
        CLK: in std_logic;


        INPUT: in std_logic_vector((WIDTH - 1) downto 0);
        LOOKUP: in std_logic_vector((WIDTH - 1) downto 0 );
        OUTPUT: out std_logic_vector((WIDTH - 1) downto 0)
    );
end entity SBOX;

architecture SBOX_ARCH of SBOX is
    constant TABLE_SIZE  : INTEGER := 2 ** WIDTH;
    type LOOKUPTABLE is array(0 to (TABLE_SIZE - 1 )) of std_logic_vector((WIDTH - 1) downto 0);
begin
    process(CLK)
    variable TABLE: LOOKUPTABLE;
    variable COUNTER: INTEGER := 0;
    variable LAST_SET: std_logic;
    begin
        case SET is
            when '1' =>
                case  LAST_SET is
                    when '1' =>
                        COUNTER := (COUNTER + 1) mod TABLE_SIZE;
                    when '0' =>
                        COUNTER := 0;
                    when others =>
                        COUNTER := COUNTER;
                end case;
                TABLE(COUNTER) := INPUT;
            when '0' =>
                OUTPUT <= TABLE(to_integer(unsigned(LOOKUP)));
            when others =>
                OUTPUT <= ( others => 'Z' );
            end case;
        LAST_SET := SET;
    end process;
end architecture SBOX_ARCH;

