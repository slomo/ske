library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Round is

  generic (
    BLOCK_WIDTH : Integer := 128;
    ROUND_NUMBER : Integer := 1
    );

  port (
    reset: in std_logic;
    set: in std_logic;
    clk: in std_logic;


    keyA: in  std_logic_vector( ( BLOCK_WIDTH - 1) downto 0);
    keyB: in  std_logic_vector( ( BLOCK_WIDTH - 1) downto 0);
    
    input: in std_logic_vector( ( BLOCK_WIDTH - 1) downto 0);
    output: out std_logic_vector( ( BLOCK_WIDTH - 1) downto 0)
    );

end entity Round;

architecture RoundArch of Round is

  constant WIDTH_G : integer := BLOCK_WIDTH / 2; 

  component FunctionG is
    generic (
      WIDTH:  integer := WIDTH_G );
    port (
      reset: in std_logic;
      set: in std_logic;
      clk: in std_logic;

      input: in std_logic_vector((WIDTH-1) downto 0);
      output: out  std_logic_vector((WIDTH-1) downto 0)
      );
  end component FunctionG;

  type goutT is array ( 0 to 1 ) of std_logic_vector((WIDTH_G - 1) downto 0);
  signal gout : goutT;
    
begin

  -- handling of value 1 and 2
  gfunc0 : FunctionG port map (
    input =>  input(WIDTH_G - 1 downto 0),
    output => gout(0),
    set => set,
    reset => reset,
    clk => clk    
    );

  gfunc1 : FunctionG port map (
    input => shift_left( input(WIDTH_G * 2 - 1 downto WIDTH_G), 8),        
    output => gout(1),
    set => set,
    reset => reset,
    clk => clk    
    );


  output( BLOCK_WIDTH/2 - 1 downto 0) <= input(  BLOCK_WIDTH/2 - 1 downto 0);
  
  -- handling of value 3 and 4

  output( WIDTH_G*3 - 1 downto WIDTH_G*2) <=
    std_logic_vector(unsigned(gout(1)) + unsigned(gout(0)) + unsigned(keyB))
    xor shift_left( input( WIDTH_G*3 - 1 downto WIDTH_G*2), 1);

  output( WIDTH_G*4 - 1 downto WIDTH_G*3) <=
    shift_left(
      std_logic_vector(unsigned(gout(1)) + unsigned(gout(0)) + unsigned(keyA))
      xor input( WIDTH_G*4 - 1 downto WIDTH_G*3)
      , 1); 
  
  
end architecture RoundArch;
  
  

  
