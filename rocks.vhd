LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rocks is
    Port (
        --thread variables 
--        threads : INOUT  STD_LOGIC_VECTOR (7 downto 0); -- 8 bit bus for thread activity 
--        threads : INOUT STD_LOGIC; -- 8 bit bus for thread activity 
        setOn : IN STD_LOGIC;
        busy : OUT STD_LOGIC;
        reset : IN STD_LOGIC;
--        id : IN STD_LOGIC_VECTOR (2 downto 0); -- 3 bit id corresponding to thread index

        --graphics clock variables
        v_sync : IN STD_LOGIC; -- vsync pulse
        
        --game variables
        rock_speed : IN STD_LOGIC_VECTOR (9 DOWNTO 0); -- rock speed
        rock_start_x : IN STD_LOGIC_VECTOR (9 DOWNTO 0); -- initial rock x-position

        --sending back up for draw information
        rock_x_out, rock_y_out : OUT STD_LOGIC_VECTOR (9 DOWNTO 0); -- rock x-position, rock y-position
        rock_size : OUT STD_LOGIC_VECTOR (9 DOWNTO 0) -- rock size
    );
end rocks;

architecture Behavioral of rocks is

    --signal declarations
    signal rock_x, rock_y : STD_LOGIC_VECTOR (9 DOWNTO 0); -- rock x-position, rock y-position
    CONSTANT init_rock_size : STD_LOGIC_VECTOR (9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(20, 10); -- rock size
    SIGNAL is_busy : STD_LOGIC;
    BEGIN

    -- send rock position and size up to draw module
    rock_x_out <= rock_x;
    rock_y_out <= rock_y;
    rock_size <= init_rock_size;

    -- process to start rock at initial position on top of screen
    rock_handler : process (setOn, v_sync, reset)
    begin
--          wait until rising_edge(threads(conv_integer(id)));
--          wait until rising_edge(threads);
        IF (reset = '1') THEN
            is_busy <= '0';    
        ElSIF (rising_edge(setOn)) THEN
            is_busy <= '1';
            rock_x <= rock_start_x;
            rock_y <= (OTHERS => '0');
        END IF;
        
        IF (rising_edge(v_sync)) THEN
            IF (is_busy = '1') THEN
                IF (rock_y >= 600) THEN -- if rock meets bottom wall
                    is_busy <= '0'; -- set thread to idle
                END IF;
            -- compute next rock vertical position
                rock_y <= rock_y + rock_speed;
            END IF;
        END IF;        
        
        busy <= is_busy; -- Any changes to output of busy get applied in the process
    end process;

--    -- process to move rock once every frame (i.e., once every vsync pulse)
--    mrock : PROCESS
----        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
--    BEGIN
--        WAIT UNTIL rising_edge(v_sync);
----        IF (threads(conv_integer(id)) = '1') THEN
----        IF (threads = '1') THEN
--        IF (is_busy = '1') THEN
--            IF (rock_y >= 600) THEN -- if rock meets bottom wall
--                is_busy <= '0'; -- set thread to idle
----                threads <= '0';
----                threads(conv_integer(id)) <= '0'; -- set thread to idle
--            END IF;
            
--            -- compute next rock vertical position
--            rock_y <= rock_y + rock_speed;
--            -- variable temp adds one more bit to calculation to fix unsigned underflow problems when rock_y is close to zero and rock_y_motion is negative
----            temp := ("00" & rock_y) + (rock_speed(10) & rock_speed);
----            IF temp(11) = '1' THEN
----                rock_y <= (OTHERS => '0');
----            ELSE
----                rock_y <= temp(9 DOWNTO 0); -- 9 downto 0
----            END IF;
--        END IF;
--    END PROCESS;

END Behavioral;

