-- hexcount.vhd --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY hexcount IS
	PORT (
		clk_100MHz : IN STD_LOGIC;
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		score : IN STD_LOGIC_VECTOR(23 downto 0) -- score input from pong
	);
END hexcount;

ARCHITECTURE Behavioral OF hexcount IS

	COMPONENT counter IS
		PORT (
			clk : IN STD_LOGIC;
			mpx : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
	END COMPONENT;

	COMPONENT leddec IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR(3 downto 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
    SIGNAL decimalOf : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL md : STD_LOGIC_VECTOR (2 DOWNTO 0); -- mpx selects displays
	SIGNAL display : STD_LOGIC_vector(3 downto 0); -- Send digit for only one display to leddec
BEGIN
    display <= score(3 downto 0) when md = "000" else
               score(7 downto 4) when md = "001" else
               score(11 downto 8) when md = "010" else
               score(15 downto 12) when md = "011" else
               score(19 downto 16) when md = "100" else
               score(23 downto 20) when md = "101";
	C1 : counter
	PORT MAP(clk => clk_100MHz, mpx => md);
	L1 : leddec
	PORT MAP(dig => md, data => display, anode => anode, seg => seg);
END Behavioral;