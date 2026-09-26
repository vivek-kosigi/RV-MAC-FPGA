## ===============================================================
## XDC for rv_top_fpga on EDGE Artix-7 (XC7A35TFTG256-1)
## - Clock     : clk
## - Reset     : rst_n  (mapped to SW0, active-high)
## - LEDs      : led[2:0]
## - LCD       : lcd_rs, lcd_e, data[7:0]
## ===============================================================

# --------------- Clock ------------------------------------------
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports { clk }];

# --------------- Reset (use switch SW0) -------------------------
# Slide SW0 = '1'  -> rst_n = 1 (no reset)
# Slide SW0 = '0'  -> rst_n = 0 (reset active)
set_property -dict { PACKAGE_PIN L5 IOSTANDARD LVCMOS33 } [get_ports { rst_n }];

# --------------- LEDs (we only use led[0..2]) -------------------
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; # LED0
set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; # LED1
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; # LED2

# --------------- 2x16 LCD --------------------------------------
# From board XDC (8-bit data + RS + E, RW is tied to GND on board)

set_property -dict { PACKAGE_PIN P3 IOSTANDARD LVCMOS33 } [get_ports { data[7] }];
set_property -dict { PACKAGE_PIN M5 IOSTANDARD LVCMOS33 } [get_ports { data[6] }];
set_property -dict { PACKAGE_PIN N4 IOSTANDARD LVCMOS33 } [get_ports { data[5] }];
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports { data[4] }];
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports { data[3] }];
set_property -dict { PACKAGE_PIN R3 IOSTANDARD LVCMOS33 } [get_ports { data[2] }];
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports { data[1] }];
set_property -dict { PACKAGE_PIN T4 IOSTANDARD LVCMOS33 } [get_ports { data[0] }];

set_property -dict { PACKAGE_PIN T3 IOSTANDARD LVCMOS33 } [get_ports { lcd_e }];
set_property -dict { PACKAGE_PIN P5 IOSTANDARD LVCMOS33 } [get_ports { lcd_rs }];
