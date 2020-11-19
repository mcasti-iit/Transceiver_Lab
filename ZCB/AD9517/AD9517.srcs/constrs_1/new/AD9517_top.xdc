
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports CLK_125]
set_property -dict {PACKAGE_PIN U9} [get_ports GTREFCLK0P]
set_property -dict {PACKAGE_PIN V9} [get_ports GTREFCLK0N]
set_property -dict {PACKAGE_PIN U5} [get_ports GTREFCLK1P]
set_property -dict {PACKAGE_PIN V5} [get_ports GTREFCLK1N]

set_property -dict {PACKAGE_PIN L5  IOSTANDARD LVCMOS33} [get_ports AD9517_PD_N]
set_property -dict {PACKAGE_PIN L4  IOSTANDARD LVCMOS33} [get_ports AD9517_SYNC_N]
# The AD9517_RESET_N is on TP7 because of the TE0715 doesn't connect the JM2.29
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports AD9517_RESET_N]
set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [get_ports AD9517_SCLK]
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports AD9517_SDIO]
set_property -dict {PACKAGE_PIN K5  IOSTANDARD LVCMOS33} [get_ports AD9517_CS_N]
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports AD9517_SDO]
set_property -dict {PACKAGE_PIN K3  IOSTANDARD LVCMOS33} [get_ports AD9517_STATUS]
set_property -dict {PACKAGE_PIN K4  IOSTANDARD LVCMOS33} [get_ports AD9517_REFMON]

# Led red
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {LEDS[4]}]
# Led Green
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33} [get_ports {LEDS[3]}]
# Led Blue
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {LEDS[2]}]
# Phy Led 1
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {LEDS[1]}]
# Phy Led 2
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {LEDS[0]}]


set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {EN_GTP_OSC}]


set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_ps]



