-- counter.vhd --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY counter IS
	PORT (
		clk : IN STD_LOGIC;
		mpx : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)); -- NEW ONE ADD! send signal to select displays
END counter;

ARCHITECTURE Behavioral OF counter IS
	SIGNAL cnt : STD_LOGIC_VECTOR (15 DOWNTO 0); -- 15-bit counter
	
BEGIN
	mpx <= cnt (15 DOWNTO 13); -- 3 bits at top of counter

	CounterProc: PROCESS (clk)
	BEGIN
    ------------------------------------------------------------
    -- Code from mealy machine
        if (rising_edge(CLK)) THEN 
        cnt <= cnt + 1;
        end if;
    ------------------------------------------------------------
    END process;
END Behavioral;