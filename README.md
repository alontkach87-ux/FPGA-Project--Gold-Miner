# FPGA Gold Miner - Enhanced Hardware Implementation

## Project Overview
A complex real-time hardware system implementing an enhanced version of the "Gold Miner" game. This project was developed in **SystemVerilog** and deployed on an **Intel Cyclone V FPGA**. Unlike the classic game, this version introduces randomized mechanics and strategic progression, all managed via hardware logic.

## Key Features & Hardware Integration
* **Graphics & Display:** Custom-built **VGA Controller** (640x480 resolution).
* **Audio Module:** Integrated sound effects for immersive gameplay.
* **Peripheral Support:** Full integration of a **Numeric Keypad** for game controls and a **PS/2 Keyboard**.
* **Advanced Mechanics:**
    * **Dynamic Bomb System:** Bombs are deployed at random time intervals with randomized explosion radii, implemented using hardware-based **PRNG** (Pseudo-Random Number Generation).
    * **Scoring System:** Real-time point calculation where players gain or lose points based on performance and bomb interactions.
    * **In-Game Shop:** A functional shop system allowing players to purchase upgrades and items to improve their success, managed via a dedicated **FSM** (Finite State Machine).
    * **Level Progression:** Multiple game levels with increasing difficulty and state management.

## Technical Skills Demonstrated
* RTL Design & Synthesis using **Quartus Prime**.
* Complex State Machine (FSM) design for game logic and shop transitions.
* Hardware-software synchronization for peripherals (Keypad, VGA, Audio).
* Timing analysis and hardware debugging using **SignalTap** and **ModelSim**.

## Project Collaboration
This project was a joint effort by **Alon Tkach** and **Yanay Nazimov**. 
It showcases our ability to design a multi-module hardware system and handle real-time synchronization in FPGA design.
