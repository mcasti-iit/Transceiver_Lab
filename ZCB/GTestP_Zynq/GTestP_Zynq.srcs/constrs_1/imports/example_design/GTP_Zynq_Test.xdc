

################################## Clock Constraints ##########################

create_clock -period 8.000 [get_ports Q0_CLK1_GTREFCLK_PAD_P_IN]



################################# RefClk Location constraints #####################

set_property PACKAGE_PIN U5 [get_ports Q0_CLK1_GTREFCLK_PAD_P_IN]
set_property PACKAGE_PIN V5 [get_ports Q0_CLK1_GTREFCLK_PAD_N_IN]

set_property PACKAGE_PIN AA9 [get_ports RXP_IN]
set_property PACKAGE_PIN AB9 [get_ports RXN_IN]

################################# Other Location constraints #####################
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports TRACK_DATA_OUT]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports AD9517_PD_N]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports AD9517_SYNC_N]
# The AD9517_RESET_N is on TP7 because of the TE0715 doesn't connect the JM2.29
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports AD9517_RESET_N]


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

################################# mgt wrapper constraints #####################



