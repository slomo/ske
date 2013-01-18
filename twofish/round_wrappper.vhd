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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity round_wrappper is
    port (
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        set : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        ready : OUT STD_LOGIC;
        
        clk : IN STD_LOGIC;
        );
        



end round_wrappper;

architecture Behavioral of round_wrappper is






    COMPONENT blockram
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
            clkb : IN STD_LOGIC;
            web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
            );
    END COMPONENT;

    component Round is

          generic (
            BLOCK_WIDTH : Integer := 128
            );

          port (
            set: in std_logic;
            clk: in std_logic;


            keyA: in  std_logic_vector( ( BLOCK_WIDTH/4 - 1) downto 0);
            keyB: in  std_logic_vector( ( BLOCK_WIDTH/4 - 1) downto 0);
            
            input: in std_logic_vector( ( BLOCK_WIDTH - 1) downto 0);
            output: out std_logic_vector( ( BLOCK_WIDTH - 1) downto 0)
            );

        end component Round;




    mlb : blockram
        PORT MAP (
            clka => clka,
            wea => wea,
            addra => addra,
            dina => dina,
            douta => douta,
            clkb => clkb,
            web => web,
            addrb => addrb,
            dinb => dinb,
            doutb => doutb
            );

    round : Round port map (
    
        clk => clk,
        
        input => douta,
        output => dina,
        
        


begin

    process(clk)
    
    
    begin
        
        if clk = '1' and clk'event then
        
            if set = '1' then
                
            end if;
        
        end if;
    
    
    end process;

end Behavioral;

