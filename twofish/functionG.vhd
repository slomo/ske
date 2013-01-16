library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FunctionG is
  generic ( WIDTH:  integer := 32 );
  port (
    reset: in std_logic;
    set: in std_logic;
    clk: in std_logic;

    input: in std_logic_vector((WIDTH-1) downto 0);
    output: out std_logic_vector((WIDTH-1) downto 0)
    );
end entity FunctionG;

architecture FunctionGArch of FunctionG is

  constant SBOX_WIDTH : integer := WIDTH/4;

  type vectorT is array (1 to 4) of unsigned(SBOX_WIDTH-1 downto 0);
  type matrixT is array (1 to 4) of vectorT;

  constant mdsMatrix : matrixT := (
    ( x"01", x"EF", x"5B", x"5B" ),
    ( x"5B", x"EF", x"EF", x"01" ),
    ( x"EF", x"5B", x"01", x"EF" ),
    ( x"EF", x"01", x"EF", x"5B" )
    );

  component Sbox is
    generic ( WIDTH : INTEGER := SBOX_WIDTH );
    port (
      reset: in std_logic;
      set: in std_logic;
      clk: in std_logic;
      input: in std_logic_vector( SBOX_WIDTH - 1 downto 0);
      output: out std_logic_vector( SBOX_WIDTH - 1 downto 0)
      );
  end component Sbox;

  --type tmp is array (1 to 4) of std_logic_vector ( SBOX_WIDTH - 1 downto 0);
  signal sboxOut :  vectorT ;

  function mul( vector: vectorT;  matrix: matrixT) return vectorT is 
    variable i,j : integer range 1 to 4 := 1;
    variable result : vectorT := ( others => to_unsigned(0, SBOX_WIDTH - 1) );
  begin
    for i in 1 to 4 loop
      for j in 1 to 4 loop 
        result(i) := resize(result(i) + vector(i) * matrix(i)(j),(SBOX_WIDTH-1));
      end loop;
    end loop;
    return result;
  end function mul;
  
begin
  sboxes: for i in 3 to 0 generate
    sboxInstance : Sbox port map (
      input => input( (SBOX_WIDTH * i) - 1 downto SBOX_WIDTH * i ),
      unsigned(output) => sboxOut(i+1),

      set => set,
      reset => reset,
      clk => clk
      );
  end generate sboxes; 
  
  mds : process (clk)
    variable vector : vectorT;
  begin
    output <= ( others => 'X' );

    if clk = '1' and clk'event then
      if set = '0' and reset = '0' then
        vector := mul(sboxOut, mdsMatrix);
        output <=
          std_logic_vector(vector(1)) &
          std_logic_vector(vector(2)) &
          std_logic_vector(vector(3)) &
          std_logic_vector(vector(4));
      end if;
    end if;
  end process;
end architecture FunctionGArch;
