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
use twofish.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RoundWrapper is
    port (
        clkb : IN STD_LOGIC;
        rstb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        set : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        reset : in std_logic;
        
        done : OUT STD_LOGIC;
        
        clk : IN STD_LOGIC
        );
        
end RoundWrapper;

architecture RoundWrapperArch of RoundWrapper is

    component blockram
        port (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
            clkb : IN STD_LOGIC;
            rstb : IN STD_LOGIC;
            enb : IN STD_LOGIC;
            web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
            );
    end component blockram;
    
    type tempT is array (0 to 3) of std_logic_vector(31 downto 0); 
    
    signal blockIn, blockOut : tempT ;
    signal writeEnable : std_logic_vector(0 downto 0);
    signal adress: std_logic_vector(4 DOWNTO 0);
    signal nextAdress: std_logic_vector(4 DOWNTO 0);
    
    type stateT is ( idle, waitForM, waitForS, getS, ready, waitForBlock, crypt, writeBlock );
    signal state : stateT := idle;
    signal nextState : stateT := idle;
    
begin

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
            web => web(0 downto 0),
            rstb => rstb,
            enb => enb,
            addrb => addrb(6 downto 0),
            dinb => dinb,
            doutb => doutb
            );

    store: process(clk, reset)
    begin
        if reset = '1' then
            state <= idle;
        elsif clk = '1' and clk'event then
            state <= nextState;
            adress <= nextAdress;
        end if;
    end process;
    
    transaction: process(state, enable, set)
    begin
        nextState <= state;
        case state is
            when idle =>
                if set = '1' then
                    nextState <= waitForM;
                end if;
            when waitForM =>
                nextState <= waitForS;
            when waitForS =>
                nextState <= getS;
            when getS =>
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
                nextState <= ready;
        end case;        
    end process;
    
    outlogic: process(state, blockIn)
        variable tmp : blockT;
        -- keys
        variable m0 : halfBlockT;
        variable me : halfBlockT;
        variable s : halfBlockT;
    begin
        nextAdress <= "00000";
        writeEnable(0) <= '0';
        done <= '0';
        blockOut <= ( others => (others => '0') );
        
        case state is
            when idle =>
                done <= '1';
            when waitForM =>
                nextAdress <= "00001";
            when waitForS =>
                m0(0) := unsigned(blockIn(0));
                m0(1) := unsigned(blockIn(1));
                me(0) := unsigned(blockIn(2));
                me(1) := unsigned(blockIn(3));
            when getS =>
                s(0) := unsigned(blockIn(0));
                s(1) := unsigned(blockIn(1));
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
                writeEnable(0) <= '1';
            when writeBlock =>
                writeEnable(0) <= '0';
        end case;
    end process;

end RoundWrapperArch;

