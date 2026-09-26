# Timing Analysis

This report summarizes the post-implementation timing results of the RV-MAC FPGA design obtained using Xilinx Vivado.

## Target FPGA

- **FPGA:** Xilinx Artix-7
- **Device:** XC7A100T-1CSG324C
- **Target Frequency:** 100 MHz
- **Clock Period:** 10 ns

## Timing Summary

| Timing Metric | Result |
|---|---:|
| Clock Period | 10 ns |
| Target Frequency | 100 MHz |
| Worst Negative Slack (WNS) | +0.741 ns |
| Worst Hold Slack (WHS) | +0.148 ns |
| Total Negative Slack (TNS) | 0 ns |

## Timing Results

### Worst Negative Slack (WNS)

The design achieved a **WNS of +0.741 ns**.

A positive WNS indicates that the critical timing paths satisfy the setup-time requirement for the 100 MHz target clock.

### Worst Hold Slack (WHS)

The reported **WHS is +0.148 ns**.

The positive hold slack indicates that the implemented design satisfies the hold-time requirements.

### Total Negative Slack (TNS)

The reported **TNS is 0 ns**, indicating that there are no failing setup paths contributing negative total slack.

## Summary

The implemented RV-MAC design meets the **100 MHz timing target** with positive setup and hold slack.

The post-implementation timing results are:

- **WNS:** +0.741 ns
- **WHS:** +0.148 ns
- **TNS:** 0 ns
- **Operating Target:** 100 MHz
