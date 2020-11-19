############################################################################
##
##  Xilinx, Inc. 2006            www.xilinx.com
############################################################################
##  File name :       ps7_constraints.xdc
##
##  Details :     Constraints file
##                    FPGA family:       zynq
##                    FPGA:              xc7z015clg485-1
##                    Device Size:        xc7z015
##                    Package:            clg485
##                    Speedgrade:         -1
##
##
############################################################################
############################################################################
############################################################################
# Clock constraints                                                        #
############################################################################
create_clock -name clk_fpga_0 -period "8" [get_pins "PS7_i/FCLKCLK[0]"]
set_input_jitter clk_fpga_0 0.24
#The clocks are asynchronous, user should constrain them appropriately.#


############################################################################
# I/O STANDARDS and Location Constraints                                   #
############################################################################

set_property iostandard "LVCMOS33" [get_ports "PS_PORB"]
set_property PACKAGE_PIN "B18" [get_ports "PS_PORB"]
set_property slew "fast" [get_ports "PS_PORB"]
set_property iostandard "LVCMOS33" [get_ports "PS_SRSTB"]
set_property PACKAGE_PIN "C14" [get_ports "PS_SRSTB"]
set_property slew "fast" [get_ports "PS_SRSTB"]
set_property iostandard "LVCMOS33" [get_ports "PS_CLK"]
set_property PACKAGE_PIN "F16" [get_ports "PS_CLK"]
set_property slew "fast" [get_ports "PS_CLK"]

