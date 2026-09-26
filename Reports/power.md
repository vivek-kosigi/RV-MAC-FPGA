# Power Analysis

This report summarizes the estimated power consumption of the RV-MAC FPGA implementation using Xilinx Vivado.

## Target FPGA

- **FPGA:** Xilinx Artix-7
- **Device:** XC7A100T-1CSG324C
- **Tool:** Xilinx Vivado

## Power Summary

| Power Component | Power |
|---|---:|
| Static Power | 0.068 W |
| Dynamic Power | 0.003 W |
| **Total Power** | **0.071 W** |

## Static Power

The estimated static power consumption is **0.068 W**.

Static power represents the power consumed by the FPGA device independent of switching activity.

## Dynamic Power

The estimated dynamic power consumption is **0.003 W**.

Dynamic power is associated with switching activity within the implemented design, including the processor datapath, pipeline logic, MAC/perceptron accelerators, and interface logic.

## Total Power

The estimated total power consumption is:

**0.071 W (71 mW)**

This value represents the combined static and dynamic power reported for the implemented RV-MAC design.

## Summary

The power analysis indicates a total estimated power consumption of **71 mW** for the RV-MAC implementation on the target Artix-7 FPGA.

The detailed power values are based on the Vivado power analysis of the implemented design.
