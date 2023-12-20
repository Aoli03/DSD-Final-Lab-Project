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
--        threads : IN STD_LOGIC; 
--        threads : INOUT  STD_LOGIC_VECTOR (7 downto 0); 
--        id : IN STD_LOGIC_VECTOR (2 downto 0); 
        setOn : IN STD_LOGIC; -- sets thread on
        busy : OUT STD_LOGIC; -- is thread busy?
        reset : IN STD_LOGIC; -- resets thread to 0
        
        v_sync : IN STD_LOGIC;
        rock_speed : IN STD_LOGIC_VECTOR (9 DOWNTO 0); 
        rock_start_x : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        rock_x_out, rock_y_out : OUT STD_LOGIC_VECTOR (9 DOWNTO 0); 
        rock_size : OUT STD_LOGIC_VECTOR (9 DOWNTO 0) 
    );
    END COMPONENT;
    -- Car information
    CONSTANT csize : INTEGER := 8; -- car size in pixels
    CONSTANT car_w : INTEGER := 10; -- width of our object in pixels
    CONSTANT car_h : INTEGER := 15; -- car height in pixels
   
    -- GAME INFORMATION
    SIGNAL rock_on : STD_LOGIC; -- indicates whether rock is at current pixel position
    SIGNAL car_on : STD_LOGIC; -- indicates whether car at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether rock is in play
    SIGNAL counter : STD_LOGIC_VECTOR(10 downto 0); -- Score, the amount of VGA frames you've been in the game divided 

    -- CAR vertical position
    CONSTANT car_y : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 10);

    -- We need this to be at the TOP of the screen, 600.
    -- Rock array of 8 rocks (x,y) positions
    SIGNAL rock_x0, rock_x1, rock_x2, rock_x3, rock_x4, rock_x5, rock_x6, rock_x7 : STD_LOGIC_VECTOR (9 downto 0);
    SIGNAL rock_y0, rock_y1, rock_y2, rock_y3, rock_y4, rock_y5, rock_y6, rock_y7 : STD_LOGIC_VECTOR (9 downto 0);
    SIGNAL rock_x, rock_y : STD_LOGIC_VECTOR(79 DOWNTO 0); -- Large bit array, each rock is 10 bits of data to represent 1024 pixels NEED TO ADD AN EXTRA BIT TO EACH
    SIGNAL rock_speed, rock_size : STD_LOGIC_VECTOR(9 downto 0);-- Large bit array, each rock is 10 bits of data to represent 1024 pixels NEED TO ADD AN EXTRA BIT TO EACH

    SIGNAL threads : STD_LOGIC_VECTOR(7 downto 0) := (OTHERS => '0'); -- 8 threads for 8 rocks
    SIGNAL reset_threads : STD_LOGIC := '0'; -- flag that will reset all threads if '1'
    SIGNAL start_thread :  STD_LOGIC_VECTOR(7 downto 0) := (OTHERS => '0'); -- MUST FLASH THIS FLAG TO START A THREAD
    SIGNAL start_x : STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL rand_add : STD_LOGIC_VECTOR(12 downto 0) := "0000000000001"; -- random address for rock start position
BEGIN
    score <= counter(10 downto 3); -- convert the integer to a std logic vector to the displays
    rock_speed <= ('0' & raw_rock_speed) + conv_std_logic_vector(1,10); -- add 1 to the speed to make it 1 to 32
    
    rock_x <= rock_x7 & rock_x6 & rock_x5 & rock_x4 & rock_x3 & rock_x2 & rock_x1 & rock_x0;
    rock_y <= rock_y7 & rock_y6 & rock_y5 & rock_y4 & rock_y3 & rock_y2 & rock_y1 & rock_y0;
    
    --process to start the game and instantiate values when button is pressed
    gameStart : PROCESS (start_game, v_sync, car_on, rock_on) IS
    BEGIN

        IF game_on = '1' THEN
                counter <= counter + 1;
        END IF;
                
        IF start_game = '1' and game_on = '0' THEN
            game_on <= '1';
            counter <= (OTHERS => '0'); -- set score to 0
            reset_threads <= '1'; -- flash reset flags
            reset_threads <= '0'; -- unflash the reset flags
        END IF;
        
        -- IF collide, then turn off game
        IF car_on = '1' AND rock_on = '1' THEN
            game_on <= '0';
        END IF;
        
    END PROCESS;
    
    -- Spawn_rocks activates between the falling and rising edge of v_sync, because that is when rand_add changes
    -- we spawn threads by setting the corresponding start_thread index to '1' then immediately set it back.
    -- This initializes the rock from the top in rocks.vhd at whatever x-value start_x happened to be at the time 
    -- and then the rocks.vhd module will set our same threads index to 1, until it is no longer busy.
    spawn_rocks : PROCESS (rand_add) IS
    BEGIN
        IF game_on = '1' THEN
            -- TUNE THE MOD VALUE TO CHANGE THE SPAWN RATE 
            -- HIGHER MEANS LESS ROCKS
            -- LOWER MEANS MORE ROCKS
           IF (conv_integer(rand_add) mod 10 = 0) THEN
                -- create a loop to see if a thread is available then spawn in a rock
                send_to_idle_thread : FOR i IN 0 TO 7 LOOP
                    IF threads(i) = '0' THEN -- if thread is not busy
                        start_thread(i) <= '1'; -- start thread
                        EXIT send_to_idle_thread;
                    END IF;
                END LOOP send_to_idle_thread;
                start_thread <= (OTHERS => '0'); -- reset the start thread flag set
            END IF;
        END IF;
    END PROCESS;
    

    -- process to set the start x position of the rocks, pseudo random
    randomizer: PROCESS (v_sync, reset_threads) IS
        variable tmp : STD_LOGIC := '0';
        variable overflow_tmp : STD_LOGIC_VECTOR(12 downto 0);
    BEGIN
        overflow_tmp := rand_add + start_x;
        start_x <= overflow_tmp(9 downto 0);

--    IF (reset_threads='1') THEN
--       -- can't reset to all 0's, as you will enter an invalid state
--       rand_add <= "0000000000001";
    IF falling_edge(v_sync) THEN
       --ELSE Qt <= seed;
        tmp := rand_add(6) XOR rand_add(4) XOR rand_add(2) XOR rand_add(0);
        rand_add <= tmp & rand_add(12 downto 1); -- append a random bit and shift it right
    END IF;
    END PROCESS;

--    --process to increase the score when experiencing a game pulse
--    scoreUp : PROCESS (v_sync)IS 
--    BEGIN
--        IF rising_edge(v_sync) AND game_on = '1' THEN
--            counter <= counter + 1;
--        END IF;
--    END PROCESS;
    
    -- process check collisions
--    collision : PROCESS () IS
--    BEGIN 
--        IF car_on = '1' AND rock_on = '1' THEN
--            game_on <= '0';
--        END IF;
--    END PROCESS;

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
    --
    -- set rock_on if current pixel address is covered by rock position
    rockdraw : PROCESS (rock_x, rock_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy, size : STD_LOGIC_VECTOR (9 DOWNTO 0); -- 9 downto 0
    BEGIN
    -- for loop for every rock's position
        every_rock : FOR i IN 0 TO 7 LOOP
            IF threads(i) = '1' THEN
                vx := rock_x(i*10+9 downto i*10);
                vy := rock_y(i*10+9 downto i*10);
                size := rock_size(9 downto 0);
                --OR (rock_x(i*10+9 downto i*10) <= rock_size(i*10+9 downto i*10))
                IF ((pixel_col >= vx - size) AND
                    (pixel_col <= vx + size) AND
                    (pixel_row >= vy - size) AND
                    (pixel_row <= vy + size)) THEN
                    rock_on <= '1';
                ELSE
                    rock_on <= '0';
                END IF;
            ELSE
                rock_on <= '0';
            END IF;
        END LOOP every_rock;
    END PROCESS;

    -- THREAD BLOCK
    -------------------------------------------------------------------
    RThread_0 : rocks 
    PORT MAP (
--        threads => threads(0), 
--        id => "000",
        setOn => start_thread(0),
        busy => threads(0),
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x0, 
        rock_y_out => rock_y0, 
        rock_size => rock_size
    );

    RThread_1 : rocks 
    PORT MAP (
--        threads => threads(1), 
--        id => "001",
        setOn => start_thread(1),
        busy => threads(1),
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x1, 
        rock_y_out => rock_y1,
        rock_size => rock_size
    );

    RThread_2 : rocks 
    PORT MAP (
--        threads => threads(2), 
--        id => "010",
        setOn => start_thread(2),
        busy => threads(2),
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x2, 
        rock_y_out => rock_y2,
        rock_size => rock_size
    );

    RThread_3 : rocks 
    PORT MAP (
--        threads => threads(3), 
--        id => "011",
        setOn => start_thread(3),
        busy => threads(3),
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x3, 
        rock_y_out => rock_y3, 
        rock_size => rock_size
    );

    RThread_4 : rocks 
    PORT MAP (
--        threads => threads(4), 
--        id => "100",
        setOn => start_thread(4),
        busy => threads(4), 
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x4, 
        rock_y_out => rock_y4,
        rock_size => rock_size
    );

    RThread_5 : rocks 
    PORT MAP (
--        threads => threads(5), 
--        id => "101", 
        setOn => start_thread(5),
        busy => threads(5),
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x5, 
        rock_y_out => rock_y5,
        rock_size => rock_size
    );

    RThread_6 : rocks 
    PORT MAP (
--        threads => threads(6), 
--        id => "110", 
        setOn => start_thread(6),
        busy => threads(6),
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x6, 
        rock_y_out => rock_y6,
        rock_size => rock_size
    );

    RThread_7 : rocks 
    PORT MAP (
--        threads => threads(7), 
--        id => "111",
        setOn => start_thread(7),
        busy => threads(7), 
        reset => reset_threads,
        v_sync => v_sync,
        rock_speed => rock_speed, 
        rock_start_x => start_x, 
        rock_x_out => rock_x7, 
        rock_y_out => rock_y7,
        rock_size => rock_size
    );
END Behavioral;
