# Resource Utilization

This report summarizes the FPGA resource utilization of the RV-MAC design after synthesis and implementation using Xilinx Vivado.

## Target FPGA

- **FPGA:** Xilinx Artix-7
- **Device:** XC7A100T-1CSG324C
- **Tool:** Xilinx Vivado

## Utilization Summary

| Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| LUTs | 2,300 | 63,400 | 3.60% |
| Flip-Flops (FFs) | 2,000 | 126,800 | 1.57% |
| DSP48E1 | 24 | 240 | 10.00% |
| Block RAM (BRAM) | 2 | 135 | 1.48% |

## Resource Breakdown

### LUTs

The design uses **2,300 LUTs**, corresponding to approximately **3.60%** of the available LUT resources on the target Artix-7 device.

LUTs are primarily used for:

- RISC-V processor control and datapath logic
- ALU operations
- Pipeline control
- Register and instruction handling
- MAC/perceptron control logic
- FPGA interface logic

### Flip-Flops

The design uses approximately **2,000 flip-flops**, representing **1.57%** of the available registers.

These registers are used throughout the pipelined processor and for sequential control and interface logic.

### DSP48E1

The design uses **24 DSP48E1 slices**, corresponding to **10%** of the available DSP resources.

The DSP resources are utilized primarily for the arithmetic operations associated with the MAC accelerator.

### Block RAM

The implementation uses **2 BRAM blocks**, representing approximately **1.48%** of the available Block RAM resources.

## Summary

The RV-MAC implementation occupies a relatively small portion of the available FPGA resources while integrating the 32-bit RISC-V processor, MAC accelerator, perceptron accelerator, and FPGA interface logic.

The complete synthesis and implementation reports can be generated from the Vivado project for further analysis.
