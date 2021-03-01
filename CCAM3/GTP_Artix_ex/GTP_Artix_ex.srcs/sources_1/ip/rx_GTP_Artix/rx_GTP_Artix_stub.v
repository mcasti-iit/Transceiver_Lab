// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Feb 22 17:46:03 2021
// Host        : IITICUBLAP127 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Progetti/Transceiver_Lab/CCAM3/GTP_Artix_ex/GTP_Artix_ex.srcs/sources_1/ip/rx_GTP_Artix/rx_GTP_Artix_stub.v
// Design      : rx_GTP_Artix
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a50tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "rx_GTP_Artix,gtwizard_v3_6_11,{protocol_file=Start_from_scratch}" *)
module rx_GTP_Artix(SYSCLK_IN, SOFT_RESET_RX_IN, 
  DONT_RESET_ON_DATA_ERROR_IN, GT0_DRP_BUSY_OUT, GT0_TX_FSM_RESET_DONE_OUT, 
  GT0_RX_FSM_RESET_DONE_OUT, GT0_DATA_VALID_IN, gt0_drpaddr_in, gt0_drpclk_in, 
  gt0_drpdi_in, gt0_drpdo_out, gt0_drpen_in, gt0_drprdy_out, gt0_drpwe_in, 
  gt0_eyescanreset_in, gt0_rxuserrdy_in, gt0_eyescandataerror_out, gt0_eyescantrigger_in, 
  gt0_rxdata_out, gt0_rxusrclk_in, gt0_rxusrclk2_in, gt0_rxcharisk_out, gt0_rxdisperr_out, 
  gt0_rxnotintable_out, gt0_gtprxn_in, gt0_gtprxp_in, gt0_rxslide_in, gt0_dmonitorout_out, 
  gt0_rxlpmhfhold_in, gt0_rxlpmlfhold_in, gt0_rxoutclk_out, gt0_rxoutclkfabric_out, 
  gt0_gtrxreset_in, gt0_rxlpmreset_in, gt0_rxresetdone_out, gt0_gttxreset_in, 
  gt0_txpcsreset_in, GT0_PLL0OUTCLK_IN, GT0_PLL0OUTREFCLK_IN, GT0_PLL0RESET_OUT, 
  GT0_PLL0LOCK_IN, GT0_PLL0REFCLKLOST_IN, GT0_PLL1OUTCLK_IN, GT0_PLL1OUTREFCLK_IN)
/* synthesis syn_black_box black_box_pad_pin="SYSCLK_IN,SOFT_RESET_RX_IN,DONT_RESET_ON_DATA_ERROR_IN,GT0_DRP_BUSY_OUT,GT0_TX_FSM_RESET_DONE_OUT,GT0_RX_FSM_RESET_DONE_OUT,GT0_DATA_VALID_IN,gt0_drpaddr_in[8:0],gt0_drpclk_in,gt0_drpdi_in[15:0],gt0_drpdo_out[15:0],gt0_drpen_in,gt0_drprdy_out,gt0_drpwe_in,gt0_eyescanreset_in,gt0_rxuserrdy_in,gt0_eyescandataerror_out,gt0_eyescantrigger_in,gt0_rxdata_out[15:0],gt0_rxusrclk_in,gt0_rxusrclk2_in,gt0_rxcharisk_out[1:0],gt0_rxdisperr_out[1:0],gt0_rxnotintable_out[1:0],gt0_gtprxn_in,gt0_gtprxp_in,gt0_rxslide_in,gt0_dmonitorout_out[14:0],gt0_rxlpmhfhold_in,gt0_rxlpmlfhold_in,gt0_rxoutclk_out,gt0_rxoutclkfabric_out,gt0_gtrxreset_in,gt0_rxlpmreset_in,gt0_rxresetdone_out,gt0_gttxreset_in,gt0_txpcsreset_in,GT0_PLL0OUTCLK_IN,GT0_PLL0OUTREFCLK_IN,GT0_PLL0RESET_OUT,GT0_PLL0LOCK_IN,GT0_PLL0REFCLKLOST_IN,GT0_PLL1OUTCLK_IN,GT0_PLL1OUTREFCLK_IN" */;
  input SYSCLK_IN;
  input SOFT_RESET_RX_IN;
  input DONT_RESET_ON_DATA_ERROR_IN;
  output GT0_DRP_BUSY_OUT;
  output GT0_TX_FSM_RESET_DONE_OUT;
  output GT0_RX_FSM_RESET_DONE_OUT;
  input GT0_DATA_VALID_IN;
  input [8:0]gt0_drpaddr_in;
  input gt0_drpclk_in;
  input [15:0]gt0_drpdi_in;
  output [15:0]gt0_drpdo_out;
  input gt0_drpen_in;
  output gt0_drprdy_out;
  input gt0_drpwe_in;
  input gt0_eyescanreset_in;
  input gt0_rxuserrdy_in;
  output gt0_eyescandataerror_out;
  input gt0_eyescantrigger_in;
  output [15:0]gt0_rxdata_out;
  input gt0_rxusrclk_in;
  input gt0_rxusrclk2_in;
  output [1:0]gt0_rxcharisk_out;
  output [1:0]gt0_rxdisperr_out;
  output [1:0]gt0_rxnotintable_out;
  input gt0_gtprxn_in;
  input gt0_gtprxp_in;
  input gt0_rxslide_in;
  output [14:0]gt0_dmonitorout_out;
  input gt0_rxlpmhfhold_in;
  input gt0_rxlpmlfhold_in;
  output gt0_rxoutclk_out;
  output gt0_rxoutclkfabric_out;
  input gt0_gtrxreset_in;
  input gt0_rxlpmreset_in;
  output gt0_rxresetdone_out;
  input gt0_gttxreset_in;
  input gt0_txpcsreset_in;
  input GT0_PLL0OUTCLK_IN;
  input GT0_PLL0OUTREFCLK_IN;
  output GT0_PLL0RESET_OUT;
  input GT0_PLL0LOCK_IN;
  input GT0_PLL0REFCLKLOST_IN;
  input GT0_PLL1OUTCLK_IN;
  input GT0_PLL1OUTREFCLK_IN;
endmodule
