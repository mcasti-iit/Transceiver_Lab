
set_property -dict {IOSTANDARD LVCMOS18  PULLUP true  PACKAGE_PIN V13} [get_ports ALIGN_REQ_N_i]
# set_property -dict {IOSTANDARD LVCMOS18  PULLUP true  PACKAGE_PIN P18} [get_ports i2c_slave_scl_io]


################################# 

create_clock -period 8.000 [get_ports Q0_CLK0_GTREFCLK_PAD_P_IN]

################################# RefClk Location constraints #####################

set_property PACKAGE_PIN B8 [get_ports REFCLK0_P_i]
set_property PACKAGE_PIN A8 [get_ports REFCLK0_N_i]

set_property PACKAGE_PIN D2 [get_ports TXP_o]
set_property PACKAGE_PIN D1 [get_ports TXN_o]


## LOC constrain for MAIN_CLK
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN N17} [get_ports CLK_IN_i]
create_clock -period 10.000 [get_ports CLK_IN_i]
################################# mgt wrapper constraints #####################




