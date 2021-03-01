// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Feb 22 10:20:16 2021
// Host        : IITICUBLAP127 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Progetti/Transceiver_Lab/ZCB/GTestP_Zynq/GTestP_Zynq.srcs/sources_1/ip/VIO_GTP/VIO_GTP_stub.v
// Design      : VIO_GTP
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2019.1" *)
module VIO_GTP(clk, probe_in0, probe_out0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[15:0],probe_out0[15:0]" */;
  input clk;
  input [15:0]probe_in0;
  output [15:0]probe_out0;
endmodule
