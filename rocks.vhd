LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rocks is
    Port (
        --thread variables 
        threads : INOUT  STD_LOGIC_VECTOR (7 downto 0); -- 8 bit bus for thread activity 
        id : IN STD_LOGIC_VECTOR (2 downto 0); -- 3 bit id corresponding to thread index

        --graphics clock variables
        v_sync : IN STD_LOGIC; -- vsync pulse
        
        --game variables
        rock_speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- rock speed
        rock_start_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- initial rock x-position
        game_on : IN STD_LOGIC; -- is game on?

        --sending back up for draw information
        rock_x_out, rock_y_out : OUT STD_LOGIC_VECTOR (10 DOWNTO 0); -- rock x-position, rock y-position
        rock_size : OUT STD_LOGIC_VECTOR (10 DOWNTO 0) -- rock size
    );
end rocks;

architecture Behavioral of rocks is

    --signal declarations
    signal rock_y_motion : STD_LOGIC_VECTOR(10 downto 0); 
    signal rock_x, rock_y : STD_LOGIC_VECTOR (10 DOWNTO 0); -- rock x-position, rock y-position
    CONSTANT init_rock_size : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11); -- rock size
    
    BEGIN

    rock_y_motion <= (NOT rock_speed) + 1; -- set vspeed to (- rock_speed) pixels

    -- send rock position and size up to draw module
    rock_x_out <= rock_x;
    rock_y_out <= rock_y;
    rock_size <= init_rock_size;

    -- process to start rock at initial position on top of screen
    rock_start : process
    begin
        wait until rising_edge(threads(conv_integer(id)));
        rock_x <= rock_start_x;
        rock_y <= (OTHERS => '0');
    end process;

    -- process to move rock once every frame (i.e., once every vsync pulse)
    mrock : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF threads(conv_integer(id)) = '1' THEN

            IF (rock_y >= 600) THEN -- if rock meets bottom wall
                threads(conv_integer(id)) <= '0'; -- set thread to idle
            END IF;

            -- compute next rock vertical position
            -- variable temp adds one more bit to calculation to fix unsigned underflow problems when rock_y is close to zero and rock_y_motion is negative
            temp := ('0' & rock_y) + (rock_y_motion(10) & rock_y_motion);
            IF temp(11) = '1' THEN
                rock_y <= (OTHERS => '0');
            ELSE
                rock_y <= temp(10 DOWNTO 0); -- 9 downto 0
            END IF;
        END IF;
    END PROCESS;

END Behavioral;

