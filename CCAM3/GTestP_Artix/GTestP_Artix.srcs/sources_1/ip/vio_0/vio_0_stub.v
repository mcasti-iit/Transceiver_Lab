// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue Aug 31 08:57:41 2021
// Host        : IITICUBWS052 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Projects/Transceiver_Lab/CCAM3/GTestP_Artix/GTestP_Artix.srcs/sources_1/ip/vio_0/vio_0_stub.v
// Design      : vio_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a50tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2020.1" *)
module vio_0(clk, probe_in0, probe_out0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[15:0],probe_out0[15:0]" */;
  input clk;
  input [15:0]probe_in0;
  output [15:0]probe_out0;
endmodule
