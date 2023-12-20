-- FILEPATH: /c:/Users/cjsur/OneDrive - stevens.edu/Desktop/GitRepos/DSD_Final_Project/My_Branch/DSD-Final-Lab-Project/bat_n_ball.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        car_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current car x position
        start_game : IN STD_LOGIC; -- initiates game start
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        
        raw_rock_speed : IN STD_LOGIC_VECTOR(4 downto 0); -- NEW Input contains unmodified speed on range of 0 to 31
        score : OUT STD_LOGIC_VECTOR(7 downto 0) -- NEW Score for game needs to go to hexcount
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS

    COMPONENT rocks IS 
    Port (
        threads : INOUT  STD_LOGIC_VECTOR (7 downto 0); 
        id : IN STD_LOGIC_VECTOR (2 downto 0); 
        v_sync : IN STD_LOGIC;
        rock_speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0); 
        rock_start_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        rock_x_out, rock_y_out : OUT STD_LOGIC_VECTOR (10 DOWNTO 0); 
        rock_size : OUT STD_LOGIC_VECTOR (10 DOWNTO 0) 
    );
    END COMPONENT;
    -- Car information
    CONSTANT csize : INTEGER := 8; -- car size in pixels
    CONSTANT car_w : INTEGER := 10; -- width of our object in pixels
    CONSTANT car_h : INTEGER := 15; -- car height in pixels
   
    -- GAME INFORMATION
    SIGNAL rock_on : STD_LOGIC; -- indicates whether rock is at current pixel position
    SIGNAL car_on : STD_LOGIC; -- indicates whether car at over current pixel position
    SIGNAL game_on : STD_LOGIC; -- indicates whether rock is in play
    SIGNAL counter : STD_LOGIC_VECTOR(16 downto 0) := (OTHERS => '0'); -- Score, the amount of VGA frames you've been in the game divided 

    -- CAR vertical position
    CONSTANT car_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);

    -- We need this to be at the TOP of the screen, 600.
    -- Rock array of 8 rocks (x,y) positions
    SIGNAL rock_x, rock_y : STD_LOGIC_VECTOR(79 DOWNTO 0); -- Large bit array, each rock is 10 bits of data to represent 1024 pixels NEED TO ADD AN EXTRA BIT TO EACH
    -- Rock motion array of 8 rocks x velocities
    SIGNAL rock_y_motion : STD_LOGIC_VECTOR(79 DOWNTO 0); -- Large bit array, each rock is 10 bits of data to represent 1024 pixels NEED TO ADD AN EXTRA BIT TO EACH
    SIGNAL rock_speed, rock_size : STD_LOGIC_VECTOR(10 downto 0);
    
    SIGNAL threads : STD_LOGIC_VECTOR(7 downto 0) := (OTHERS => '0'); -- 8 threads for 8 rocks
    
    SIGNAL start_x : STD_LOGIC_VECTOR(10 downto 0);
    
BEGIN
    score <= counter(16 downto 9); -- convert the integer to a std logic vector to the displays
    rock_speed <= raw_rock_speed + conv_std_logic_vector(1,11); -- handles the type conversion
    
    --process to start the game and instantiate values when button is pressed
    gameStart : PROCESS (start_game) IS
    BEGIN
        IF start_game = '1' and game_on = '0' THEN
            game_on <= '1';
            counter <= (OTHERS => '0'); -- reset the score
            threads <= (OTHERS => '0'); -- reset the threads
        END IF;
    END PROCESS;
    
    --process to increase the score when experiencing a game pulse
    scoreUp : PROCESS IS 
    BEGIN
        WAIT UNTIL (rising_edge(v_sync));
        IF game_on = '1' THEN
            counter <= counter + 1;
        END IF;
    END PROCESS;
    
    -- process check collisions
    collision : PROCESS (car_on, rock_on) IS
    BEGIN 
        IF car_on = '1' AND rock_on = '1' THEN
            game_on <= '0';
        END IF;
    END PROCESS;

    --DRAWING BLOCK
    -------------------------------------------------------------------
    -- color setup for red rock and cyan car on white background
    red <= NOT car_on; 
    green <= NOT rock_on;
    blue <= NOT rock_on;
    
    -- process to draw car
    -- set car_on if current pixel address is covered by car position
    cardraw : PROCESS (car_x, pixel_row, pixel_col) IS
    BEGIN
        IF ((pixel_col >= car_x - car_w) OR (car_x <= car_w)) AND
            pixel_col <= car_x + car_w AND
            pixel_row >= car_y - car_h AND
            pixel_row <= car_y + car_h THEN
                car_on <= '1';
        ELSE
            car_on <= '0';
        END IF;
    END PROCESS;

    -- process to draw square rocks
    -- set rock_on if current pixel address is covered by rock position
    rockdraw : PROCESS (rock_x, rock_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
    -- for loop for every rock's position
        FOR i IN 0 TO 7 LOOP
            IF threads(i) = '1' THEN
                vx := rock_x(i*10+9 downto i*10);
                vy := rock_y(i*10+9 downto i*10);
                IF ((pixel_col >= vx - rock_size(i*10+9 downto i*10)) OR (vx <= rock_size(i*10+9 downto i*10))) AND
                    pixel_col <= vx + rock_size(i*10+9 downto i*10) AND
                    pixel_row >= vy - rock_size(i*10+9 downto i*10) AND
                    pixel_row <= vy + rock_size(i*10+9 downto i*10) THEN
                        rock_on <= '1';
                ELSE
                    rock_on <= '0';
                END IF;
            END IF;
        END LOOP;
    END PROCESS;

    -- THREAD BLOCK
    -------------------------------------------------------------------
    RThread_0 : rocks 
    PORT MAP (
        threads => threads, id => x"0", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(9 downto 0), 
        rock_y_out => rock_y(9 downto 0), 
        rock_size => rock_size
    );

    RThread_1 : rocks 
    PORT MAP (
        threads => threads, id => x"1", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(19 downto 10), 
        rock_y_out => rock_y(19 downto 10),
        rock_size => rock_size
    );

    RThread_2 : rocks 
    PORT MAP (
        threads => threads, id => x"2", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(29 downto 20), 
        rock_y_out => rock_y(29 downto 20),
        rock_size => rock_size
    );

    RThread_3 : rocks 
    PORT MAP (
        threads => threads, id => x"3", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(39 downto 30), 
        rock_y_out => rock_y(39 downto 30), 
        rock_size => rock_size
    );

    RThread_4 : rocks 
    PORT MAP (
        threads => threads, id => x"4", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(49 downto 40), 
        rock_y_out => rock_y(49 downto 40),
        rock_size => rock_size
    );

    RThread_5 : rocks 
    PORT MAP (
        threads => threads, id => x"5", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(59 downto 50), 
        rock_y_out => rock_y(59 downto 50),
        rock_size => rock_size
    );

    RThread_6 : rocks 
    PORT MAP (
        threads => threads, id => x"6", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(69 downto 60), 
        rock_y_out => rock_y(69 downto 60),
        rock_size => rock_size
    );

    RThread_7 : rocks 
    PORT MAP (
        threads => threads, id => x"7", 
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x(79 downto 70), 
        rock_y_out => rock_y(79 downto 70),
        rock_size => rock_size
    );
END Behavioral;
