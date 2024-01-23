EE354 Final Project: Ocean Blues

Team Members:

- Carrie Lei (cnlei@usc.edu)
- Lynn Nguyen (lynnnguy@usc.edu)

Background: 

Being students who love spending our time in nature -- especially in the ocean -- we wanted to create a game that combined our skills in electrical engineering and our passions beyond academia. The objective is for the diver to collect all the plastic pieces while avoiding dangerous encounters, ultimately bringing to light the importance of keeping our waters plastic-free and safe for marine habitation. 

# Block Controller Module Readme

This Verilog module, named `block_controller`, is designed to control the behavior of a block in a graphical display. The block can move within the display, encountering various objects, and responding to user inputs. Below is an overview of the key features and functionality of the module.

## Module Inputs
- **clk:** Clock signal for the module.
- **clk25:** Clock signal operating at 25 Hz.
- **bright:** Brightness control signal for display.
- **rst:** Reset signal.
- **up, down, left, right:** User input signals for block movement.
- **hCount, vCount:** Horizontal and vertical counters for display synchronization.

## Module Outputs
- **rgb:** Output representing the color of the block.
- **background:** Output representing the background color.

## States
The module operates in different states, and each state corresponds to a specific behavior of the block. The states are defined as follows:
- **IDLE:** Block is idle and waiting for user input.
- **UP:** Block is moving up.
- **DN:** Block is moving down.
- **DEAD:** Block encounters a collision and is in a dead state.
- **GAME_OVER:** Game over state.

## Collision Detection
The module includes collision detection logic for the block interacting with various objects, such as sharks and bottles. The collisions trigger state transitions, affecting the block's behavior.

## Handshake Mechanism
The module implements a handshake mechanism using signals like `sharkACK` and `bottleACK` to handle collisions and ensure proper synchronization.

## Initialization
The initial positions of the block, sharks, and bottles, as well as other parameters, are set during the initialization phase or when the reset signal is asserted.

## User Inputs
The block responds to user inputs (up, down) to move within the display. The game continues until a specific condition, such as encountering a game-over scenario.

## Background Color
The background color changes based on the block's state, providing visual feedback to the user about the game's progress.

## Game Over and Dead States
The module transitions to the "Game Over" state when specific conditions are met, signaling the end of the game. The "Dead" state is entered when the block encounters a collision.

# Display Controller Module Readme

This Verilog module, named `display_controller`, is responsible for generating horizontal and vertical synchronization signals (`hSync` and `vSync`) for a display system. Additionally, it includes logic for brightness control (`bright`) based on specific screen regions. Below is an overview of the key features and functionality of the module.

## Module Inputs
- **clk:** Clock signal for the module.

## Module Outputs
- **hSync:** Horizontal synchronization signal.
- **vSync:** Vertical synchronization signal.
- **bright:** Brightness control signal for display.
- **hCount:** Horizontal counter representing the pixel position in a line.
- **vCount:** Vertical counter representing the current line number.

## Clock Division
The module includes logic to divide the incoming clock signal (`clk`) to generate a secondary clock signal (`clk25`). This divided clock is used for timing purposes in the module.

## Counters
The module maintains two counters: 
- **Horizontal Counter (`hCount`):** Represents the pixel position in a line. It resets at the end of each line.
- **Vertical Counter (`vCount`):** Represents the current line number. It resets at the end of each frame.

## Synchronization Signals
The `hSync` and `vSync` signals are generated based on the counters. 
- `hSync` is asserted during the horizontal blanking period.
- `vSync` is asserted during the vertical blanking period.

## Brightness Control
The `bright` signal is controlled based on the pixel position, and it is set to 1 when the pixel is within a specified region on the screen, indicating a brighter area.

## Initialization
The initial values of the clock-related signals (`clk25` and `pulse`) are set to 0 during the initialization phase.

## Screen Regions
The module defines specific regions on the screen where brightness is adjusted. In this case, the brightness is increased when the pixel position is within the region defined by the conditions `(hCount > 143 && hCount < 784 && vCount > 34 && vCount < 516)`.
