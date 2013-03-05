-- package twofish
-- ===============
--
-- Copyright (c) 2013, Alexander (alex@spline.de) and Yves (uves@spline.de)
--
-- Permission to use, copy, modify, and/or distribute this software for any purpose with
-- or without fee is hereby granted, provided that the above copyright notice and this
-- permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO
-- THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
-- EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
-- DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
-- IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
-- CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--
-- Implemened after those papers (referenced in comments):
--      [1] https://www.schneier.com/paper-twofish-paper.pdf
--      [2] https://www.schneier.com/paper-twofish-fpga.pdf
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package twofish is

  constant SBOX_WIDTH : integer := 8;
  constant FUNC_WIDTH : integer := SBOX_WIDTH * 4;
  constant BLOCK_WIDTH : integer := FUNC_WIDTH * 4;

  -- types
  type vectorT is array (1 to 4) of unsigned(SBOX_WIDTH-1 downto 0);
  type matrixT is array (1 to 4) of vectorT;

  type tT is array ( 0 to 15 ) of unsigned( 3 downto 0);
  type qT is array ( 0 to 3 ) of tT;
  type qsT is array ( 0 to 1) of qT;

  type confRowT is array ( 0 to 2 ) of integer range 0 to 1;
  type confT is array( 0 to 3 ) of confRowT;

  type halfBlockT is array ( 0 to 1 ) of unsigned( FUNC_WIDTH-1 downto 0 );
  
  type blockT is array ( 0 to 3 ) of unsigned( FUNC_WIDTH-1 downto 0 );
  
  constant q : qsT := (
    (
      ( x"8", x"1", x"7", x"D", x"6", x"F", x"3", x"2",
        x"0", x"B", x"5", x"9", x"E", x"C", x"A", x"4" ),
      ( x"E", x"C", x"B", x"8", x"1", x"2", x"3", x"5",
        x"F", x"4", x"A", x"6", x"7", x"0", x"9", x"D" ),
      ( x"B", x"A", x"5", x"E", x"6", x"D", x"9", x"0",
        x"C", x"8", x"F", x"3", x"2", x"4", x"7", x"1" ),
      ( x"D", x"7", x"F", x"4", x"1", x"2", x"6", x"E", 
        x"9", x"B", x"3", x"0", x"8", x"5", x"C", x"A" )
      ),
    (
      ( x"2", x"8", x"B", x"D", x"F", x"7", x"6", x"E",
        x"3", x"1", x"9", x"4", x"0", x"A", x"C", x"5" ),
      ( x"1", x"E", x"2", x"B", x"4", x"C", x"3", x"7",
        x"6", x"D", x"A", x"5", x"F", x"9", x"0", x"8" ), 
      ( x"4", x"C", x"7", x"5", x"1", x"6", x"9", x"A",
        x"0", x"E", x"D", x"8", x"2", x"B", x"3", x"F" ),
      ( x"B", x"9", x"5", x"1", x"C", x"3", x"D", x"E",
        x"6", x"4", x"7", x"F", x"2", x"0", x"8", x"A" )
      
      )
    );
  
  constant MDS_MATRIX : matrixT := (
    ( x"01", x"EF", x"5B", x"5B" ),
    ( x"5B", x"EF", x"EF", x"01" ),
    ( x"EF", x"5B", x"01", x"EF" ),
    ( x"EF", x"01", x"EF", x"5B" )
    );

  constant QPERM_CONF : confT := (
    ( 0, 0, 1),
    ( 1, 0, 0),
    ( 0, 1, 1),
    ( 1, 1, 0)
    );
  
  --
  -- funcion headers
  --
  function qperm ( input: unsigned( SBOX_WIDTH-1 downto 0); 
                   qId: integer range 0 to 1 ) 
    return unsigned;

  function mds( vector: vectorT)
    return vectorT;

  function g ( input, s0, s1: unsigned( FUNC_WIDTH-1 downto 0))
    return unsigned;

  function sbox ( input, s0, s1: unsigned( SBOX_WIDTH-1 downto 0);
                  id: integer range 0 to 3 )
    return unsigned;

  function h ( input, s0, s1: unsigned( FUNC_WIDTH-1 downto 0))
    return unsigned;
    
  function round ( inBlock : blockT;
                   rNo : integer range 0 to 15;
                   m0, me, s : halfBlockT )
    return blockT;

end twofish;

package body twofish is

  -- Q-Permutation
  --
  -- perform  either a q0 or q1 permutaion (see [1] 4.5.3 )  
  function qperm ( input: unsigned( SBOX_WIDTH-1 downto 0); 
                   qId: integer range 0 to 1 ) 
    return unsigned is
    
    variable a0, b0, a1, b1 :  unsigned( SBOX_WIDTH/2-1 downto 0);
    
  begin
    
    a0 := input( SBOX_WIDTH-1 downto SBOX_WIDTH/2 );
    b0 := input( SBOX_WIDTH/2-1 downto 0 );
    
    
    l1: for i in 0 to 1 loop
      a1 := a0 xor b0;
      b1 := a0 xor (b0 ror 1) xor ( a0(0) & '0' & '0' & '0');
      
      a0 := q(qId)(2*i)(to_integer(a1));
      b0 := q(qId)(2*i+1)(to_integer(b1));
    end loop l1;
    
    return (a0 & b0);
    
  end function qperm;

  -- MDS-Matrixmultiplication
  --
  -- Multiplys vector with the constant MDS-Matrix ( given in [1] 4.2 )
  function mds( vector: vectorT) return vectorT is 
    variable i,j : integer range 1 to 4 := 1;
    variable result : vectorT := ( others => to_unsigned(0, SBOX_WIDTH) );

  begin

    for i in 1 to 4 loop
      for j in 1 to 4 loop 
        result(i) := resize(result(i) + vector(i) * MDS_MATRIX(i)(j),SBOX_WIDTH);
      end loop;
    end loop;
    return result;
  end function mds;

  -- Innermost Function of twofish
  --
  -- Compute the inner Function g based directly on the Q-pertmutation. This
  -- Function is compatible to h (see [2] fig 2)
  function g ( input, s0, s1: unsigned( FUNC_WIDTH-1 downto 0))
    return unsigned is

    type sT is array ( 0 to 1 ) of unsigned (FUNC_WIDTH-1 downto 0);
    variable intern : unsigned( FUNC_WIDTH-1 downto 0);
    variable mdsVec : vectorT;
    variable s : sT := ( s0, s1 );
    
  begin

    -- apply two first columns of sboxes
    for i in 0 to 1 loop 
      for j in 0 to 3 loop

        intern(SBOX_WIDTH*(j+1)-1 downto SBOX_WIDTH*j) :=
          qperm( intern(SBOX_WIDTH*(j+1)-1 downto SBOX_WIDTH*j), QPERM_CONF(j)(i));

      end loop;
      intern := intern xor s(i); 
    end loop;

    -- apply last columns of sbox
    for j in 0 to 3 loop 
      mdsVec(j+1) :=  qperm(intern(SBOX_WIDTH*(j+1)-1 downto SBOX_WIDTH*j), QPERM_CONF(j)(2));
    end loop;
    
    mdsVec := mds(mdsVec);        

    for j in 0 to 3 loop 
      intern(SBOX_WIDTH*(j+1)-1 downto SBOX_WIDTH*j) := mdsVec(j+1); 
    end loop;

    return intern;

  end function g;

  -- Single sbox
  --
  -- Implments one single sbox (there are 4), it can be configured by specifing
  -- which sbox is needed ( see [2] fig 2).
  function sbox ( input, s0, s1: unsigned( SBOX_WIDTH-1 downto 0);
                  id: integer range 0 to 3 )
    return unsigned is

    type sT is array ( 0 to 1 ) of unsigned( SBOX_WIDTH-1 downto 0);
    variable s: sT := (s0, s1);
    variable intern : unsigned( SBOX_WIDTH-1 downto 0);
  begin
    intern := input;
    
    for i in 0 to 2 loop 

      intern := qperm( intern, QPERM_CONF(id)(i) );

      if i /= 2 then 
        intern := s(i) xor intern;
      end if;
      
    end loop;

    return intern;

  end function sbox;

  -- Innermost function of two fish
  --
  -- Implements function h by using the sboxes defined before. This is a direct
  -- replacment for function g (see [2] fig 2)
  function h ( input, s0, s1: unsigned( FUNC_WIDTH-1 downto 0))
    return unsigned is

    variable intern: vectorT;
  begin
    
    for i in 0 to 3 loop 

      intern(i+1) :=  sbox(
        input(SBOX_WIDTH*(i+1)-1 downto SBOX_WIDTH*i),
        s0(SBOX_WIDTH*(i+1)-1 downto SBOX_WIDTH*i),
        s1(SBOX_WIDTH*(i+1)-1 downto SBOX_WIDTH*i),
        i);
      
    end loop;

    intern :=  mds( intern );

    return (
      intern(1) & intern(2) & intern(3) & intern(4)
     );

  end function h;

  -- pseudo havermad transform
  --
  --
  function pht ( input : halfBlockT )
    return halfBlockT is
  begin
    return ( input(0) + input(1), input(1) + input(0) ); 
  end function pht;
  
  -- round function
  -- 
  -- this function is one single round
  function round ( inBlock : blockT;
                   rNo : integer range 0 to 15;
                   m0, me, s : halfBlockT )
    return blockT is

    variable tmpBlock : blockT := inBlock;
    variable roundKey : halfBlockT;
    variable keySeed : unsigned(SBOX_WIDTH - 1 downto 0); 
    
  begin

    -- compute keys
    
    -- inital round keys generate round keys
    for i in 0 to 1 loop
      keySeed := to_unsigned(2 * rNo + i, SBOX_WIDTH);

      for j in 0 to 3 loop
        roundKey(i) ( keySeed'length*(j+1) - 1 downto
                      keySeed'length*j ) := keySeed;
      end loop;
    end loop;

    
    roundKey(0) := h(roundKey(0), m0(0), m0(1));
    roundKey(1) := h(roundKey(1), me(0), me(1)) rol 8;

    roundKey := pht(roundKey);
    roundKey(1) := roundKey(1) rol 9;  

    
    -- compute rest of f
    tmpBlock(1) := tmpBlock(1) rol 8;

    for i in 0 to 1 loop
      tmpBlock(i) := g(tmpBlock(i), s(0), s(1));
    end loop;

    ( tmpBlock(0), tmpBlock(1) ) := pht( (tmpBlock(0), tmpBlock(1)) );

    for i in 0 to 1 loop
      tmpBlock(i) := tmpBlock(i) xor roundKey(i);
    end loop;

    -- perform round related stuff

    tmpBlock(3) := tmpBlock(3) rol 1;

    for i in 2 to 3 loop
      tmpBlock(i) := tmpBlock(i) xor tmpBlock(i-2);
    end loop;

    tmpBlock(2) := tmpBlock(2) ror 1;
    
    return tmpBlock;
  end function round;

end package body twofish;
