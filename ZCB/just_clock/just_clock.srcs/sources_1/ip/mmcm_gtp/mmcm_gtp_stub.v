// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Sep 23 12:21:26 2020
// Host        : IITICUBWS052 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Projects/Transceiver/ZCB/just_clock/just_clock.srcs/sources_1/ip/mmcm_gtp/mmcm_gtp_stub.v
// Design      : mmcm_gtp
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module mmcm_gtp(clk_out1, reset, input_clk_stopped, locked, 
  clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,reset,input_clk_stopped,locked,clk_in1" */;
  output clk_out1;
  input reset;
  output input_clk_stopped;
  output locked;
  input clk_in1;
endmodule
