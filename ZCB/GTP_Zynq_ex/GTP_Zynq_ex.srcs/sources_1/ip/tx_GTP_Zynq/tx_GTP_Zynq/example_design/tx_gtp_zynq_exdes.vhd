------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 3.6
--  \   \         Application : 7 Series FPGAs Transceivers Wizard 
--  /   /         Filename : tx_gtp_zynq_exdes.vhd
-- /___/   /\      
-- \   \  /  \ 
--  \___\/\___\
--
--
-- Module tx_GTP_Zynq_exdes
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard
-- 
-- 
-- (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity tx_GTP_Zynq_exdes is
generic
(
    EXAMPLE_CONFIG_INDEPENDENT_LANES        : integer   := 1;
    EXAMPLE_LANE_WITH_START_CHAR            : integer   := 0;    -- specifies lane with unique start frame ch
    EXAMPLE_WORDS_IN_BRAM                   : integer   := 512;  -- specifies amount of data in BRAM
    EXAMPLE_SIM_GTRESET_SPEEDUP             : string    := "FALSE";    -- simulation setting for GT SecureIP model
    STABLE_CLOCK_PERIOD                     : integer   := 8; 
    EXAMPLE_USE_CHIPSCOPE                   : integer   := 1           -- Set to 1 to use Chipscope to drive resets
);
port
(
Q0_CLK1_GTREFCLK_PAD_N_IN               : in   std_logic;
Q0_CLK1_GTREFCLK_PAD_P_IN               : in   std_logic;
    DRP_CLK_IN_P                            : in   std_logic;
    DRP_CLK_IN_N                            : in   std_logic;
GTTX_RESET_IN                           : in   std_logic;
GTRX_RESET_IN                           : in   std_logic;
PLL0_RESET_IN                           : in   std_logic; 
PLL1_RESET_IN                           : in   std_logic;
    TXN_OUT                                 : out  std_logic;
    TXP_OUT                                 : out  std_logic
);


end tx_GTP_Zynq_exdes;
    
architecture RTL of tx_GTP_Zynq_exdes is
    attribute DowngradeIPIdentifiedWarnings: string;
    attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

    attribute CORE_GENERATION_INFO : string;
    attribute CORE_GENERATION_INFO of RTL : architecture is "tx_GTP_Zynq,gtwizard_v3_6_11,{protocol_file=Start_from_scratch}";

--**************************Component Declarations*****************************
    
component tx_GTP_Zynq_support
generic
(
    -- Simulation attributes
    EXAMPLE_SIM_GTRESET_SPEEDUP    : string    := "FALSE";    -- Set to TRUE to speed up sim reset
    STABLE_CLOCK_PERIOD            : integer   := 8 
);
port
(
    SOFT_RESET_TX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_N_IN               : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_P_IN               : in   std_logic;

    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;
 
    GT0_TXUSRCLK_OUT                        : out  std_logic;
    GT0_TXUSRCLK2_OUT                       : out  std_logic;

    --_________________________________________________________________________
    --GT0  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
    gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
    gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
    gt0_drpen_in                            : in   std_logic;
    gt0_drprdy_out                          : out  std_logic;
    gt0_drpwe_in                            : in   std_logic;
    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in                     : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                : out  std_logic;
    gt0_eyescantrigger_in                   : in   std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt0_dmonitorout_out                     : out  std_logic_vector(14 downto 0);
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                        : in   std_logic;
    gt0_rxlpmreset_in                       : in   std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                        : in   std_logic;
    gt0_txuserrdy_in                        : in   std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt0_txdata_in                           : in   std_logic_vector(15 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt0_gtptxn_out                          : out  std_logic;
    gt0_gtptxp_out                          : out  std_logic;
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt0_txoutclkfabric_out                  : out  std_logic;
    gt0_txoutclkpcs_out                     : out  std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt0_txresetdone_out                     : out  std_logic;

    --____________________________COMMON PORTS________________________________
         GT0_PLL0OUTCLK_OUT  : out std_logic;
         GT0_PLL0OUTREFCLK_OUT  : out std_logic;
         GT0_PLL0LOCK_OUT  : out std_logic;
         GT0_PLL0REFCLKLOST_OUT  : out std_logic;    
         GT0_PLL1OUTCLK_OUT  : out std_logic;
         GT0_PLL1OUTREFCLK_OUT  : out std_logic;

        sysclk_in : in std_logic
);
end component;



component tx_GTP_Zynq_GT_FRAME_GEN 
generic
(
     WORDS_IN_BRAM    : integer := 512
);
port
(
    -- User Interface
TX_DATA_OUT             : out   std_logic_vector(79 downto 0);
TXCTRL_OUT              : out   std_logic_vector(7 downto 0); 
    -- System Interface
USER_CLK                : in    std_logic;      
SYSTEM_RESET            : in    std_logic
); 
end component;

component tx_GTP_Zynq_GT_FRAME_CHECK 
generic
(
    RX_DATA_WIDTH            : integer := 16;
    RXCTRL_WIDTH             : integer := 2; 
    WORDS_IN_BRAM            : integer := 256;
    CHANBOND_SEQ_LEN         : integer := 1;
START_OF_PACKET_CHAR     : std_logic_vector ( 15 downto 0)  := x"027c"
);
port
(
    -- User Interface
    RX_DATA_IN               : in  std_logic_vector((RX_DATA_WIDTH-1) downto 0);
RXENMCOMMADET_OUT        : out std_logic;
RXENPCOMMADET_OUT        : out std_logic;

    -- Error Monitoring
ERROR_COUNT_OUT          : out std_logic_vector(7 downto 0);

    -- Track Data
TRACK_DATA_OUT           : out std_logic;

 

    -- System Interface
USER_CLK                 : in std_logic;       
SYSTEM_RESET             : in std_logic
);
end component;

component vio_0 
port (
    clk : in std_logic;
    probe_in0 : in std_logic_vector(0 downto 0);
    probe_out0 : out std_logic_vector(0 downto 0)
);
end component;

component ila_0 
port (
    clk : in std_logic;
    probe0 : in std_logic_vector(79 downto 0);
    probe1: in std_logic_vector(7 downto 0);
    probe2: in std_logic_vector(0 downto 0);
    probe3: in std_logic_vector(1 downto 0);
    probe4: in std_logic_vector(7 downto 0);
    probe5: in std_logic_vector(0 downto 0);
    probe6: in std_logic_vector(0 downto 0)
); 
end component;

component ila_1 
port (
    clk : in std_logic;
    probe0: in std_logic_vector(0 downto 0);
    probe1: in std_logic_vector(0 downto 0)
); 
end component;

--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;

--************************** Register Declarations ****************************
attribute ASYNC_REG                        : string;
signal   gt_txfsmresetdone_i             : std_logic;
signal   gt_rxfsmresetdone_i             : std_logic;
signal   gt_txfsmresetdone_r             : std_logic;
signal   gt_txfsmresetdone_r2            : std_logic;
attribute ASYNC_REG of gt_txfsmresetdone_r     : signal is "TRUE";
attribute ASYNC_REG of gt_txfsmresetdone_r2     : signal is "TRUE";
signal   gt0_txfsmresetdone_i            : std_logic;
signal   gt0_rxfsmresetdone_i            : std_logic;
signal   gt0_txfsmresetdone_r            : std_logic;
signal   gt0_txfsmresetdone_r2           : std_logic;
attribute ASYNC_REG of gt0_txfsmresetdone_r     : signal is "TRUE";
attribute ASYNC_REG of gt0_txfsmresetdone_r2     : signal is "TRUE";



--**************************** Wire Declarations ******************************
    -------------------------- GT Wrapper Wires ------------------------------
    --________________________________________________________________________
    --________________________________________________________________________
    --GT0  (X0Y2)

    ---------------------------- Channel - DRP Ports  --------------------------
    signal  gt0_drpaddr_i                   : std_logic_vector(8 downto 0);
    signal  gt0_drpdi_i                     : std_logic_vector(15 downto 0);
    signal  gt0_drpdo_i                     : std_logic_vector(15 downto 0);
    signal  gt0_drpen_i                     : std_logic;
    signal  gt0_drprdy_i                    : std_logic;
    signal  gt0_drpwe_i                     : std_logic;
    --------------------- RX Initialization and Reset Ports --------------------
    signal  gt0_eyescanreset_i              : std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    signal  gt0_eyescandataerror_i          : std_logic;
    signal  gt0_eyescantrigger_i            : std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    signal  gt0_dmonitorout_i               : std_logic_vector(14 downto 0);
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    signal  gt0_gtrxreset_i                 : std_logic;
    signal  gt0_rxlpmreset_i                : std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    signal  gt0_gttxreset_i                 : std_logic;
    signal  gt0_txuserrdy_i                 : std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    signal  gt0_txdata_i                    : std_logic_vector(15 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    signal  gt0_gtptxn_i                    : std_logic;
    signal  gt0_gtptxp_i                    : std_logic;
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    signal  gt0_txoutclk_i                  : std_logic;
    signal  gt0_txoutclkfabric_i            : std_logic;
    signal  gt0_txoutclkpcs_i               : std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    signal  gt0_txresetdone_i               : std_logic;



    --____________________________COMMON PORTS________________________________
    -------------------------- Common Block - PLL Ports ------------------------
    signal  gt0_pll0lock_i                  : std_logic;
    signal  gt0_pll0refclklost_i            : std_logic;
    signal  gt0_pll0reset_i                 : std_logic;



    ------------------------------- Global Signals -----------------------------
signal  gt0_tx_system_reset_c           : std_logic;
signal  gt0_rx_system_reset_c           : std_logic;
signal  tied_to_ground_i                : std_logic;
signal  tied_to_ground_vec_i            : std_logic_vector(63 downto 0);
signal  tied_to_vcc_i                   : std_logic;
signal  tied_to_vcc_vec_i               : std_logic_vector(7 downto 0);
signal  drpclk_in_i                     : std_logic;
signal  DRPCLK_IN                       : std_logic;
 
signal  GTTXRESET_IN                    : std_logic;
signal  GTRXRESET_IN                    : std_logic;
signal  PLL0RESET_IN                    : std_logic;
signal  PLL1RESET_IN                    : std_logic;


attribute keep: string;
   ------------------------------- User Clocks ---------------------------------
signal    gt0_txusrclk_i                  : std_logic; 
signal    gt0_txusrclk2_i                 : std_logic; 
signal    gt0_rxusrclk_i                  : std_logic; 
signal    gt0_rxusrclk2_i                 : std_logic; 
 
 

    ----------------------------- Reference Clocks ----------------------------
signal    q0_clk1_refclk_i                : std_logic;


    ----------------------- Frame check/gen Module Signals --------------------
    
signal    gt0_matchn_i                    : std_logic;
signal    gt0_txcharisk_float_i           : std_logic_vector(5 downto 0);
signal    gt0_txdata_float16_i            : std_logic_vector(15 downto 0);
signal    gt0_txdata_float_i              : std_logic_vector(47 downto 0);
signal    gt0_track_data_i                : std_logic;
signal    gt0_block_sync_i                : std_logic;
signal    gt0_error_count_i               : std_logic_vector(7 downto 0);
signal    gt0_frame_check_reset_i         : std_logic;
signal    gt0_inc_in_i                    : std_logic;
signal    gt0_inc_out_i                   : std_logic;
signal    gt0_unscrambled_data_i          : std_logic_vector(15 downto 0);

signal    reset_on_data_error_i           : std_logic;
signal    track_data_out_i                : std_logic;
signal    track_data_out_ila_i : std_logic_vector(0 downto 0);

    ----------------------- Chipscope Signals ---------------------------------

    signal  tx_data_vio_control_i           : std_logic_vector(35 downto 0);
    signal  rx_data_vio_control_i           : std_logic_vector(35 downto 0);
    signal  shared_vio_control_i            : std_logic_vector(35 downto 0);
    signal  ila_control_i                   : std_logic_vector(35 downto 0);
    signal  channel_drp_vio_control_i       : std_logic_vector(35 downto 0);
    signal  common_drp_vio_control_i        : std_logic_vector(35 downto 0);
    signal  tx_data_vio_async_in_i          : std_logic_vector(31 downto 0);
    signal  tx_data_vio_sync_in_i           : std_logic_vector(31 downto 0);
    signal  tx_data_vio_async_out_i         : std_logic_vector(31 downto 0);
    signal  tx_data_vio_sync_out_i          : std_logic_vector(31 downto 0);
    signal  rx_data_vio_async_in_i          : std_logic_vector(31 downto 0);
    signal  rx_data_vio_sync_in_i           : std_logic_vector(31 downto 0);
    signal  rx_data_vio_async_out_i         : std_logic_vector(31 downto 0);
    signal  rx_data_vio_sync_out_i          : std_logic_vector(31 downto 0);
    signal  shared_vio_in_i                 : std_logic_vector(31 downto 0);
    signal  shared_vio_out_i                : std_logic_vector(31 downto 0);
    signal  ila_in_i                        : std_logic_vector(163 downto 0);
    signal  channel_drp_vio_async_in_i      : std_logic_vector(31 downto 0);
    signal  channel_drp_vio_sync_in_i       : std_logic_vector(31 downto 0);
    signal  channel_drp_vio_async_out_i     : std_logic_vector(31 downto 0);
    signal  channel_drp_vio_sync_out_i      : std_logic_vector(31 downto 0);
    signal  common_drp_vio_async_in_i       : std_logic_vector(31 downto 0);
    signal  common_drp_vio_sync_in_i        : std_logic_vector(31 downto 0);
    signal  common_drp_vio_async_out_i      : std_logic_vector(31 downto 0);
    signal  common_drp_vio_sync_out_i       : std_logic_vector(31 downto 0);

    signal  gt0_tx_data_vio_async_in_i      : std_logic_vector(31 downto 0);
    signal  gt0_tx_data_vio_sync_in_i       : std_logic_vector(31 downto 0);
    signal  gt0_tx_data_vio_async_out_i     : std_logic_vector(31 downto 0);
    signal  gt0_tx_data_vio_sync_out_i      : std_logic_vector(31 downto 0);
    signal  gt0_rx_data_vio_async_in_i      : std_logic_vector(31 downto 0);
    signal  gt0_rx_data_vio_sync_in_i       : std_logic_vector(31 downto 0);
    signal  gt0_rx_data_vio_async_out_i     : std_logic_vector(31 downto 0);
    signal  gt0_rx_data_vio_sync_out_i      : std_logic_vector(31 downto 0);
    signal  gt0_ila_in_i                    : std_logic_vector(163 downto 0);
    signal  gt0_channel_drp_vio_async_in_i  : std_logic_vector(31 downto 0);
    signal  gt0_channel_drp_vio_sync_in_i   : std_logic_vector(31 downto 0);
    signal  gt0_channel_drp_vio_async_out_i : std_logic_vector(31 downto 0);
    signal  gt0_channel_drp_vio_sync_out_i  : std_logic_vector(31 downto 0);
    signal  gt0_common_drp_vio_async_in_i   : std_logic_vector(31 downto 0);
    signal  gt0_common_drp_vio_sync_in_i    : std_logic_vector(31 downto 0);
    signal  gt0_common_drp_vio_async_out_i  : std_logic_vector(31 downto 0);
    signal  gt0_common_drp_vio_sync_out_i   : std_logic_vector(31 downto 0);


signal    gttxreset_i                     : std_logic;
signal    gtrxreset_i                     : std_logic;

signal    user_tx_reset_i                 : std_logic;
signal    user_rx_reset_i                 : std_logic;
signal    tx_vio_clk_i                    : std_logic;
signal    tx_vio_clk_mux_out_i            : std_logic;    
signal    rx_vio_ila_clk_i                : std_logic;
signal    rx_vio_ila_clk_mux_out_i        : std_logic;    

signal    pll0reset_i                     : std_logic;
signal    pll1reset_i                     : std_logic;
signal    pll0pd_i                        : std_logic;
signal    pll1pd_i                        : std_logic;


   signal zero_vector_rx_80 : std_logic_vector ((80 -16) -1 downto 0) := (others => '0');
   signal zero_vector_rx_8 : std_logic_vector ((8 -2) -1 downto 0) := (others => '0');
  signal gt0_rxdata_ila : std_logic_vector (79 downto 0);
  signal gt0_rxdatavalid_ila : std_logic_vector (1 downto 0);
  signal gt0_rxcharisk_ila : std_logic_vector (7 downto 0);
  signal gt0_txmmcm_lock_ila : std_logic_vector (0 downto 0);
  signal gt0_rxmmcm_lock_ila : std_logic_vector (0 downto 0);
  signal gt0_rxresetdone_ila : std_logic_vector (0 downto 0);
  signal gt0_txresetdone_ila : std_logic_vector (0 downto 0);
  signal tied_to_ground_ila_i : std_logic_vector (0 downto 0);
  -- update with the actual reset name
  signal soft_reset_i  : std_logic;
  signal soft_reset_vio_i  : std_logic_vector (0 downto 0);
  signal gt0_rxfsmresetdone_s : std_logic_vector(0 downto 0);


   function and_reduce(arg: std_logic_vector) return std_logic is
   variable result: std_logic;
    begin
   result := '1';
   for i in arg'range loop
       result := result and arg(i);
   end loop;
        return result;
    end;


--**************************** Main Body of Code *******************************
begin

    --  Static signal Assigments
tied_to_ground_i                             <= '0';
tied_to_ground_vec_i                         <= x"0000000000000000";
tied_to_vcc_i                                <= '1';
tied_to_vcc_vec_i                            <= "11111111";

 
    ----------------------------- The GT Wrapper -----------------------------
    
    -- Use the instantiation template in the example directory to add the GT wrapper to your design.
    -- In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    -- checker. The GTs will reset, then attempt to align and transmit data. If channel bonding is 
    -- enabled, bonding should occur after alignment
    -- While connecting the GT TX/RX Reset ports below, please add a delay of
    -- minimum 500ns as mentioned in AR 43482.

    
    tx_GTP_Zynq_support_i : tx_GTP_Zynq_support
    generic map
    (
        EXAMPLE_SIM_GTRESET_SPEEDUP     =>      EXAMPLE_SIM_GTRESET_SPEEDUP,
        STABLE_CLOCK_PERIOD             =>      STABLE_CLOCK_PERIOD
    )
    port map
    (
        soft_reset_tx_in                =>      soft_reset_i,
        DONT_RESET_ON_DATA_ERROR_IN     =>      tied_to_ground_i,
    Q0_CLK1_GTREFCLK_PAD_N_IN => Q0_CLK1_GTREFCLK_PAD_N_IN,
    Q0_CLK1_GTREFCLK_PAD_P_IN => Q0_CLK1_GTREFCLK_PAD_P_IN,
        GT0_TX_FSM_RESET_DONE_OUT       =>      gt0_txfsmresetdone_i,
        GT0_RX_FSM_RESET_DONE_OUT       =>      gt0_rxfsmresetdone_i,
        GT0_DATA_VALID_IN               =>      tied_to_ground_i,
 
    GT0_TXUSRCLK_OUT => gt0_txusrclk_i,
    GT0_TXUSRCLK2_OUT => gt0_txusrclk2_i,

        --_____________________________________________________________________
        --_____________________________________________________________________
        --GT0  (X0Y2)

        ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      gt0_drpaddr_i,
        gt0_drpdi_in                    =>      gt0_drpdi_i,
        gt0_drpdo_out                   =>      gt0_drpdo_i,
        gt0_drpen_in                    =>      gt0_drpen_i,
        gt0_drprdy_out                  =>      gt0_drprdy_i,
        gt0_drpwe_in                    =>      gt0_drpwe_i,
        --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      tied_to_ground_i,
        -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out        =>      gt0_eyescandataerror_i,
        gt0_eyescantrigger_in           =>      tied_to_ground_i,
        ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        gt0_dmonitorout_out             =>      gt0_dmonitorout_i,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      tied_to_ground_i,
        gt0_rxlpmreset_in               =>      gt0_rxlpmreset_i,
        --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      tied_to_ground_i,
        gt0_txuserrdy_in                =>      tied_to_vcc_i,
        ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
        gt0_txdata_in                   =>      gt0_txdata_i,
        --------------- Transmit Ports - TX Configurable Driver Ports --------------
        gt0_gtptxn_out                  =>      TXN_OUT,
        gt0_gtptxp_out                  =>      TXP_OUT,
        ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        gt0_txoutclkfabric_out          =>      gt0_txoutclkfabric_i,
        gt0_txoutclkpcs_out             =>      gt0_txoutclkpcs_i,
        ------------- Transmit Ports - TX Initialization and Reset Ports -----------
        gt0_txresetdone_out             =>      gt0_txresetdone_i,



    --____________________________COMMON PORTS________________________________
         GT0_PLL0OUTCLK_OUT  => open,
         GT0_PLL0OUTREFCLK_OUT  => open,
         GT0_PLL0LOCK_OUT  => open,
         GT0_PLL0REFCLKLOST_OUT  => open,    
         GT0_PLL1OUTCLK_OUT  => open,
         GT0_PLL1OUTREFCLK_OUT  => open,
       sysclk_in => drpclk_in_i
    );

   IBUFDS_DRP_CLK : IBUFDS
   port map
     (
        I  => DRP_CLK_IN_P,
        IB => DRP_CLK_IN_N,
        O  => DRPCLK_IN
     );
 
   DRP_CLK_BUFG : BUFG 
   port map 
    (
        I    => DRPCLK_IN,
        O    => drpclk_in_i 
    );

 

    -------------------------- User Module Resets -----------------------------
    -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
    -- are held in reset till the RESETDONE goes high. 
    -- The RESETDONE is registered a couple of times on USRCLK2 and connected 
    -- to the reset of the modules
    
process(gt0_txusrclk2_i,gt0_txfsmresetdone_i)
    begin
        if(gt0_txfsmresetdone_i = '0') then
            gt0_txfsmresetdone_r  <= '0'   after DLY;
            gt0_txfsmresetdone_r2 <= '0'   after DLY;
elsif (gt0_txusrclk2_i'event and gt0_txusrclk2_i = '1') then
            gt0_txfsmresetdone_r  <= gt0_txfsmresetdone_i   after DLY;
            gt0_txfsmresetdone_r2 <= gt0_txfsmresetdone_r   after DLY;
        end if;
    end process;


    ------------------------------ Frame Generators ---------------------------
    -- The example design uses Block RAM based frame generators to provide test
    -- data to the GTs for transmission. By default the frame generators are 
    -- loaded with an incrementing data sequence that includes commas/alignment
    -- characters for alignment. If your protocol uses channel bonding, the 
    -- frame generator will also be preloaded with a channel bonding sequence.
    
    -- You can modify the data transmitted by changing the INIT values of the frame
    -- generator in this file. Pay careful attention to bit order and the spacing
    -- of your control and alignment characters.

    gt0_frame_gen : tx_GTP_Zynq_GT_FRAME_GEN
    generic map
    (
        WORDS_IN_BRAM                   =>      EXAMPLE_WORDS_IN_BRAM
    )
    port map
    (
        -- User Interface
        TX_DATA_OUT(79 downto 32)       =>      gt0_txdata_float_i,
        TX_DATA_OUT(15 downto 0)        =>      gt0_txdata_float16_i,
        TX_DATA_OUT(31 downto 16)       =>      gt0_txdata_i,
        TXCTRL_OUT                      =>      open,
        -- System Interface
        USER_CLK                        =>      gt0_txusrclk2_i,
        SYSTEM_RESET                    =>      gt0_tx_system_reset_c
    );

    ---------------------------------- Frame Checkers -------------------------
    -- The example design uses Block RAM based frame checkers to verify incoming  
    -- data. By default the frame generators are loaded with a data sequence that 
    -- matches the outgoing sequence of the frame generators for the TX ports.
    
    -- You can modify the expected data sequence by changing the INIT values of the frame
    -- checkers in this file. Pay careful attention to bit order and the spacing
    -- of your control and alignment characters.
    
    -- When the frame checker receives data, it attempts to synchronise to the 
    -- incoming pattern by looking for the first sequence in the pattern. Once it 
    -- finds the first sequence, it increments through the sequence, and indicates an 
    -- error whenever the next value received does not match the expected value.










-------------------------------------------------------------------------------
----------------------------- Debug Signals assignment -----------------------

------------ optional Ports assignments --------------
------------------------------------------------------ 

    -- assign resets for frame_gen modules
gt0_tx_system_reset_c                        <= not gt0_txfsmresetdone_r2;

    -- assign resets for frame_check modules


gt0_rxlpmreset_i <= '0';
gt0_drpaddr_i <= (others => '0');
gt0_drpdi_i <= (others => '0');
gt0_drpen_i <= '0';
gt0_drpwe_i <= '0';

chipscope : if EXAMPLE_USE_CHIPSCOPE = 1 generate
   soft_reset_i <= soft_reset_vio_i(0);
end generate chipscope;

no_chipscope : if EXAMPLE_USE_CHIPSCOPE = 0 generate
  soft_reset_i <= tied_to_ground_i;
end generate no_chipscope;
tied_to_ground_ila_i(0) <= '0';
gt0_rxfsmresetdone_s(0) <= gt0_rxfsmresetdone_i;
-- vio core insertion for driving soft_reset_i
vio_gt_inst: vio_0 port map (
  clk        => drpclk_in_i,                -- input clk
  probe_in0 => gt0_rxfsmresetdone_s,
  probe_out0 => soft_reset_vio_i  
);



   gt0_txmmcm_lock_ila(0) <= '0';

   gt0_rxmmcm_lock_ila(0) <= '0';
gt0_rxresetdone_ila(0) <= '0';
gt0_txresetdone_ila(0) <= gt0_txresetdone_i;

track_data_out_ila_i(0) <= track_data_out_i;


-- ila core insertion for observing data and control signals
ila_tx0_inst: ila_1 port map (
  clk        => gt0_txusrclk_i,        -- input clk
  probe0     => gt0_txmmcm_lock_ila,
  probe1     => gt0_txresetdone_ila
);


end RTL;


