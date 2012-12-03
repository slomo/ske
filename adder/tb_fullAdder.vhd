
entity tb_fullAdder is
end tb_fullAdder;

architecture test of tb_fullAdder is

type oper_test_type is (initialization, test_fa,
                        end_test );

signal OPER_TEST   : oper_test_type;


constant CLOCKCYCLE : time := 100 ns;

-- =============================================================================
-- ====  start of signals in  file "tb_fa.vhd" (connected to entity "fa.vhd" ===
-- =============================================================================

signal  A_in                 : BIT;
signal  B_in                 : BIT;
signal  C_in                 : BIT;
signal  carry                : BIT;
signal  sum                  : BIT;

-- =============================================================================
-- ======  end of signal in file "tb_fa.vhd (connected to entity "fa.vhd" ======
-- =============================================================================

component FullAdder
   port (A          : in  BIT;
         B          : in  BIT;
         CIN        : in  BIT;
         S          : out BIT; -- sum out of X+Y
         COUT       : out BIT  -- carry out
        );
end component;   --------- end of entity for fa ----------

begin
-- =============================================================================
-- =============================================================================
   main:process
   begin
      OPER_TEST             <= initialization;
      A_in<='0';  B_in<='0';  C_in<='0';
      wait for 1*CLOCKCYCLE;

-- =============================================================================
      OPER_TEST             <= test_fa;
      wait for 1*CLOCKCYCLE;          -- sum=0, c_out=0

      A_in<='1';  B_in<='0';  C_in<='0';
      wait for 1*CLOCKCYCLE;          -- sum=1, c_out=0

      A_in<='0'; B_in<='1';  C_in<='0';
      wait for 1*CLOCKCYCLE;          -- sum=1, c_out=0

      A_in<='1';  B_in<='1';  C_in<='0';
      wait for 1*CLOCKCYCLE;          -- sum=0, c_out=1

      A_in<='0';  B_in<='0'; C_in<='1';
      wait for 1*CLOCKCYCLE;          -- sum=1, c_out=0

      A_in<='1'; B_in<='0'; C_in<='1';
      wait for 1*CLOCKCYCLE;          -- sum=0, c_out=1

      A_in<='0';  B_in<='1'; C_in<='1';
      wait for 1*CLOCKCYCLE;          -- sum=0, c_out=1

      A_in<='1';  B_in<='1'; C_in<='1';
      wait for 1*CLOCKCYCLE;          -- sum=1, c_out=1

      A_in<='0';  B_in<='0'; C_in<='0';
-- =============================================================================
-- End test
      OPER_TEST              <= end_test;

      wait;  --forever
   end process main;
-- =============================================================================
-- =============================================================================

fa_u : FullAdder
   port map (
--   fa            testbench
    A       =>    A_in,
    B       =>    B_in,
    CIN     =>    C_in,
    S       =>    sum,
    COUT    =>    carry
    );            --------- end of port map for  "fa_u" ----------

-- =============================================================================
end test ;

