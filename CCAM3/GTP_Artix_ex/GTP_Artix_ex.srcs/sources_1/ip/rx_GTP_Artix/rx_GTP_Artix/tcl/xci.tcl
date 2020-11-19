
create_ip -name vio -vendor xilinx.com -library ip -module_name vio_0
generate_target {instantiation_template} [get_files vio_0.xci]
generate_target all [get_files  vio_0.xci]

create_ip -name ila -vendor xilinx.com -library ip -module_name ila_0
set_property -dict [list CONFIG.C_PROBE4_WIDTH {8} CONFIG.C_PROBE3_WIDTH {2} CONFIG.C_PROBE1_WIDTH {8} CONFIG.C_PROBE0_WIDTH {80} CONFIG.C_NUM_OF_PROBES {7}] [get_ips ila_0]
generate_target {instantiation_template} [get_files ila_0.xci]
generate_target all [get_files  ila_0.xci]


create_ip -name ila -vendor xilinx.com -library ip -module_name ila_1
set_property -dict [list CONFIG.C_NUM_OF_PROBES {2}] [get_ips ila_1]
generate_target {instantiation_template} [get_files ila_1.xci]
generate_target all [get_files  ila_1.xci]

create_ip_run [get_files -of_objects [get_fileset sources_1] vio_0.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ila_0.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ila_1.xci]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]; 
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
