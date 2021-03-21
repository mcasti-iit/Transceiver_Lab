###################################################################################################

# set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33 PULLUP true} [get_ports LCAM_SDA_io];   # FPGA_L_Slave_CSn - J1.55
# set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33 PULLUP true} [get_ports LCAM_SCL_io];   # FPGA_L_Slave_SCK - J1.61
set_property PACKAGE_PIN V14 [get_ports ALIGN_REQUEST_o]
set_property IOSTANDARD LVCMOS33 [get_ports ALIGN_REQUEST_o]
set_property PULLUP true [get_ports ALIGN_REQUEST_o]
set_property PACKAGE_PIN R17 [get_ports CCAM_PLL_RESET_o]
set_property IOSTANDARD LVCMOS33 [get_ports CCAM_PLL_RESET_o]
set_property PULLUP true [get_ports CCAM_PLL_RESET_o]


###################################################################################################

create_clock -period 8.000 [get_ports REFCLK0_RX_P_i]
create_clock -period 8.000 [get_ports REFCLK1_RX_P_i]

###################################################################################################

set_property PACKAGE_PIN U9 [get_ports REFCLK0_RX_P_i]
set_property PACKAGE_PIN V9 [get_ports REFCLK0_RX_N_i]

set_property PACKAGE_PIN U5 [get_ports REFCLK1_RX_P_i]
set_property PACKAGE_PIN V5 [get_ports REFCLK1_RX_N_i]


set_property PACKAGE_PIN AB9 [get_ports RXN_i]
set_property PACKAGE_PIN AA9 [get_ports RXP_i]
set_property PACKAGE_PIN AB5 [get_ports TXN_o]
set_property PACKAGE_PIN AA5 [get_ports TXP_o]

###################################################################################################

## -------------------------------------------------------------------------------
## AD9517

set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports AD9517_PD_N_o]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports AD9517_SYNC_N_o]
# The AD9517_RESET_N is on TP7 because of the TE0715 doesn't connect the JM2.29
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports AD9517_RESET_N_o]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports AD9517_SCLK_o]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports AD9517_SDIO_io]
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports AD9517_CS_N_o]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports AD9517_SDO_i]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports AD9517_STATUS_i]
set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports AD9517_REFMON_i]

set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports EN_GTP_OSC_o]

## -------------------------------------------------------------------------------
## LEDS
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {LEDS_o[4]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33} [get_ports {LEDS_o[3]}]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {LEDS_o[2]}]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {LEDS_o[1]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {LEDS_o[0]}]

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]

connect_debug_port dbg_hub/clk [get_nets gckrx]

set_false_path -from [get_pins GTP_RX_Manager_i/gtp_pll_alarm_reg/C] -to [get_pins GTP_RX_Manager_i/TIME_MACHINE_GCK_i/p_rst_n_reg/CLR]
set_false_path -from [get_pins GTP_RX_Manager_i/gtp_pll_alarm_reg/C] -to [get_pins GTP_RX_Manager_i/TIME_MACHINE_GCK_i/p_rst_n_reg/CLR]
set_false_path -from [get_pins GTP_RX_Manager_i/gtp_pll_alarm_reg/C] -to [get_pins GTP_RX_Manager_i/TIME_MACHINE_GCK_i/pp_rst_n_reg/CLR]
set_false_path -from [get_pins GTP_RX_Manager_i/gtp_pll_alarm_reg/C] -to [get_pins GTP_RX_Manager_i/TIME_MACHINE_GCK_i/pp_rst_reg/PRE]
set_false_path -from [get_pins GTP_RX_Manager_i/gtp_pll_alarm_reg/C] -to [get_pins GTP_RX_Manager_i/TIME_MACHINE_GCK_i/rst_n_reg/CLR]
set_false_path -from [get_pins GTP_RX_Manager_i/gtp_pll_alarm_reg/C] -to [get_pins GTP_RX_Manager_i/TIME_MACHINE_GCK_i/rst_reg/PRE]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets gtp_rxusrclk2]
