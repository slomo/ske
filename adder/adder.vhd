ENTITY HalfAdder IS
    PORT(
        A,B: IN BIT;
        S,C: OUT BIT
    );
END HalfAdder;

ARCHITECTURE HalfAdderBehave OF HalfAdder IS
BEGIN
    S <= A XOR B;
    C <= A AND B;
END HalfAdderBehave;

ENTITY FullAdder IS
    PORT(
        A,B,CIN: IN BIT;
        S,COUT: OUT BIT
    );
END FullAdder;

ARCHITECTURE FullAdderBehave OF FullAdder IS
    SIGNAL clow : BIT;
    SIGNAL chigh : BIT;
    SIGNAL slow : BIT;
    COMPONENT HalfAdder
        PORT(
            A,B: IN BIT;
            S,C: OUT BIT
        );
    END COMPONENT;
BEGIN
    ha_low : HalfAdder PORT MAP (
        A => A,
        B => B,
        C => clow,
        S => slow
    );
    ha_high : HalfAdder PORT MAP (
        A => slow,
        B => CIN,
        C => chigh,
        S => S
    );
    COUT <= (clow OR chigh);
END FullAdderBehave;

