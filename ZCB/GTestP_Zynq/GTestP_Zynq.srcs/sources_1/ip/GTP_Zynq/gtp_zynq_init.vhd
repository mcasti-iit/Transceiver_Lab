------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 3.6
--  \   \         Application : 7 Series FPGAs Transceivers Wizard 
--  /   /         Filename : gtp_zynq_init.vhd
-- /___/   /\      
-- \   \  /  \ 
--  \___\/\___\
--
--  Description : This module instantiates the modules required for
--                reset and initialisation of the Transceiver
--
-- Module GTP_Zynq_init
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
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity GTP_Zynq_init is
generic
(
    EXAMPLE_SIM_GTRESET_SPEEDUP             : string    := "FALSE";     -- simulation setting for GT SecureIP model
    EXAMPLE_SIMULATION                      : integer   := 0;          -- Set to 1 for simulation
 
    STABLE_CLOCK_PERIOD                     : integer   := 10;  
        -- Set to 1 for simulation
    EXAMPLE_USE_CHIPSCOPE                   : integer   := 0           -- Set to 1 to use Chipscope to drive resets

);
port
(
    SYSCLK_IN                               : in   std_logic;
    SOFT_RESET_RX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    GT0_DRP_BUSY_OUT                        : out  std_logic;
    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;
    --_________________________________________________________________________
    --GT0  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
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
    gt0_rxdata_out                          : out  std_logic_vector(15 downto 0);
    gt0_rxusrclk_in                         : in   std_logic;
    gt0_rxusrclk2_in                        : in   std_logic;
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    gt0_rxchariscomma_out                   : out  std_logic_vector(1 downto 0);
    gt0_rxcharisk_out                       : out  std_logic_vector(1 downto 0);
    gt0_rxdisperr_out                       : out  std_logic_vector(1 downto 0);
    gt0_rxnotintable_out                    : out  std_logic_vector(1 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtprxn_in                           : in   std_logic;
    gt0_gtprxp_in                           : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxbyteisaligned_out                 : out  std_logic;
    gt0_rxbyterealign_out                   : out  std_logic;
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
   GT0_PLL0RESET_OUT  : out std_logic;
         GT0_PLL0OUTCLK_IN  : in std_logic;
         GT0_PLL0OUTREFCLK_IN  : in std_logic;
         GT0_PLL0LOCK_IN  : in std_logic;
         GT0_PLL0REFCLKLOST_IN  : in std_logic;    
         GT0_PLL1OUTCLK_IN  : in std_logic;
         GT0_PLL1OUTREFCLK_IN  : in std_logic

);

end GTP_Zynq_init;
    
architecture RTL of GTP_Zynq_init is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

--**************************Component Declarations*****************************


component GTP_Zynq_multi_gt 
generic
(
    -- Simulation attributes
    EXAMPLE_SIMULATION             : integer   := 0;      -- Set to 1 for simulation
    WRAPPER_SIM_GTRESET_SPEEDUP    : string    := "FALSE" -- Set to "TRUE" to speed up sim reset

);
port
(

    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
    GT0_DRP_BUSY_OUT                        : out  std_logic;
    GT0_RXPMARESETDONE_OUT                        : out  std_logic;

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
    gt0_rxdata_out                          : out  std_logic_vector(15 downto 0);
    gt0_rxusrclk_in                         : in   std_logic;
    gt0_rxusrclk2_in                        : in   std_logic;
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    gt0_rxchariscomma_out                   : out  std_logic_vector(1 downto 0);
    gt0_rxcharisk_out                       : out  std_logic_vector(1 downto 0);
    gt0_rxdisperr_out                       : out  std_logic_vector(1 downto 0);
    gt0_rxnotintable_out                    : out  std_logic_vector(1 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtprxn_in                           : in   std_logic;
    gt0_gtprxp_in                           : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxbyteisaligned_out                 : out  std_logic;
    gt0_rxbyterealign_out                   : out  std_logic;
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
end component;

component GTP_Zynq_TX_STARTUP_FSM
  Generic(
           EXAMPLE_SIMULATION       : integer := 0;
           STABLE_CLOCK_PERIOD      : integer range 4 to 250 := 8; --Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   : integer range 2 to 8  := 8; 
           TX_PLL0_USED             : boolean := False;           -- the TX and RX Reset FSMs must
           RX_PLL0_USED             : boolean := False;           -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   : boolean := True             -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                  -- is enough. For single-lane applications the automatic alignment is 
                                                                  -- sufficient              
         );     
    Port ( STABLE_CLOCK             : in  STD_LOGIC;              --Stable Clock, either a stable clock from the PCB
                                                                  --or reference-clock present at startup.
           TXUSERCLK                : in  STD_LOGIC;              --TXUSERCLK as used in the design
           SOFT_RESET               : in  STD_LOGIC;              --User Reset, can be pulled any time
           PLL0REFCLKLOST           : in  STD_LOGIC;              --PLL0 Reference-clock for the GT is lost
           PLL1REFCLKLOST           : in  STD_LOGIC;              --PLL1 Reference-clock for the GT is lost
           PLL0LOCK                 : in  STD_LOGIC;              --Lock Detect from the PLL0 of the GT
           PLL1LOCK                 : in  STD_LOGIC;              --Lock Detect from the PLL1 of the GT
           TXRESETDONE              : in  STD_LOGIC;      
           MMCM_LOCK                : in  STD_LOGIC;      
           GTTXRESET                : out STD_LOGIC:='0';      
           MMCM_RESET               : out STD_LOGIC:='0';      
           PLL0_RESET               : out STD_LOGIC:='0';        --Reset PLL0
           PLL1_RESET               : out STD_LOGIC:='0';        --Reset PLL1
           TX_FSM_RESET_DONE        : out STD_LOGIC:='0';        --Reset-sequence has sucessfully been finished.
           TXUSERRDY                : out STD_LOGIC:='0';
           RUN_PHALIGNMENT          : out STD_LOGIC:='0';
           RESET_PHALIGNMENT        : out STD_LOGIC:='0';
           PHALIGNMENT_DONE         : in  STD_LOGIC;
           
           RETRY_COUNTER            : out  STD_LOGIC_VECTOR (RETRY_COUNTER_BITWIDTH-1 downto 0):=(others=>'0')-- Number of 
                                                            -- Retries it took to get the transceiver up and running
           );
end component;

component GTP_Zynq_RX_STARTUP_FSM
  Generic(
           EXAMPLE_SIMULATION       : integer := 0;
           STABLE_CLOCK_PERIOD      : integer range 4 to 250 := 8; --Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   : integer range 2 to 8  := 8; 
           TX_PLL0_USED             : boolean := False;           -- the TX and RX Reset FSMs must
           RX_PLL0_USED             : boolean := False;           -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   : boolean := True             -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                  -- is enough. For single-lane applications the automatic alignment is 
                                                                  -- sufficient                         
         );     
    Port ( STABLE_CLOCK             : in  STD_LOGIC;        --Stable Clock, either a stable clock from the PCB
                                                            --or reference-clock present at startup.
           RXUSERCLK                : in  STD_LOGIC;        --RXUSERCLK as used in the design
           SOFT_RESET               : in  STD_LOGIC;        --User Reset, can be pulled any time
           RXPMARESETDONE               : in  STD_LOGIC;              
           RXOUTCLK               : in  STD_LOGIC; 
             
           PLL0REFCLKLOST           : in  STD_LOGIC;        --PLL0 Reference-clock for the GT is lost
           PLL1REFCLKLOST           : in  STD_LOGIC;        --PLL1 Reference-clock for the GT is lost
           PLL0LOCK                 : in  STD_LOGIC;        --Lock Detect from the PLL0 of the GT
           PLL1LOCK                 : in  STD_LOGIC;        --Lock Detect from the PLL1 of the GT
           RXRESETDONE              : in  STD_LOGIC;
           MMCM_LOCK                : in  STD_LOGIC;
           RECCLK_STABLE            : in  STD_LOGIC;
           RECCLK_MONITOR_RESTART   : in  STD_LOGIC;
           DATA_VALID               : in  STD_LOGIC;
           TXUSERRDY                : in  STD_LOGIC;       --TXUSERRDY from GT 
           DONT_RESET_ON_DATA_ERROR : in  STD_LOGIC;
           GTRXRESET                : out STD_LOGIC:='0';
           MMCM_RESET               : out STD_LOGIC:='0';
           PLL0_RESET               : out STD_LOGIC:='0';  --Reset PLL0 (only if RX uses PLL0)
           PLL1_RESET               : out STD_LOGIC:='0';  --Reset PLL1 (only if RX uses PLL1)
           RX_FSM_RESET_DONE        : out STD_LOGIC:='0';  --Reset-sequence has sucessfully been finished.
           RXUSERRDY                : out STD_LOGIC:='0';
           RUN_PHALIGNMENT          : out STD_LOGIC;
           PHALIGNMENT_DONE         : in  STD_LOGIC; 
           RESET_PHALIGNMENT        : out STD_LOGIC:='0';           
           RETRY_COUNTER            : out STD_LOGIC_VECTOR (RETRY_COUNTER_BITWIDTH-1 downto 0):=(others=>'0')-- Number of 
                                                            -- Retries it took to get the transceiver up and running
           );
end component;






  function get_cdrlock_time(is_sim : in integer) return integer is
    variable lock_time: integer;
  begin
    if (is_sim = 1) then
      lock_time := 1000;
    else
      lock_time := 100000 / integer(3.125); --Typical CDR lock time is 50,000UI as per DS183
    end if;
    return lock_time;
  end function;


--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;
    constant RX_CDRLOCK_TIME      : integer := get_cdrlock_time(EXAMPLE_SIMULATION);       -- 200us
    constant WAIT_TIME_CDRLOCK    : integer := RX_CDRLOCK_TIME / STABLE_CLOCK_PERIOD;      -- 200 us time-out



    -------------------------- GT Wrapper Wires ------------------------------
    signal   gt0_txpmaresetdone_i            : std_logic;
    signal   gt0_rxpmaresetdone_i            : std_logic;
    signal   gt0_txresetdone_i               : std_logic;
    signal   gt0_rxresetdone_i               : std_logic;
    signal   gt0_txresetdone_ii              : std_logic;
    signal   gt0_rxresetdone_ii              : std_logic;
    signal   gt0_gttxreset_i                 : std_logic;
    signal   gt0_gttxreset_t                 : std_logic;
    signal   gt0_gtrxreset_i                 : std_logic;
    signal   gt0_gtrxreset_t                 : std_logic;
    signal   gt0_txuserrdy_i                 : std_logic;
    signal   gt0_txuserrdy_t                 : std_logic;
    signal   gt0_rxuserrdy_i                 : std_logic;
    signal   gt0_rxuserrdy_t                 : std_logic;




    signal   gt0_pll0reset_i                 : std_logic;
    signal   gt0_pll0reset_t                 : std_logic;
    signal   gt0_pll0refclklost_i            : std_logic;
    signal   gt0_pll0lock_i                  : std_logic;


    ------------------------------- Global Signals -----------------------------
    signal  tied_to_ground_i                : std_logic;
    signal  tied_to_vcc_i                   : std_logic;

    signal   gt0_txoutclk_i                  : std_logic;
    signal   gt0_rxoutclk_i                  : std_logic;
    signal   gt0_rxoutclk_i2                 : std_logic;
    signal   gt0_txoutclk_i2                 : std_logic;
    signal   gt0_recclk_stable_i             : std_logic;
    signal   gt0_rx_cdrlocked                : std_logic;
    signal   gt0_rx_cdrlock_counter  :   integer range 0 to WAIT_TIME_CDRLOCK:= 0 ;






    signal      rx_cdrlocked                    : std_logic;


 


--**************************** Main Body of Code *******************************
begin
    --  Static signal Assigments
    tied_to_ground_i                             <= '0';
    tied_to_vcc_i                                <= '1';

    ----------------------------- The GT Wrapper -----------------------------
    
    -- Use the instantiation template in the example directory to add the GT wrapper to your design.
    -- In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    -- checker. The GTs will reset, then attempt to align and transmit data. If channel bonding is 
    -- enabled, bonding should occur after alignment.


    GTP_Zynq_i : GTP_Zynq_multi_gt
    generic map
    (
        EXAMPLE_SIMULATION              =>      EXAMPLE_SIMULATION,
        WRAPPER_SIM_GTRESET_SPEEDUP     =>      EXAMPLE_SIM_GTRESET_SPEEDUP
    )
    port map
    (
        GT0_DRP_BUSY_OUT                =>      GT0_DRP_BUSY_OUT,
        GT0_RXPMARESETDONE_OUT          =>      gt0_rxpmaresetdone_i,
        --_____________________________________________________________________
        --_____________________________________________________________________
        --GT0  (X0Y2)

        ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      gt0_drpaddr_in,
        gt0_drpclk_in                   =>      gt0_drpclk_in,
        gt0_drpdi_in                    =>      gt0_drpdi_in,
        gt0_drpdo_out                   =>      gt0_drpdo_out,
        gt0_drpen_in                    =>      gt0_drpen_in,
        gt0_drprdy_out                  =>      gt0_drprdy_out,
        gt0_drpwe_in                    =>      gt0_drpwe_in,
        --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      gt0_eyescanreset_in,
        gt0_rxuserrdy_in                =>      gt0_rxuserrdy_i,
        -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out        =>      gt0_eyescandataerror_out,
        gt0_eyescantrigger_in           =>      gt0_eyescantrigger_in,
        ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        gt0_rxdata_out                  =>      gt0_rxdata_out,
        gt0_rxusrclk_in                 =>      gt0_rxusrclk_in,
        gt0_rxusrclk2_in                =>      gt0_rxusrclk2_in,
        ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
        gt0_rxchariscomma_out           =>      gt0_rxchariscomma_out,
        gt0_rxcharisk_out               =>      gt0_rxcharisk_out,
        gt0_rxdisperr_out               =>      gt0_rxdisperr_out,
        gt0_rxnotintable_out            =>      gt0_rxnotintable_out,
        ------------------------ Receive Ports - RX AFE Ports ----------------------
        gt0_gtprxn_in                   =>      gt0_gtprxn_in,
        gt0_gtprxp_in                   =>      gt0_gtprxp_in,
        -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
        gt0_rxbyteisaligned_out         =>      gt0_rxbyteisaligned_out,
        gt0_rxbyterealign_out           =>      gt0_rxbyterealign_out,
        ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        gt0_dmonitorout_out             =>      gt0_dmonitorout_out,
        -------------------- Receive Ports - RX Equailizer Ports -------------------
        gt0_rxlpmhfhold_in              =>      gt0_rxlpmhfhold_in,
        gt0_rxlpmlfhold_in              =>      gt0_rxlpmlfhold_in,
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        gt0_rxoutclk_out                =>      gt0_rxoutclk_i,
        gt0_rxoutclkfabric_out          =>      gt0_rxoutclkfabric_out,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      gt0_gtrxreset_i,
        gt0_rxlpmreset_in               =>      gt0_rxlpmreset_in,
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out             =>      gt0_rxresetdone_i,
        --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      gt0_gttxreset_i,




    --____________________________COMMON PORTS________________________________
        gt0_pll0reset_in                =>      gt0_pll0reset_t,
        gt0_pll0outclk_in               =>      gt0_pll0outclk_in,
        gt0_pll0outrefclk_in            =>      gt0_pll0outrefclk_in,
        gt0_pll1outclk_in               =>      gt0_pll1outclk_in,
        gt0_pll1outrefclk_in            =>      gt0_pll1outrefclk_in
    );




GT0_RXRESETDONE_OUT                          <= gt0_rxresetdone_i;
GT0_RXOUTCLK_OUT                             <= gt0_rxoutclk_i;
    GT0_PLL0RESET_OUT                            <= gt0_pll0reset_t;

chipscope : if EXAMPLE_USE_CHIPSCOPE = 1 generate
    gt0_gttxreset_i                              <= GT0_GTTXRESET_IN or gt0_gttxreset_t;
    gt0_gtrxreset_i                              <= GT0_GTRXRESET_IN or gt0_gtrxreset_t;
    gt0_rxuserrdy_i                              <= GT0_RXUSERRDY_IN and gt0_rxuserrdy_t;
end generate chipscope;

no_chipscope : if EXAMPLE_USE_CHIPSCOPE = 0 generate
gt0_gttxreset_i                              <= gt0_gttxreset_t;
gt0_gtrxreset_i                              <= gt0_gtrxreset_t;
gt0_txuserrdy_i                              <= gt0_txuserrdy_t;
gt0_rxuserrdy_i                              <= gt0_rxuserrdy_t;
end generate no_chipscope;


 gt0_txuserrdy_t <= tied_to_ground_i;
 gt0_gttxreset_t <= tied_to_vcc_i;







gt0_rxresetfsm_i:  GTP_Zynq_RX_STARTUP_FSM 

  generic map(
           EXAMPLE_SIMULATION       => EXAMPLE_SIMULATION,
           STABLE_CLOCK_PERIOD      => STABLE_CLOCK_PERIOD,           --Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   => 8, 
           TX_PLL0_USED             => FALSE ,                       -- the TX and RX Reset FSMs must
           RX_PLL0_USED             => TRUE,                         -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   =>  FALSE                        -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                     -- is enough. For single-lane applications the automatic alignment is 
                                                                     -- sufficient              
             )     
    port map ( 
        STABLE_CLOCK                    =>      SYSCLK_IN,
        RXUSERCLK                       =>      GT0_RXUSRCLK_IN,
        SOFT_RESET                      =>      SOFT_RESET_RX_IN,
        DONT_RESET_ON_DATA_ERROR        =>      DONT_RESET_ON_DATA_ERROR_IN,
        RXPMARESETDONE                  =>      gt0_rxpmaresetdone_i,
        RXOUTCLK                        =>      gt0_rxusrclk_in,
        PLL0REFCLKLOST                  =>      GT0_PLL0REFCLKLOST_IN,
        PLL0LOCK                        =>      GT0_PLL0LOCK_IN,
        PLL1REFCLKLOST                  =>      tied_to_ground_i,
        PLL1LOCK                        =>      tied_to_vcc_i,
        RXRESETDONE                     =>      gt0_rxresetdone_i,
        MMCM_LOCK                       =>      tied_to_vcc_i,
        RECCLK_STABLE                   =>      gt0_recclk_stable_i,
        RECCLK_MONITOR_RESTART          =>      tied_to_ground_i,
        DATA_VALID                      =>      GT0_DATA_VALID_IN,
        TXUSERRDY                       =>      tied_to_vcc_i,
        GTRXRESET                       =>      gt0_gtrxreset_t,
        MMCM_RESET                      =>      open,
        PLL0_RESET                      =>      gt0_pll0reset_t,
        PLL1_RESET                      =>      open,
        RX_FSM_RESET_DONE               =>      GT0_RX_FSM_RESET_DONE_OUT,
        RXUSERRDY                       =>      gt0_rxuserrdy_t,
        RUN_PHALIGNMENT                 =>      open,
        RESET_PHALIGNMENT               =>      open,
        PHALIGNMENT_DONE                =>      tied_to_vcc_i,
        RETRY_COUNTER                   =>      open
           );



  gt0_cdrlock_timeout:process(SYSCLK_IN)
  begin
    if rising_edge(SYSCLK_IN) then
        if(gt0_gtrxreset_i = '1') then
          gt0_rx_cdrlocked       <= '0';
          gt0_rx_cdrlock_counter <=  0                        after DLY;
        elsif (gt0_rx_cdrlock_counter = WAIT_TIME_CDRLOCK) then
          gt0_rx_cdrlocked       <= '1';
          gt0_rx_cdrlock_counter <= gt0_rx_cdrlock_counter        after DLY;
        else
          gt0_rx_cdrlock_counter <= gt0_rx_cdrlock_counter + 1    after DLY;
        end if;
    end if;
  end process;

gt0_recclk_stable_i                          <= gt0_rx_cdrlocked;






end RTL;


