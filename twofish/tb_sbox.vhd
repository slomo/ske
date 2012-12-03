library     ieee;
use         ieee.std_logic_1164.all;
use         ieee.numeric_std.all;

entity TB_SBOX is
end TB_SBOX;


architecture TB_ARCH of TB_SBOX is

    signal SET_IN: std_logic;
    signal CLK_IN: std_logic;

    signal INPUT_IN: std_logic_vector(1 downto 0);
    signal LOOKUP_IN: std_logic_vector(1 downto 0);
    signal OUTPUT_OUT: std_logic_vector(1 downto 0);

    constant CLOCKCYCLE : time := 100 ns;
    component SBOX is
        generic (
            WIDTH : INTEGER := 2
        );
        port (
            SET: in std_logic;
            CLK: in std_logic;

            INPUT: in std_logic_vector((WIDTH - 1) downto 0);

            LOOKUP: in std_logic_vector((WIDTH - 1) downto 0);
            OUTPUT: out std_logic_vector((WIDTH - 1) downto 0)
        );
    end component SBOX;
begin
    main:process
    begin
        wait for 1*CLOCKCYCLE;
            SET_IN <= '1';
            INPUT_IN <= "01";
        wait for 1*CLOCKCYCLE;
            INPUT_IN <= "10";
        wait for 1*CLOCKCYCLE;
            INPUT_IN <= "11";
        wait for 1*CLOCKCYCLE;
            INPUT_IN <= "00";
        wait for 1*CLOCKCYCLE;
            SET_IN <= '0';
            LOOKUP_IN <= "00";
        wait for 1*CLOCKCYCLE;
            LOOKUP_IN <= "10";
        wait for 1*CLOCKCYCLE;
            LOOKUP_IN <= "00";
        wait for 1*CLOCKCYCLE;
            LOOKUP_IN <= "11";
        wait for 1*CLOCKCYCLE;
            LOOKUP_IN <= "01";
        wait for 1*CLOCKCYCLE;
    end process;
    clock:process
    begin
        wait for 1*CLOCKCYCLE;
            CLK_IN <='0';
        wait for 1*CLOCKCYCLE;
            CLK_IN <='1';
    end process;
    the_sbox : SBOX
        port map (
            INPUT => INPUT_IN,
            OUTPUT => OUTPUT_OUT,
            LOOKUP => LOOKUP_IN,

            SET => SET_IN,
            CLK => CLK_IN
        );
end architecture TB_ARCH;
