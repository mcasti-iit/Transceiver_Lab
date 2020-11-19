-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 3.6
--  \   \         Application : 7 Series FPGAs Transceivers Wizard
--  /   /         Filename : gtp_zynq_multi_gt.vhd
-- /___/   /\     
-- \   \  /  \ 
--  \___\/\___\
--
--
-- Module GTP_Zynq_multi_gt (a Multi GT Wrapper)
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


--***************************** Entity Declaration ****************************

entity GTP_Zynq_multi_gt is
generic
(
    -- Simulation attributes
    EXAMPLE_SIMULATION             : integer  := 0;      -- Set to 1 for simulation
    WRAPPER_SIM_GTRESET_SPEEDUP    : string   := "FALSE" -- Set to "TRUE" to speed up sim reset
);
port
(
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
    GT0_DRP_BUSY_OUT                        : out  std_logic; 
 GT0_RXPMARESETDONE_OUT  : out  std_logic;

    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
    gt0_drpclk_in                           : in   std_logic;
    gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
    gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
    gt0_drpen_in                            : in   std_logic;
    gt0_drprdy_out                          : out  std_logic;
    gt0_drpwe_in                            : in   std_logic;
    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in                     : in   std_logic;
    gt0_rxuserrdy_in                        : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                : out  std_logic;
    gt0_eyescantrigger_in                   : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    gt0_rxdata_out                          : out  std_logic_vector(31 downto 0);
    gt0_rxusrclk_in                         : in   std_logic;
    gt0_rxusrclk2_in                        : in   std_logic;
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    gt0_rxchariscomma_out                   : out  std_logic_vector(3 downto 0);
    gt0_rxcharisk_out                       : out  std_logic_vector(3 downto 0);
    gt0_rxdisperr_out                       : out  std_logic_vector(3 downto 0);
    gt0_rxnotintable_out                    : out  std_logic_vector(3 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtprxn_in                           : in   std_logic;
    gt0_gtprxp_in                           : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxbyteisaligned_out                 : out  std_logic;
    gt0_rxbyterealign_out                   : out  std_logic;
    gt0_rxcommadet_out                      : out  std_logic;
    gt0_rxmcommaalignen_in                  : in   std_logic;
    gt0_rxpcommaalignen_in                  : in   std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt0_dmonitorout_out                     : out  std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    gt0_rxlpmhfhold_in                      : in   std_logic;
    gt0_rxlpmlfhold_in                      : in   std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    gt0_rxoutclk_out                        : out  std_logic;
    gt0_rxoutclkfabric_out                  : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                        : in   std_logic;
    gt0_rxlpmreset_in                       : in   std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    gt0_rxresetdone_out                     : out  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                        : in   std_logic;


    --____________________________COMMON PORTS________________________________
      GT0_PLL0RESET_IN : in  std_logic;
      GT0_PLL0OUTCLK_IN : in  std_logic;
      GT0_PLL0OUTREFCLK_IN : in  std_logic;
      GT0_PLL1OUTCLK_IN : in  std_logic;
      GT0_PLL1OUTREFCLK_IN : in  std_logic

);


end GTP_Zynq_multi_gt;
    
architecture RTL of GTP_Zynq_multi_gt is
    attribute DowngradeIPIdentifiedWarnings: string;
    attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

    attribute CORE_GENERATION_INFO : string;
    attribute CORE_GENERATION_INFO of RTL : architecture is "GTP_Zynq_multi_gt,gtwizard_v3_6_11,{protocol_file=Start_from_scratch}";


--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;

--***************************** Signal Declarations *****************************

    -- ground and tied_to_vcc_i signals
signal  tied_to_ground_i                :   std_logic;
signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
signal  tied_to_vcc_i                   :   std_logic;
signal   gt0_pll0outclk_i       :   std_logic;
signal   gt0_pll0outrefclk_i    :   std_logic;
signal   gt0_pll1outclk_i       :   std_logic;
signal   gt0_pll1outrefclk_i    :   std_logic;

signal  gt0_mgtrefclktx_i           :   std_logic_vector(1 downto 0);
signal  gt0_mgtrefclkrx_i           :   std_logic_vector(1 downto 0);
 

signal   gt0_pll0clk_i       :   std_logic;
signal   gt0_pll0refclk_i    :   std_logic;
signal   gt0_pll1clk_i       :   std_logic;
signal   gt0_pll1refclk_i    :   std_logic;
    signal    gt0_rst_i                       : std_logic;
      



--*************************** Component Declarations **************************
component GTP_Zynq_GT
generic
(
    -- Simulation attributes
    GT_SIM_GTRESET_SPEEDUP    : string := "FALSE";
    EXAMPLE_SIMULATION        : integer  := 0;  
    TXSYNC_OVRD_IN            : bit    := '0';
    TXSYNC_MULTILANE_IN       : bit    := '0'     
);
port 
(   
    RST_IN                                  : in   std_logic;
    DRP_BUSY_OUT                            : out  std_logic;
 RXPMARESETDONE  : out  std_logic;

    ---------------------------- Channel - DRP Ports  --------------------------
    drpaddr_in                              : in   std_logic_vector(8 downto 0);
    drpclk_in                               : in   std_logic;
    drpdi_in                                : in   std_logic_vector(15 downto 0);
    drpdo_out                               : out  std_logic_vector(15 downto 0);
    drpen_in                                : in   std_logic;
    drprdy_out                              : out  std_logic;
    drpwe_in                                : in   std_logic;
    ------------------------ GTPE2_CHANNEL Clocking Ports ----------------------
    pll0clk_in                              : in   std_logic;
    pll0refclk_in                           : in   std_logic;
    pll1clk_in                              : in   std_logic;
    pll1refclk_in                           : in   std_logic;
    --------------------- RX Initialization and Reset Ports --------------------
    eyescanreset_in                         : in   std_logic;
    rxuserrdy_in                            : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    eyescandataerror_out                    : out  std_logic;
    eyescantrigger_in                       : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    rxdata_out                              : out  std_logic_vector(31 downto 0);
    rxusrclk_in                             : in   std_logic;
    rxusrclk2_in                            : in   std_logic;
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    rxchariscomma_out                       : out  std_logic_vector(3 downto 0);
    rxcharisk_out                           : out  std_logic_vector(3 downto 0);
    rxdisperr_out                           : out  std_logic_vector(3 downto 0);
    rxnotintable_out                        : out  std_logic_vector(3 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gtprxn_in                               : in   std_logic;
    gtprxp_in                               : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    rxbyteisaligned_out                     : out  std_logic;
    rxbyterealign_out                       : out  std_logic;
    rxcommadet_out                          : out  std_logic;
    rxmcommaalignen_in                      : in   std_logic;
    rxpcommaalignen_in                      : in   std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    dmonitorout_out                         : out  std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    rxlpmhfhold_in                          : in   std_logic;
    rxlpmlfhold_in                          : in   std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    rxoutclk_out                            : out  std_logic;
    rxoutclkfabric_out                      : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gtrxreset_in                            : in   std_logic;
    rxlpmreset_in                           : in   std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    rxresetdone_out                         : out  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    gttxreset_in                            : in   std_logic


);
end component;


    constant PLL0_FBDIV_IN      :   integer := 5;
    constant PLL1_FBDIV_IN      :   integer := 1;
    constant PLL0_FBDIV_45_IN   :   integer := 5;
    constant PLL1_FBDIV_45_IN   :   integer := 4;
    constant PLL0_REFCLK_DIV_IN :   integer := 1;
    constant PLL1_REFCLK_DIV_IN :   integer := 1;

--********************************* Main Body of Code**************************

begin                       

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';
    gt0_pll0clk_i    <= GT0_PLL0OUTCLK_IN;  
    gt0_pll0refclk_i <= GT0_PLL0OUTREFCLK_IN; 
    gt0_pll1clk_i    <= GT0_PLL1OUTCLK_IN;  
    gt0_pll1refclk_i <= GT0_PLL1OUTREFCLK_IN; 
    gt0_rst_i        <= GT0_PLL0RESET_IN;
      
   
    --------------------------- GT Instances  -------------------------------   
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0  (X0Y2)
gt0_GTP_Zynq_i : GTP_Zynq_GT
    generic map
    (
        -- Simulation attributes
        GT_SIM_GTRESET_SPEEDUP => WRAPPER_SIM_GTRESET_SPEEDUP,
        EXAMPLE_SIMULATION     => EXAMPLE_SIMULATION,
        TXSYNC_OVRD_IN         => ('0'),
        TXSYNC_MULTILANE_IN    => ('0')
    )
    port map
    (
        RST_IN                          =>      gt0_rst_i,
        DRP_BUSY_OUT                    =>      GT0_DRP_BUSY_OUT,
        RXPMARESETDONE                  =>      GT0_RXPMARESETDONE_OUT,
        ---------------------------- Channel - DRP Ports  --------------------------
        drpaddr_in                      =>      gt0_drpaddr_in,
        drpclk_in                       =>      gt0_drpclk_in,
        drpdi_in                        =>      gt0_drpdi_in,
        drpdo_out                       =>      gt0_drpdo_out,
        drpen_in                        =>      gt0_drpen_in,
        drprdy_out                      =>      gt0_drprdy_out,
        drpwe_in                        =>      gt0_drpwe_in,
        ------------------------ GTPE2_CHANNEL Clocking Ports ----------------------
        pll0clk_in                      =>      gt0_pll0clk_i,
        pll0refclk_in                   =>      gt0_pll0refclk_i,
        pll1clk_in                      =>      gt0_pll1clk_i,
        pll1refclk_in                   =>      gt0_pll1refclk_i,
        --------------------- RX Initialization and Reset Ports --------------------
        eyescanreset_in                 =>      gt0_eyescanreset_in,
        rxuserrdy_in                    =>      gt0_rxuserrdy_in,
        -------------------------- RX Margin Analysis Ports ------------------------
        eyescandataerror_out            =>      gt0_eyescandataerror_out,
        eyescantrigger_in               =>      gt0_eyescantrigger_in,
        ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        rxdata_out                      =>      gt0_rxdata_out,
        rxusrclk_in                     =>      gt0_rxusrclk_in,
        rxusrclk2_in                    =>      gt0_rxusrclk2_in,
        ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
        rxchariscomma_out               =>      gt0_rxchariscomma_out,
        rxcharisk_out                   =>      gt0_rxcharisk_out,
        rxdisperr_out                   =>      gt0_rxdisperr_out,
        rxnotintable_out                =>      gt0_rxnotintable_out,
        ------------------------ Receive Ports - RX AFE Ports ----------------------
        gtprxn_in                       =>      gt0_gtprxn_in,
        gtprxp_in                       =>      gt0_gtprxp_in,
        -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
        rxbyteisaligned_out             =>      gt0_rxbyteisaligned_out,
        rxbyterealign_out               =>      gt0_rxbyterealign_out,
        rxcommadet_out                  =>      gt0_rxcommadet_out,
        rxmcommaalignen_in              =>      gt0_rxmcommaalignen_in,
        rxpcommaalignen_in              =>      gt0_rxpcommaalignen_in,
        ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        dmonitorout_out                 =>      gt0_dmonitorout_out,
        -------------------- Receive Ports - RX Equailizer Ports -------------------
        rxlpmhfhold_in                  =>      gt0_rxlpmhfhold_in,
        rxlpmlfhold_in                  =>      gt0_rxlpmlfhold_in,
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        rxoutclk_out                    =>      gt0_rxoutclk_out,
        rxoutclkfabric_out              =>      gt0_rxoutclkfabric_out,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gtrxreset_in                    =>      gt0_gtrxreset_in,
        rxlpmreset_in                   =>      gt0_rxlpmreset_in,
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        rxresetdone_out                 =>      gt0_rxresetdone_out,
        --------------------- TX Initialization and Reset Ports --------------------
        gttxreset_in                    =>      gt0_gttxreset_in

    );


end RTL;     
