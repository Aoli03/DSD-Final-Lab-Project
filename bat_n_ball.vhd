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
        start : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        score : OUT STD_LOGIC_VECTOR(23 downto 0) -- NEW Score for game needs to go to hexcount
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    -- Bat information
    CONSTANT bat_w : INTEGER := 20; -- MODIFIED bat width in pixels, Started at 20, doubled into 40, removed constant status
    CONSTANT bat_h : INTEGER := 45; -- bat height in pixels
    
    -- NEW SCORE INFOMATION
    SIGNAL counter : INTEGER := 0; -- Score, or the number of times the ball has come in contact with the bat 
    
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(525, 11);
    
   -- rock position
    SIGNAL rock1_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11);
    SIGNAL rock2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 11);
    SIGNAL rock3_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(250, 11);
    SIGNAL rock4_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350, 11);
    SIGNAL rock5_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    SIGNAL rock6_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11);
    SIGNAL rock7_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650, 11);
    SIGNAL rock8_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(750, 11);
    
    signal rock_on_screen: std_logic_vector(7 downto 0) := (OTHERS => '0');
    signal rock1_y, rock2_y, rock3_y, rock4_y, rock5_y, rock6_y, rock7_y, rock8_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    SIGNAL rock_speed: STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    CONSTANT r_size : integer := 12;
    SIGNAL rock_on: std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL start_x : STD_LOGIC_VECTOR(10 downto 0);
BEGIN
    score <= conv_std_logic_vector(counter/8,24); -- convert the integer to a std logic vector to the displays
    
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT (rock_on(0) or rock_on(1) or rock_on(2) or rock_on(3) or rock_on(4) or rock_on(5) or rock_on(6) or rock_on(7));
    blue <= NOT (rock_on(0) or rock_on(1) or rock_on(2) or rock_on(3) or rock_on(4) or rock_on(5) or rock_on(6) or rock_on(7));
    
    mrock0 : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF start = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            rock_on_screen <= "00001000";
            counter <= 0;
            rock_speed <= "00000000101";
        END IF;
        
        IF game_on = '1' THEN
            counter <= counter + 1;
        END IF;
        
        IF (rock_speed < "00000001110") AND (counter mod 500 = 0) THEN
            rock_speed <= rock_speed + 1;
        END IF;
        
        -- rock1 collision with car
        IF (rock1_x + r_size/2) >= (bat_x - bat_w) AND
         (rock1_x - r_size/2) <= (bat_x + bat_w) AND
             (rock1_y + r_size/2) >= (bat_y - bat_h) AND
             (rock1_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
        -- rock2 collision with car
        IF (rock2_x + r_size/2) >= (bat_x - bat_w) AND
         (rock2_x - r_size/2) <= (bat_x + bat_w) AND
             (rock2_y + r_size/2) >= (bat_y - bat_h) AND
             (rock2_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
        -- rock3 collision with car
        IF (rock3_x + r_size/2) >= (bat_x - bat_w) AND
         (rock3_x - r_size/2) <= (bat_x + bat_w) AND
             (rock3_y + r_size/2) >= (bat_y - bat_h) AND
             (rock3_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
        -- rock4 collision with car
        IF (rock4_x + r_size/2) >= (bat_x - bat_w) AND
         (rock4_x - r_size/2) <= (bat_x + bat_w) AND
             (rock4_y + r_size/2) >= (bat_y - bat_h) AND
             (rock4_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
         -- rock5 collision with car
        IF (rock5_x + r_size/2) >= (bat_x - bat_w) AND
         (rock5_x - r_size/2) <= (bat_x + bat_w) AND
             (rock5_y + r_size/2) >= (bat_y - bat_h) AND
             (rock5_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
         -- rock6 collision with car
        IF (rock6_x + r_size/2) >= (bat_x - bat_w) AND
         (rock6_x - r_size/2) <= (bat_x + bat_w) AND
             (rock6_y + r_size/2) >= (bat_y - bat_h) AND
             (rock6_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
         -- rock7 collision with car
        IF (rock7_x + r_size/2) >= (bat_x - bat_w) AND
         (rock7_x - r_size/2) <= (bat_x + bat_w) AND
             (rock7_y + r_size/2) >= (bat_y - bat_h) AND
             (rock7_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
         -- rock8 collision with car
        IF (rock8_x + r_size/2) >= (bat_x - bat_w) AND
         (rock8_x - r_size/2) <= (bat_x + bat_w) AND
             (rock8_y + r_size/2) >= (bat_y - bat_h) AND
             (rock8_y - r_size/2) <= (bat_y + bat_h) THEN
                rock_on_screen <= "00000000";
                game_on <= '0'; 
        END IF;
        
        -- rock1 collision logic
        IF rock1_y >= 600 THEN 
           rock_on_screen(0) <= '0';
        END IF; 
        -- rock2 collision logic
        IF rock2_y >= 600 THEN 
           rock_on_screen(1) <= '0';
        END IF; 
        -- rock3 collision logic
        IF rock3_y >= 600 THEN 
           rock_on_screen(2) <= '0';
        END IF;
        -- rock4 collision logic
        IF rock4_y >= 600 THEN 
           rock_on_screen(3) <= '0';
        END IF;
        -- rock5 collision logic
        IF rock5_y >= 600 THEN 
           rock_on_screen(4) <= '0';
        END IF; 
        -- rock6 collision logic
        IF rock6_y >= 600 THEN 
           rock_on_screen(5) <= '0';
        END IF; 
        -- rock7 collision logic
        IF rock7_y >= 600 THEN 
           rock_on_screen(6) <= '0';
        END IF; 
        -- rock8 collision logic
        IF rock8_y >= 600 THEN 
           rock_on_screen(7) <= '0';
        END IF;  
        
        
        --rock1 spawn logic
        IF counter > 50 THEN 
            IF rock_on_screen(0) = '0' and game_on = '1' THEN 
                rock1_x <= conv_std_logic_vector(conv_integer(start_x) * 2 mod 800, 11);
                rock1_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(0) <= '1';
            ELSE
                rock1_y <= rock1_y + rock_speed;
            END IF;
        END IF;
         --rock2 spawn logic 
        IF counter > 75 THEN
            IF rock_on_screen(1) = '0' and game_on = '1' THEN 
                rock2_x <= conv_std_logic_vector(conv_integer(start_x) * 9 mod 800, 11);
                rock2_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(1) <= '1';
            ELSE
                rock2_y <= rock2_y + rock_speed;
            END IF;
        END IF;
         --rock3 spawn logic 
        IF counter > 125 THEN
            IF rock_on_screen(2) = '0' and game_on = '1' THEN 
                rock3_x <= conv_std_logic_vector(conv_integer(start_x) * 7 mod 800, 11);
                rock3_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(2) <= '1';
            ELSE
                rock3_y <= rock3_y + rock_speed;
            END IF;
        END IF;
         --rock4 spawn logic 
        IF rock_on_screen(3) = '0' and game_on = '1' THEN 
            rock4_x <= start_x ;
            rock4_y <= CONV_STD_LOGIC_VECTOR(0, 11);
            rock_on_screen(3) <= '1';
        ELSE
            rock4_y <= rock4_y + rock_speed;
        END IF;
        --rock5 spawn logic
        IF counter > 200 THEN
            IF rock_on_screen(4) = '0' and game_on = '1' THEN 
                rock5_x <= conv_std_logic_vector(conv_integer(start_x) * 17 mod 800, 11);
                rock5_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(4) <= '1';
            ELSE
                rock5_y <= rock5_y + rock_speed;
            END IF;
        END IF;
        --rock6 spawn logic
        IF counter > 250 THEN
            IF rock_on_screen(5) = '0' and game_on = '1' THEN 
                rock6_x <= conv_std_logic_vector(conv_integer(start_x) * 57 mod 800, 11);
                rock6_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(5) <= '1';
            ELSE
                rock6_y <= rock6_y + rock_speed;
            END IF;
        END IF;
        --rock7 spawn logic
        IF counter > 300 THEN
            IF rock_on_screen(6) = '0' and game_on = '1' THEN 
                rock7_x <= conv_std_logic_vector(conv_integer(start_x) * 30 mod 800, 11);
                rock7_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(6) <= '1';
            ELSE
                rock7_y <= rock7_y + rock_speed;
            END IF;
        END IF;
         --rock8 spawn logic
        IF counter > 350 THEN
            IF rock_on_screen(7) = '0' and game_on = '1' THEN 
                rock8_x <= conv_std_logic_vector(conv_integer(start_x) * 23 mod 800, 11);
                rock8_y <= CONV_STD_LOGIC_VECTOR(0, 11);
                rock_on_screen(7) <= '1';
            ELSE
                rock8_y <= rock8_y + rock_speed;
            END IF;
        END IF;
        
    END PROCESS;
    
        -- process to draw rock
    rockdraw: PROCESS (pixel_row, pixel_col,rock1_y,rock2_y, rock3_y, rock4_y,rock5_y,rock6_y,rock7_y,rock8_y ) IS
    BEGIN
    -- draw first rock
        IF rock_on_screen(0) = '1' THEN 
            IF pixel_col >= rock1_x - r_size AND
            pixel_col <= rock1_x + r_size AND
                pixel_row >= rock1_y - r_size AND
                pixel_row <= rock1_y + r_size THEN
                   rock_on(0) <= '1';
            ELSE
                rock_on(0) <= '0';
            END IF;
        END IF;
    -- draw second rock
    IF rock_on_screen(1) = '1' THEN 
            IF pixel_col >= rock2_x - r_size AND
            pixel_col <= rock2_x + r_size AND
                pixel_row >= rock2_y - r_size AND
                pixel_row <= rock2_y + r_size THEN
                   rock_on(1) <= '1';
            ELSE
                rock_on(1) <= '0';
            END IF;
        END IF;
    -- draw third rock
    IF rock_on_screen(2) = '1' THEN 
            IF pixel_col >= rock3_x - r_size AND
            pixel_col <= rock3_x + r_size AND
                pixel_row >= rock3_y - r_size AND
                pixel_row <= rock3_y + r_size THEN
                   rock_on(2) <= '1';
            ELSE
                rock_on(2) <= '0';
            END IF;
        END IF;
    -- draw fourth rock
    IF rock_on_screen(3) = '1' THEN 
            IF pixel_col >= rock4_x - r_size AND
            pixel_col <= rock4_x + r_size AND
                pixel_row >= rock4_y - r_size AND
                pixel_row <= rock4_y + r_size THEN
                   rock_on(3) <= '1';
            ELSE
                rock_on(3) <= '0';
            END IF;
        END IF;
    -- draw fifth rock
    IF rock_on_screen(4) = '1' THEN 
            IF pixel_col >= rock5_x - r_size AND
            pixel_col <= rock5_x + r_size AND
                pixel_row >= rock5_y - r_size AND
                pixel_row <= rock5_y + r_size THEN
                   rock_on(4) <= '1';
            ELSE
                rock_on(4) <= '0';
            END IF;
        END IF;
     -- draw sixth rock
    IF rock_on_screen(5) = '1' THEN 
            IF pixel_col >= rock6_x - r_size AND
            pixel_col <= rock6_x + r_size AND
                pixel_row >= rock6_y - r_size AND
                pixel_row <= rock6_y + r_size THEN
                   rock_on(5) <= '1';
            ELSE
                rock_on(5) <= '0';
            END IF;
        END IF;
    -- draw seventh rock
    IF rock_on_screen(6) = '1' THEN 
            IF pixel_col >= rock7_x - r_size AND
            pixel_col <= rock7_x + r_size AND
                pixel_row >= rock7_y - r_size AND
                pixel_row <= rock7_y + r_size THEN
                   rock_on(6) <= '1';
            ELSE
                rock_on(6) <= '0';
            END IF;
        END IF;
    -- draw eigth rock
    IF rock_on_screen(7) = '1' THEN 
            IF pixel_col >= rock8_x - r_size AND
            pixel_col <= rock8_x + r_size AND
                pixel_row >= rock8_y - r_size AND
                pixel_row <= rock8_y + r_size THEN
                   rock_on(7) <= '1';
            ELSE
                rock_on(7) <= '0';
            END IF;
        END IF;
    END PROCESS;
        
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
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
    
    randomizer: PROCESS IS
        VARIABLE rand : INTEGER;        
    BEGIN
        WAIT UNTIL (falling_edge(v_sync));
        rand := conv_integer(conv_std_logic_vector(counter, 11) XOR bat_x XOR pixel_row XOR pixel_col) mod 800 ;
        start_x <= conv_std_logic_vector(rand,11);
    END PROCESS;
END Behavioral;