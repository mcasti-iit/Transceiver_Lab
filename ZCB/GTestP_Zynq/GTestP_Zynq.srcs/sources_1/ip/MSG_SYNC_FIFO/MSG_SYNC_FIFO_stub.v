// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Mar  1 10:20:47 2021
// Host        : IITICUBLAP127 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Progetti/Transceiver_Lab/ZCB/GTestP_Zynq/GTestP_Zynq.srcs/sources_1/ip/MSG_SYNC_FIFO/MSG_SYNC_FIFO_stub.v
// Design      : MSG_SYNC_FIFO
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_4,Vivado 2019.1" *)
module MSG_SYNC_FIFO(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  overflow, empty, valid)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[7:0],wr_en,rd_en,dout[7:0],full,overflow,empty,valid" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [7:0]din;
  input wr_en;
  input rd_en;
  output [7:0]dout;
  output full;
  output overflow;
  output empty;
  output valid;
endmodule
