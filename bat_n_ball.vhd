LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        
        raw_ball_speed : IN STD_LOGIC_VECTOR(4 downto 0); -- NEW Input contains unmodified speed on range of 0 to 31
        score : OUT STD_LOGIC_VECTOR(7 downto 0) -- NEW Score for game needs to go to hexcount
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    -- Bat information
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 14; -- width of our object
    CONSTANT bat_h : INTEGER := 7; -- bat height in pixels
    
    -- NEW SCORE INFOMATION
    SIGNAL has_scored : STD_LOGIC := '0'; -- Flag that makes score only able to happen once per bounce, as it used to proc 2-3 times on bounce
    SIGNAL counter : STD_LOGIC_VECTOR(7 downto 0); -- Score, or the number of times the ball has come in contact with the bat 
    
    -- distance ball moves each frame
    -- CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0); -- removed constant status because it was to be modified by switches
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    --
    -- Can we make this somewhat RANDOM?
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    -- Can we make this starting value random?
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    -- We need this to be at the TOP of the screen, 600. Will that mess with anything?
    --
    -- CAR vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(1, 11); -- MODIFIED Instantitate both velocities to 1 so they don't start at 0
    
    
BEGIN
    score <= counter; -- convert the integer to a std logic vector to the displays
    ball_speed <= raw_ball_speed + conv_std_logic_vector(1,11); -- handles the type conversion
    
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on;
    blue <= NOT ball_on;
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
    -- Draw OBSTACLE instead
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
    -- Within here
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat (THE CAR)
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 10 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_x_motion <= ball_speed; -- ADDED add an x-velocity when we serve
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            counter <= counter XOR counter; -- If reset counter goes to 0
            has_scored <= '0'; -- flag set to 0 to indicate the score and beam can be changed
            
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            has_scored <= '0'; -- flag set to 0 to indicate the score and beam can be changed 
        --
        -- THIS is where we update the score.
        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
            counter <= counter + 1; -- IF you bounce off the bat, increase score count by 1
            has_scored <= '1'; -- flag set to 1 to indicate the car has been hit.
            --serve <= '1'; --Create another obstacle automatically
            
        END IF;
        --
        -- We DO NOT WANT THIS TO HAPPEN
        -- Instead we need the obstacles to disappear, and then add to the score count
        -- What happens when the ball hits the bottom of the screen?
        --
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 800 THEN -- bounce off right wall
            -- make obstacle disappear, add new obstacle
            -- add 1 to score
            ball_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            has_scored <= '0'; -- flag set to 0 to indicate the score and beam can be reset again
        ELSIF ball_x <= bsize THEN -- bounce off left wall
            ball_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
            has_scored <= '0'; -- flag set to 0 to indicate the score and beam can be reset again
        END IF;
        --
        -- We want THIS to be what stops the game.
        -- allow for bounce off bat. We shouldn't bounce off the bat, we should stop it and end the game.
        -- Set x and y motion to 0.
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                --ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
                -- This should nullify the speed, and the game will reset when we press the button.
                ball_y_motion <= (ball_speed) - (ball_speed); 
                ball_x_motion <= (ball_speed) - (ball_speed);
                -- game_on <= '0'; -- and make OBSTACLE disappear?
                
        END IF;
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
    END PROCESS;
END Behavioral;
