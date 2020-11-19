library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
	
library unisim;
  use unisim.vcomponents.all;

--***********************************Entity Declaration************************

entity GTP_Zynq_exdes is
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

RXN_IN                                  : in   std_logic;
RXP_IN                                  : in   std_logic;
    
FIXED_IO_0_mio                          : inout STD_LOGIC_VECTOR ( 53 downto 0 );
FIXED_IO_0_ps_clk                       : inout STD_LOGIC;
FIXED_IO_0_ps_porb                      : inout STD_LOGIC;
FIXED_IO_0_ps_srstb                     : inout STD_LOGIC;    
    
AD9517_PD_N                             : out STD_LOGIC;
AD9517_SYNC_N                           : out STD_LOGIC;
AD9517_RESET_N                          : out STD_LOGIC;

EN_GTP_OSC                              : out STD_LOGIC;

LEDS                                    : out std_logic_vector(4 downto 0) 
);


end GTP_Zynq_exdes;
    
architecture RTL of GTP_Zynq_exdes is
    attribute DowngradeIPIdentifiedWarnings: string;
    attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

    attribute CORE_GENERATION_INFO : string;
    attribute CORE_GENERATION_INFO of RTL : architecture is "GTP_Zynq,gtwizard_v3_6_11,{protocol_file=Start_from_scratch}";

--**************************Component Declarations*****************************
component GTP_Zynq
port
(
    SOFT_RESET_RX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_N_IN               : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_P_IN               : in   std_logic;

    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;
 
    GT0_RXUSRCLK_OUT                        : out  std_logic;
    GT0_RXUSRCLK2_OUT                       : out  std_logic;

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
    gt0_rxuserrdy_in                        : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                : out  std_logic;
    gt0_eyescantrigger_in                   : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    gt0_rxdata_out                          : out  std_logic_vector(15 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtprxn_in                           : in   std_logic;
    gt0_gtprxp_in                           : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxslide_in                          : in   std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt0_dmonitorout_out                     : out  std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    gt0_rxlpmhfhold_in                      : in   std_logic;
    gt0_rxlpmlfhold_in                      : in   std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
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
         GT0_PLL0OUTCLK_OUT  : out std_logic;
         GT0_PLL0OUTREFCLK_OUT  : out std_logic;
         GT0_PLL0LOCK_OUT  : out std_logic;
         GT0_PLL0REFCLKLOST_OUT  : out std_logic;    
         GT0_PLL1OUTCLK_OUT  : out std_logic;
         GT0_PLL1OUTREFCLK_OUT  : out std_logic;

        sysclk_in : in std_logic
);
end component;

component PS is
  port (
    FCLK_CLK0_0 : out STD_LOGIC;
    FIXED_IO_0_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk : inout STD_LOGIC;
    FIXED_IO_0_ps_porb : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb : inout STD_LOGIC
  );
end component;

component GTP_Zynq_GT_FRAME_GEN 
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

component GTP_Zynq_GT_FRAME_CHECK 
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

RX_SLIDE                 : out std_logic;

 

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
signal   gt0_txfsmresetdone_i            : std_logic;
signal   gt0_rxfsmresetdone_i            : std_logic;
    signal   gt0_rxfsmresetdone_r            : std_logic;
    signal   gt0_rxfsmresetdone_r2           : std_logic;
attribute ASYNC_REG of gt0_rxfsmresetdone_r     : signal is "TRUE";
attribute ASYNC_REG of gt0_rxfsmresetdone_r2     : signal is "TRUE";
signal   gt0_rxresetdone_r               : std_logic;
signal   gt0_rxresetdone_r2              : std_logic;
signal   gt0_rxresetdone_r3              : std_logic;
attribute ASYNC_REG of gt0_rxresetdone_r     : signal is "TRUE";
attribute ASYNC_REG of gt0_rxresetdone_r2     : signal is "TRUE";
attribute ASYNC_REG of gt0_rxresetdone_r3     : signal is "TRUE";



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
    signal  gt0_rxuserrdy_i                 : std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    signal  gt0_eyescandataerror_i          : std_logic;
    signal  gt0_eyescantrigger_i            : std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    signal  gt0_rxdata_i                    : std_logic_vector(15 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    signal  gt0_gtprxn_i                    : std_logic;
    signal  gt0_gtprxp_i                    : std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    signal  gt0_rxslide_i                   : std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    signal  gt0_dmonitorout_i               : std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    signal  gt0_rxlpmhfhold_i               : std_logic;
    signal  gt0_rxlpmlfhold_i               : std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    signal  gt0_rxoutclk_i                  : std_logic;
    signal  gt0_rxoutclkfabric_i            : std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    signal  gt0_gtrxreset_i                 : std_logic;
    signal  gt0_rxlpmreset_i                : std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    signal  gt0_rxresetdone_i               : std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    signal  gt0_gttxreset_i                 : std_logic;



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

-- **********************************************************************************
signal  gt0_rxdata_d, gt0_rxdata_dd     : std_logic_vector(15 downto 0);
signal  rxdata_cnt                      : std_logic_vector(31 downto 0);
signal  rxdata_ch                       : std_logic;

signal  onesec_cnt                      : std_logic_vector(31 downto 0);
signal  onesec_en_mclk                  : std_logic;

signal  onesec_en_gclk                  : std_logic;
signal  onesec_en_gclk_s                : std_logic;
signal  onesec_en_gclk_s_r                : std_logic;
signal  onesec_en_gclk_s_rr               : std_logic;
signal  onesec_en_gclk_s_rrr              : std_logic;
-- **********************************************************************************

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

GTP_Zynq_support_i : GTP_Zynq
port map
  (
    soft_reset_rx_in                =>      soft_reset_i,
    DONT_RESET_ON_DATA_ERROR_IN     =>      tied_to_ground_i,
    Q0_CLK1_GTREFCLK_PAD_N_IN       =>      Q0_CLK1_GTREFCLK_PAD_N_IN,
    Q0_CLK1_GTREFCLK_PAD_P_IN       =>      Q0_CLK1_GTREFCLK_PAD_P_IN,
    GT0_TX_FSM_RESET_DONE_OUT       =>      gt0_txfsmresetdone_i,
    GT0_RX_FSM_RESET_DONE_OUT       =>      gt0_rxfsmresetdone_i,
    GT0_DATA_VALID_IN               =>      gt0_track_data_i,
   
    GT0_RXUSRCLK_OUT                =>      gt0_rxusrclk_i,
    GT0_RXUSRCLK2_OUT               =>      gt0_rxusrclk2_i,
   
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
    gt0_rxuserrdy_in                =>      tied_to_vcc_i,
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out        =>      gt0_eyescandataerror_i,
    gt0_eyescantrigger_in           =>      tied_to_ground_i,
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    gt0_rxdata_out                  =>      gt0_rxdata_i,
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtprxn_in                   =>      RXN_IN,
    gt0_gtprxp_in                   =>      RXP_IN,
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxslide_in                  =>      gt0_rxslide_i,
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt0_dmonitorout_out             =>      gt0_dmonitorout_i,
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    gt0_rxlpmhfhold_in              =>      tied_to_ground_i,
    gt0_rxlpmlfhold_in              =>      tied_to_ground_i,
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    gt0_rxoutclkfabric_out          =>      gt0_rxoutclkfabric_i,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                =>      tied_to_ground_i,
    gt0_rxlpmreset_in               =>      gt0_rxlpmreset_i,
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    gt0_rxresetdone_out             =>      gt0_rxresetdone_i,
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                =>      tied_to_ground_i,
   
   
   
    -- __________________________COMMON PORTS________________________________
    GT0_PLL0RESET_OUT               =>      open,
    GT0_PLL0OUTCLK_OUT              =>      open,
    GT0_PLL0OUTREFCLK_OUT           =>      open,
    GT0_PLL0LOCK_OUT                =>      open,
    GT0_PLL0REFCLKLOST_OUT          =>      open,    
    GT0_PLL1OUTCLK_OUT              =>      open,
    GT0_PLL1OUTREFCLK_OUT           =>      open,
    sysclk_in                       =>      drpclk_in_i
    );

PS_i : PS
  port map(
    FCLK_CLK0_0         => drpclk_in_i, -- : out STD_LOGIC;
    FIXED_IO_0_mio      => FIXED_IO_0_mio     , -- : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk   => FIXED_IO_0_ps_clk  , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_porb  => FIXED_IO_0_ps_porb , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb => FIXED_IO_0_ps_srstb -- : inout STD_LOGIC
  );

 

    -------------------------- User Module Resets -----------------------------
    -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
    -- are held in reset till the RESETDONE goes high. 
    -- The RESETDONE is registered a couple of times on USRCLK2 and connected 
    -- to the reset of the modules
    
process(gt0_rxusrclk2_i,gt0_rxresetdone_i)
  begin
    if(gt0_rxresetdone_i = '0') then
      gt0_rxresetdone_r  <= '0'   after DLY;
      gt0_rxresetdone_r2 <= '0'   after DLY;
      gt0_rxresetdone_r3 <= '0'   after DLY;
    elsif (gt0_rxusrclk2_i'event and gt0_rxusrclk2_i = '1') then
      gt0_rxresetdone_r  <= gt0_rxresetdone_i   after DLY;
      gt0_rxresetdone_r2 <= gt0_rxresetdone_r   after DLY;
      gt0_rxresetdone_r3  <= gt0_rxresetdone_r2   after DLY;
    end if;
end process;




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

gt0_frame_check_reset_i  <= reset_on_data_error_i when (EXAMPLE_CONFIG_INDEPENDENT_LANES=0) else gt0_matchn_i;

    -- gt0_frame_check0 is always connected to the lane with the start of char 
    -- and this lane starts off the data checking on all the other lanes. The INC_IN port is tied off
gt0_inc_in_i <= '0';

gt0_frame_check : GTP_Zynq_GT_FRAME_CHECK
  generic map(
    RX_DATA_WIDTH                   =>      16,
    RXCTRL_WIDTH                    =>      2,
    WORDS_IN_BRAM                   =>      EXAMPLE_WORDS_IN_BRAM,
    START_OF_PACKET_CHAR            =>      x"027c"
    )
  port map(
    -- GT Interface
    RX_DATA_IN                      =>      gt0_rxdata_i,
    RXENMCOMMADET_OUT               =>      open,
    RXENPCOMMADET_OUT               =>      open,
    -- System Interface
    USER_CLK                        =>      gt0_rxusrclk2_i,
    SYSTEM_RESET                    =>      gt0_rx_system_reset_c,
    ERROR_COUNT_OUT                 =>      gt0_error_count_i,
    RX_SLIDE                        =>      gt0_rxslide_i,
    TRACK_DATA_OUT                  =>      gt0_track_data_i
    );




-- TRACK_DATA_OUT  <= track_data_out_i;

track_data_out_i   <= gt0_track_data_i ;







-------------------------------------------------------------------------------
----------------------------- Debug Signals assignment -----------------------

------------ optional Ports assignments --------------
------------------------------------------------------ 

    -- assign resets for frame_gen modules

    -- assign resets for frame_check modules
gt0_rx_system_reset_c                        <= not gt0_rxresetdone_r3;


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

gt0_rxdata_ila      <= zero_vector_rx_80 & gt0_rxdata_i;

gt0_rxdatavalid_ila(0) <= '0'; 
gt0_rxdatavalid_ila(1) <= '0'; 

gt0_rxcharisk_ila <= (others => '0'); 


gt0_txmmcm_lock_ila(0) <= '0';

gt0_rxmmcm_lock_ila(0) <= '0';
gt0_rxresetdone_ila(0) <= gt0_rxresetdone_i;
gt0_txresetdone_ila(0) <= '0';

track_data_out_ila_i(0) <= track_data_out_i;


-- ila core insertion for observing data and control signals

ila_rx0_inst: ila_0 
  port map (
    clk        => gt0_rxusrclk_i,        -- input clk
    probe0     => gt0_rxdata_ila,
    probe1     => gt0_error_count_i,
    probe2     => track_data_out_ila_i,
    probe3     => gt0_rxdatavalid_ila,
    probe4     => gt0_rxcharisk_ila,
    probe5     => gt0_rxmmcm_lock_ila, 
    probe6     => gt0_rxresetdone_ila
);


-- ***************************************************
process(drpclk_in_i)
	begin
  	if rising_edge(drpclk_in_i) then
			if (onesec_cnt = x"00000000") then
        onesec_cnt	   <= x"0773593F";
        onesec_en_mclk <= '1';
			else 
        onesec_cnt	<= onesec_cnt - 1;
        onesec_en_mclk <= '0';
      end if;
    end if;
end process;


process(gt0_rxusrclk_i)
	begin
  	if rising_edge(gt0_rxusrclk_i) then
			onesec_en_gclk_s     <= onesec_en_mclk;
			onesec_en_gclk_s_r   <= onesec_en_gclk_s;
			onesec_en_gclk_s_rr  <= onesec_en_gclk_s_r;
			onesec_en_gclk_s_rrr <= onesec_en_gclk_s_rr;
    end if;
end process;





process(gt0_rxusrclk_i)
	begin
  	if rising_edge(gt0_rxusrclk_i) then
      gt0_rxdata_d	<= gt0_rxdata_i;
			gt0_rxdata_dd <= gt0_rxdata_d;
			if true then
        rxdata_cnt <= (others => '0');
			elsif (gt0_rxdata_dd /= gt0_rxdata_d) then
        rxdata_cnt <= rxdata_cnt + 1;
      end if;
    end if;
end process;



-- ***************************************************



LEDS(4) <= gt0_rxdata_i(15); 
LEDS(3) <= gt0_rxdata_i(7); 
LEDS(2) <= gt0_rxdata_i(0); 
LEDS(1) <= '0'; -- count_3(24); 
LEDS(0) <= '0'; -- count_4(24); 



AD9517_PD_N     <= '1'    ;-- : out STD_LOGIC;
AD9517_SYNC_N   <= '1'    ;-- : out STD_LOGIC;
AD9517_RESET_N  <= '1'    ;-- : out STD_LOGIC;

EN_GTP_OSC <= '1';

end RTL;


