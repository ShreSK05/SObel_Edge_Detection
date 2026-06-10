# Pipelined Sobel Edge Detection Engine

## Overview

This project implements a high-throughput **Sobel Edge Detection Engine** on FPGA using Verilog HDL. The design is optimized for real-time image processing through a multi-stage pipelined architecture, enabling efficient edge extraction from VGA-resolution video streams.

The implementation targets the Nexys A7 FPGA platform and was developed using Xilinx Vivado. By combining BRAM-based line buffering, parallel convolution units, and RTL pipelining, the design achieves real-time performance while maintaining efficient hardware utilization.

---

## Features

* Real-time Sobel edge detection
* Fully pipelined RTL architecture
* FPGA implementation using Verilog HDL
* BRAM-based image line buffering
* Parallel gradient computation (Gx and Gy)
* Resource-optimized datapath design
* VGA-resolution image support
* Real-time 60 FPS processing capability

---

## System Architecture

The design consists of four major pipeline stages:

### Stage 1: Pixel Acquisition & Line Buffering

* Receives incoming pixel stream.
* Stores image rows using FPGA BRAM.
* Generates 3×3 pixel windows required for convolution.

### Stage 2: Gradient Computation

* Parallel Sobel convolution for:

  * Horizontal Gradient (Gx)
  * Vertical Gradient (Gy)
* Computes edge intensity information.

### Stage 3: Magnitude Processing

* Combines Gx and Gy results.
* Generates edge strength values.
* Implements pipelined arithmetic for timing closure.

### Stage 4: Output Controller

* Synchronizes processed output stream.
* Maintains frame timing.
* Produces edge-detected video output.

---

## Technical Specifications

| Parameter                | Value         |
| ------------------------ | ------------- |
| Language                 | Verilog HDL   |
| FPGA Board               | Nexys A7      |
| Toolchain                | Xilinx Vivado |
| Resolution               | 640 × 480     |
| Pipeline Depth           | 4 Stages      |
| Pixel Clock              | 25 MHz        |
| Throughput               | 60 FPS        |
| Maximum Frequency (Fmax) | 100 MHz       |
| Timing Slack             | +2.3 ns       |

---

## Hardware Optimizations

### BRAM-Based Line Buffering

* Efficient storage of image rows.
* Reduces external memory accesses.
* Supports continuous pixel streaming.

### Parallel Convolution Units

* Simultaneous computation of Gx and Gy.
* Improves throughput and latency.

### Shared Arithmetic Resources

* Shared adder-subtractor structures.
* Reduced logic utilization.
* Approximately 30% lower combinational resource usage.

### Pipelined MAC Architecture

* Improved timing performance.
* Higher achievable clock frequencies.
* Stable operation at target frame rates.

---

## Performance Results

### Achievements

✅ Real-time edge detection on VGA-resolution frames

✅ 60 FPS processing throughput

✅ 100 MHz maximum operating frequency

✅ +2.3 ns positive timing slack

✅ 30% reduction in combinational resource utilization

✅ Fully pipelined RTL implementation

✅ Accurate edge detection across multiple test images

---

## Sobel Operator

The Sobel filter calculates image gradients using two convolution kernels:

### Horizontal Kernel (Gx)

```text
-1  0  +1
-2  0  +2
-1  0  +1
```

### Vertical Kernel (Gy)

```text
+1  +2  +1
 0   0   0
-1  -2  -1
```

Edge magnitude is computed using the horizontal and vertical gradients to highlight image boundaries.

---

## Verification

The design was verified through:

* RTL simulation
* Functional verification
* Timing analysis in Vivado
* FPGA implementation testing
* Multiple image test cases

---

## Applications

* Computer Vision
* Real-Time Video Processing
* Robotics
* Autonomous Systems
* Industrial Inspection
* Object Detection Preprocessing
* Embedded Vision Systems

---

## Future Improvements

* Canny Edge Detection Accelerator
* RGB Image Processing Support
* High-Definition (HD) Resolution Support
* AXI Stream Integration
* DMA-Based Image Transfer
* CNN Preprocessing Accelerator
* Hardware-Software Co-Design on SoC Platforms

---
