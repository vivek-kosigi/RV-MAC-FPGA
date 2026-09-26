# RV-MAC-FPGA

## 32-bit RISC-V Processor with MAC and Perceptron Accelerators

FPGA implementation of a lightweight 32-bit RISC-V processor integrated with
Multiply-Accumulate (MAC) and single-layer perceptron accelerator blocks.

The design was developed in synthesizable Verilog HDL and implemented on a
Xilinx Artix-7 FPGA using the Vivado design flow. The project covers RTL
design, functional simulation, synthesis, implementation, timing analysis,
power estimation, bitstream generation, and physical FPGA validation.

---

## 📌 Project Overview

The objective of this project is to explore lightweight hardware acceleration
for MAC-based computation and perceptron inference by integrating accelerator
logic with a five-stage RISC-V processor datapath.

The processor uses the following pipeline:

**IF → ID → EX → MEM → WB**

The MAC and perceptron blocks are connected to the processor datapath and the
final results are presented through LEDs and a 16×2 LCD interface on the FPGA
development board.

---

## 🏗️ Architecture

![System Architecture](Results/block%20diagram.png)

The system consists of:

- 32-bit RISC-V processor
- Five-stage pipeline
- Instruction memory
- Register file
- ALU
- MAC accelerator
- Perceptron accelerator
- LED output interface
- HD44780-compatible 16×2 LCD controller

The processor implements a lightweight RISC-V instruction subset including
arithmetic and logical operations together with multiplication support.

---

## 🔄 Design Flow

```text
                    Verilog RTL
                         │
                         ▼
                 Functional Simulation
                         │
                         ▼
                     Synthesis
                         │
                         ▼
                   Implementation
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
       Timing Analysis        Power Analysis
              │                     │
              └──────────┬──────────┘
                         ▼
                  Bitstream Generation
                         │
                         ▼
                  FPGA Programming
                         │
                         ▼
                Hardware Validation
                         │
                    ┌────┴────┐
                    ▼         ▼
                   LEDs      LCD
