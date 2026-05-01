## ============================================================
## Nexys A7 - Edge Detection 128x128 Constraints
## Target Device : xc7a100tcsg324-1
## All I/O Standard: LVCMOS33 (3.3V - matches Nexys A7 banks)
## ============================================================

## ---- 100 MHz System Clock ----
set_property PACKAGE_PIN E3       [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33  [get_ports CLK100MHZ]
create_clock -add -name sys_clk_pin -period 10.00 \
             -waveform {0 5}      [get_ports CLK100MHZ]

## ---- CPU Reset Button (active LOW on Nexys A7) ----
set_property PACKAGE_PIN C12      [get_ports CPU_RESETN]
set_property IOSTANDARD LVCMOS33  [get_ports CPU_RESETN]

## ---- Status LED (LD0 - ON when processing complete) ----
set_property PACKAGE_PIN H17      [get_ports LED]
set_property IOSTANDARD LVCMOS33  [get_ports LED]

## ---- VGA Red [3:0] ----
set_property PACKAGE_PIN A3       [get_ports {VGA_R[0]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_R[0]}]

set_property PACKAGE_PIN B4       [get_ports {VGA_R[1]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_R[1]}]

set_property PACKAGE_PIN C5       [get_ports {VGA_R[2]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_R[2]}]

set_property PACKAGE_PIN A4       [get_ports {VGA_R[3]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_R[3]}]

## ---- VGA Green [3:0] ----
set_property PACKAGE_PIN C6       [get_ports {VGA_G[0]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_G[0]}]

set_property PACKAGE_PIN A5       [get_ports {VGA_G[1]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_G[1]}]

set_property PACKAGE_PIN B6       [get_ports {VGA_G[2]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_G[2]}]

set_property PACKAGE_PIN A6       [get_ports {VGA_G[3]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_G[3]}]

## ---- VGA Blue [3:0] ----
set_property PACKAGE_PIN B7       [get_ports {VGA_B[0]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_B[0]}]

set_property PACKAGE_PIN C7       [get_ports {VGA_B[1]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_B[1]}]

set_property PACKAGE_PIN D7       [get_ports {VGA_B[2]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_B[2]}]

set_property PACKAGE_PIN D8       [get_ports {VGA_B[3]}]
set_property IOSTANDARD LVCMOS33  [get_ports {VGA_B[3]}]

## ---- VGA Sync Signals ----
set_property PACKAGE_PIN B11      [get_ports VGA_HS]
set_property IOSTANDARD LVCMOS33  [get_ports VGA_HS]

set_property PACKAGE_PIN B12      [get_ports VGA_VS]
set_property IOSTANDARD LVCMOS33  [get_ports VGA_VS]