# RTL Design

This directory contains the synthesizable Verilog RTL for the RV-MAC FPGA
implementation.

## Design Files

### 1. `rv_top_all.v`

Main RTL design containing the core hardware blocks of the RV-MAC system,
including:

- 32-bit RISC-V processor
- Five-stage pipeline
- Instruction memory
- Register file
- ALU
- MAC accelerator
- Perceptron accelerator
- LED output logic
- LCD interface/controller

The processor follows the pipeline structure:

```text
IF → ID → EX → MEM → WB
```

### 2. `rv_top_fpga.v`

Top-level FPGA wrapper for the RV-MAC design.

This module provides the FPGA-level I/O interface and connects the main
`rv_top_all` design to the physical FPGA pins.

### FPGA I/O

| Signal      | Description         |
| ----------- | ------------------- |
| `clk`       | System clock        |
| `rst_n`     | Active-low reset    |
| `led[2:0]`  | LED outputs         |
| `lcd_rs`    | LCD Register Select |
| `lcd_e`     | LCD Enable          |
| `data[7:0]` | 8-bit LCD data bus  |

## RTL Hierarchy

```text
rv_top_fpga
      │
      ▼
  rv_top_all
      │
      ├── RISC-V Processor
      │     ├── Instruction Memory
      │     ├── Register File
      │     ├── ALU
      │     └── Pipeline Stages
      │
      ├── MAC Accelerator
      │
      ├── Perceptron Accelerator
      │
      └── LED / LCD Interface
```

## Implementation

The RTL is intended for synthesis and implementation using **Xilinx Vivado**
on the target Artix-7 FPGA platform.

The corresponding FPGA pin and clock constraints are available in the
[`Constraints`](../Constraints/) directory.


