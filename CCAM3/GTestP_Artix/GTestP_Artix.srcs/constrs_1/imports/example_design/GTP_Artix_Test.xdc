


create_clock -period 8.000 [get_ports Q0_CLK0_GTREFCLK_PAD_P_IN]

################################# RefClk Location constraints #####################

set_property PACKAGE_PIN B8 [get_ports Q0_CLK0_GTREFCLK_PAD_P_IN]
set_property PACKAGE_PIN A8 [get_ports Q0_CLK0_GTREFCLK_PAD_N_IN]

set_property PACKAGE_PIN D2 [get_ports TXP_OUT]
set_property PACKAGE_PIN D1 [get_ports TXN_OUT]


## LOC constrain for MAIN_CLK
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN N17} [get_ports CLK_IN]
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN V13} [get_ports CLK_MON]

################################# mgt wrapper constraints #####################




