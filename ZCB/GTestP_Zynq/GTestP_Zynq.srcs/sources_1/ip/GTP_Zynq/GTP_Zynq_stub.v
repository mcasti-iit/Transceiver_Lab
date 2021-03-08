// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Feb 23 16:28:22 2021
// Host        : IITICUBLAP127 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top GTP_Zynq -prefix
//               GTP_Zynq_ GTP_Zynq_stub.v
// Design      : GTP_Zynq
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "GTP_Zynq,gtwizard_v3_6_11,{protocol_file=Start_from_scratch}" *)
module GTP_Zynq(SOFT_RESET_RX_IN, 
  DONT_RESET_ON_DATA_ERROR_IN, Q0_CLK1_GTREFCLK_PAD_N_IN, Q0_CLK1_GTREFCLK_PAD_P_IN, 
  GT0_TX_FSM_RESET_DONE_OUT, GT0_RX_FSM_RESET_DONE_OUT, GT0_DATA_VALID_IN, 
  GT0_RXUSRCLK_OUT, GT0_RXUSRCLK2_OUT, gt0_drpaddr_in, gt0_drpdi_in, gt0_drpdo_out, 
  gt0_drpen_in, gt0_drprdy_out, gt0_drpwe_in, gt0_eyescanreset_in, gt0_rxuserrdy_in, 
  gt0_eyescandataerror_out, gt0_eyescantrigger_in, gt0_rxdata_out, gt0_rxchariscomma_out, 
  gt0_rxcharisk_out, gt0_rxdisperr_out, gt0_rxnotintable_out, gt0_gtprxn_in, gt0_gtprxp_in, 
  gt0_rxbyteisaligned_out, gt0_rxbyterealign_out, gt0_rxcommadet_out, 
  gt0_rxmcommaalignen_in, gt0_rxpcommaalignen_in, gt0_dmonitorout_out, 
  gt0_rxlpmhfhold_in, gt0_rxlpmlfhold_in, gt0_rxoutclkfabric_out, gt0_gtrxreset_in, 
  gt0_rxlpmreset_in, gt0_rxresetdone_out, gt0_gttxreset_in, GT0_PLL0RESET_OUT, 
  GT0_PLL0OUTCLK_OUT, GT0_PLL0OUTREFCLK_OUT, GT0_PLL0LOCK_OUT, GT0_PLL0REFCLKLOST_OUT, 
  GT0_PLL1OUTCLK_OUT, GT0_PLL1OUTREFCLK_OUT, sysclk_in)
/* synthesis syn_black_box black_box_pad_pin="SOFT_RESET_RX_IN,DONT_RESET_ON_DATA_ERROR_IN,Q0_CLK1_GTREFCLK_PAD_N_IN,Q0_CLK1_GTREFCLK_PAD_P_IN,GT0_TX_FSM_RESET_DONE_OUT,GT0_RX_FSM_RESET_DONE_OUT,GT0_DATA_VALID_IN,GT0_RXUSRCLK_OUT,GT0_RXUSRCLK2_OUT,gt0_drpaddr_in[8:0],gt0_drpdi_in[15:0],gt0_drpdo_out[15:0],gt0_drpen_in,gt0_drprdy_out,gt0_drpwe_in,gt0_eyescanreset_in,gt0_rxuserrdy_in,gt0_eyescandataerror_out,gt0_eyescantrigger_in,gt0_rxdata_out[15:0],gt0_rxchariscomma_out[1:0],gt0_rxcharisk_out[1:0],gt0_rxdisperr_out[1:0],gt0_rxnotintable_out[1:0],gt0_gtprxn_in,gt0_gtprxp_in,gt0_rxbyteisaligned_out,gt0_rxbyterealign_out,gt0_rxcommadet_out,gt0_rxmcommaalignen_in,gt0_rxpcommaalignen_in,gt0_dmonitorout_out[14:0],gt0_rxlpmhfhold_in,gt0_rxlpmlfhold_in,gt0_rxoutclkfabric_out,gt0_gtrxreset_in,gt0_rxlpmreset_in,gt0_rxresetdone_out,gt0_gttxreset_in,GT0_PLL0RESET_OUT,GT0_PLL0OUTCLK_OUT,GT0_PLL0OUTREFCLK_OUT,GT0_PLL0LOCK_OUT,GT0_PLL0REFCLKLOST_OUT,GT0_PLL1OUTCLK_OUT,GT0_PLL1OUTREFCLK_OUT,sysclk_in" */;
  input SOFT_RESET_RX_IN;
  input DONT_RESET_ON_DATA_ERROR_IN;
  input Q0_CLK1_GTREFCLK_PAD_N_IN;
  input Q0_CLK1_GTREFCLK_PAD_P_IN;
  output GT0_TX_FSM_RESET_DONE_OUT;
  output GT0_RX_FSM_RESET_DONE_OUT;
  input GT0_DATA_VALID_IN;
  output GT0_RXUSRCLK_OUT;
  output GT0_RXUSRCLK2_OUT;
  input [8:0]gt0_drpaddr_in;
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
  output [1:0]gt0_rxchariscomma_out;
  output [1:0]gt0_rxcharisk_out;
  output [1:0]gt0_rxdisperr_out;
  output [1:0]gt0_rxnotintable_out;
  input gt0_gtprxn_in;
  input gt0_gtprxp_in;
  output gt0_rxbyteisaligned_out;
  output gt0_rxbyterealign_out;
  output gt0_rxcommadet_out;
  input gt0_rxmcommaalignen_in;
  input gt0_rxpcommaalignen_in;
  output [14:0]gt0_dmonitorout_out;
  input gt0_rxlpmhfhold_in;
  input gt0_rxlpmlfhold_in;
  output gt0_rxoutclkfabric_out;
  input gt0_gtrxreset_in;
  input gt0_rxlpmreset_in;
  output gt0_rxresetdone_out;
  input gt0_gttxreset_in;
  output GT0_PLL0RESET_OUT;
  output GT0_PLL0OUTCLK_OUT;
  output GT0_PLL0OUTREFCLK_OUT;
  output GT0_PLL0LOCK_OUT;
  output GT0_PLL0REFCLKLOST_OUT;
  output GT0_PLL1OUTCLK_OUT;
  output GT0_PLL1OUTREFCLK_OUT;
  input sysclk_in;
endmodule
