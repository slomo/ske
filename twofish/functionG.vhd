library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FunctionG is
    generic ( WIDTH:  integer := 4 );
    port (
        reset: in std_logic;
        set: in std_logic;
        clk: in std_logic;
        input: in std_logic_vector((4*WIDTH-1) downto 0);
        output: out std_logic_vector((4*WIDTH-1) downto 0)
    );
end entity FunctionG;

architecture FunctionGArch of FunctionG is
    type vectorT is array (1 to 4) of unsigned((WIDTH-1) downto 0);
    type matrixT is array (1 to 4) of vectorT;
    
    constant mdsMatrix : matrixT := (
        ( x"01", x"EF", x"5B", x"5B" ),
        ( x"5B", x"EF", x"EF", x"01" ),
        ( x"EF", x"5B", x"01", x"EF" ),
        ( x"EF", x"01", x"EF", x"5B" )
     );
    component SBOX is
        generic ( WIDTH : INTEGER := WIDTH);
        port (
            reset: in std_logic;
            set: in std_logic;
            clk: in std_logic;
            input: in std_logic_vector((WIDTH - 1) downto 0);
            output: out std_logic_vector((WIDTH - 1) downto 0)
        );
    end component SBOX;
    signal sbox0Out, sbox1Out, sbox2Out, sbox3Out : std_logic_vector((WIDTH-1) downto 0);
    
    function mul( vector: vectorT;  matrix: matrixT) return vectorT is 
        variable i,j : integer range 1 to 4 := 1;
        variable result : vectorT := ( others => to_unsigned(0,WIDTH));
    begin
        for i in 1 to 4 loop
            for j in 1 to 4 loop
                result(i) := resize(result(i) + vector(i) * matrix(i)(j),(WIDTH-1));
            end loop;
        end loop;
        return result; 
    end function mul;
    
begin
    sbox0 : SBOX port map (
        input => input((WIDTH*4-1) downto (WIDTH*3)),
        output => sbox0Out,
        set => set,
        reset => reset,
        clk => clk
    );
    sbox1 : SBOX port map (
        input => input((WIDTH*3-1) downto (WIDTH*2)),
        output => sbox1Out,
        set => set,
        reset => reset,
        clk => clk
    );
    sbox2 : SBOX port map (
        input => input((WIDTH*2-1) downto (WIDTH*1)),
        output => sbox2Out,
        set => set,
        reset => reset,
        clk => clk
    );
    sbox3 : SBOX port map (
        input => input((WIDTH-1) downto 0),
        output => sbox3Out,
        set => set,
        reset => reset,
        clk => clk
    );
    

    
    mds : process (clk)
        variable vector : vectorT;
    begin
        if clk = '1' and clk'event then
            if set = '1' or reset = '1' then
                output <= ( others => 'X' );
            else
                vector := (
                    unsigned(sbox0out),
                    unsigned(sbox1out),
                    unsigned(sbox2out),
                    unsigned(sbox3out)
                );
                vector := mul(vector, mdsMatrix);
                output <=
                    std_logic_vector(vector(1)) &
                    std_logic_vector(vector(2)) &
                    std_logic_vector(vector(3)) &
                    std_logic_vector(vector(4));
             end if;
        end if;
    end process;
end architecture FunctionGArch;



