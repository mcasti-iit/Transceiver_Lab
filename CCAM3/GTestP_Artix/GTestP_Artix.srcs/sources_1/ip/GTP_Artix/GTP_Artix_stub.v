// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Mar  3 11:36:21 2021
// Host        : IITICUBLAP127 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Progetti/Transceiver_Lab/CCAM3/GTestP_Artix/GTestP_Artix.srcs/sources_1/ip/GTP_Artix/GTP_Artix_stub.v
// Design      : GTP_Artix
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a50tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "GTP_Artix,gtwizard_v3_6_11,{protocol_file=Start_from_scratch}" *)
module GTP_Artix(SOFT_RESET_TX_IN, 
  DONT_RESET_ON_DATA_ERROR_IN, Q0_CLK0_GTREFCLK_PAD_N_IN, Q0_CLK0_GTREFCLK_PAD_P_IN, 
  GT0_TX_FSM_RESET_DONE_OUT, GT0_RX_FSM_RESET_DONE_OUT, GT0_DATA_VALID_IN, 
  GT0_TXUSRCLK_OUT, GT0_TXUSRCLK2_OUT, gt0_drpaddr_in, gt0_drpdi_in, gt0_drpdo_out, 
  gt0_drpen_in, gt0_drprdy_out, gt0_drpwe_in, gt0_eyescanreset_in, 
  gt0_eyescandataerror_out, gt0_eyescantrigger_in, gt0_dmonitorout_out, gt0_gtrxreset_in, 
  gt0_rxlpmreset_in, gt0_gttxreset_in, gt0_txuserrdy_in, gt0_txdata_in, gt0_txcharisk_in, 
  gt0_gtptxn_out, gt0_gtptxp_out, gt0_txoutclkfabric_out, gt0_txoutclkpcs_out, 
  gt0_txpcsreset_in, gt0_txpmareset_in, gt0_txresetdone_out, GT0_PLL0OUTCLK_OUT, 
  GT0_PLL0OUTREFCLK_OUT, GT0_PLL0LOCK_OUT, GT0_PLL0REFCLKLOST_OUT, GT0_PLL1OUTCLK_OUT, 
  GT0_PLL1OUTREFCLK_OUT, sysclk_in)
/* synthesis syn_black_box black_box_pad_pin="SOFT_RESET_TX_IN,DONT_RESET_ON_DATA_ERROR_IN,Q0_CLK0_GTREFCLK_PAD_N_IN,Q0_CLK0_GTREFCLK_PAD_P_IN,GT0_TX_FSM_RESET_DONE_OUT,GT0_RX_FSM_RESET_DONE_OUT,GT0_DATA_VALID_IN,GT0_TXUSRCLK_OUT,GT0_TXUSRCLK2_OUT,gt0_drpaddr_in[8:0],gt0_drpdi_in[15:0],gt0_drpdo_out[15:0],gt0_drpen_in,gt0_drprdy_out,gt0_drpwe_in,gt0_eyescanreset_in,gt0_eyescandataerror_out,gt0_eyescantrigger_in,gt0_dmonitorout_out[14:0],gt0_gtrxreset_in,gt0_rxlpmreset_in,gt0_gttxreset_in,gt0_txuserrdy_in,gt0_txdata_in[15:0],gt0_txcharisk_in[1:0],gt0_gtptxn_out,gt0_gtptxp_out,gt0_txoutclkfabric_out,gt0_txoutclkpcs_out,gt0_txpcsreset_in,gt0_txpmareset_in,gt0_txresetdone_out,GT0_PLL0OUTCLK_OUT,GT0_PLL0OUTREFCLK_OUT,GT0_PLL0LOCK_OUT,GT0_PLL0REFCLKLOST_OUT,GT0_PLL1OUTCLK_OUT,GT0_PLL1OUTREFCLK_OUT,sysclk_in" */;
  input SOFT_RESET_TX_IN;
  input DONT_RESET_ON_DATA_ERROR_IN;
  input Q0_CLK0_GTREFCLK_PAD_N_IN;
  input Q0_CLK0_GTREFCLK_PAD_P_IN;
  output GT0_TX_FSM_RESET_DONE_OUT;
  output GT0_RX_FSM_RESET_DONE_OUT;
  input GT0_DATA_VALID_IN;
  output GT0_TXUSRCLK_OUT;
  output GT0_TXUSRCLK2_OUT;
  input [8:0]gt0_drpaddr_in;
  input [15:0]gt0_drpdi_in;
  output [15:0]gt0_drpdo_out;
  input gt0_drpen_in;
  output gt0_drprdy_out;
  input gt0_drpwe_in;
  input gt0_eyescanreset_in;
  output gt0_eyescandataerror_out;
  input gt0_eyescantrigger_in;
  output [14:0]gt0_dmonitorout_out;
  input gt0_gtrxreset_in;
  input gt0_rxlpmreset_in;
  input gt0_gttxreset_in;
  input gt0_txuserrdy_in;
  input [15:0]gt0_txdata_in;
  input [1:0]gt0_txcharisk_in;
  output gt0_gtptxn_out;
  output gt0_gtptxp_out;
  output gt0_txoutclkfabric_out;
  output gt0_txoutclkpcs_out;
  input gt0_txpcsreset_in;
  input gt0_txpmareset_in;
  output gt0_txresetdone_out;
  output GT0_PLL0OUTCLK_OUT;
  output GT0_PLL0OUTREFCLK_OUT;
  output GT0_PLL0LOCK_OUT;
  output GT0_PLL0REFCLKLOST_OUT;
  output GT0_PLL1OUTCLK_OUT;
  output GT0_PLL1OUTREFCLK_OUT;
  input sysclk_in;
endmodule
