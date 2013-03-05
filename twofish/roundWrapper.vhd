-- entity RoundWrapper
-- ===================
--
-- Copyright (c) 2013, Alexander (alex@spline.de) and Yves (uves@spline.de)
--
-- Implements a single round of the twofish algorithm. Usable by a microblaze
-- processor via the integrated blockram ( 32bit and 128bit ports, ip-core
-- needed )

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

use work.twofish.ALL;

entity RoundWrapper is
  port (
    clkb : IN STD_LOGIC;
    rstb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    addrb, dinb : IN STD_LOGIC_VECTOR(31 downto 0 );
    doutb : OUT STD_LOGIC_VECTOR(31 downto 0);
    cmds : IN STD_LOGIC_VECTOR ( 0 TO 2 );
    
    done : OUT STD_LOGIC;
    
    clk : IN STD_LOGIC
    );
  
end RoundWrapper;

architecture RoundWrapperArch of RoundWrapper is

  component blockram
    port (
      clka : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      clkb : IN STD_LOGIC;
      rstb : IN STD_LOGIC;
      enb : IN STD_LOGIC;
      web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
  end component blockram;
  
  type tempT is array (0 to 3) of std_logic_vector(31 downto 0); 
  
  signal blockIn, blockOut : tempT ;
  signal writeEnable : std_logic_vector(15 downto 0);
  signal adress: std_logic_vector(4 DOWNTO 0);
  signal nextAdress: std_logic_vector(4 DOWNTO 0);

  type stateT is ( idle, waitForM, waitForS, getS, ready, waitForBlock, crypt, writeBlock, waitForDisable );
  signal state : stateT := idle;
  signal nextState : stateT := idle;
  
  signal set, enable, reset : std_logic;
  
  signal m0, me, s, nextS, nextM0, nextMe :  halfBlockT;
  
begin

  set <= cmds(0);
  enable <= cmds(1);
  reset <= cmds(2);
  
  mlb : blockram
    port map (
      clka => clk,
      wea => writeEnable,
      addra => adress,
      dina (31 downto 0) => blockOut(0),
      dina (63 downto 32) => blockOut(1),
      dina (95 downto 64) => blockOut(2),
      dina (127 downto 96) => blockOut(3),
      
      douta (31 downto 0) => blockIn(0),
      douta (63 downto 32) => blockIn(1),
      douta (95 downto 64) => blockIn(2),
      douta (127 downto 96) => blockIn(3),
      
      clkb => clkb,
      web => web,
      rstb => rstb,
      enb => enb,
      addrb(6 downto 0) => addrb(8 downto 2),
      dinb(31 downto 0) => dinb(31 downto 0),
      doutb(31 downto 0) => doutb(31 downto 0)
      );

  store: process(clk, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif clk = '1' and clk'event then
      state <= nextState;
      adress <= nextAdress;
      me <= nextMe;
      m0 <= nextM0;
      s <= nextS;
    end if;
  end process;
  
  transaction: process(state, enable, set, blockIn, m0, me, s)
  begin
    nextState <= state;
    nextM0 <= m0;
    nextMe <= me;
    nextS <= s;
    case state is
      when idle =>
        if set = '1' then
          nextState <= waitForM;
        end if;
      when waitForM =>
        nextState <= waitForS;
      when waitForS =>
        nextState <= getS;
        nextM0(0) <= unsigned(blockIn(0));
        nextM0(1) <= unsigned(blockIn(1));
        nextMe(0) <= unsigned(blockIn(2));
        nextMe(1) <= unsigned(blockIn(3));
      when getS =>
        nextS(0) <= unsigned(blockIn(0));
        nextS(1) <= unsigned(blockIn(1));
        nextState <= ready;
      when ready =>
        if enable = '1' then
          nextState <= waitForBlock;
        end if;
      when waitForBlock =>
        nextState <= crypt;
      when crypt =>
        nextState <= writeBlock;
      when writeBlock =>
        nextState <= waitForDisable;
      when waitForDisable =>
        if enable = '0' then
          nextState <= ready;
        end if;
    end case;        
  end process;
  
  outlogic: process(state, blockIn, m0, me, s)
    variable tmp : blockT;
  begin
    nextAdress <= "00000";
    writeEnable <= (others =>'0');
    done <= '0';
    blockOut <= ( others => (others => '0') );
    
    case state is
      when idle =>
        done <= '1';
      when waitForM =>
        nextAdress <= "00001";
      when waitForS =>
      when getS =>
      when ready =>
        done <= '1';
      when waitForBlock =>
      when crypt =>
        tmp := (
          unsigned(blockIn(0)),
          unsigned(blockIn(1)),
          unsigned(blockIn(2)),
          unsigned(blockIn(3)) );
        tmp := round(tmp, 0, m0, me, s);
        blockOut <= (
          std_logic_vector(tmp(0)),
          std_logic_vector(tmp(1)),
          std_logic_vector(tmp(2)),
          std_logic_vector(tmp(3)) );
        writeEnable <= ( others => '1');
      when writeBlock =>
      when waitForDisable =>
        done <= '1';
    end case;

  end process;

end RoundWrapperArch;

