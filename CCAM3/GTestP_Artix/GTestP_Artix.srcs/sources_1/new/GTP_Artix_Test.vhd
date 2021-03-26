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


component GTP_Manager is
  generic ( 
    USER_DATA_WIDTH_g         : integer range 0 to 64 := 32;    -- Width of Data - Fabric side
    USER_MESSAGE_WIDTH_g      : integer range 0 to 64 :=  8;    -- Width of Message - Fabric side 
    GTP_DATA_WIDTH_g          : integer range 0 to 64 := 16;    -- Width of Data - GTP side
    GTP_TXUSRCLK2_PERIOD_NS_g : real := 10.0;                   -- GTP User clock period
    GTP_RXUSRCLK2_PERIOD_NS_g : real := 10.0;                   -- GTP User clock period
    SIM_TIME_COMPRESSION_g    : in boolean := FALSE             -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port (
    
    -- COMMONs
    -- Bare Control ports
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1S_i                  : in  std_logic;   -- Enable @ 1 sec in clk domain 

    -- Status
    PLL_ALARM_o             : out std_logic;
    
    -- ---------------------------------------------------------------------------------------
    -- TX SIDE

    -- Control in
    TX_AUTO_ALIGN_i         : in  std_logic;   -- Enables the "Auto alignment mode"
    TX_ALIGN_REQUEST_i      : in  std_logic;   -- Align request from Receiver
    TX_ERROR_INJECTION_i    : in  std_logic;   -- Error insertin (debug purpose)
    
    -- Status
    TX_GTP_ALIGN_FLAG_o     : out std_logic;   -- Monitor out: sending align
    
    -- Statistics
    TX_DATA_RATE_o          : out std_logic_vector(15 downto 0); 
    TX_GTP_ALIGN_RATE_o     : out std_logic_vector( 7 downto 0); 
    TX_MSG_RATE_o           : out std_logic_vector(15 downto 0); 
    TX_IDLE_RATE_o          : out std_logic_vector(15 downto 0); 
    TX_EVENT_RATE_o         : out std_logic_vector(15 downto 0); 
    TX_MESSAGE_RATE_o       : out std_logic_vector( 7 downto 0); 

  
    -- Data TX 
    TX_DATA_i               : in  std_logic_vector(USER_DATA_WIDTH_g-1 downto 0); -- Data to be transmitted
    TX_DATA_SRC_RDY_i       : in  std_logic;  -- Handshake for data transmission: Source Ready
    TX_DATA_DST_RDY_o       : out std_logic;  -- Handshake for data transmission: Destination Ready
    -- Message TX
    TX_MSG_i                : in   std_logic_vector(USER_MESSAGE_WIDTH_g-1 downto 0); -- Message to be transmitted
    TX_MSG_SRC_RDY_i        : in   std_logic;  -- Handshake for message transmission: Source Ready     
    TX_MSG_DST_RDY_o        : out  std_logic;  -- Handshake for message transmission: Destination Ready

    -- ---------------------------------------------------------------------------------------
    -- RX SIDE    
    
    -- Control out
    RX_ALIGN_REQUEST_o      : out std_logic;  
    
    -- Statistics        
    RX_DATA_RATE_o          : out std_logic_vector(15 downto 0); 
    RX_GTP_ALIGN_RATE_o     : out std_logic_vector( 7 downto 0); 
    RX_MSG_RATE_o           : out std_logic_vector(15 downto 0); 
    RX_IDLE_RATE_o          : out std_logic_vector(15 downto 0); 
    RX_EVENT_RATE_o         : out std_logic_vector(15 downto 0); 
    RX_MESSAGE_RATE_o       : out std_logic_vector( 7 downto 0); 

    -- Data RX 
    RX_DATA_o               : out std_logic_vector(USER_DATA_WIDTH_g-1 downto 0);
    RX_DATA_SRC_RDY_o       : out std_logic;
    RX_DATA_DST_RDY_i       : in  std_logic;
    -- Message RX
    RX_MSG_o                : out std_logic_vector(USER_MESSAGE_WIDTH_g-1 downto 0);
    RX_MSG_SRC_RDY_o        : out std_logic;
    RX_MSG_DST_RDY_i        : in  std_logic;    
    
        
   
    -- *****************************************************************************************
    -- GTP Interface    
    -- *****************************************************************************************
    
    -- Clock Ports
    GTP_TXUSRCLK2_i          : in  std_logic;
    GTP_RXUSRCLK2_i          : in  std_logic;  
    
    -- Reset FSM Control Ports
    SOFT_RESET_TX_o          : out  std_logic;                                          -- SYS_CLK   --
    SOFT_RESET_RX_o          : out  std_logic;                                          -- SYS_CLK   --
    GTP_DATA_VALID_o         : out std_logic;                                           -- SYS_CLK   --
    
    -- -------------------------------------------------------------------------
    -- TRANSMITTER 
    --------------------- TX Initialization and Reset Ports --------------------
    GTP_TXUSERRDY_o          : out std_logic;                                           -- ASYNC     --
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GTP_TXDATA_o             : out std_logic_vector(15 downto 0);                       -- TXUSRCLK2 --
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    GTP_TXCHARISK_o          : out std_logic_vector(1 downto 0);                        -- TXUSRCLK2 --
    
    -- -------------------------------------------------------------------------
    -- RECEIVER
    --------------------- RX Initialization and Reset Ports --------------------
    GTP_RXUSERRDY_o          : out std_logic;                                           -- ASYNC     --
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GTP_RXDATA_i             : in  std_logic_vector(GTP_DATA_WIDTH_g-1 downto 0);       -- RXUSRCLK2 --
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    GTP_RXCHARISCOMMA_i      : in  std_logic_vector((GTP_DATA_WIDTH_g/8)-1 downto 0);   -- RXUSRCLK2 --
    GTP_RXCHARISK_i          : in  std_logic_vector((GTP_DATA_WIDTH_g/8)-1 downto 0);   -- RXUSRCLK2 --
    GTP_RXDISPERR_i          : in  std_logic_vector((GTP_DATA_WIDTH_g/8)-1 downto 0);   -- RXUSRCLK2 --
    GTP_RXNOTINTABLE_i       : in  std_logic_vector((GTP_DATA_WIDTH_g/8)-1 downto 0);   -- RXUSRCLK2 --
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    GTP_RXBYTEISALIGNED_i      : in  std_logic;                                         -- RXUSRCLK2 --
    GTP_RXBYTEREALIGN_i        : in  std_logic;                                         -- RXUSRCLK2 --
    
    -- -------------------------------------------------------------------------    
    -- COMMON PORTS
    GTP_PLL_LOCK_i           : in  std_logic;                                           -- ASYNC     --
    GTP_PLL_REFCLKLOST_i     : in  std_logic                                            -- SYS_CLK   -- 
             
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
signal auto_align          : std_logic;


signal clear               : std_logic;
signal clk_100_reset       : std_logic;
signal clk_100_locked      : std_logic;

-- ------------------------
signal align_req_meta         : std_logic;
signal align_req_sync         : std_logic;
signal align_req              : std_logic;

signal gen_data              : std_logic_vector(31 downto 0);
signal gen_data_src_rdy      : std_logic;
signal gen_data_dst_rdy      : std_logic;
signal gen_data_rate_cnt     : std_logic_vector(7 downto 0);

signal gen_msg               : std_logic_vector(7 downto 0);
signal gen_msg_src_rdy       : std_logic;
signal gen_msg_dst_rdy       : std_logic;
signal gen_msg_rate_cnt      : std_logic_vector(7 downto 0);


signal tx_error_injection   : std_logic;

signal ccam_pll_reset_meta  : std_logic;
signal ccam_pll_reset_sync  : std_logic;
signal ccam_pll_reset       : std_logic;


-- ------------------------------------------------------------------
-- TX

signal tx_gtp_txusrclk2  : std_logic;

signal tx_pll_alarm      : std_logic;
signal tx_align_request  : std_logic;
signal tx_gtp_align_flag : std_logic;

signal tx_data_rate      : std_logic_vector(15 downto 0);
signal tx_gtp_align_rate : std_logic_vector( 7 downto 0);
signal tx_msg_rate       : std_logic_vector(15 downto 0);
signal tx_idle_rate      : std_logic_vector(15 downto 0);
signal tx_event_rate     : std_logic_vector(15 downto 0);
signal tx_message_rate   : std_logic_vector( 7 downto 0);

signal tx_data           : std_logic_vector(31 downto 0); -- Data to be transmitted
signal tx_data_src_rdy   : std_logic;  -- Handshake for data transmission: Source Ready
signal tx_data_dst_rdy   : std_logic;  -- Handshake for data transmission: Destination Ready
                       
signal tx_msg            : std_logic_vector(7 downto 0); -- Message to be transmitted
signal tx_msg_src_rdy    : std_logic;  -- Handshake for message transmission: Source Ready     
signal tx_msg_dst_rdy    : std_logic;  -- Handshake for message transmission: Destination Ready

signal tx_soft_reset_tx  : std_logic;
signal tx_soft_reset_rx  : std_logic;
signal tx_gtp_data_valid : std_logic;

signal tx_gtp_txuserrdy  : std_logic;                                           -- ASYNC     --
signal tx_gtp_txdata     : std_logic_vector(15 downto 0);                       -- TXUSRCLK2 --
signal tx_gtp_txcharisk  : std_logic_vector(1 downto 0);                        -- TXUSRCLK2 --

signal tx_gtp_pll_lock       : std_logic;
signal tx_gtp_pll_refclklost : std_logic;

-- ---------------------------------------------------------------------------


-- MARK DEBUG
attribute mark_debug : string;
attribute keep : string;
-- attribute keep of ALIGN_REQ_N_i     : signal is "true";
attribute keep of align_req        : signal is "true";
attribute keep of clk_100_reset    : signal is "true";
attribute keep of clk_100_locked   : signal is "true";
attribute keep of tx_gtp_pll_lock  : signal is "true";
attribute keep of tx_gtp_pll_refclklost : signal is "true";
attribute keep of tx_gtp_align_flag : signal is "true";
attribute keep of tx_data          : signal is "true";
attribute keep of tx_data_dst_rdy  : signal is "true";
attribute keep of tx_data_src_rdy  : signal is "true";
attribute keep of tx_msg           : signal is "true";
attribute keep of tx_msg_dst_rdy   : signal is "true";
attribute keep of tx_msg_src_rdy   : signal is "true";
attribute keep of tx_gtp_txdata    : signal is "true";
attribute keep of tx_gtp_txcharisk : signal is "true";

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
 


clear <= fpga_probe_out0(0);

TIME_MACHINE_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  10.0,  -- Main Clock period
    CLEAR_POLARITY_g        => "HIGH",  -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>    10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => false   -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => clk_100,
    CLEAR_i                 => clear,
  
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

process(clk_100, rst_n)
begin
  if (rst_n = '0') then
    align_req_meta  <= '0';
    align_req_sync  <= '0';
    align_req       <= '0';
  elsif rising_edge(clk_100) then
    align_req_meta <= ALIGN_REQUEST_i;
    align_req_sync <= align_req_meta;
    align_req      <= align_req_sync;
  end if;
end process;

-- --------------------------------------------------------
-- Data Generator

process(clk_100, rst_n)
begin
  if (pon_reset_n = '0') then
    gen_data           <= (others => '0');
    gen_data_rate_cnt  <= (others => '0');
    gen_data_src_rdy   <= '0';
  elsif rising_edge(clk_100) then
    if (gen_data_rate_cnt = x"03") then
      gen_data_rate_cnt  <= (others => '0');
      gen_data           <= gen_data + 1;
      gen_data_src_rdy   <= '1';
    else
      if (gen_data_dst_rdy = '1') then
        gen_data_rate_cnt  <= gen_data_rate_cnt + 1;
        gen_data_src_rdy   <= '0';
      end if;
    end if;
  end if;	
end process;

process(clk_100, rst_n)
begin
  if (pon_reset_n = '0') then
    gen_msg           <= (others => '0');
    gen_msg_rate_cnt  <= (others => '0');
    gen_msg_src_rdy   <= '0';
  elsif rising_edge(clk_100) then
    if (gen_msg_rate_cnt = x"03") then
      gen_msg_rate_cnt  <= (others => '0');
      gen_msg           <= gen_msg + 1;
      gen_msg_src_rdy   <= '1';
    else
      if (gen_msg_dst_rdy = '1') then
        gen_msg_rate_cnt  <= gen_msg_rate_cnt + 1;
        gen_msg_src_rdy   <= '0';
      end if;
    end if;
  end if;	
end process;




tx_data          <= gen_data;
tx_data_src_rdy  <= gen_data_src_rdy; 
gen_data_dst_rdy <= tx_data_dst_rdy;

tx_msg           <= gen_msg;
tx_msg_src_rdy   <= gen_msg_src_rdy;
gen_msg_dst_rdy  <= tx_msg_dst_rdy;

tx_align_request <= align_req;

GTP_MANAGER_TX_i : GTP_Manager 
  generic map( 
    USER_DATA_WIDTH_g         =>   32,    -- Width of Data - Fabric side
    USER_MESSAGE_WIDTH_g      =>    8,    -- Width of Message - Fabric side 
    GTP_DATA_WIDTH_g          =>   16,    -- Width of Data - GTP side
    GTP_TXUSRCLK2_PERIOD_NS_g =>  6.4,    -- GTP User clock period
    GTP_RXUSRCLK2_PERIOD_NS_g =>  6.4,    -- GTP User clock period
    SIM_TIME_COMPRESSION_g    => false    -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    
    -- COMMONs
    -- Bare Control ports
    CLK_i                   => clk_100,   -- Input clock - Fabric side
    RST_N_i                 => rst_n,   -- Asynchronous active low reset (clk clock)
    EN1S_i                  => en1s,   -- Enable @ 1 sec in clk domain 

    -- Status
    PLL_ALARM_o             => tx_pll_alarm,
    
    -- ---------------------------------------------------------------------------------------
    -- TX SIDE

    -- Control in
    TX_AUTO_ALIGN_i         => '0',   -- Enables the "Auto alignment mode"
    TX_ALIGN_REQUEST_i      => tx_align_request,   -- Align request from Receiver
    TX_ERROR_INJECTION_i    => '0',   -- Error insertin (debug purpose)
    
    -- Status
    TX_GTP_ALIGN_FLAG_o     => tx_gtp_align_flag,   -- Monitor out: sending align
    
    -- Statistics
    TX_DATA_RATE_o          => tx_data_rate, 
    TX_GTP_ALIGN_RATE_o     => tx_gtp_align_rate, 
    TX_MSG_RATE_o           => tx_msg_rate, 
    TX_IDLE_RATE_o          => tx_idle_rate, 
    TX_EVENT_RATE_o         => tx_event_rate, 
    TX_MESSAGE_RATE_o       => tx_message_rate, 

  
    -- Data TX 
    TX_DATA_i               => tx_data,
    TX_DATA_SRC_RDY_i       => tx_data_src_rdy,
    TX_DATA_DST_RDY_o       => tx_data_dst_rdy,
    -- Message TX                 
    TX_MSG_i                => tx_msg,
    TX_MSG_SRC_RDY_i        => tx_msg_src_rdy,
    TX_MSG_DST_RDY_o        => tx_msg_dst_rdy,

    -- ---------------------------------------------------------------------------------------
    -- RX SIDE    
    
    -- Control out
    RX_ALIGN_REQUEST_o      => open,  
    
    -- Statistics        
    RX_DATA_RATE_o          => open,     
    RX_GTP_ALIGN_RATE_o     => open,
    RX_MSG_RATE_o           => open,      
    RX_IDLE_RATE_o          => open,     
    RX_EVENT_RATE_o         => open,    
    RX_MESSAGE_RATE_o       => open,  

    -- Data RX 
    RX_DATA_o               => open,
    RX_DATA_SRC_RDY_o       => open,
    RX_DATA_DST_RDY_i       => '0',
    -- Message RX
    RX_MSG_o                => open,
    RX_MSG_SRC_RDY_o        => open, 
    RX_MSG_DST_RDY_i        => '0', 
    
        
   
    -- *****************************************************************************************
    -- GTP Interface    
    -- *****************************************************************************************
    
    -- Clock Ports
    GTP_TXUSRCLK2_i          => tx_gtp_txusrclk2,
    GTP_RXUSRCLK2_i          => '0',  
    
    -- Reset FSM Control Ports
    SOFT_RESET_TX_o          => tx_soft_reset_tx,                                       -- SYS_CLK   --
    SOFT_RESET_RX_o          => tx_soft_reset_rx,                                       -- SYS_CLK   --
    GTP_DATA_VALID_o         => tx_gtp_data_valid,
        
    -- -------------------------------------------------------------------------
    -- TRANSMITTER 
    --------------------- TX Initialization and Reset Ports --------------------
    GTP_TXUSERRDY_o          => tx_gtp_txuserrdy,                                       -- ASYNC     --
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GTP_TXDATA_o             => tx_gtp_txdata,                                          -- TXUSRCLK2 --
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    GTP_TXCHARISK_o          => tx_gtp_txcharisk,                                       -- TXUSRCLK2 --
    
    -- -------------------------------------------------------------------------
    -- RECEIVER
    --------------------- RX Initialization and Reset Ports --------------------
    GTP_RXUSERRDY_o          => open,                                                   -- ASYNC     --
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GTP_RXDATA_i             => (others => '0'),                                        -- RXUSRCLK2 --
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    GTP_RXCHARISCOMMA_i      => (others => '0'),                                        -- RXUSRCLK2 --
    GTP_RXCHARISK_i          => (others => '0'),                                        -- RXUSRCLK2 --
    GTP_RXDISPERR_i          => (others => '0'),                                        -- RXUSRCLK2 --
    GTP_RXNOTINTABLE_i       => (others => '0'),                                        -- RXUSRCLK2 --
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    GTP_RXBYTEISALIGNED_i    => '0',                                                    -- RXUSRCLK2 --
    GTP_RXBYTEREALIGN_i      => '0',                                                    -- RXUSRCLK2 --
    
    -- -------------------------------------------------------------------------    
    -- COMMON PORTS
    GTP_PLL_LOCK_i           => tx_gtp_pll_lock,                                        -- ASYNC     --
    GTP_PLL_REFCLKLOST_i     => tx_gtp_pll_refclklost                                   -- SYS_CLK   -- 
    );


-- -----------------------------------------------------------------------------
-- GTP Clock Domain




   
GTP_Artix_i : GTP_Artix
  port map
    (
      SOFT_RESET_TX_IN                =>      tx_soft_reset_tx,
      DONT_RESET_ON_DATA_ERROR_IN     =>      '0',
      Q0_CLK0_GTREFCLK_PAD_N_IN       =>      REFCLK0_TX_N_i,
      Q0_CLK0_GTREFCLK_PAD_P_IN       =>      REFCLK0_TX_P_i,
      GT0_TX_FSM_RESET_DONE_OUT       =>      open,
      GT0_RX_FSM_RESET_DONE_OUT       =>      open,
      GT0_DATA_VALID_IN               =>      tx_gtp_data_valid,
 
      GT0_TXUSRCLK_OUT                =>      open,
      GT0_TXUSRCLK2_OUT               =>      tx_gtp_txusrclk2,

      --_____________________________________________________________________
      --_____________________________________________________________________
      --GT0  (X0Y0)

      ---------------------------- Channel - DRP Ports  --------------------------
      gt0_drpaddr_in                  => (others => '0'),
      gt0_drpdi_in                    => (others => '0'),  
      gt0_drpdo_out                   => open,  
      gt0_drpen_in                    => '0',  
      gt0_drprdy_out                  => open, 
      gt0_drpwe_in                    => '0', 
      --------------------- RX Initialization and Reset Ports --------------------
      gt0_eyescanreset_in             => '0',
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out        =>  open,
      gt0_eyescantrigger_in           =>  '0',
      ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
      gt0_dmonitorout_out             =>  open,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in                =>  '0',
      gt0_rxlpmreset_in               =>  '0',
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in                =>  '0',
      gt0_txuserrdy_in                =>  tx_gtp_txuserrdy,
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      gt0_txdata_in                   =>  tx_gtp_txdata, -- gt0_txdata_in,
      ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
      gt0_txcharisk_in                =>  tx_gtp_txcharisk, -- gt0_txcharisk_in,
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      gt0_gtptxn_out                  =>  TXN_o,
      gt0_gtptxp_out                  =>  TXP_o,
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      gt0_txoutclkfabric_out          =>  open,
      gt0_txoutclkpcs_out             =>  open,
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      gt0_txresetdone_out             =>  open,

      --____________________________COMMON PORTS________________________________
      GT0_PLL0OUTCLK_OUT              =>  open,
      GT0_PLL0OUTREFCLK_OUT           =>  open,
      GT0_PLL0LOCK_OUT                =>  tx_gtp_pll_lock,
      GT0_PLL0REFCLKLOST_OUT          =>  tx_gtp_pll_refclklost,    
      GT0_PLL1OUTCLK_OUT              =>  open,
      GT0_PLL1OUTREFCLK_OUT           =>  open,
      sysclk_in                       =>  clk_100
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










-- -----------------------------------------------------------------------------
-- IDEBUG

-- ila_fpga_probe0 <= tx_data;
-- ila_fpga_probe1 <= "00000000000000" & tx_data_dst_rdy & tx_data_src_rdy; 
fpga_probe_in0 <= "00000000000000" & clk_100_locked & rst_n;  

VIO_FPGA : vio_0
  PORT MAP (
    clk => clk_100,
    probe_in0   => fpga_probe_in0,
    probe_out0  => fpga_probe_out0
  );
  
  
  
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



--------------------------------

gtp_probe_in0 <= "0000000000000" & align_req & tx_gtp_pll_refclklost & tx_gtp_pll_lock;  

VIO_GTP : vio_0
  PORT MAP (
    clk => tx_gtp_txusrclk2,
    probe_in0   => gtp_probe_in0,
    probe_out0  => gtp_probe_out0
  );
  
  
  
ila_gtp_probe0 <= tx_gtp_txdata;
ila_gtp_probe1 <= "000000000000" & tx_gtp_align_flag & tx_gtp_txcharisk & align_req;

ILA_GTP_i : ila_0
PORT MAP (
	clk      => tx_gtp_txusrclk2,
	probe0   => ila_gtp_probe0,
	probe1   => ila_gtp_probe1
);



CCAM_PLL_RESET_i <= fpga_probe_out0(15);
-- ALIGN_REQ_N_i    <= gck;

end RTL;

