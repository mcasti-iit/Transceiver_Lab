#-------------------------------------------------------------
# Generated Example Tcl script for IP 'GTP_Artix' (xilinx.com:ip:gtwizard:3.6)
#-------------------------------------------------------------

# Set up project params
set_param board.repoPaths D:/WinTools/Xilinx/Boards
# Declare source IP directory
set srcIpDir "d:/Projects/Transceiver/CCAM3/GTestP_Artix/GTestP_Artix.srcs/sources_1/ip/GTP_Artix"

# Create project
puts "INFO: \[open_example_project\] Creating new example project..."
create_project -name GTP_Artix_ex -force
# Set the board_part_repo_paths from the original project
puts "INFO: \[open_example_project\] Setting board_part_repo_paths..."
set_property board_part_repo_paths [list d:/Projects/Transceiver/CCAM3/ibert_7series_gtp_0_ex/Users/mcasti/AppData/Roaming/Xilinx/Vivado/2019.1/xhub/board_store d:/Projects/Transceiver/CCAM3/ibert_7series_gtp_0_ex/Xilinx/Vivado/Other_Boards] [current_project]

set_property part xc7a50tcpg236-1 [current_project]
set_property target_language vhdl [current_project]
set_property simulator_language MIXED [current_project]
set_property coreContainer.enable false [current_project]
set returnCode 0

# Set the repo paths from the original project
puts "INFO: \[open_example_project\] Loading IP Catalog..."
set_property ip_repo_paths [list d:/Projects/Transceiver/CCAM3/src/Vivado_repo d:/Projects/ISAAC/FPGA/Filters/ebv_filter d:/Projects/ISAAC/FPGA/Corner_Extraction/cornext_harris] [current_project]
update_ip_catalog

# Set up pre-compilation paths

# Import the original IP (excluding example files)
puts "INFO: \[open_example_project\] Importing original IP ..."
import_ip -files [list [file join $srcIpDir GTP_Artix.xci]] -name GTP_Artix
reset_target {open_example} [get_ips GTP_Artix]

# Generate the IP
proc _filter_supported_targets {targets ip} {
  set res {}
  set all [get_property SUPPORTED_TARGETS $ip]
  foreach target $targets {
    lappend res {*}[lsearch -all -inline -nocase $all $target]
  }
  return $res
}
puts "INFO: \[open_example_project\] Generating the example project IP ..."
generate_target -quiet [_filter_supported_targets {instantiation_template synthesis simulation implementation shared_logic} [get_ips GTP_Artix]] [get_ips GTP_Artix]

# Add example synthesis HDL files
puts "INFO: \[open_example_project\] Adding example synthesis HDL files ..."
add_files -scan_for_includes -quiet -fileset [current_fileset] \
  [list [file join $srcIpDir GTP_Artix/example_design/gtp_artix_exdes.vhd]] \
  [list [file join $srcIpDir GTP_Artix/example_design/gtp_artix_gt_frame_check.vhd]] \
  [list [file join $srcIpDir GTP_Artix/example_design/gtp_artix_gt_frame_gen.vhd]]

# Add example miscellaneous synthesis files
puts "INFO: \[open_example_project\] Adding example synthesis miscellaneous files ..."
add_files -quiet -fileset [current_fileset] \
  [list [file join $srcIpDir GTP_Artix/example_design/gt_rom_init_tx.dat]]
set_property USED_IN_SIMULATION false [get_files [list [file join $srcIpDir GTP_Artix/example_design/gt_rom_init_tx.dat]]]

# Add example XDC files
puts "INFO: \[open_example_project\] Adding example XDC files ..."
add_files -quiet -fileset [current_fileset -constrset] \
  [list [file join $srcIpDir GTP_Artix/example_design/GTP_Artix_exdes.xdc]]


# Add example simulation HDL files
puts "INFO: \[open_example_project\] Adding simulation HDL files ..."
if { [catch {current_fileset -simset} exc] } { create_fileset -simset sim_1 }
add_files -quiet -scan_for_includes -fileset [current_fileset -simset] \
  [list [file join $srcIpDir GTP_Artix/simulation/gtp_artix_tb.vhd]] \
  [list [file join $srcIpDir GTP_Artix/simulation/sim_reset_gt_model.vhd]]
set_property USED_IN_SYNTHESIS false [get_files [list [file join $srcIpDir GTP_Artix/simulation/gtp_artix_tb.vhd]]]
set_property USED_IN_SYNTHESIS false [get_files [list [file join $srcIpDir GTP_Artix/simulation/sim_reset_gt_model.vhd]]]

# Add example miscellaneous simulation files
puts "INFO: \[open_example_project\] Adding simulation miscellaneous files ..."
if { [catch {current_fileset -simset} exc] } { create_fileset -simset sim_1 }
add_files -quiet -fileset [current_fileset -simset] \
  [list [file join $srcIpDir GTP_Artix/simulation/functional/gt_rom_init_tx.dat]]
set_property USED_IN_SYNTHESIS false [get_files [list [file join $srcIpDir GTP_Artix/simulation/functional/gt_rom_init_tx.dat]]]

# Import all files while preserving hierarchy
import_files

# Set top
set_property TOP [lindex [find_top] 0] [current_fileset]

puts "INFO: \[open_example_project\] Sourcing example extension scripts ..."
# Source script extension file(s)
if {[catch {source [file join $srcIpDir tcl/set_top.tcl]} errMsg]} {
  puts "ERROR: \[open_example_project\] Open Example Project failed: Error encountered while sourcing custom IP example design script."
  puts "$errorInfo"
  error "ERROR: see log file for details."
  incr returnCode
}
if {[catch {source [file join $srcIpDir GTP_Artix/tcl/xci.tcl]} errMsg]} {
  puts "ERROR: \[open_example_project\] Open Example Project failed: Error encountered while sourcing custom IP example design script."
  puts "$errorInfo"
  error "ERROR: see log file for details."
  incr returnCode
}
if {[catch {source [file join $srcIpDir GTP_Artix/tcl/gtp_artix_partner.tcl]} errMsg]} {
  puts "ERROR: \[open_example_project\] Open Example Project failed: Error encountered while sourcing custom IP example design script."
  puts "$errorInfo"
  error "ERROR: see log file for details."
  incr returnCode
}

# Update compile order
update_compile_order -fileset [current_fileset]
update_compile_order -fileset [current_fileset -simset]
set tops [list]
foreach tfile [ get_files -filter {name=~"*.xci" || name=~"*.bdj" || name=~"*.bd"}] { if { [lsearch [list_property $tfile] PARENT_COMPOSITE_FILE ] == -1} {lappend tops $tfile} }
puts "INFO: \[open_example_project\] Rebuilding all the top level IPs ..."
generate_target all $tops
export_ip_user_files -force

set dfile [file join $srcIpDir oepdone.txt]
if { [ catch { set doneFile [open $dfile w] } ] } {
} else { 
  puts $doneFile "Open Example Project DONE"
  close $doneFile
}
if { $returnCode != 0 } {
  puts "ERROR: \[open_example_project\] Problems were encountered while executing the example design script, please review the log file."
  error "ERROR: See log file for details."
  incr returnCode
} else {
  puts "INFO: \[open_example_project\] Open Example Project completed"
}
