module just_clock
(
  // GT top level ports

  input  SYSCLK,
  input  GTREFCLK0P,
  input  GTREFCLK0N,
  input  GTREFCLK1P,
  input  GTREFCLK1N
);

  //
  // Ibert refclk internal signals
  //
  wire   gtrefclk0;
  wire   gtrefclk1;
  wire   refclk0;
  wire   refclk1;
  wire   clk;
  wire   extclk;
  wire   gtp_clk;
  wire   sys_clk;

  wire   sys_clk_locked, sys_clk_missing, gtp_clk_locked, gtp_clk_missing;



BUFR BUFR_inst
  (
    .O  (extclk),  
    .I  (SYSCLK)   
   );

IBUFDS_GTE2 u_buf_q0_clk0
  (
    .O            (refclk0),
    .ODIV2        (),
    .CEB          (1'b0),
    .I            (GTREFCLK0P),
    .IB           (GTREFCLK0N)
  );

IBUFDS_GTE2 u_buf_q0_clk1
  (
    .O            (refclk1),
    .ODIV2        (),
    .CEB          (1'b0),
    .I            (GTREFCLK1P),
    .IB           (GTREFCLK1N)
      );

mmcm_gtp GTP_CLK 
  (
    .clk_in1  (refclk1),
    .clk_out1 (gtp_clk),
    .input_clk_stopped(gtp_clk_missing),
    .locked(gtp_clk_locked),
    .reset(probe_out0[1])
  );

mmcm_sys SYS_CLK 
  (
    .clk_in1  (extclk),
    .clk_out1 (sys_clk),
    .input_clk_stopped(sys_clk_missing),
    .locked(sys_clk_locked),
    .reset(probe_out0[0])
  );
   
// Counter


reg [31:0] count = 32'b0;
reg [15:0] ref_count = 10'b0;
reg [31:0] freq  = 32'b0;

   always @(posedge gtp_clk)
      if (ref_count == 9999) begin
         ref_count <= 16'b0;
         end
      else 
         ref_count <= ref_count + 1'b1;

//   always @(posedge gtp_clk)
//      if (ref_count == 9999) begin
//          count <= 32'b0;
//          freq  <= count;
//          end
//      else 
//         count <= count + 1'b1;
         

wire [3:0] probe_in1;
assign probe_in1 = {sys_clk_locked, sys_clk_missing, gtp_clk_locked, gtp_clk_missing}; 

wire [1:0] probe_out0;

vio_0 VIO (
  .clk(refclk1),              // input wire clk
  .probe_in0(ref_count),    // input wire [31 : 0] probe_in0
  .probe_in1(probe_in1),    // input wire [3 : 0] probe_in1
  .probe_out0(probe_out0)  // output wire [1 : 0] probe_out0
);

endmodule
