library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;
	
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity GTP_Artix_Test is
generic
(
    EXAMPLE_CONFIG_INDEPENDENT_LANES : integer   := 1;
    EXAMPLE_LANE_WITH_START_CHAR     : integer   := 0;    -- specifies lane with unique start frame ch
    EXAMPLE_WORDS_IN_BRAM            : integer   := 512;  -- specifies amount of data in BRAM
    EXAMPLE_SIM_GTRESET_SPEEDUP      : string    := "FALSE";    -- simulation setting for GT SecureIP model
    STABLE_CLOCK_PERIOD              : integer   := 8; 
    EXAMPLE_USE_CHIPSCOPE            : integer   := 1           -- Set to 1 to use Chipscope to drive resets
);
port
(

    CLK_IN_i                          : in   std_logic;
    CCAM_PLL_RESET_i                  : out  std_logic;
    ALIGN_REQUEST_i                   : in   std_logic;
    
    REFCLK0_TX_P_i                    : in   std_logic;
    REFCLK0_TX_N_i                    : in   std_logic;
    
    
    TXN_o                             : out  std_logic;
    TXP_o                             : out  std_logic 

-- DRP_CLK_IN_P                       : in   std_logic;
-- DRP_CLK_IN_N                       : in   std_logic;

-- GTTX_RESET_IN                      : in   std_logic;
-- GTRX_RESET_IN                      : in   std_logic;
-- PLL0_RESET_IN                      : in   std_logic; 
-- PLL1_RESET_IN                      : in   std_logic;

);


end GTP_Artix_Test;
    
architecture RTL of GTP_Artix_Test is

--**************************Component Declarations*****************************

component clk_wiz_0
port(
  clk_in1           : in     std_logic;
  clk_out1          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic
 );
end component;

component vio_0
  port (
    clk : in std_logic;
    probe_in0 : in std_logic_vector(15 downto 0);
    probe_out0 : out std_logic_vector(15 downto 0)
  );
end component;

component ila_0
port (
	clk    : in std_logic;
	probe0 : in std_logic_vector(15 downto 0);
	probe1 : in std_logic_vector(15 downto 0)
);
end component  ;

COMPONENT ila_1

port (
	clk : in std_logic;
	probe0 : in std_logic_vector(31 downto 0); 
	probe1 : in std_logic_vector(1 downto 0); 
	probe2 : in std_logic_vector(7 downto 0); 
	probe3 : in std_logic_vector(1 downto 0)
);
end component  ;

component time_machine is
  generic ( 
    CLK_PERIOD_NS_g         : real := 10.0;                   -- Main Clock period
    CLEAR_POLARITY_g        : string := "LOW";                -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g : integer range 0 to 255 := 10;   -- Duration of Power-On reset  
    SIM_TIME_COMPRESSION_g  : in boolean := FALSE             -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port (
    -- Clock in port
    CLK_i                   : in  std_logic;   -- Input clock @ 50 MHz,
    CLEAR_i                 : in  std_logic;   -- Asynchronous active low reset
  
    -- Output reset
    RESET_o                 : out std_logic;    -- Reset out (active high)
    RESET_N_o               : out std_logic;    -- Reset out (active low)
    PON_RESET_OUT_o         : out std_logic;	  -- Power on Reset out (active high)
    PON_RESET_N_OUT_o       : out std_logic;	  -- Power on Reset out (active low)
    
    -- Output ports for generated clock enables
    EN200NS_o               : out std_logic;	  -- Clock enable every 200 ns
    EN1US_o                 : out std_logic;	  -- Clock enable every 1 us
    EN10US_o                : out std_logic;	  -- Clock enable every 10 us
    EN100US_o               : out std_logic;	  -- Clock enable every 100 us
    EN1MS_o                 : out std_logic;	  -- Clock enable every 1 ms
    EN10MS_o                : out std_logic;	  -- Clock enable every 10 ms
    EN100MS_o               : out std_logic;	  -- Clock enable every 100 ms
    EN1S_o                  : out std_logic 	  -- Clock enable every 1 s
    );
end component;

component GTP_TX_Manager is
  generic ( 
    TX_DATA_IN_WIDTH_g        : integer range 0 to 64 := 32;    -- Width of TX Data - Fabric side 
    GTP_STREAM_WIDTH_g        : integer range 0 to 64 := 16;    -- Width of TX Data - GTP side
    GTP_RXUSRCLK2_PERIOD_NS_g : real := 10.0;                   -- GTP User clock period
    SIM_TIME_COMPRESSION_g    : in boolean := FALSE             -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port (
    -- Bare Control ports
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1S_i                  : in  std_logic;   -- Enable @ 100 us in clk domain 

    -- Control in
    AUTO_ALIGN_i            : in  std_logic;
    ALIGN_REQUEST_i         : in  std_logic;
    ALIGN_KEY_i             : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    TX_ERROR_INJECTION_i    : in  std_logic;
    
    -- Status
    ALIGN_FLAG_o            : out std_logic;
  
    -- Data in 
    TX_DATA_i               : in  std_logic_vector(TX_DATA_IN_WIDTH_g-1 downto 0);
    TX_DATA_SRC_RDY_i       : in  std_logic;
    TX_DATA_DST_RDY_o       : out std_logic;
    
    TX_MSG_i                : in   std_logic_vector(7 downto 0);
    TX_MSG_SRC_RDY_i        : in   std_logic;
    TX_MSG_DST_RDY_o        : out  std_logic;
    
   
    -- *****************************************************************************************
    -- GTP Interface    
    SOFT_RESET_TX_o             : out std_logic;
    DONT_RESET_ON_DATA_ERROR_o  : out std_logic;

    GTP_TX_FSM_RESET_DONE_i     : in  std_logic;
    GTP_RX_FSM_RESET_DONE_i     : in  std_logic;
    GTP_DATA_VALID_o            : out std_logic;
 
    GTP_TXUSRCLK2_i             : in  std_logic;

    --_________________________________________________________________________
    --GTP  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    GTP_DRPADDR_o               : out std_logic_vector(8 downto 0);
    GTP_DRPDI_o                 : out std_logic_vector(15 downto 0);
    GTP_DRPDO_i                 : in  std_logic_vector(15 downto 0);
    GTP_DRPEN_o                 : out std_logic;
    GTP_DRPRDY_i                : in  std_logic;
    GTP_DRPWE_o                 : out std_logic;
    --------------------- RX Initialization and Reset Ports --------------------
    GTP_EYESCANRESET_o          : out std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    GTP_EYESCANDATAERROR_i      : in  std_logic;
    GTP_EYESCANTRIGGER_o        : out std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    GTP_DMONITOROUT_i           : in  std_logic_vector(14 downto 0);
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GTP_GTRXRESET_o             : out std_logic;
    GTP_RXLPMRESET_o            : out std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    GTP_GTTXRESET_o             : out std_logic;
    GTP_TXUSERRDY_o             : out std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GTP_TXDATA_o                : out std_logic_vector(15 downto 0);
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    GTP_TXCHARISk_o             : out std_logic_vector(1 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GTP_TXOUTCLKFABRIC_i        : in  std_logic;
    GTP_TXOUTCLKPCS_i           : in  std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GTP_TXRESETDONe_i           : in  std_logic;

    --____________________________COMMON PORTS________________________________
    GTP_PLL0OUTCLK_i            : in  std_logic;
    GTP_PLL0OUTREFCLK_i         : in  std_logic;
    GTP_PLL0LOCK_i              : in  std_logic;
    GTP_PLL0REFCLKLOST_i        : in  std_logic;    
    GTP_PLL1OUTCLK_i            : in  std_logic;
    GTP_PLL1OUTREFCLK_i         : in  std_logic                  
    );
end component;

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



signal  tied_to_ground                  : std_logic;
signal  tied_to_ground_vec              : std_logic_vector(63 downto 0);
signal  tied_to_vcc                     : std_logic;
signal  tied_to_vcc_vec                 : std_logic_vector(7 downto 0);


-- *****************************************************************************************

-- -------------------------------------------------------------------------------------

signal clk_in                                  : std_logic;
signal clk_100                                 : std_logic;
signal rst_n                                   : std_logic;
signal rst_n_gck                               : std_logic;

signal pon_reset_n                             : std_logic;                             -- Power On Reset
signal en50ns                                  : std_logic;
signal en1ms                                   : std_logic;
signal en1s                                    : std_logic;
signal en100us                                 : std_logic;

signal tx_cnt_16bit                            : std_logic_vector(15 downto 0);
signal tx_cnt_32bit                            : std_logic_vector(31 downto 0);
signal tx_cnt_32bit_gck                        : std_logic_vector(31 downto 0);


-- -------------------------------------------------------------------------------------
signal    gtp_probe_in0    : std_logic_vector(15 downto 0);
signal    gtp_probe_out0   : std_logic_vector(15 downto 0);
signal    gtp_probe_out0_d : std_logic_vector(15 downto 0);

signal    fpga_probe_in0    : std_logic_vector(15 downto 0);
signal    fpga_probe_out0   : std_logic_vector(15 downto 0);

signal    ila_gtp_probe0       : std_logic_vector(15 downto 0);
signal    ila_gtp_probe1       : std_logic_vector(15 downto 0);
-- signal    ila_gtp_probe2       : std_logic_vector(31 downto 0);

signal    ila_fpga_probe0       : std_logic_vector(31 downto 0);
signal    ila_fpga_probe1       : std_logic_vector(31 downto 0);
signal    ila_fpga_probe2       : std_logic_vector(31 downto 0);
signal    ila_fpga_probe3       : std_logic_vector(31 downto 0);
-- signal    ila_fpga_probe2       : std_logic_vector(31 downto 0);

-- -------------------------------------------------------------------------------------
signal    auto_align          : std_logic;

signal    send_align          : std_logic;
signal    send_k              : std_logic;
signal    charisk             : std_logic_vector(1 downto 0);
signal    en_20ns             : std_logic;




signal    pon_reset_n_gck     : std_logic;                             -- Power On Reset
signal    en100us_gck         : std_logic;
signal    en1ms_gck           : std_logic;
signal    en1s_gck            : std_logic;


signal    clk_100_reset       : std_logic;
signal    clk_100_locked      : std_logic;

signal    clk_gtp_reset       : std_logic;
signal    clk_gtp_locked      : std_logic;


-- ------------------------
signal align_req_n_meta         : std_logic;
signal align_req_n_sync         : std_logic;
signal align_req                : std_logic;


signal gtp_tx_stream        : std_logic_vector(15 downto 0);
signal gtp_tx_char_is_k     : std_logic_vector(1 downto 0);
signal p_pll_reset          : std_logic;
signal pll_reset            : std_logic;

signal gtp_pll_lock         : std_logic;
signal gtp_clk_lost         : std_logic;
signal align_key            : std_logic_vector(1 downto 0);
signal align_flag           : std_logic;

signal tx_data              : std_logic_vector(31 downto 0);
signal tx_data_src_rdy      : std_logic;
signal tx_data_dst_rdy      : std_logic;
signal tx_data_rate_cnt     : std_logic_vector(7 downto 0);

signal tx_msg               : std_logic_vector(7 downto 0);
signal tx_msg_src_rdy       : std_logic;
signal tx_msg_dst_rdy       : std_logic;
signal tx_msg_rate_cnt      : std_logic_vector(7 downto 0);


signal tx_error_injection   : std_logic;
signal gtp_soft_reset_tx    : std_logic;

signal ccam_pll_reset_meta  : std_logic;
signal ccam_pll_reset_sync  : std_logic;
signal ccam_pll_reset       : std_logic;

-- ---------------------------------------------------------------------------
signal soft_reset_tx            : std_logic;
signal dont_reset_on_data_error : std_logic;
 
signal gtp_tx_fsm_reset_done    : std_logic;
signal gtp_rx_fsm_reset_done    : std_logic;
signal gtp_data_valid           : std_logic;
signal gtp_txusrclk2            : std_logic;
 
signal gtp_drpaddr              : std_logic_vector(8 downto 0);
signal gtp_drpdi                : std_logic_vector(15 downto 0);
signal gtp_drpdo                : std_logic_vector(15 downto 0);
signal gtp_drpen                : std_logic;
signal gtp_drprdy               : std_logic;
signal gtp_drpwe                : std_logic;
 
signal gtp_eyescanreset         : std_logic;
 
signal gtp_eyescandataerror     : std_logic;
signal gtp_eyescantrigger       : std_logic;
 
signal gtp_dmonitorout          : std_logic_vector(14 downto 0);
 
signal gtp_gtrxreset            : std_logic;
signal gtp_rxlpmreset           : std_logic;

signal gtp_gttxreset            : std_logic;
signal gtp_txuserrdy            : std_logic;
 
signal gtp_txdata               : std_logic_vector(15 downto 0);
 
signal gtp_txcharisk            : std_logic_vector(1 downto 0);
 
signal gtp_txoutclkfabric       : std_logic;
signal gtp_txoutclkpcs          : std_logic;
 
signal gtp_txresetdone          : std_logic;
 
signal gtp_pll0outclk           : std_logic;
signal gtp_pll0outrefclk        : std_logic;
signal gtp_pll0lock             : std_logic;
signal gtp_pll0refclklost       : std_logic;    
signal gtp_pll1outclk           : std_logic;
signal gtp_pll1outrefclk        : std_logic;
-- ---------------------------------------------------------------------------


-- MARK DEBUG
attribute mark_debug : string;
attribute keep : string;
-- attribute keep of ALIGN_REQ_N_i     : signal is "true";
attribute keep of align_req        : signal is "true";
attribute keep of clk_100_reset    : signal is "true";
attribute keep of clk_100_locked   : signal is "true";
attribute keep of pll_reset        : signal is "true";
attribute keep of gtp_pll_lock     : signal is "true";
attribute keep of gtp_clk_lost     : signal is "true";
attribute keep of align_key        : signal is "true";
attribute keep of align_flag       : signal is "true";


--**************************** Main Body of Code *******************************
begin

    --  Static signal Assigments
tied_to_ground                             <= '0';
tied_to_ground_vec                         <= x"0000000000000000";
tied_to_vcc                                <= '1';
tied_to_vcc_vec                            <= "11111111";


-- -----------------------------------------------------------------------------
-- 100 MHz Domain

IBUF_CLK : IBUF
  port map(
    I  => CLK_IN_i,
    O  => clk_in
    );

MAIN_CLOCK : clk_wiz_0
  port map ( 
    clk_in1  => clk_in,
    clk_out1 => clk_100,
    reset    => '0', -- CCAM_PLL_RESET_i,     -- fpga_probe_out0(5), -- clk_100_reset,
    locked   => clk_100_locked    
    );
 

TIME_MACHINE_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  10.0,  -- Main Clock period
    CLEAR_POLARITY_g        => "LOW",  -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>    10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => false   -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => clk_100,
    CLEAR_i                 => '1',
  
    -- Output reset
    RESET_o                 => open,
    RESET_N_o               => rst_n,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => pon_reset_n,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => open,
    EN1MS_o                 => en1ms,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => en1s
    );

-- --------------------------------------------------------
-- Data Generator

process(clk_100, rst_n)
begin
  if (pon_reset_n = '0') then
    tx_data           <= (others => '0');
    tx_data_rate_cnt  <= (others => '0');
    tx_data_src_rdy   <= '0';
  elsif rising_edge(clk_100) then
    if (tx_data_rate_cnt = x"03") then
      tx_data_rate_cnt  <= (others => '0');
      tx_data           <= tx_data + 1;
      tx_data_src_rdy   <= '1';
    else
      if (tx_data_dst_rdy = '1') then
        tx_data_rate_cnt  <= tx_data_rate_cnt + 1;
        tx_data_src_rdy   <= '0';
      end if;
    end if;
  end if;	
end process;

process(clk_100, rst_n)
begin
  if (pon_reset_n = '0') then
    tx_msg           <= (others => '0');
    tx_msg_rate_cnt  <= (others => '0');
    tx_msg_src_rdy   <= '0';
  elsif rising_edge(clk_100) then
    if (tx_data_rate_cnt = x"03") then
      tx_msg_rate_cnt  <= (others => '0');
      tx_msg           <= tx_msg + 1;
      tx_msg_src_rdy   <= '1';
    else
      if (tx_msg_dst_rdy = '1') then
        tx_msg_rate_cnt  <= tx_msg_rate_cnt + 1;
        tx_msg_src_rdy   <= '0';
      end if;
    end if;
  end if;	
end process;



-- -----------------------------------------------------------------------------
-- Clock Cross Domain

align_key <= "01"; -- gtp_probe_out0(2 downto 1);

GTP_TX_MANAGER_i : GTP_TX_Manager 
  generic map( 
    TX_DATA_IN_WIDTH_g        => 32, 
    GTP_STREAM_WIDTH_g         => 16, 
    GTP_RXUSRCLK2_PERIOD_NS_g  => 6.4, 
    SIM_TIME_COMPRESSION_g     => FALSE
    )
  port map(
    -- Bare Control ports
    CLK_i                   => clk_100,
    RST_N_i                 => rst_n,
    EN1S_i                  => en1s, 

    -- Control in
    AUTO_ALIGN_i            => auto_align,
    ALIGN_REQUEST_i         => ALIGN_REQUEST_i,
    ALIGN_KEY_i             => align_key,
    TX_ERROR_INJECTION_i    => tx_error_injection,
    
    -- Status
    ALIGN_FLAG_o            => align_flag,
  
    -- Data in 
    TX_DATA_i               => tx_data, 
    TX_DATA_SRC_RDY_i       => tx_data_src_rdy,
    TX_DATA_DST_RDY_o       => tx_data_dst_rdy,
    
    TX_MSG_i                => tx_msg,           
    TX_MSG_SRC_RDY_i        => tx_msg_src_rdy,
    TX_MSG_DST_RDY_o        => tx_msg_dst_rdy, 
    
   
    -- *****************************************************************************************
    -- GTP Interface    
    SOFT_RESET_TX_o             => soft_reset_tx,
    DONT_RESET_ON_DATA_ERROR_o  => dont_reset_on_data_error,

    GTP_TX_FSM_RESET_DONE_i     => gtp_tx_fsm_reset_done,
    GTP_RX_FSM_RESET_DONE_i     => gtp_rx_fsm_reset_done,
    GTP_DATA_VALID_o            => gtp_data_valid,
 
    GTP_TXUSRCLK2_i             => gtp_txusrclk2,

    --_________________________________________________________________________
    --GTP  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    GTP_DRPADDR_o               => gtp_drpaddr,
    GTP_DRPDI_o                 => gtp_drpdi,
    GTP_DRPDO_i                 => gtp_drpdo,
    GTP_DRPEN_o                 => gtp_drpen,
    GTP_DRPRDY_i                => gtp_drprdy,
    GTP_DRPWE_o                 => gtp_drpwe,  
    --------------------- RX Initialization and Reset Ports --------------------
    GTP_EYESCANRESET_o          => gtp_eyescanreset,
    -------------------------- RX Margin Analysis Ports ------------------------
    GTP_EYESCANDATAERROR_i      => gtp_eyescandataerror,
    GTP_EYESCANTRIGGER_o        => gtp_eyescantrigger,
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    GTP_DMONITOROUT_i           => gtp_dmonitorout,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GTP_GTRXRESET_o             => gtp_gtrxreset,
    GTP_RXLPMRESET_o            => gtp_rxlpmreset,
    --------------------- TX Initialization and Reset Ports --------------------
    GTP_GTTXRESET_o             => gtp_gttxreset,
    GTP_TXUSERRDY_o             => gtp_txuserrdy,
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GTP_TXDATA_o                => gtp_txdata,
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    GTP_TXCHARISk_o             => gtp_txcharisk,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GTP_TXOUTCLKFABRIC_i        => gtp_txoutclkfabric,
    GTP_TXOUTCLKPCS_i           => gtp_txoutclkpcs,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GTP_TXRESETDONe_i           => gtp_txresetdone,

    --____________________________COMMON PORTS________________________________
    GTP_PLL0OUTCLK_i            => gtp_pll0outclk,
    GTP_PLL0OUTREFCLK_i         => gtp_pll0outrefclk,
    GTP_PLL0LOCK_i              => gtp_pll0lock,
    GTP_PLL0REFCLKLOST_i        => gtp_pll0refclklost,
    GTP_PLL1OUTCLK_i            => gtp_pll1outclk,
    GTP_PLL1OUTREFCLK_i         => gtp_pll1outrefclk     
    );


-- -----------------------------------------------------------------------------
-- GTP Clock Domain

TIME_MACHINE_GCK_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>   6.4, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => false  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => gtp_txusrclk2,
    CLEAR_i                 => '1',
  
    -- Output reset
    RESET_o                 => open,
    RESET_N_o               => rst_n_gck,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => open,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => en100us_gck,
    EN1MS_o                 => en1ms_gck,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );





--------------------------------------------------------
-- GTP Reset

-- process(clk_100, rst_n)
-- begin
--   if (rst_n_gck = '0') then 
--     ccam_pll_reset_meta <= '0';
--     ccam_pll_reset_sync <= '0';
--     ccam_pll_reset <= '0';
--   elsif rising_edge(gck) then
--     ccam_pll_reset_meta  <= CCAM_PLL_RESET_i;
--     ccam_pll_reset_sync  <= ccam_pll_reset_meta;
--     ccam_pll_reset       <= ccam_pll_reset_sync or gtp_soft_reset_tx;
--   end if;
-- end process;


   
GTP_Artix_i : GTP_Artix
  port map
    (
      SOFT_RESET_TX_IN                =>      soft_reset_tx,
      DONT_RESET_ON_DATA_ERROR_IN     =>      dont_reset_on_data_error,
      Q0_CLK0_GTREFCLK_PAD_N_IN       =>      REFCLK0_TX_N_i,
      Q0_CLK0_GTREFCLK_PAD_P_IN       =>      REFCLK0_TX_P_i,
      GT0_TX_FSM_RESET_DONE_OUT       =>      gtp_tx_fsm_reset_done,
      GT0_RX_FSM_RESET_DONE_OUT       =>      gtp_rx_fsm_reset_done,
      GT0_DATA_VALID_IN               =>      gtp_data_valid,
 
      GT0_TXUSRCLK_OUT                =>      open,
      GT0_TXUSRCLK2_OUT               =>      gtp_txusrclk2,

      --_____________________________________________________________________
      --_____________________________________________________________________
      --GT0  (X0Y0)

      ---------------------------- Channel - DRP Ports  --------------------------
      gt0_drpaddr_in                  =>      gtp_drpaddr,
      gt0_drpdi_in                    =>      gtp_drpdi,
      gt0_drpdo_out                   =>      gtp_drpdo,
      gt0_drpen_in                    =>      gtp_drpen,
      gt0_drprdy_out                  =>      gtp_drprdy,
      gt0_drpwe_in                    =>      gtp_drpwe,
      --------------------- RX Initialization and Reset Ports --------------------
      gt0_eyescanreset_in             =>      gtp_eyescanreset,
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out        =>      gtp_eyescandataerror,
      gt0_eyescantrigger_in           =>      gtp_eyescantrigger,
      ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
      gt0_dmonitorout_out             =>      gtp_dmonitorout,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in                =>      gtp_gtrxreset,
      gt0_rxlpmreset_in               =>      gtp_rxlpmreset,
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in                =>      gtp_gttxreset, -- fpga_probe_out0(0),
      gt0_txuserrdy_in                =>      gtp_txuserrdy,
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      gt0_txdata_in                   =>      gtp_txdata, -- gt0_txdata_in,
      ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
      gt0_txcharisk_in                =>      gtp_txcharisk, -- gt0_txcharisk_in,
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      gt0_gtptxn_out                  =>      TXN_o,
      gt0_gtptxp_out                  =>      TXP_o,
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      gt0_txoutclkfabric_out          =>      gtp_txoutclkfabric,
      gt0_txoutclkpcs_out             =>      gtp_txoutclkpcs,
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      gt0_txresetdone_out             =>      gtp_txresetdone,

      --____________________________COMMON PORTS________________________________
      GT0_PLL0OUTCLK_OUT              =>      gtp_pll0outclk,
      GT0_PLL0OUTREFCLK_OUT           =>      gtp_pll0outrefclk,
      GT0_PLL0LOCK_OUT                =>      gtp_pll0lock,
      GT0_PLL0REFCLKLOST_OUT          =>      gtp_pll0refclklost,    
      GT0_PLL1OUTCLK_OUT              =>      gtp_pll1outclk,
      GT0_PLL1OUTREFCLK_OUT           =>      gtp_pll1outrefclk,
      sysclk_in                       =>      clk_100
    );




-- -----------------------------------------------------------------------------
-- VIO



-- process(clk_100, rst_n)
-- begin
--   if (rst_n = '0') then 
--     p_pll_reset <= '0';
--     pll_reset   <= '0';
--   elsif rising_edge(clk_100) then
--     p_pll_reset  <= CCAM_PLL_RESET_i;
--     pll_reset    <= p_pll_reset;
--   end if;
-- end process;



fpga_probe_in0 <= "00000000000000" & pll_reset & clk_100_locked;  

VIO_FPGA : vio_0
  PORT MAP (
    clk => clk_100,
    probe_in0   => fpga_probe_in0,
    probe_out0  => fpga_probe_out0
  );


gtp_probe_in0 <= "0000000000000" & ALIGN_REQUEST_i & gtp_pll0refclklost & gtp_pll0lock;  

VIO_GTP : vio_0
  PORT MAP (
    clk => gtp_txusrclk2,
    probe_in0   => gtp_probe_in0,
    probe_out0  => gtp_probe_out0
  );




-- -----------------------------------------------------------------------------
-- ILAs

-- ila_fpga_probe0 <= tx_data;
-- ila_fpga_probe1 <= "00000000000000" & tx_data_dst_rdy & tx_data_src_rdy; 

ila_fpga_probe1 (1 downto 0) <= (tx_data_dst_rdy & tx_data_src_rdy);
ila_fpga_probe3 (1 downto 0) <= (tx_msg_dst_rdy & tx_msg_src_rdy);

ILA_FPGA_i : ila_1
PORT MAP (
	clk => clk_100,
	probe0 => tx_data, 
	probe1 => ila_fpga_probe1(1 downto 0), 
	probe2 => tx_msg, 
	probe3 => ila_fpga_probe3(1 downto 0)
  );

ila_gtp_probe0 <= gtp_tx_stream;
ila_gtp_probe1 <= "000000000000" & align_flag & gtp_txcharisk & ALIGN_REQUEST_i;

ILA_GTP_i : ila_0
PORT MAP (
	clk      => gtp_txusrclk2,
	probe0   => ila_gtp_probe0,
	probe1   => ila_gtp_probe1
);



CCAM_PLL_RESET_i <= fpga_probe_out0(15); -- not gtp_pll_lock or gtp_clk_lost; -- gtp_clk_lost;
-- ALIGN_REQ_N_i    <= gck;

end RTL;

