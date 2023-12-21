# DSD-Final-Lab-Project
Group work for Digital System Design, VHDL Projects for Nexys A7-100T FPGAs using Vivado

## Introduction
This project creates a game in which a car object, whose horizontal position is controlled by a potentiometer, must avoid obstacles as it speeds down a road. When the car passes an obstacle, the 7-segment display will show a score that increases by 1. If the car gets hit by an obstacle, then the game will end. To restart the game, press the center button on the board.
Attachments needed: Potentiometer
### (get images of potentiometer and attachments)
### (video of code and game working)

## How to run
### (update this step with our new file names)
1. Create six new source files of file type VHDL called clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bat_n_ball, adc_if, and pong
- Create a new constraint file of file type XDC called pong
- Choose Nexys A7-100T board for the project
- Click 'Finish'
- Click design sources and copy the VHDL code from clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync.vhd, bat_n_ball.vhd, adc_if.vhd, pong.vhd
- Click constraints and copy the code from pong.xdc
2. Run synthesis
3. Run implementation and open implemented design
4. Generate bitstream, open hardware manager, and program device
Click 'Generate Bitstream'
Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
Click 'Program Device' then xc7a100t_0 to download pong.bit to the Nexys A7-100T board
Push BTNC to start the bouncing ball and use the bat to keep the ball in play

## Modifications
We built upon the code provided, and the portions we created, for Lab 6, the Pong game. Some major functionalities were swapped:
- When an object hits the car, instead of incrementing the score counter, it will end the game
- When an object reaches the bottom of the screen, instead of ending the game, it will increment the score counter
From Lab 6, we also used our score display code with the 7-segment display.
We also created eight total obstacles instead of just one ball, which run off the original collision detection and framework, and have the modified behaviors.
In order to continuously generate obstacles, whenever one reaches the bottom of the screen, random number generation was used to change:
- How long it would take to reappear
- The horizontal position it would respawn at

## Process Summary
The majority of programming was done by Christopher and Owen, and Alex's original github push included the ideas for how and where the new functionalities would be implemented, and writing the Github readme file reprot.
There were two very different parts of this project's development. Chris originally took a very different direction with the code, creating a thread for each obstacle, and a system that would enable and disable them. Unfortunately, due to unfindable issues, we went back to a more simplified approach that ran more closely to the original Lab 6 code.
