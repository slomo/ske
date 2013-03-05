----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:27:29 01/16/2013 
-- Design Name: 
-- Module Name:    round_wrappper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--library twofish;
use work.twofish.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CryptWrapper is
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
	attribute use_dsp48: string;
	attribute use_dsp48 of CryptWrapper: entity is "no";
end CryptWrapper;

architecture CryptWrapperArch of CryptWrapper is

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

    type stateT is ( idle, waitForKey, getKey, ready, waitForBlock, doCrypt, writeBlock, waitForDisable );
    signal state : stateT := idle;
    signal nextState : stateT := idle;
    
    signal set, enable, reset : std_logic;
	 
	 signal  key, nextKey : blockT;
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
				key <= nextKey;
        end if;
    end process;
    
    transaction: process(state, enable, set, blockIn, key)
    begin
        nextState <= state;
		  nextKey <= key;
        case state is
            when idle =>
                if set = '1' then
                    nextState <= waitForKey;
                end if;
            when waitForKey =>
                nextState <= getKey;
            when getKey =>
                nextState <= ready;
					 nextKey(0) <= unsigned(blockIn(0));
                nextKey(1) <= unsigned(blockIn(1));
                nextKey(2) <= unsigned(blockIn(2));
                nextKey(3) <= unsigned(blockIn(3));
            when ready =>
                if enable = '1' then
                    nextState <= waitForBlock;
                end if;
            when waitForBlock =>
                nextState <= doCrypt;
            when doCrypt =>
                nextState <= writeBlock;
            when writeBlock =>
                nextState <= waitForDisable;
				when waitForDisable =>
				   if enable = '0' then
					     nextState <= ready;
					end if;
        end case;        
    end process;
    
    outlogic: process(state, blockIn, key)
        variable tmp : blockT;
    begin
        nextAdress <= "00000";
        writeEnable <= (others =>'0');
        done <= '0';
        blockOut <= ( others => (others => '0') );
        
        case state is
            when idle =>
                done <= '1';
            when waitForKey =>
            when getKey =>
            when ready =>
                done <= '1';
            when waitForBlock =>
            when doCrypt =>
                tmp := (
                    unsigned(blockIn(0)),
                    unsigned(blockIn(1)),
                    unsigned(blockIn(2)),
                    unsigned(blockIn(3)) );
                tmp := crypt(key, tmp);
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

end CryptWrapperArch;

