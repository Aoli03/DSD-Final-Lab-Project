# DSD-Final-Lab-Project : Evade
Group work for Digital System Design, VHDL Projects for Nexys A7-100T FPGAs using Vivado

## Introduction
This project creates a game in which a car object, whose horizontal position is controlled by a potentiometer, must avoid obstacles as it speeds down a road. The 7-segment display on the board increments based on the time spent until the player is hit. If the car gets hit by an obstacle, then the game will end. To restart the game, press the center button on the board.
Attachments needed: Potentiometer
* Reforged the FPGA code developed in Lab 6 (PONG) to build a new game called **_Evade_** game using a 5k&Omega; potentiometer with a 12-bit [analog-to-digital converter](https://en.wikipedia.org/wiki/Analog-to-digital_converter) (ADC) called [Pmod AD1](https://store.digilentinc.com/pmod-ad1-two-12-bit-a-d-inputs/) connected to the top pins of the Pmod port JA (See Section 10 of the [Reference Manual](https://reference.digilentinc.com/_media/reference/programmable-logic/nexys-a7/nexys-a7_rm.pdf))
* 
![ad1](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/ed545e78-0733-40e7-aa92-60703d478cdd)
![knob](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/550d01d7-49ca-421a-8eb5-8dc8e1025038)
![potentiometer](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/bd074cfc-af65-4608-83c1-67b9f7131356)
![adc](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/afd477de-8d1b-43ec-8c98-96ecb9016d4c)
## (Video of Game Working)
[![WorkingProject](https://markdown-videos-api.jorgenkh.no/url?url=https%3A%2F%2Fyoutu.be%2FKA-9__TiZo8%3Fsi%3DHlSYueoIqooJYmKL)](https://youtu.be/KA-9__TiZo8?si=HlSYueoIqooJYmKL)

## How to run
1. Create six new source files of file type VHDL called clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bat_n_ball, adc_if, and pong
- Create a new constraint file of file type XDC called pong
- Choose Nexys A7-100T board for the project
- Click 'Finish'
- Click design sources and copy the VHDL code from clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync.vhd, bat_n_ball.vhd, adc_if.vhd, pong.vhd
- Click constraints and copy the code from pong.xdc
2. Run synthesis
3. Run implementation and open the implemented design
4. Generate bitstream, open hardware manager, and program device
Click 'Generate Bitstream'
Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
Click 'Program Device' then xc7a100t_0 to download pong.bit to the Nexys A7-100T board
Push BTNC to start the bouncing ball and use the bat to keep the ball in play

## Modifications
We built upon the code provided, and the portions we created, for Lab 6, the Pong game. Some major functionalities were swapped:
- When an object hits the car, instead of incrementing the score counter, it will end the game
- When an object reaches the bottom of the screen, instead of ending the game, it will respawn in a new location

From Lab 6, we also used our score display code with the 7-segment display.
We also created eight total obstacles instead of just one ball, which run off the original collision detection and framework, and have the modified behaviors. Over time, the obstacles would also begin to travel more quickly, increasing the difficulty over time.

In order to continuously generate obstacles, we used a formula involving multiple factors, including score, the current position of the car and the obstacle, a prime number identifier, and a mod division:
![image](https://github.com/Aoli03/DSD-Final-Lab-Project/assets/98103091/6a174626-a31d-4507-95e5-4e58a3f4c471)
This formula chooses new positions for each obstacle when they reappear.


## Process Summary
Christopher and Owen did the majority of the programming, Alex's work was on the original GitHub push highlighting ideas for how and where the new functionalities would be implemented and writing ReadMe file for the Repo.
There were two very different parts of this project's development. Chris originally took a very different direction with the code, creating a thread for each obstacle, and a system that would enable and disable them. Unfortunately, due to complications with how VHDL handles and announces concurrency issues, we went back to a more simplified approach that ran more closely to the original Lab 6, Pong, code.

When implementing the random respawns, we initially had an issue where the obstacles would respawn in similar areas and at similar intervals. To counter this, Owen used prime number multiplication to add uniqueness to each spawn.
