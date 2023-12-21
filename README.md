# DSD-Final-Lab-Project : Evade
Group work for Digital System Design, VHDL Projects for Nexys A7-100T FPGAs using Vivado
![image](Game_Running.gif)

## Introduction
In _**Evade**_ you play as a 'car' whose horizontal position is controlled by a potentiometer. 
* **GOAL:** You must avoid obstacles as you accelerate down a road. 
* **SCORING:** The 7-segment display on the board increments based on the time spent until the player is hit. 
* **LOSING:** If the car gets hit by an obstacle, then the game will end.
* **INITIALIZING:** To start/restart the game, press the center button, _BTNC_, on the board.
  * Your score will be renewed and you will start at base speed

## Video of Game
[![WorkingProject](https://markdown-videos-api.jorgenkh.no/url?url=https%3A%2F%2Fyoutu.be%2FKA-9__TiZo8%3Fsi%3DHlSYueoIqooJYmKL)](https://youtu.be/KA-9__TiZo8?si=HlSYueoIqooJYmKL)

## Attachments needed: 
* [NI Digilent Nexys A7-100T FPGA Trainer Board](https://store.digilentinc.com/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/) 
* 5 k&Omega; Potentiometer
* 12-bit [analog-to-digital converter](https://en.wikipedia.org/wiki/Analog-to-digital_converter) (ADC)
  * [Pmod AD1](https://store.digilentinc.com/pmod-ad1-two-12-bit-a-d-inputs/) Connected to top pins of Pmod port JA (Section 10 of the [Reference Manual](https://reference.digilentinc.com/_media/reference/programmable-logic/nexys-a7/nexys-a7_rm.pdf))
![ad1](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/ed545e78-0733-40e7-aa92-60703d478cdd)
![knob](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/550d01d7-49ca-421a-8eb5-8dc8e1025038)
![potentiometer](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/bd074cfc-af65-4608-83c1-67b9f7131356)
![adc](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/afd477de-8d1b-43ec-8c98-96ecb9016d4c)

## How to Run
1. Create six new source files of file type VHDL called clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bat_n_ball, adc_if, counter, hexcalc, leddec, and pong
* Create a new constraint file of file type XDC called Evade
* Choose Nexys A7-100T board for the project
* Click 'Finish'
* Click design sources and copy the VHDL code from clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bat_n_ball, adc_if, counter, hexcalc, leddec, and pong
* Click constraints and copy the code from Evade.xdc

2. Run synthesis
3. Run implementation and open the implemented design
4. Generate bitstream, open hardware manager, and program device
Click 'Generate Bitstream'
Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
Click 'Program Device' then xc7a100t_0 to download pong.bit to the Nexys A7-100T board
Push BTNC to start the game

## Modifications
We built upon the code provided, and the portions we created, for Lab 6, the Pong game. Some major functionalities were swapped:
- When an object hits the car, instead of incrementing the score counter, it will end the game
- When an object reaches the bottom of the screen, instead of ending the game, it will respawn in a new location

From Lab 6, we also used our score display code with the 7-segment display **in Hexadecimal**. _Every frame, your score will increase by 1 but is displayed as a 'count' integer divided by 8 to keep numbers small._


We also created eight total obstacles instead of just one ball. These run off the original collision detection and framework of ball with the modified behaviors. Over time, the obstacles would also begin to travel more quickly, increasing the difficulty.


When implementing random respawns, we initially had an issue where the obstacles would respawn in similar areas and at similar intervals. 


To counter this, we used multiplication to add uniqueness to each spawn.

**Here is our VHDL object entity tree:**

![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/779deea3-a5a6-4c68-9a5f-ecb9fc0fb7c9)


### Core Changes
#### Call a Set of 8 Rocks
- Instantiate 8 Rocks with a uniform size and speed, but independent X and Y-Coordinates.
- Further, we made an STD_LOGIC_VECTOR 'rock_on_screen' which reads '1' on an index if that is on the screen, and '0' if the rock has reached the bottom of the screen.
- 'rock_on' is '1' at an index if the current pixel is looking at that rock, '0' if not.
- When respawning the rocks, we use start_x as a pseudo-random value defined in a process later.
  
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/9c019665-2c67-4cc6-8fcd-7eea6d16e4be)

#### Pixel Encoding -- The Multiple Rock Problem
- If a pixel is looking at any rock of the many, this becomes the equivalent logic for simple RGB values.

![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/c919065e-cc44-489b-8149-53cd352b94d6)

#### Rock-Car Collisions
##### **For each of the 8 rocks, there is almost identical code for the code below**
- Check for collisions with the car. If the rock is within the car's geometry, then the game turns off.
  
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/ea86322e-3d7d-492f-a5d0-d5010d016e89)

#### Rock-Wall Collisions
- Check for collisions with the bottom wall. If the rock hits the bottom wall, then turn 'rock_on_screen' to '0' for that rock.
  
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/b5458365-5acf-4a4a-b4ba-a90ac9751970)

#### Spawning
- If the game is running, and the rock is not on the screen, then spawn it in again at a random start_X.
 - If it's currently on screen, move it down according to the speed.
- **Each rock has a unique initial spawn delay according to the score, _count_, that needs to be exceeded.**
 - **In order to continuously generate obstacles, we used a formula involving multiple factors, including score, the current position of the car and the obstacle, a prime number identifier, and a mod division:**
  - Mod Division by 800 guarantees the position is in bounds from 0-800
  - The '*2' term isn't uniform, every rock has a unique multiplicative term to maintain randomness between rocks.
    
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/2096bc8c-c21b-48f8-9f88-63375488e316)

This formula chooses new positions for each obstacle when they reappear.

- Check to see if the corresponding rock is on screen by calculating if the pixel is in its geometry.
  
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/eef0ffc2-7cd1-439c-b064-1963e433dee0)

#### Random Positions
We had to get creative to generate pseudo-random numbers as a lot of resources online mention that package-based RNG systems don't synthesize well.
We found quite even spawn distributions when we XOR'd the current pixel row, pixel column, current bat position, and current score together for every falling edge of the clock cycle.
Falling Edges were used to change this number so that other modules could use it on the Rising Edge.

**Something of Note:** _**changes in the output between any two frames are likely to be similar so we added a unique multiple to each random position when each rock wanted to respawn.**_
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/f52a5b77-695d-4b96-b7e2-58a604f8d095)

## Process Summary

There were two very different parts of this project's development. 
Chris originally took a very different direction with the code, creating a thread for each obstacle, and a system that would enable and disable them. 

Below is the diagram representing this hypothetical system.
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/82727581/087b074c-05ce-4953-92c9-d6dcc68af912)

Unfortunately, due to complications with how VHDL handles and announces concurrency issues, we went back to a more simplified approach that ran more closely to the original Lab 6, Pong, code.

#### Successful Case
3 Processes in Bat_n_Ball: 
- randomizer
- rockdraw
- mrock

#
<p align="center">
  <img src="https://media.giphy.com/media/VekcnHOwOI5So/giphy.gif" alt="Cat Coding">
</p>
