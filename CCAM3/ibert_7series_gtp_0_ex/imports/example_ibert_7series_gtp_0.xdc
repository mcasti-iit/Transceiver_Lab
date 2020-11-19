









# file: ibert_7series_gtp_0.xdc
####################################################################################
##   ____  ____
##  /   /\/   /
## /___/  \  /    Vendor: Xilinx
## \   \   \/     Version : 2012.3
##  \   \         Application : IBERT 7Series
##  /   /         Filename : example_ibert_7series_gtp_0.xdc
## /___/   / ## \   \  / ##  \___\/\___ ##
##
##
## Generated by Xilinx IBERT 7Series
##**************************************************************************
##
## Icon Constraints
##
create_clock -period 30.000 -name J_CLK [get_pins -of_objects [get_cells u_ibert_core/inst/bscan_inst/SERIES7_BSCAN.bscan_inst] -filter {name =~ *DRCK}]
create_clock -period 8.000 -name D_CLK [get_ports SYSCLKP_I]
set_clock_groups -asynchronous -group [get_clocks D_CLK]
set_clock_groups -asynchronous -group [get_clocks J_CLK]
##
## System clock Divider paramter values
##
set_property CLKFBOUT_MULT_F 8 [get_cells u_ibert_core/inst/SYSCLK_DIVIDER.U_GT_MMCM]
set_property DIVCLK_DIVIDE 1 [get_cells u_ibert_core/inst/SYSCLK_DIVIDER.U_GT_MMCM]
set_property CLKIN1_PERIOD 8 [get_cells u_ibert_core/inst/SYSCLK_DIVIDER.U_GT_MMCM]
set_property CLKOUT0_DIVIDE_F 10 [get_cells u_ibert_core/inst/SYSCLK_DIVIDER.U_GT_MMCM]
##
## Refclk constraints
##
create_clock -period 8.000 -name gtrefclk0_2 [get_ports {GTREFCLK0P_I[0]}]
create_clock -period 8.000 -name gtrefclk1_2 [get_ports {GTREFCLK1P_I[0]}]
set_clock_groups -asynchronous -group [get_clocks gtrefclk* -include_generated_clocks]
#
#
#
##
## TX/RX out clock constraints
##
# GT X0Y0
create_clock -period 5.120 -name Q0_RXCLK0 [get_pins {u_ibert_core/inst/QUAD[0].u_q/CH[0].u_ch/u_gtpe2_channel/RXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks Q0_RXCLK0]
create_clock -period 5.120 -name Q0_TX0 [get_pins {u_ibert_core/inst/QUAD[0].u_q/CH[0].u_ch/u_gtpe2_channel/TXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks Q0_TX0]
# GT X0Y1
create_clock -period 5.120 -name Q0_RXCLK1 [get_pins {u_ibert_core/inst/QUAD[0].u_q/CH[1].u_ch/u_gtpe2_channel/RXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks Q0_RXCLK1]
##
## System clock pin locs and timing constraints
##
set_property PACKAGE_PIN N17 [get_ports SYSCLKP_I]
set_property IOSTANDARD LVCMOS18 [get_ports SYSCLKP_I]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_pins u_ibert_core/inst/SYSCLK_DIVIDER.U_GT_MMCM/CLKIN1]
##
## GTPE2 Channel and Common Loc constraints
##
set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[0].u_ch/u_gtpe2_channel}]
set_property LOC GTPE2_CHANNEL_X0Y1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[1].u_ch/u_gtpe2_channel}]
set_property LOC GTPE2_COMMON_X0Y0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
##
## BUFH Loc constraints for TX/RX userclks
##
set_property LOC BUFHCE_X1Y24 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_clocking/local_txusr.u_txusr}]
set_property LOC BUFHCE_X1Y25 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_clocking/rx_ind.u_rxusr0}]
set_property LOC BUFHCE_X1Y26 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_clocking/rx_ind.u_rxusr1}]
##
## MGT reference clock BUFFERS location constraints
##


set_property LOC IBUFDS_GTE2_X0Y0 [get_cells u_buf_q0_clk0]
set_property LOC IBUFDS_GTE2_X0Y1 [get_cells u_buf_q0_clk1]

##
## Attribute values for GTPE2 Channel and Common instances
##
##
##remove ASYNC_REG property
##
set_property ASYNC_REG false [get_cells {u_ibert_core/inst/QUAD[*].u_q/CH[*].u_ch/U_CHANNEL_REGS/reg_310/I_EN_STAT_EQ1.U_STAT/xsdb_reg_reg[*]}]
set_property ASYNC_REG false [get_cells {u_ibert_core/inst/QUAD[*].u_q/CH[*].u_ch/U_CHANNEL_REGS/reg_30E/I_EN_STAT_EQ1.U_STAT/xsdb_reg_reg[*]}]
set_property ASYNC_REG false [get_cells {u_ibert_core/inst/QUAD[*].u_q/CH[*].u_ch/U_CHANNEL_REGS/reg_312/I_EN_STAT_EQ1.U_STAT/xsdb_reg_reg[*]}]
set_property ASYNC_REG false [get_cells {u_ibert_core/inst/QUAD[*].u_q/CH[*].u_ch/U_CHANNEL_REGS/reg_314/I_EN_STAT_EQ1.U_STAT/xsdb_reg_reg[*]}]

set_property ASYNC_REG false [get_cells {u_ibert_core/inst/QUAD[*].u_q/CH[*].u_ch/U_CHANNEL_REGS/reg_306/I_EN_STAT_EQ1.U_STAT/xsdb_reg_reg[*]}]

set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_RD/U_RD_FIFO/SUBCORE_FIFO.xsdb_rdfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.rd_rst_asreg_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_RD/U_RD_FIFO/SUBCORE_FIFO.xsdb_rdfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.rd_rst_asreg_d1_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_RD/U_RD_FIFO/SUBCORE_FIFO.xsdb_rdfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.rd_rst_asreg_d2_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_RD/U_RD_FIFO/SUBCORE_FIFO.xsdb_rdfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.wr_rst_asreg_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_RD/U_RD_FIFO/SUBCORE_FIFO.xsdb_rdfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.wr_rst_asreg_d1_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_RD/U_RD_FIFO/SUBCORE_FIFO.xsdb_rdfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.wr_rst_asreg_d2_reg]

set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_WR/U_WR_FIFO/SUBCORE_FIFO.xsdb_wrfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.rd_rst_asreg_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_WR/U_WR_FIFO/SUBCORE_FIFO.xsdb_wrfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.rd_rst_asreg_d1_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_WR/U_WR_FIFO/SUBCORE_FIFO.xsdb_wrfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.rd_rst_asreg_d2_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_WR/U_WR_FIFO/SUBCORE_FIFO.xsdb_wrfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.wr_rst_asreg_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_WR/U_WR_FIFO/SUBCORE_FIFO.xsdb_wrfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.wr_rst_asreg_d1_reg]
set_property ASYNC_REG false [get_cells u_ibert_core/inst/UUT_MASTER/U_ICON_INTERFACE/U_CMD6_WR/U_WR_FIFO/SUBCORE_FIFO.xsdb_wrfifo_inst/inst_fifo_gen/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.g7serrst.wr_rst_asreg_d2_reg]

##
## Attribute Values for QUAD[0] - Channel
##
##------Comma Detection and Alignment---------
set_property ALIGN_COMMA_DOUBLE FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ALIGN_COMMA_ENABLE 10'b0001111111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ALIGN_COMMA_WORD 1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ALIGN_MCOMMA_DET TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ALIGN_MCOMMA_VALUE 10'b1010000011 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ALIGN_PCOMMA_DET TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ALIGN_PCOMMA_VALUE 10'b0101111100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property DEC_MCOMMA_DETECT FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property DEC_PCOMMA_DETECT FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property DEC_VALID_COMMA_ONLY FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property DMONITOR_CFG 24'h000A00 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##--------------Channel Bonding--------------
set_property CBCC_DATA_SOURCE_SEL DECODED [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_KEEP_ALIGN FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_MAX_SKEW 7 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_LEN 1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_1_1 10'b0101111100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_1_2 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_1_3 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_1_4 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_1_ENABLE 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_2_1 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_2_2 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_2_3 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_2_4 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_2_ENABLE 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CHAN_BOND_SEQ_2_USE FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------Clock Correction------------
set_property CLK_COR_KEEP_IDLE FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_MAX_LAT 9 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_MIN_LAT 7 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_PRECEDENCE TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_CORRECT_USE FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_REPEAT_WAIT 0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_LEN 1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_1_1 10'b0100011100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_1_2 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_1_3 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_1_4 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_1_ENABLE 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_2_1 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_2_2 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_2_3 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_2_4 10'b0100000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_2_ENABLE 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CLK_COR_SEQ_2_USE FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------Channel PLL----------------------




set_property RXOUT_DIV 2 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXOUT_DIV 2 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------------Eyescan--------------
set_property ES_CONTROL 6'b000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_ERRDET_EN TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_EYE_SCAN_EN TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_HORZ_OFFSET 12'h002 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_PMA_CFG 10'b0000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_PRESCALE 5'b00000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_QUALIFIER 80'h00000000000000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_QUAL_MASK 80'h00000000000000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_SDATA_MASK 80'h00000000000000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ES_VERT_OFFSET 9'b010000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property FTS_DESKEW_SEQ_ENABLE 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property FTS_LANE_DESKEW_CFG 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property FTS_LANE_DESKEW_EN FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property GEARBOX_MODE 3'b000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property OUTREFCLK_SEL_INV 2'b11 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PCS_PCIE_EN FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PCS_RSVD_ATTR 48'h000000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV 32'h00000333 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV2 32'h00002040 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV3 2'b00 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV4 4'b0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV5 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV6 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV7 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_BIAS_CFG 16'b0000111100110011 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_PREDRIVER_MODE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------Rx Elastic Buffer and Phase alignment-------------
set_property RXBUF_ADDR_MODE FAST [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_EIDLE_HI_CNT 4'b1000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_EIDLE_LO_CNT 4'b0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_EN TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_BUFFER_CFG 6'b000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_RESET_ON_CB_CHANGE TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_RESET_ON_COMMAALIGN FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_RESET_ON_EIDLE FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_RESET_ON_RATE_CHANGE TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUFRESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_THRESH_OVFLW 61 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_THRESH_OVRD FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXBUF_THRESH_UNDFLW 4 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXDLY_CFG 16'h0010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXDLY_LCFG 9'h020 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXDLY_TAP_CFG 16'h0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------RX driver, OOB signalling, Coupling and Eq., CDR------------
set_property RXCDR_CFG 83'h0001107FE206021081010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXCDRFREQRESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXCDR_FR_RESET_ON_EIDLE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXCDR_HOLD_DURING_EIDLE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXCDR_LOCK_CFG 6'b001001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXCDR_PH_RESET_ON_EIDLE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXCDRPHRESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXOOB_CFG 7'b0000110 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------------------RX Interface-------------------------
set_property RX_DATA_WIDTH 16 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_CLK25_DIV 5 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_CM_SEL 2'b11 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_CM_TRIM 4'b1010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_DDI_SEL 6'b000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_DEBUG_CFG 14'b00000000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##------------RX Decision Feedback Equalizer(DFE)-------------
set_property RX_DEFER_RESET_BUF_EN TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_OS_CFG 13'b0000010000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_DISPERR_SEQ_MATCH TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------------------RX Gearbox---------------------------
set_property RXGEARBOX_EN FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXISCANRESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_HF_CFG 14'b00001111110000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_HF_CFG2 5'b01010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_HF_CFG3 4'b0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_HOLD_DURING_EIDLE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_INCM_CFG 1'b1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_IPCM_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_LF_CFG 18'b000000001111110000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_LF_CFG2 5'b01010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_OSINT_CFG 3'b000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPCSRESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPH_CFG 24'hC00002 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPHDLY_CFG 24'h084000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPH_MONITOR_SEL 5'b00000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPMARESET_TIME 5'b00011 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------------------PRBS Detection-----------------------
set_property RXPRBS_ERR_LOOPBACK 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_SIG_VALID_DLY 10 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXSLIDE_AUTO_WAIT 7 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXSLIDE_MODE OFF [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_XCLK_SEL RXREC [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------RX Attributes for PCI Express/SATA/SAS----------
set_property PD_TRANS_TIME_FROM_P2 12'h03C [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PD_TRANS_TIME_NONE_P2 8'h3C [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PD_TRANS_TIME_TO_P2 8'h64 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SAS_MAX_COM 64 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SAS_MIN_COM 36 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_BURST_SEQ_LEN 4'b1111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_BURST_VAL 3'b100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_PLL_CFG VCO_3000MHZ [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_EIDLE_VAL 3'b100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_MAX_BURST 8 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_MAX_INIT 21 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_MAX_WAKE 7 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_MIN_BURST 4 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_MIN_INIT 12 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SATA_MIN_WAKE 4 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property SHOW_REALIGN_COMMA TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TERM_RCAL_CFG 15'b100001000010000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TERM_RCAL_OVRD 3'b000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TRANS_TIME_RATE 8'h0E [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TST_RSV 32'h00000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##------------TX Buffering and Phase Alignment----------------
set_property TXBUF_EN TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXBUF_RESET_ON_RATE_CHANGE TRUE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------------------TX Interface-------------------------
set_property TX_DATA_WIDTH 16 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_DEEMPH0 6'b000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_DEEMPH1 6'b000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXDLY_CFG 16'h0010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXDLY_LCFG 9'h020 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXDLY_TAP_CFG 16'h0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_CLK25_DIV 5 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##--------------TX Driver and OOB Signalling------------------
set_property TX_EIDLE_ASSERT_DELAY 3'b110 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_EIDLE_DEASSERT_DELAY 3'b100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_LOOPBACK_DRIVE_HIZ FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MAINCURSOR_SEL 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_DRIVE_MODE DIRECT [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##-----------------------TX Gearbox---------------------------
set_property TXGEARBOX_EN FALSE [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##----------------TX Attributes for PCI Express---------------
set_property TX_MARGIN_FULL_0 7'b1001110 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_FULL_1 7'b1001001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_FULL_2 7'b1000101 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_FULL_3 7'b1000010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_FULL_4 7'b1000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_LOW_0 7'b1000110 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_LOW_1 7'b1000100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_LOW_2 7'b1000010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_LOW_3 7'b1000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_MARGIN_LOW_4 7'b1000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPCSRESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPH_CFG 16'h0400 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPHDLY_CFG 24'h084000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPH_MONITOR_SEL 5'b00000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPMARESET_TIME 5'b00001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_RXDETECT_CFG 14'h1832 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_RXDETECT_REF 3'b100 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_XCLK_SEL TXOUT [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property UCODEER_CLR 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
##---------------- JTAG Attributes ---------------
set_property ACJTAG_DEBUG_MODE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ACJTAG_MODE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ACJTAG_RESET 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property ADAPT_CFG0 20'b00000000000000000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPMRESET_TIME 7'b0001111 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_BIAS_STARTUP_DISABLE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_CFG 4'b0110 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_CFG1 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_CM_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_GC_CFG 9'b101110010 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXLPM_GC_CFG2 3'b001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CFOK_CFG 43'b1001001000000000000000001000000111010000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CFOK_CFG2 7'b0100000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CFOK_CFG3 7'b0100000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CFOK_CFG4 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CFOK_CFG5 2'b00 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property CFOK_CFG6 4'b0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- EYESCAN ---------------
set_property ES_CLK_PHASE_SEL 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_RSV5 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- RX Phase Interpolator ---------------
set_property RXPI_CFG0 3'b000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPI_CFG1 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXPI_CFG2 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- TX Phase Interpolator ---------------
set_property TXPI_CFG0 2'b00 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_CFG1 2'b00 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_CFG2 2'b00 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_CFG3 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_CFG4 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_CFG5 3'b000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_GREY_SEL 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_INVSTROBE_SEL 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_PPMCLK_SEL TXUSRCLK2 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_PPM_CFG 8'b00000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXPI_SYNFREQ_PPM 3'b000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property USE_PCS_CLK_PHASE_SEL 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- LOOPBACK ---------------
set_property LOOPBACK_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- OOB Signalling ---------------
set_property RXOOB_CLK_CFG PMA [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXOSCALRESET_TIME 5'b00011 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXOSCALRESET_TIMEOUT 5'b00000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXOOB_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- PMA Attributes ---------------
set_property CLK_COMMON_SWING 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RX_CLKMUX_EN 1'b1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TX_CLKMUX_EN 1'b1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property PMA_LOOPBACK_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- RX SYNC ---------------
set_property RXSYNC_MULTILANE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXSYNC_OVRD 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property RXSYNC_SKIP_DA 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##---------------- TX SYNC ---------------
set_property TXSYNC_MULTILANE 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXSYNC_OVRD 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]
set_property TXSYNC_SKIP_DA 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/CH[*].u_ch/u_gtpe2_channel}]

##
## Attribute Values for QUAD[0] - Common
##
set_property BIAS_CFG 64'h0000000000050001 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property COMMON_CFG 32'h00000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL1_CFG 27'h01F0319 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_CFG 27'h01F0319 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_DMON_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL1_DMON_CFG 1'b0 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL_CLKOUT_CFG 8'b00000000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_INIT_CFG 24'h00001E [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL1_INIT_CFG 24'h00001E [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_LOCK_CFG 9'h1E8 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL1_LOCK_CFG 9'h1E8 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]



set_property PLL1_FBDIV 5 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_FBDIV 5 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL1_FBDIV_45 5 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_FBDIV_45 5 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL0_REFCLK_DIV 1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property PLL1_REFCLK_DIV 1 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property RSVD_ATTR0 16'h0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]
set_property RSVD_ATTR1 16'h0000 [get_cells {u_ibert_core/inst/QUAD[0].u_q*/u_common/u_gtpe2_common}]

