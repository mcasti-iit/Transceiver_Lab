
create_clock -period 8.000 -name D_CLK [get_ports SYSCLK]
create_clock -period 8.000 -name gtrefclk0_2 [get_ports {GTREFCLK0P}]
create_clock -period 8.000 -name gtrefclk1_2 [get_ports {GTREFCLK1P}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets refclk0]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets refclk1]

set_property -dict {PACKAGE_PIN U9} [get_ports GTREFCLK0P]
set_property -dict {PACKAGE_PIN V9} [get_ports GTREFCLK0N]
set_property -dict {PACKAGE_PIN U5} [get_ports GTREFCLK1P]
set_property -dict {PACKAGE_PIN V5} [get_ports GTREFCLK1N]

set_property PACKAGE_PIN K2 [get_ports SYSCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SYSCLK]



