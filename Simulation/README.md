
# Simulation

This directory contains the Verilog testbench used for functional verification
of the RV-MAC FPGA design.

## Testbench

### `tb_stageb.v`

The testbench instantiates the RV-MAC design and provides the simulation
environment required to verify the processor and accelerator operation.

It includes:

- Clock generation
- Reset generation
- Device Under Test (DUT) instantiation
- Pipeline-stage monitoring
- ALU operation monitoring
- MAC output monitoring
- Perceptron output monitoring
- LED output monitoring
- Cycle-by-cycle console output
- Final MAC and perceptron result reporting

## Monitored Pipeline

The testbench monitors the five processor pipeline stages:

```text
IF → ID → EX → MEM → WB
````

The simulation also monitors the accelerator outputs:

```text
RISC-V Pipeline
      │
      ├── ALU
      │
      ├── MAC
      │
      └── Perceptron
```

## Console Verification

During simulation, the testbench prints cycle-level information including:

* Current cycle
* Decoded operation
* ALU output
* Pipeline-stage values
* MAC output
* Perceptron output
* LED status

The simulation output is used to verify the expected operation of the
processor pipeline and accelerator blocks.

## Simulation Results

The generated waveform and console output are available in the
[`Results`](../Results/) directory.

* [Simulation Waveform](../Results/waveform.png)
* [Console Output](../Results/console_output.png)

## Simulation Tool

The testbench is intended to be executed using **Xilinx Vivado Simulator
(XSim)** with the RV-MAC RTL files from the [`RTL`](../RTL/) directory.


