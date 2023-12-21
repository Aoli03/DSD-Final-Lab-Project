LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		data : IN STD_LOGIC; -- Made to be binary
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END leddec;

ARCHITECTURE Behavioral OF leddec IS
BEGIN
	-- Turn on segments corresponding to 4-bit data word
	seg <= "0000001" WHEN data = '0' ELSE -- 0
	       "1001111" WHEN data = '1' ELSE -- 1
	       "1111111";
	-- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
	         "11111101" WHEN dig = "001" ELSE -- 1
	         "11111011" WHEN dig = "010" ELSE -- 2
	         "11110111" WHEN dig = "011" ELSE -- 3
	         "11101111" WHEN dig = "100" ELSE -- 4
	         "11011111" WHEN dig = "101" ELSE -- 5
	         "10111111" WHEN dig = "110" ELSE -- 6
	         "01111111" WHEN dig = "111" ELSE -- 7
	         "11111111";
END Behavioral;