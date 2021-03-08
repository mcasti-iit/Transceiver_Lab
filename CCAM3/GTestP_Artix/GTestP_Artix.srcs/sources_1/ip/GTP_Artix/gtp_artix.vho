------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 3.6
--  \   \         Application : 7 Series FPGAs Transceivers Wizard
--  /   /         Filename : gtp_artix.vho
-- /___/   /\      
-- \   \  /  \ 
--  \___\/\___\
--
--
-- Instantiation Template
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard


--**************************Wrapper Component Declarations*****************************


------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component GTP_Artix
port
(
    SOFT_RESET_TX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    Q0_CLK0_GTREFCLK_PAD_N_IN               : in   std_logic;
    Q0_CLK0_GTREFCLK_PAD_P_IN               : in   std_logic;

    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;
 
    GT0_TXUSRCLK_OUT                        : out  std_logic;
    GT0_TXUSRCLK2_OUT                       : out  std_logic;

    --_________________________________________________________________________
    --GT0  (X0Y0)
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
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt0_txcharisk_in                        : in   std_logic_vector(1 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt0_gtptxn_out                          : out  std_logic;
    gt0_gtptxp_out                          : out  std_logic;
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt0_txoutclkfabric_out                  : out  std_logic;
    gt0_txoutclkpcs_out                     : out  std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt0_txpcsreset_in                       : in   std_logic;
    gt0_txpmareset_in                       : in   std_logic;
    gt0_txresetdone_out                     : out  std_logic;

    --____________________________COMMON PORTS________________________________
         GT0_PLL0OUTCLK_OUT  : out std_logic;
         GT0_PLL0OUTREFCLK_OUT  : out std_logic;
         GT0_PLL0LOCK_OUT  : out std_logic;
         GT0_PLL0REFCLKLOST_OUT  : out std_logic;    
         GT0_PLL1OUTCLK_OUT  : out std_logic;
         GT0_PLL1OUTREFCLK_OUT  : out std_logic;

          sysclk_in                               : in   std_logic

);

end component;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
    GTP_Artix_i : GTP_Artix
port map
(
    SOFT_RESET_TX_IN => SOFT_RESET_TX_IN,
    DONT_RESET_ON_DATA_ERROR_IN => DONT_RESET_ON_DATA_ERROR_IN,
    Q0_CLK0_GTREFCLK_PAD_N_IN => Q0_CLK0_GTREFCLK_PAD_N_IN,
    Q0_CLK0_GTREFCLK_PAD_P_IN => Q0_CLK0_GTREFCLK_PAD_P_IN,

     GT0_TX_FSM_RESET_DONE_OUT => GT0_TX_FSM_RESET_DONE_OUT,
     GT0_RX_FSM_RESET_DONE_OUT => GT0_RX_FSM_RESET_DONE_OUT,
     GT0_DATA_VALID_IN => GT0_DATA_VALID_IN,
 
     GT0_TXUSRCLK_OUT => GT0_TXUSRCLK_OUT,
     GT0_TXUSRCLK2_OUT => GT0_TXUSRCLK2_OUT,

    --_________________________________________________________________________
    --GT0  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      gt0_drpaddr_in,
        gt0_drpdi_in                    =>      gt0_drpdi_in,
        gt0_drpdo_out                   =>      gt0_drpdo_out,
        gt0_drpen_in                    =>      gt0_drpen_in,
        gt0_drprdy_out                  =>      gt0_drprdy_out,
        gt0_drpwe_in                    =>      gt0_drpwe_in,
    --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      gt0_eyescanreset_in,
    -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out        =>      gt0_eyescandataerror_out,
        gt0_eyescantrigger_in           =>      gt0_eyescantrigger_in,
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        gt0_dmonitorout_out             =>      gt0_dmonitorout_out,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      gt0_gtrxreset_in,
        gt0_rxlpmreset_in               =>      gt0_rxlpmreset_in,
    --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      gt0_gttxreset_in,
        gt0_txuserrdy_in                =>      gt0_txuserrdy_in,
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
        gt0_txdata_in                   =>      gt0_txdata_in,
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
        gt0_txcharisk_in                =>      gt0_txcharisk_in,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
        gt0_gtptxn_out                  =>      gt0_gtptxn_out,
        gt0_gtptxp_out                  =>      gt0_gtptxp_out,
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        gt0_txoutclkfabric_out          =>      gt0_txoutclkfabric_out,
        gt0_txoutclkpcs_out             =>      gt0_txoutclkpcs_out,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
        gt0_txpcsreset_in               =>      gt0_txpcsreset_in,
        gt0_txpmareset_in               =>      gt0_txpmareset_in,
        gt0_txresetdone_out             =>      gt0_txresetdone_out,

    --____________________________COMMON PORTS________________________________
         GT0_PLL0OUTCLK_OUT  => GT0_PLL0OUTCLK_OUT,
         GT0_PLL0OUTREFCLK_OUT  => GT0_PLL0OUTREFCLK_OUT,
         GT0_PLL0LOCK_OUT  => GT0_PLL0LOCK_OUT,
         GT0_PLL0REFCLKLOST_OUT  => GT0_PLL0REFCLKLOST_OUT,    
         GT0_PLL1OUTCLK_OUT  => GT0_PLL1OUTCLK_OUT,
         GT0_PLL1OUTREFCLK_OUT  => GT0_PLL1OUTREFCLK_OUT,
     sysclk_in => sysclk_in

);
-- INST_TAG_END ------ End INSTANTIATION Template ---------



