-- ==============================================================================
-- DESCRIPTION:
-- Provides an interface from/to GTP Transceivers 
-- ------------------------------------------
-- File        : GTP_Manager.vhd
-- Revision    : 1.0
-- Author      : M. Casti
-- Date        : 22/03/2021
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  04/05/2020 - M. Casti
-- - Initial release
-- 
-- ==============================================================================
-- WRITING STYLE 
-- 
-- INPUTs:    UPPERCASE followed by "_i"
-- OUTPUTs:   UPPERCASE followed by "_o"
-- BUFFERs:   UPPERCASE followed by "_b"
-- CONSTANTs: UPPERCASE followed by "_c"
-- GENERICs:  UPPERCASE followed by "_g"
-- 
-- ==============================================================================


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;

entity GTP_Manager is
  generic ( 
    USER_DATA_WIDTH_g         : integer range 0 to 64 := 32;    -- Width of Data - Fabric side
    USER_MESSAGE_WIDTH_g      : integer range 0 to 64 :=  8;    -- Width of Message - Fabric side 
    GTP_DATA_WIDTH_g          : integer range 0 to 64 := 16;    -- Width of Data - GTP side
    GTP_TXUSRCLK2_PERIOD_NS_g : real :=  6.4;                   -- GTP User clock period
    GTP_RXUSRCLK2_PERIOD_NS_g : real :=  6.4;                   -- GTP User clock period
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
end GTP_Manager;


architecture Behavioral of GTP_Manager is

attribute ASYNC_REG : string;

component DATA_SYNC_FIFO
  port (
    rst : in std_logic;
    wr_clk : in std_logic;
    rd_clk : in std_logic;
    din : in std_logic_vector(31 downto 0);
    wr_en : in std_logic;
    rd_en : in std_logic;
    dout : out std_logic_vector(31 downto 0);
    full : out std_logic;
    overflow : out std_logic;
    empty : out std_logic;
    valid : out std_logic
  );
end component;

component MSG_SYNC_FIFO
  port (
    rst : in std_logic;
    wr_clk : in std_logic;
    rd_clk : in std_logic;
    din : in std_logic_vector(7 downto 0);
    wr_en : in std_logic;
    rd_en : in std_logic;
    dout : out std_logic_vector(7 downto 0);
    full : out std_logic;
    overflow : out std_logic;
    empty : out std_logic;
    valid : out std_logic
  );
end component;

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

component enable_signal_cdc is
 port (
  CLEAR_N_i           : in     std_logic;                      -- System Reset 
  CLK_SOURCE_i        : in     std_logic;                      -- Origin Clock 
  CLK_DEST_i          : in     std_logic;                      -- Destination Clock
  EN_SIG_SOURCE_i     : in     std_logic;                      -- "Enable Signal" in origin clock domain 
  EN_SIG_DEST_o       : out    std_logic;                      -- "Enable Signal" in destination clock domain 
  EN_SIG_SHORT_DEST_o : out    std_logic := '0'                -- Derivation of "EN_SIG_DEST" in destination clock domain 
  );                                                           -- NOTE: Use EN_DEST if SIG_ORIGIN is a one clock duration enable to be transferred
end component;

-- ----------------------------------------------------------------------------------------------
-- CONSTANTS
--
-- Valid Control K Characters (8B/10B)
constant K28_0 : std_logic_vector(7 downto 0) := "00011100"; -- 1C
constant K28_1 : std_logic_vector(7 downto 0) := "00111100"; -- 3C
constant K28_2 : std_logic_vector(7 downto 0) := "01011100"; -- 5C
constant K28_3 : std_logic_vector(7 downto 0) := "01111100"; -- 7C
constant K28_4 : std_logic_vector(7 downto 0) := "10011100"; -- 9C
constant K28_5 : std_logic_vector(7 downto 0) := "10111100"; -- BC
constant K28_6 : std_logic_vector(7 downto 0) := "11011100"; -- DC
constant K28_7 : std_logic_vector(7 downto 0) := "11111100"; -- FC
constant K23_7 : std_logic_vector(7 downto 0) := "11110111"; -- F7
constant K27_7 : std_logic_vector(7 downto 0) := "11111011"; -- FB
constant K29_7 : std_logic_vector(7 downto 0) := "11111101"; -- FD
constant K30_7 : std_logic_vector(7 downto 0) := "11111110"; -- FE

--
constant IDLE_HEAD_c : std_logic_vector(15 downto 0) := K28_0 & K28_1;
constant IDLE_TAIL_c : std_logic_vector(15 downto 0) := K28_2 & K28_3;
constant ALIGN_c     : std_logic_vector(15 downto 0) := K28_5 & K28_5;
constant MSG_c       : std_logic_vector( 7 downto 0) := K30_7; -- & K30_7;

-- ----------------------------------------------------------------------------------------------
-- SIGNALS

-- ------------------------------------------------------------------------------
-- COMMON

signal cm_pll_lock_meta    : std_logic;
attribute ASYNC_REG of cm_pll_lock_meta  : signal is "true";
signal cm_pll_lock_sync    : std_logic;
attribute ASYNC_REG of cm_pll_lock_sync  : signal is "true";
signal cm_pll_lock         : std_logic;
attribute ASYNC_REG of cm_pll_lock       : signal is "true";
signal cm_clk_lost_meta    : std_logic;
attribute ASYNC_REG of cm_clk_lost_meta  : signal is "true";
signal cm_clk_lost_sync    : std_logic;
attribute ASYNC_REG of cm_clk_lost_sync  : signal is "true";
signal cm_clk_lost         : std_logic;
attribute ASYNC_REG of cm_clk_lost       : signal is "true";

signal cm_pll_fail         : std_logic;
signal cm_pll_alarm_cnt    : std_logic_vector(1 downto 0);
signal cm_pll_alarm        : std_logic;

signal cm_reset_cnt        : std_logic_vector(3 downto 0);
signal cm_reset            : std_logic;


-- ------------------------------------------------------------------------------
-- TX
signal tx_clear                    : std_logic;          

signal tx_rst_gcktx                : std_logic;
signal tx_rst_n_gcktx              : std_logic;
signal tx_pon_reset_n_gcktx        : std_logic;
signal tx_en100us_gcktx            : std_logic;
signal tx_en1ms_gcktx              : std_logic;
signal tx_en1ms_gcktx_cdc          : std_logic;

signal tx_align_req_meta_gcktx : std_logic;
attribute ASYNC_REG of tx_align_req_meta_gcktx : signal is "true";
signal tx_align_req_sync_gcktx : std_logic;
attribute ASYNC_REG of tx_align_req_sync_gcktx : signal is "true";
signal tx_align_req_gcktx      : std_logic;
attribute ASYNC_REG of tx_align_req_gcktx      : signal is "true";
signal tx_align_req_r_gcktx    : std_logic;

signal tx_gtp_align_flag_meta_gcktx_cdc       : std_logic;
attribute ASYNC_REG of tx_gtp_align_flag_meta_gcktx_cdc : signal is "true";
signal tx_gtp_align_flag_sync_gcktx_cdc       : std_logic;
attribute ASYNC_REG of tx_gtp_align_flag_sync_gcktx_cdc : signal is "true";
signal tx_gtp_align_flag_gcktx_cdc            : std_logic;
attribute ASYNC_REG of tx_gtp_align_flag_gcktx_cdc      : signal is "true";

signal tx_data_fifo_wr_en          : std_logic;
signal tx_data_fifo_rd_en_gcktx    : std_logic;
signal tx_data_fifo_din            : std_logic_vector(31 downto 0);
signal tx_data_fifo_dout_gcktx     : std_logic_vector(31 downto 0);
signal tx_data_fifo_full           : std_logic;
signal tx_data_fifo_overflow       : std_logic;
signal tx_data_fifo_empty_gcktx    : std_logic;
signal tx_data_fifo_valid_gcktx    : std_logic;
signal tx_data_fifo_rst            : std_logic;

signal tx_msg_fifo_wr_en           : std_logic; 
signal tx_msg_fifo_rd_en_gcktx     : std_logic;
signal tx_msg_fifo_din             : std_logic_vector(7 downto 0);
signal tx_msg_fifo_dout_gcktx      : std_logic_vector(7 downto 0);
signal tx_msg_fifo_full            : std_logic;
signal tx_msg_fifo_overflow        : std_logic;
signal tx_msg_fifo_empty_gcktx     : std_logic;
signal tx_msg_fifo_valid_gcktx     : std_logic;
signal tx_msg_fifo_rst             : std_logic;

signal gtp_stream_out_p_gcktx      : std_logic_vector(GTP_DATA_WIDTH_g-1 downto 0);
signal gtp_stream_out_gcktx        : std_logic_vector(GTP_DATA_WIDTH_g-1 downto 0);
signal tx_char_is_k_p_gcktx        : std_logic_vector((GTP_DATA_WIDTH_g/8)-1 downto 0);
signal tx_char_is_k_gcktx          : std_logic_vector((GTP_DATA_WIDTH_g/8)-1 downto 0);

signal tx_data_w_sel_gcktx         : std_logic;
-- signal tx_idle_w_sel_gcktx         : std_logic;
-- signal tx_word_toggle_gcktx        : std_logic;
signal tx_data_w_enable_gcktx      : std_logic;
-- signal tx_idle_w_enable_gcktx      : std_logic;
-- signal tx_msg_enable_gcktx         : std_logic;

-- signal tx_idle_head_flag_gcktx     : std_logic;
-- signal tx_idle_tail_flag_gcktx     : std_logic;
signal tx_idle_flag_gcktx          : std_logic;
signal tx_gtp_align_flag_gcktx     : std_logic;          
signal tx_msg_flag_gcktx           : std_logic; 
signal tx_data_w0_flag_gcktx       : std_logic;
signal tx_data_w1_flag_gcktx       : std_logic;
signal tx_data_flag_gcktx          : std_logic;

-- Rate Counters
signal tx_data_cnt_gcktx           : std_logic_vector(15 downto 0); 
signal tx_data_rate_gcktx          : std_logic_vector(15 downto 0); 
signal tx_gtp_align_cnt_gcktx      : std_logic_vector( 7 downto 0); 
signal tx_gtp_align_rate_gcktx     : std_logic_vector( 7 downto 0); 
signal tx_msg_cnt_gcktx            : std_logic_vector(15 downto 0); 
signal tx_msg_rate_gcktx           : std_logic_vector(15 downto 0); 
signal tx_idle_cnt_gcktx           : std_logic_vector(15 downto 0); 
signal tx_idle_rate_gcktx          : std_logic_vector(15 downto 0); 

signal tx_data_rate_gcktx_cdc      : std_logic_vector(15 downto 0); 
signal tx_gtp_align_rate_gcktx_cdc : std_logic_vector( 7 downto 0); 
signal tx_msg_rate_gcktx_cdc       : std_logic_vector(15 downto 0); 
signal tx_idle_rate_gcktx_cdc      : std_logic_vector(15 downto 0); 
signal tx_event_cnt                : std_logic_vector(15 downto 0); 
signal tx_event_rate               : std_logic_vector(15 downto 0); 
signal tx_message_cnt              : std_logic_vector( 7 downto 0); 
signal tx_message_rate             : std_logic_vector( 7 downto 0); 

-- ------------------------------------------------------------------------------
-- RX
signal rx_clear                    : std_logic;      

signal rx_rst_gckrx                : std_logic;
signal rx_rst_n_gckrx              : std_logic;
signal rx_pon_reset_n_gckrx        : std_logic;
signal rx_en100us_gckrx            : std_logic;
signal rx_en1ms_gckrx              : std_logic;
signal rx_en1ms_gckrx_cdc          : std_logic;

signal rx_k_chars_gckrx            : std_logic;
signal rx_k_chars_d_gckrx          : std_logic;
signal rx_k_chars_up_gckrx         : std_logic;

signal rx_data_flag_gckrx          : std_logic;
signal rx_data_flag_d_gckrx        : std_logic;
signal rx_msg_flag_gckrx           : std_logic; 
signal rx_msg_flag_d_gckrx         : std_logic; 
signal rx_idle_flag_gckrx          : std_logic;
signal rx_idle_flag_d_gckrx        : std_logic;
signal rx_gtp_align_flag_gckrx     : std_logic;
signal rx_gtp_align_flag_d_gckrx   : std_logic;
signal rx_unknown_k_flag_gckrx     : std_logic;
signal rx_unknown_k_flag_d_gckrx   : std_logic;

-- Rate Counters
signal rx_data_cnt_gckrx           : std_logic_vector(15 downto 0); 
signal rx_data_rate_gckrx          : std_logic_vector(15 downto 0); 
signal rx_gtp_align_cnt_gckrx      : std_logic_vector( 7 downto 0); 
signal rx_gtp_align_rate_gckrx     : std_logic_vector( 7 downto 0); 
signal rx_msg_cnt_gckrx            : std_logic_vector(15 downto 0); 
signal rx_msg_rate_gckrx           : std_logic_vector(15 downto 0); 
signal rx_idle_cnt_gckrx           : std_logic_vector(15 downto 0); 
signal rx_idle_rate_gckrx          : std_logic_vector(15 downto 0); 

signal rx_data_rate_gckrx_cdc      : std_logic_vector(15 downto 0); 
signal rx_gtp_align_rate_gckrx_cdc : std_logic_vector( 7 downto 0); 
signal rx_msg_rate_gckrx_cdc       : std_logic_vector(15 downto 0); 
signal rx_idle_rate_gckrx_cdc      : std_logic_vector(15 downto 0); 
signal rx_event_cnt                : std_logic_vector(15 downto 0); 
signal rx_event_rate               : std_logic_vector(15 downto 0); 
signal rx_message_cnt              : std_logic_vector( 7 downto 0); 
signal rx_message_rate             : std_logic_vector( 7 downto 0); 

signal rx_data_fifo_wr_en_gckrx    : std_logic;
signal rx_data_fifo_rd_en          : std_logic;
signal rx_data_fifo_din_gckrx      : std_logic_vector(31 downto 0);
signal rx_data_fifo_dout           : std_logic_vector(31 downto 0);
signal rx_data_fifo_full_gckrx     : std_logic;
signal rx_data_fifo_overflow_gckrx : std_logic;
signal rx_data_fifo_empty          : std_logic;
signal rx_data_fifo_valid          : std_logic;
signal rx_data_fifo_rst            : std_logic;

signal rx_msg_fifo_wr_en_gckrx     : std_logic; 
signal rx_msg_fifo_rd_en           : std_logic;
signal rx_msg_fifo_din_gckrx       : std_logic_vector(7 downto 0);
signal rx_msg_fifo_dout            : std_logic_vector(7 downto 0);
signal rx_msg_fifo_full_gckrx      : std_logic;
signal rx_msg_fifo_overflow_gckrx  : std_logic;
signal rx_msg_fifo_empty           : std_logic;
signal rx_msg_fifo_valid           : std_logic;
signal rx_msg_fifo_rst             : std_logic;

signal rx_unknown_k_detect_gckrx   : std_logic;
signal rx_unknown_k_detected_gckrx : std_logic;

signal rx_align_req_gckrx          : std_logic;
signal rx_align_req_meta_gckrx_cdc       : std_logic;
attribute ASYNC_REG of rx_align_req_meta_gckrx_cdc : signal is "true";
signal rx_align_req_sync_gckrx_cdc       : std_logic;
attribute ASYNC_REG of rx_align_req_sync_gckrx_cdc : signal is "true";
signal rx_align_req_gckrx_cdc            : std_logic;
attribute ASYNC_REG of rx_align_req_gckrx_cdc      : signal is "true";

signal rx_data_w_exp_toggle_gckrx  : std_logic;
signal rx_data_w0_exp_gckrx        : std_logic;
signal rx_data_w1_exp_gckrx        : std_logic;
-- signal data_w0_gckrx            : std_logic_vector(GTP_DATA_WIDTH_g-1 downto 0);
signal rx_data_w1_gckrx            : std_logic_vector(GTP_DATA_WIDTH_g-1 downto 0);

begin


-- ----------------------------------------------------------------------------------
--    ___                               
--   / __| ___  _ __   _ __   ___  _ _  
--  | (__ / _ \| '  \ | '  \ / _ \| ' \ 
--   \___|\___/|_|_|_||_|_|_|\___/|_||_|
--                             

-- ----------------------------------------------------------------------------------
-- Input synchronization

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    cm_pll_lock_meta <= '0';
    cm_pll_lock_sync <= '0';
    cm_pll_lock <= '0';
  elsif rising_edge(CLK_i) then
    cm_pll_lock_meta  <= GTP_PLL_LOCK_i;
    cm_pll_lock_sync  <= cm_pll_lock_meta;
    cm_pll_lock       <= cm_pll_lock_sync;
  end if;
end process;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    cm_clk_lost_meta <= '0';
    cm_clk_lost_sync <= '0';
    cm_clk_lost <= '0';
  elsif rising_edge(CLK_i) then
    cm_clk_lost_meta  <= GTP_PLL_REFCLKLOST_i;
    cm_clk_lost_sync  <= cm_clk_lost_meta;
    cm_clk_lost       <= cm_clk_lost_sync;
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- GTP RESET

cm_pll_fail <= (cm_clk_lost or not cm_pll_lock);

-- Both (gtp_clk_lost) and (not gtp_pll_lock) make a Reset procedure start, but if 
-- reference clock is lost (gtp_clk_lost high) the counter will wait until it goes down before starting.
-- The entire procedure will last from two to three seconds (depending on when the faulure will occurr 
-- within the one-second slots).
-- The reset trigger is sent one second before the expected end-of-alarm, and it lasts 15 clock steps.

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    cm_pll_alarm_cnt  <= "00";
    cm_pll_alarm      <= '0';
  elsif rising_edge(CLK_i) then
    if (cm_pll_alarm_cnt /= "00" ) then                          -- If the counter was triggered
      if (EN1S_i = '1') then                                      --   if the one second clock enable occurs
        if (cm_clk_lost = '1') then                              --     if the reference clock is missing
          cm_pll_alarm_cnt <= "11";                              --       the counter will be reset again
        else                                                      --     else   
          cm_pll_alarm_cnt <= cm_pll_alarm_cnt - 1;             --       counter decreases
        end if;                            
      end if;
    elsif (cm_pll_fail = '1') then                               -- else if the counter is at its idle state and a fail occurs   
      cm_pll_alarm_cnt <= "11";                                  --   the countr is triggered  
    end if;
   
    if (cm_pll_alarm_cnt /= "00" or cm_pll_fail = '1') then     -- gtp_pll_alarm flag
      cm_pll_alarm <= '1';
    else
      cm_pll_alarm <= '0';
    end if;
  end if;
end process;


-- When triggered, the reset signal will last 15 clock steps at one second brfore the expected duratin of alarm
process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    cm_reset_cnt  <= conv_std_logic_vector(0, cm_reset_cnt'length);
    cm_reset      <= '0';
  elsif rising_edge(CLK_i) then
    if (cm_pll_alarm_cnt = "10" and EN1S_i = '1') then
      cm_reset_cnt <= conv_std_logic_vector(15, cm_reset_cnt'length);
    elsif (cm_reset_cnt /= conv_std_logic_vector(0, cm_reset_cnt'length)) then
      cm_reset_cnt <= cm_reset_cnt - 1;
    end if;
    
    cm_reset <= or_reduce(cm_reset_cnt);
    
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- OUTPUTs

-- GTP Interface outputs ports

GTP_DATA_VALID_o  <= '1'; 
PLL_ALARM_o       <= cm_pll_alarm;


-- ----------------------------------------------------------------------------------
--   _____ __  __
--  |_   _|\ \/ /
--    | |   >  < 
--    |_|  /_/\_\
--

-- ----------------------------------------------------------------------------------
-- TIME MACHINE

tx_clear <= cm_pll_alarm or not RST_N_i;

TIME_MACHINE_GCKTX_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  GTP_TXUSRCLK2_PERIOD_NS_g,  -- Main Clock period
    CLEAR_POLARITY_g        => "HIGH",                      -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,                        -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => SIM_TIME_COMPRESSION_g       -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => GTP_TXUSRCLK2_i,
    CLEAR_i                 => tx_clear,
  
    -- Output reset
    RESET_o                 => tx_rst_gcktx,
    RESET_N_o               => tx_rst_n_gcktx,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => tx_pon_reset_n_gcktx,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => tx_en100us_gcktx,
    EN1MS_o                 => tx_en1ms_gcktx,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );

ENABLE_SIGNAL_CDC_TX_i : enable_signal_cdc
 port map(
  CLEAR_N_i           => tx_rst_n_gcktx,
  CLK_SOURCE_i        => GTP_TXUSRCLK2_i,
  CLK_DEST_i          => CLK_i,
  EN_SIG_SOURCE_i     => tx_en1ms_gcktx,
  EN_SIG_DEST_o       => open,
  EN_SIG_SHORT_DEST_o => tx_en1ms_gcktx_cdc
  ); 
  
-- ----------------------------------------------------------------------------------
-- Input synchronization
  
process(GTP_TXUSRCLK2_i, tx_rst_n_gcktx)
begin
  if (tx_rst_n_gcktx = '0') then
    tx_align_req_meta_gcktx  <= '0';
    tx_align_req_sync_gcktx  <= '0';
    tx_align_req_gcktx       <= '0';
    tx_align_req_r_gcktx     <= '0';
  elsif rising_edge(GTP_TXUSRCLK2_i) then
    tx_align_req_meta_gcktx <= TX_ALIGN_REQUEST_i;
    tx_align_req_sync_gcktx <= tx_align_req_meta_gcktx;
    tx_align_req_gcktx      <= tx_align_req_sync_gcktx;
    if (tx_data_w1_flag_gcktx = '0') then
      tx_align_req_r_gcktx  <= tx_align_req_gcktx;
    end if;    
  end if;
end process;

-- --------------------------------------------------------------------------
-- FIFOES

-- Main DATA

tx_data_fifo_din         <= TX_DATA_i;
tx_data_fifo_wr_en       <= not tx_data_fifo_full and TX_DATA_SRC_RDY_i;
tx_data_fifo_rd_en_gcktx <= tx_data_w0_flag_gcktx and not tx_data_fifo_empty_gcktx;
tx_data_fifo_rst         <= tx_rst_gcktx;

TX_DATA_SYNC_FIFO_i :  DATA_SYNC_FIFO
  port map (
    rst       => tx_data_fifo_rst,               
    wr_clk    => CLK_i,         
    rd_clk    => GTP_TXUSRCLK2_i,         
    din       => tx_data_fifo_din,      
    wr_en     => tx_data_fifo_wr_en,        
    rd_en     => tx_data_fifo_rd_en_gcktx,        
    dout      => tx_data_fifo_dout_gcktx,  
    full      => tx_data_fifo_full,         
    overflow  => tx_data_fifo_overflow,     
    empty     => tx_data_fifo_empty_gcktx,        
    valid     => tx_data_fifo_valid_gcktx         
  );


-- Messages

tx_msg_fifo_din         <= TX_MSG_i;
tx_msg_fifo_wr_en       <= not tx_msg_fifo_full and TX_MSG_SRC_RDY_i;
tx_msg_fifo_rd_en_gcktx <= tx_msg_flag_gcktx and not tx_msg_fifo_empty_gcktx;
tx_msg_fifo_rst         <= tx_rst_gcktx;

TX_MSG_SYNC_FIFO_i :  MSG_SYNC_FIFO
  port map (
    rst       => tx_msg_fifo_rst,               
    wr_clk    => CLK_i,        
    rd_clk    => GTP_TXUSRCLK2_i,
    din       => tx_msg_fifo_din,      
    wr_en     => tx_msg_fifo_wr_en,        
    rd_en     => tx_msg_fifo_rd_en_gcktx,        
    dout      => tx_msg_fifo_dout_gcktx,  
    full      => tx_msg_fifo_full,         
    overflow  => tx_msg_fifo_overflow,     
    empty     => tx_msg_fifo_empty_gcktx,        
    valid     => tx_msg_fifo_valid_gcktx        
  );
  

tx_data_w_enable_gcktx    <= tx_data_fifo_valid_gcktx and not tx_align_req_r_gcktx;

process(GTP_TXUSRCLK2_i, tx_rst_n_gcktx)
begin
  if (tx_rst_n_gcktx = '0') then
    tx_data_w_sel_gcktx <= '1';
  elsif rising_edge(GTP_TXUSRCLK2_i) then
    if (tx_data_w_enable_gcktx = '1') then
      tx_data_w_sel_gcktx <= not tx_data_w_sel_gcktx;
    else
      tx_data_w_sel_gcktx <= '1';
    end if;
  end if;
end process;  


tx_gtp_align_flag_gcktx  <= tx_align_req_r_gcktx and tx_en100us_gcktx;
tx_data_w1_flag_gcktx    <= not tx_align_req_r_gcktx and tx_data_fifo_valid_gcktx and tx_data_w_sel_gcktx;
tx_data_w0_flag_gcktx    <= not tx_align_req_r_gcktx and tx_data_fifo_valid_gcktx and not tx_data_w_sel_gcktx;
tx_msg_flag_gcktx        <= not tx_align_req_r_gcktx and not tx_data_fifo_valid_gcktx and tx_msg_fifo_valid_gcktx;
tx_data_flag_gcktx       <= tx_data_w0_flag_gcktx or tx_data_w1_flag_gcktx;
tx_idle_flag_gcktx       <= not (tx_gtp_align_flag_gcktx or tx_msg_flag_gcktx or tx_data_flag_gcktx);

process (tx_gtp_align_flag_gcktx, tx_data_w1_flag_gcktx, tx_data_w0_flag_gcktx, 
         tx_msg_flag_gcktx, tx_data_fifo_dout_gcktx, tx_msg_fifo_dout_gcktx)
begin

  if (tx_gtp_align_flag_gcktx = '1') then 
    gtp_stream_out_p_gcktx   <= ALIGN_c;
    tx_char_is_k_p_gcktx  <= "01"; -- ALIGN_KEY_i; 
  elsif (tx_data_w1_flag_gcktx = '1')   then 
    gtp_stream_out_p_gcktx  <= tx_data_fifo_dout_gcktx(31 downto 16);
    tx_char_is_k_p_gcktx <= "00";
  elsif (tx_data_w0_flag_gcktx = '1')   then
    gtp_stream_out_p_gcktx  <= tx_data_fifo_dout_gcktx(15 downto  0);
    tx_char_is_k_p_gcktx <= "00";
  elsif (tx_msg_flag_gcktx = '1') then 
    gtp_stream_out_p_gcktx   <= MSG_c & tx_msg_fifo_dout_gcktx;
    tx_char_is_k_p_gcktx  <= "10";
  else 
    gtp_stream_out_p_gcktx  <= IDLE_HEAD_c;
    tx_char_is_k_p_gcktx <= "11";
  end if;  
end process;


-- ------------------------------------------------------------------------------------------
-- TX Rate Counters

process (GTP_TXUSRCLK2_i, tx_rst_n_gcktx)
begin
  if (tx_rst_n_gcktx = '0') then
    tx_data_cnt_gcktx        <= (others => '0');
    tx_data_rate_gcktx       <= (others => '0');
    --
    tx_msg_cnt_gcktx         <= (others => '0');
    tx_msg_rate_gcktx        <= (others => '0');
    --
    tx_gtp_align_cnt_gcktx   <= (others => '0');
    tx_gtp_align_rate_gcktx  <= (others => '0');
    --
    tx_idle_cnt_gcktx        <= (others => '0');
    tx_idle_rate_gcktx       <= (others => '0');
    
  elsif rising_edge(GTP_TXUSRCLK2_i) then
  
    if (tx_en1ms_gcktx = '1') then
      tx_data_cnt_gcktx       <= (0 => tx_data_flag_gcktx, others => '0');
      tx_data_rate_gcktx      <= tx_data_cnt_gcktx;
    elsif (tx_data_flag_gcktx = '1') then
      tx_data_cnt_gcktx       <= tx_data_cnt_gcktx + 1;
    end if;
    --
    if (tx_en1ms_gcktx = '1') then
      tx_msg_cnt_gcktx        <= (0 => tx_msg_flag_gcktx, others => '0');
      tx_msg_rate_gcktx       <= tx_msg_cnt_gcktx;
    elsif (tx_msg_flag_gcktx = '1') then
      tx_msg_cnt_gcktx        <= tx_msg_cnt_gcktx + 1;
    end if;  
     --
    if (tx_en1ms_gcktx = '1') then
      tx_gtp_align_cnt_gcktx  <= (0 => tx_gtp_align_flag_gcktx, others => '0');
      tx_gtp_align_rate_gcktx <= tx_gtp_align_cnt_gcktx;
    elsif (tx_gtp_align_flag_gcktx = '1') then
      tx_gtp_align_cnt_gcktx  <= tx_gtp_align_cnt_gcktx + 1;
    end if;     
     --
    if (tx_en1ms_gcktx = '1') then
      tx_idle_cnt_gcktx       <= (0 => tx_idle_flag_gcktx, others => '0');
      tx_idle_rate_gcktx      <= tx_idle_cnt_gcktx;
    elsif (tx_idle_flag_gcktx = '1') then
      tx_idle_cnt_gcktx       <= tx_idle_cnt_gcktx + 1;
    end if;   
  end if;
end process;

process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    tx_event_cnt                <= (others => '0');
    tx_event_rate               <= (others => '0');
    tx_message_cnt              <= (others => '0');
    tx_message_rate             <= (others => '0');
    --
    tx_data_rate_gcktx_cdc      <= (others => '0');
    tx_msg_rate_gcktx_cdc       <= (others => '0');
    tx_gtp_align_rate_gcktx_cdc <= (others => '0');
    tx_idle_rate_gcktx_cdc      <= (others => '0');
    
  elsif rising_edge(CLK_i) then
  
    if (tx_en1ms_gcktx_cdc = '1') then
      tx_event_cnt       <= (0 => tx_data_fifo_wr_en, others => '0');
      tx_event_rate      <= tx_event_cnt;
    elsif (tx_data_fifo_wr_en = '1') then
      tx_event_cnt       <= tx_event_cnt + 1;
    end if; 
  
    if (tx_en1ms_gcktx_cdc = '1') then
      tx_message_cnt       <= (0 => tx_msg_fifo_wr_en, others => '0');
      tx_message_rate      <= tx_message_cnt;
    elsif (tx_msg_fifo_wr_en = '1') then
      tx_message_cnt       <= tx_message_cnt + 1;
    end if; 
    
    if (tx_en1ms_gcktx_cdc = '1') then
      tx_data_rate_gcktx_cdc      <= tx_data_rate_gcktx;
      tx_msg_rate_gcktx_cdc       <= tx_msg_rate_gcktx;
      tx_gtp_align_rate_gcktx_cdc <= tx_gtp_align_rate_gcktx;
      tx_idle_rate_gcktx_cdc      <= tx_idle_rate_gcktx;
    end if;
    
  end if;
end process;




SYNC_PROC: process (GTP_TXUSRCLK2_i, tx_rst_n_gcktx)
begin
  if (tx_rst_n_gcktx = '0') then
    gtp_stream_out_gcktx   <= (others => '0');
    tx_char_is_k_gcktx  <= "00";
  elsif rising_edge(GTP_TXUSRCLK2_i) then
    gtp_stream_out_gcktx   <= gtp_stream_out_p_gcktx;
    tx_char_is_k_gcktx  <= tx_char_is_k_p_gcktx;
  end if;
end process;


-- Clock domain cross
process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    tx_gtp_align_flag_meta_gcktx_cdc <= '0';
    tx_gtp_align_flag_sync_gcktx_cdc <= '0';
    tx_gtp_align_flag_gcktx_cdc      <= '0';
  elsif rising_edge(CLK_i) then
    tx_gtp_align_flag_meta_gcktx_cdc <= tx_gtp_align_flag_gcktx;
    tx_gtp_align_flag_sync_gcktx_cdc <= tx_gtp_align_flag_meta_gcktx_cdc;
    tx_gtp_align_flag_gcktx_cdc      <= tx_gtp_align_flag_sync_gcktx_cdc;    
  end if;
end process;

-- ----------------------------------------------------------------------------------
-- OUTPUTs

-- USER
TX_GTP_ALIGN_FLAG_o           <= tx_gtp_align_flag_gcktx_cdc;
TX_DATA_DST_RDY_o             <= not tx_data_fifo_full;
TX_MSG_DST_RDY_o              <= not tx_msg_fifo_full;

TX_DATA_RATE_o                <= tx_data_rate_gcktx_cdc; 
TX_GTP_ALIGN_RATE_o           <= tx_gtp_align_rate_gcktx_cdc; 
TX_MSG_RATE_o                 <= tx_msg_rate_gcktx_cdc; 
TX_IDLE_RATE_o                <= tx_idle_rate_gcktx_cdc; 
TX_EVENT_RATE_o               <= tx_event_rate; 
TX_MESSAGE_RATE_o             <= tx_message_rate; 

-- GTP
SOFT_RESET_TX_o               <= cm_reset;                -- SYS_CLK   --
GTP_TXUSERRDY_o               <= not cm_pll_alarm;        -- ASYNC     --
    
GTP_TXDATA_o                  <= gtp_stream_out_gcktx;     -- TXUSRCLK2 --            
GTP_TXCHARISK_o               <= tx_char_is_k_gcktx;       -- TXUSRCLK2 --


-- ----------------------------------------------------------------------------------
--    ___ __  __
--   | _ \\ \/ /
--   |   / >  < 
--   |_|_\/_/\_\
--

-- ----------------------------------------------------------------------------------
-- TIME MACHINE

rx_clear <= cm_pll_alarm or not RST_N_i;

TIME_MACHINE_GCKRX_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  GTP_RXUSRCLK2_PERIOD_NS_g,  -- Main Clock period
    CLEAR_POLARITY_g        => "HIGH",                      -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,                        -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => SIM_TIME_COMPRESSION_g       -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => GTP_RXUSRCLK2_i,
    CLEAR_i                 => rx_clear,
  
    -- Output reset
    RESET_o                 => rx_rst_gckrx,
    RESET_N_o               => rx_rst_n_gckrx,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => rx_pon_reset_n_gckrx,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => rx_en100us_gckrx,
    EN1MS_o                 => rx_en1ms_gckrx,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );

ENABLE_SIGNAL_CDC_i : enable_signal_cdc
 port map(
  CLEAR_N_i           => rx_rst_n_gckrx,
  CLK_SOURCE_i        => GTP_RXUSRCLK2_i,
  CLK_DEST_i          => CLK_i,
  EN_SIG_SOURCE_i     => rx_en1ms_gckrx,
  EN_SIG_DEST_o       => open,
  EN_SIG_SHORT_DEST_o => rx_en1ms_gckrx_cdc
  ); 


-- ----------------------------------------------------------------------------------
-- Kind of data
rx_k_chars_gckrx <= '0' when (GTP_RXCHARISK_i = "00") else '1';

process (GTP_RXUSRCLK2_i, rx_rst_n_gckrx)
begin
  if (rx_rst_n_gckrx = '0') then
    rx_k_chars_d_gckrx <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    rx_k_chars_d_gckrx <= rx_k_chars_gckrx;
  end if;
end process;

rx_k_chars_up_gckrx <= rx_k_chars_gckrx and not rx_k_chars_d_gckrx;


rx_data_flag_gckrx        <= '1' when (rx_k_chars_gckrx = '0') else '0';
rx_gtp_align_flag_gckrx   <= '1' when (rx_k_chars_gckrx = '1' and GTP_RXDATA_i              = ALIGN_c) else '0'; 
rx_msg_flag_gckrx         <= '1' when (rx_k_chars_gckrx = '1' and GTP_RXDATA_i(15 downto 8) = MSG_c) else '0'; 
rx_idle_flag_gckrx        <= '1' when (rx_k_chars_gckrx = '1' and GTP_RXDATA_i              = IDLE_HEAD_c) else '0';
      
rx_unknown_k_flag_gckrx   <= rx_k_chars_d_gckrx and not (rx_data_flag_d_gckrx or rx_gtp_align_flag_d_gckrx or rx_msg_flag_d_gckrx or rx_idle_flag_d_gckrx);

process (GTP_RXUSRCLK2_i, rx_rst_n_gckrx)
begin
  if (rx_rst_n_gckrx = '0') then
    rx_data_flag_d_gckrx      <= '0';
    rx_gtp_align_flag_d_gckrx <= '0';
    rx_msg_flag_d_gckrx       <= '0';
    rx_idle_flag_d_gckrx      <= '0';
    --
    rx_unknown_k_flag_d_gckrx <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    rx_data_flag_d_gckrx      <= rx_data_flag_gckrx;
    rx_gtp_align_flag_d_gckrx <= rx_gtp_align_flag_gckrx;
    rx_msg_flag_d_gckrx       <= rx_msg_flag_gckrx;
    rx_idle_flag_d_gckrx      <= rx_idle_flag_gckrx;   
    --
    rx_unknown_k_flag_d_gckrx <= rx_unknown_k_flag_gckrx;
  end if;
end process;


-- ------------------------------------------------------------------------------------------
-- RX Rate Counters

process (GTP_RXUSRCLK2_i, rx_rst_n_gckrx)
begin
  if (rx_rst_n_gckrx = '0') then
    rx_data_cnt_gckrx        <= (others => '0');
    rx_data_rate_gckrx       <= (others => '0');
    --
    rx_msg_cnt_gckrx         <= (others => '0');
    rx_msg_rate_gckrx        <= (others => '0');
    --
    rx_gtp_align_cnt_gckrx   <= (others => '0');
    rx_gtp_align_rate_gckrx  <= (others => '0');
    --
    rx_idle_cnt_gckrx        <= (others => '0');
    rx_idle_rate_gckrx       <= (others => '0');
    
  elsif rising_edge(GTP_RXUSRCLK2_i) then
  
    if (rx_en1ms_gckrx = '1') then
      rx_data_cnt_gckrx       <= (0 => rx_data_flag_d_gckrx, others => '0');
      rx_data_rate_gckrx      <= rx_data_cnt_gckrx;
    elsif (rx_data_flag_d_gckrx = '1') then
      rx_data_cnt_gckrx       <= rx_data_cnt_gckrx + 1;
    end if;
    --
    if (rx_en1ms_gckrx = '1') then
      rx_msg_cnt_gckrx        <= (0 => rx_msg_flag_d_gckrx, others => '0');
      rx_msg_rate_gckrx       <= rx_msg_cnt_gckrx;
    elsif (rx_msg_flag_d_gckrx = '1') then
      rx_msg_cnt_gckrx        <= rx_msg_cnt_gckrx + 1;
    end if;  
     --
    if (rx_en1ms_gckrx = '1') then
      rx_gtp_align_cnt_gckrx  <= (0 => rx_gtp_align_flag_d_gckrx, others => '0');
      rx_gtp_align_rate_gckrx <= rx_gtp_align_cnt_gckrx;
    elsif (rx_gtp_align_flag_d_gckrx = '1') then
      rx_gtp_align_cnt_gckrx  <= rx_gtp_align_cnt_gckrx + 1;
    end if;     
     --
    if (rx_en1ms_gckrx = '1') then
      rx_idle_cnt_gckrx       <= (0 => rx_idle_flag_d_gckrx, others => '0');
      rx_idle_rate_gckrx      <= rx_idle_cnt_gckrx;
    elsif (rx_idle_flag_d_gckrx = '1') then
      rx_idle_cnt_gckrx       <= rx_idle_cnt_gckrx + 1;
    end if;   
  end if;
end process;

process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    rx_event_cnt                <= (others => '0');
    rx_event_rate               <= (others => '0');
    rx_message_cnt              <= (others => '0');
    rx_message_rate             <= (others => '0');
    --
    rx_data_rate_gckrx_cdc      <= (others => '0');
    rx_msg_rate_gckrx_cdc       <= (others => '0');
    rx_gtp_align_rate_gckrx_cdc <= (others => '0');
    rx_idle_rate_gckrx_cdc      <= (others => '0');
    
  elsif rising_edge(CLK_i) then
  
    if (rx_en1ms_gckrx_cdc = '1') then
      rx_event_cnt       <= (0 => rx_data_fifo_rd_en, others => '0');
      rx_event_rate      <= rx_event_cnt;
    elsif (rx_data_fifo_rd_en = '1') then
      rx_event_cnt       <= rx_event_cnt + 1;
    end if; 
  
    if (rx_en1ms_gckrx_cdc = '1') then
      rx_message_cnt       <= (0 => rx_msg_fifo_rd_en, others => '0');
      rx_message_rate      <= rx_message_cnt;
    elsif (rx_msg_fifo_rd_en = '1') then
      rx_message_cnt       <= rx_message_cnt + 1;
    end if; 
    
    if (rx_en1ms_gckrx_cdc = '1') then
      rx_data_rate_gckrx_cdc      <= rx_data_rate_gckrx;
      rx_msg_rate_gckrx_cdc       <= rx_msg_rate_gckrx;
      rx_gtp_align_rate_gckrx_cdc <= rx_gtp_align_rate_gckrx;
      rx_idle_rate_gckrx_cdc      <= rx_idle_rate_gckrx;
    end if;
    
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- GTP Alignement

process (GTP_RXUSRCLK2_i, rx_rst_n_gckrx)
begin
  if (rx_rst_n_gckrx = '0') then
    rx_unknown_k_detect_gckrx    <= '0';
    rx_unknown_k_detected_gckrx  <= '0';
    rx_align_req_gckrx <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (rx_en1ms_gckrx = '1') then
      rx_unknown_k_detect_gckrx    <= rx_unknown_k_flag_gckrx;
      rx_unknown_k_detected_gckrx  <= rx_unknown_k_detect_gckrx;    
    elsif (rx_unknown_k_flag_gckrx = '1') then
      rx_unknown_k_detect_gckrx    <= '1';
    end if;
  rx_align_req_gckrx <= not GTP_RXBYTEISALIGNED_i or rx_unknown_k_detected_gckrx;
  end if;
end process;

-- Clock domain cross
process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    rx_align_req_meta_gckrx_cdc <= '0';
    rx_align_req_sync_gckrx_cdc <= '0';
    rx_align_req_gckrx_cdc      <= '0';
  elsif rising_edge(CLK_i) then
    rx_align_req_meta_gckrx_cdc <= rx_align_req_gckrx;
    rx_align_req_sync_gckrx_cdc <= rx_align_req_meta_gckrx_cdc;
    rx_align_req_gckrx_cdc      <= rx_align_req_sync_gckrx_cdc;    
  end if;
end process;


-- ------------------------------------------------------------------------------------------
-- Event composer

-- Event Word toggle
process (GTP_RXUSRCLK2_i, rx_rst_n_gckrx)
begin
  if (rx_rst_n_gckrx = '0') then
    rx_data_w_exp_toggle_gckrx <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (rx_k_chars_gckrx = '1') then
      rx_data_w_exp_toggle_gckrx <= '0'; 
    else 
      rx_data_w_exp_toggle_gckrx <= not rx_data_w_exp_toggle_gckrx;     
    end if;
  end if;
end process;

rx_data_w1_exp_gckrx <= not rx_k_chars_gckrx and not rx_data_w_exp_toggle_gckrx; -- and flag_enable;
rx_data_w0_exp_gckrx <= not rx_k_chars_gckrx and     rx_data_w_exp_toggle_gckrx; -- and flag_enable; 


-- ----------------------------------------------------------------------------------
-- Double Word

process (GTP_RXUSRCLK2_i, rx_rst_n_gckrx)
begin
  if (rx_rst_n_gckrx = '0') then
    rx_data_w1_gckrx <= (others => '0');
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (rx_data_w1_exp_gckrx = '1') then
      rx_data_w1_gckrx <= GTP_RXDATA_i;
    end if;
  end if;
end process;


rx_data_fifo_din_gckrx   <= rx_data_w1_gckrx & GTP_RXDATA_i;
rx_data_fifo_wr_en_gckrx <= rx_data_w0_exp_gckrx and not rx_data_fifo_full_gckrx;
rx_data_fifo_rd_en       <= not rx_data_fifo_empty and RX_DATA_DST_RDY_i;
rx_data_fifo_rst         <= rx_rst_gckrx;

DATA_FIFO_RX_i :  DATA_SYNC_FIFO
  port map (
    rst       => rx_data_fifo_rst,               
    wr_clk    => GTP_RXUSRCLK2_i,        
    rd_clk    => CLK_i,         
    din       => rx_data_fifo_din_gckrx,      
    wr_en     => rx_data_fifo_wr_en_gckrx,        
    rd_en     => rx_data_fifo_rd_en,        
    dout      => rx_data_fifo_dout,  
    full      => rx_data_fifo_full_gckrx,         
    overflow  => rx_data_fifo_overflow_gckrx,     
    empty     => rx_data_fifo_empty,        
    valid     => rx_data_fifo_valid         
  );


rx_msg_fifo_din_gckrx   <= GTP_RXDATA_i(7 downto 0);
rx_msg_fifo_wr_en_gckrx <= rx_msg_flag_gckrx and not rx_msg_fifo_full_gckrx;
rx_msg_fifo_rd_en <= not rx_msg_fifo_empty and RX_MSG_DST_RDY_i;
rx_msg_fifo_rst   <= rx_rst_gckrx;

MSG_FIFO_RX_i :  MSG_SYNC_FIFO
  port map (
    rst       => rx_msg_fifo_rst,               
    wr_clk    => GTP_RXUSRCLK2_i,        
    rd_clk    => CLK_i,         
    din       => rx_msg_fifo_din_gckrx,      
    wr_en     => rx_msg_fifo_wr_en_gckrx,        
    rd_en     => rx_msg_fifo_rd_en,        
    dout      => rx_msg_fifo_dout,  
    full      => rx_msg_fifo_full_gckrx,         
    overflow  => rx_msg_fifo_overflow_gckrx,     
    empty     => rx_msg_fifo_empty,        
    valid     => rx_msg_fifo_valid         
  );
  

-- ----------------------------------------------------------------------------------
-- OUTPUTs

-- USER
RX_ALIGN_REQUEST_o   <= rx_align_req_gckrx_cdc;

RX_DATA_o            <= rx_data_fifo_dout;
RX_DATA_SRC_RDY_o    <= not rx_data_fifo_empty;

RX_MSG_o             <= rx_msg_fifo_dout;
RX_MSG_SRC_RDY_o     <= not rx_msg_fifo_empty;

RX_DATA_RATE_o       <= rx_data_rate_gckrx_cdc; 
RX_GTP_ALIGN_RATE_o  <= rx_gtp_align_rate_gckrx_cdc; 
RX_MSG_RATE_o        <= rx_msg_rate_gckrx_cdc; 
RX_IDLE_RATE_o       <= rx_idle_rate_gckrx_cdc; 
RX_EVENT_RATE_o      <= rx_event_rate; 
RX_MESSAGE_RATE_o    <= rx_message_rate; 

-- GTP
SOFT_RESET_RX_o      <= cm_reset;                -- SYS_CLK   -- 
GTP_RXUSERRDY_o      <= not cm_pll_alarm;        -- ASYNC     --

end Behavioral;
