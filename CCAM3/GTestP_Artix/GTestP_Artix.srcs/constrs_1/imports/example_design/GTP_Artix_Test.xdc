
set_property -dict {IOSTANDARD LVCMOS18  PULLUP true  PACKAGE_PIN V13} [get_ports ALIGN_REQ_N_i]
set_property -dict {IOSTANDARD LVCMOS18  PULLUP true  PACKAGE_PIN P18} [get_ports CCAM_PLL_RESET_i]  

###################################################################################################

set_property PACKAGE_PIN B8 [get_ports REFCLK0_TX_P_i]
set_property PACKAGE_PIN A8 [get_ports REFCLK0_TX_N_i]

set_property PACKAGE_PIN D2 [get_ports TXP_o]
set_property PACKAGE_PIN D1 [get_ports TXN_o]

set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN N17} [get_ports CLK_IN_i]

################################################################################################### 

create_clock -period 10.000 [get_ports CLK_IN_i]
create_clock -period 8.000 [get_ports REFCLK0_TX_P_i]




