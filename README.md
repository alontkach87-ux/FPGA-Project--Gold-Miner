# FPGA Gold Miner - Enhanced Hardware Implementation

## Project Overview
An advanced real-time hardware system developed in **SystemVerilog** for the **Intel Cyclone V FPGA**. This project features a unique version of the classic "Gold Miner" game, integrating complex logic, audio, and multiple hardware peripherals.

## System Demonstration

### 🎥 Video Demos (Click to Watch)
| High-Quality Gameplay | Hardware & FPGA Setup |
| :---: | :---: |
| [![Gameplay Demo](https://img.youtube.com/vi/GWm8fjphKTI/0.jpg)](https://www.youtube.com/watch?v=GWm8fjphKTI) | [![Hardware Demo](https://img.youtube.com/vi/71o0hPUbj3Q/0.jpg)](https://www.youtube.com/watch?v=71o0hPUbj3Q) |

### 🛠️ Collaboration & Hardware Lab
<table style="width:100%">
  <tr>
    <th style="text-align:center">Team Work (Alon & Yanay)</th>
    <th style="text-align:center">Alon Tkach - Hardware Setup</th>
  </tr>
  <tr>
    <td><img src="./media/Team_FPGA_Setup.jpg" width="400"></td>
    <td><img src="./media/AlonTkach_FPGA_Project.jpg" width="400"></td>
  </tr>
</table>

## Key Features & Hardware Integration
* **Graphics & Display:** Custom-built **VGA Controller** (640x480 resolution).
* **Peripheral Support:** Full integration of a **Numeric Keypad** and keyboard interface.
* **Audio Module:** Integrated sound effects for immersive gameplay.
* **Advanced Mechanics:**
    * **Dynamic Bomb System:** Bombs deployed at random intervals with randomized explosion radii (Hardware-based **PRNG**).
    * **In-Game Shop:** Functional shop system for upgrades, managed via a dedicated **FSM** (Finite State Machine).
    * **Level Progression:** Multiple game levels with increasing difficulty.

## Technical Skills
* RTL Design & Synthesis using **Quartus Prime**.
* Complex State Machine (FSM) design and hardware-software synchronization.
* Timing analysis and debugging using **SignalTap** and **ModelSim**.

## Project Collaboration
This project was a joint effort by **Alon Tkach** and **Yanay Nazimov**. 
It showcases our ability to design a multi-module hardware system and handle real-time synchronization in FPGA design.
