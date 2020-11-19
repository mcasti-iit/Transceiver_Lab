set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[9]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[10]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[11]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[13]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[0]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[1]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[8]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[2]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[4]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[5]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[6]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[12]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[14]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[15]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[3]}]
set_property MARK_DEBUG true [get_nets {GTP_Artix_support_i/U0/gt0_txdata_in[7]}]
set_property MARK_DEBUG true [get_nets GTP_Artix_support_i/U0/GT0_PLL0LOCK_OUT]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list GTP_Artix_support_i/U0/gt_usrclk_source/GT0_TXUSRCLK_OUT]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {GTP_Artix_support_i/U0/gt0_txdata_in[0]} {GTP_Artix_support_i/U0/gt0_txdata_in[1]} {GTP_Artix_support_i/U0/gt0_txdata_in[2]} {GTP_Artix_support_i/U0/gt0_txdata_in[3]} {GTP_Artix_support_i/U0/gt0_txdata_in[4]} {GTP_Artix_support_i/U0/gt0_txdata_in[5]} {GTP_Artix_support_i/U0/gt0_txdata_in[6]} {GTP_Artix_support_i/U0/gt0_txdata_in[7]} {GTP_Artix_support_i/U0/gt0_txdata_in[8]} {GTP_Artix_support_i/U0/gt0_txdata_in[9]} {GTP_Artix_support_i/U0/gt0_txdata_in[10]} {GTP_Artix_support_i/U0/gt0_txdata_in[11]} {GTP_Artix_support_i/U0/gt0_txdata_in[12]} {GTP_Artix_support_i/U0/gt0_txdata_in[13]} {GTP_Artix_support_i/U0/gt0_txdata_in[14]} {GTP_Artix_support_i/U0/gt0_txdata_in[15]}]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list drpclk_in_i]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 1 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list GTP_Artix_support_i/U0/GT0_PLL0LOCK_OUT]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets drpclk_in_i]