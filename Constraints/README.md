# FPGA Constraints

This directory contains the Xilinx Design Constraints (XDC) file used for
FPGA synthesis, implementation, and timing analysis of the RV-MAC design.

## Constraint File

### `rv_top.xdc`

The XDC file defines the physical FPGA pin assignments and timing constraints
for the top-level FPGA design.

### Clock Constraint

The system clock is constrained to a **10 ns period**, corresponding to a
target frequency of **100 MHz**.

```text
Clock Period    : 10 ns
Target Frequency: 100 MHz
```

FPGA I/O Constraints

The XDC file provides pin assignments for:

System clock
Active-low reset input
3-bit LED output
8-bit LCD data bus
LCD Register Select (lcd_rs)
LCD Enable (lcd_e)

The LCD interface uses an 8-bit data connection along with the RS and Enable
control signals.

### Interface

                    FPGA
                     │
        ┌────────────┼────────────┐
        │            │            │
       Clock        Reset        Outputs
                                  │
                         ┌────────┴────────┐
                         │                 │
                       LEDs               LCD
                      [2:0]          DATA[7:0]
                                      RS / E
### Target Platform

The constraints are intended for the Xilinx Artix-7 XC7A100T-1CSG324C
FPGA platform used for the RV-MAC implementation.

### Usage

Add rv_top.xdc to the Vivado project together with the RTL files from the
RTL directory before synthesis and implementation.

The clock constraint is also used for static timing analysis of the
implemented design.
