-- ==============================================================================
-- DESCRIPTION:
-- Provides a managing core for GTP RX side
-- ------------------------------------------
-- File        : GTP_RX_Manager.vhd
-- Revision    : 1.0
-- Author      : M. Casti
-- Date        : 18/03/2021
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  18/03/2021 - M. Casti
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

entity GTP_RX_Manager is
  generic ( 
    RX_DATA_OUT_WIDTH_g        : integer range 0 to 64 := 32;    -- Width of RX Data - Fabric side
    GTP_STREAM_WIDTH_g         : integer range 0 to 64 := 16;    -- Width of RX Data - GTP side 
    GTP_RXUSRCLK2_PERIOD_NS_g  : real := 10.0;                   -- GTP User clock period
    SIM_TIME_COMPRESSION_g     : in boolean := FALSE             -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port (
    -- Bare Control ports
    CLK_i                      : in  std_logic;   -- Input clock - Fabric side    
    RST_N_i                    : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1S_i                     : in  std_logic;   -- Enable @ 1 sec in clk domain 
    
    -- Status
    GTP_PLL_ALARM_o            : out std_logic; 
    
    -- Control out
    ALIGN_REQUEST_o            : out std_logic;      
       
    -- Data out
    RX_DATA_o                  : out std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
    RX_DATA_SRC_RDY_o          : out std_logic;
    RX_DATA_DST_RDY_i          : in  std_logic;
    
    RX_MSG_o                   : out std_logic_vector(7 downto 0);
    RX_MSG_SRC_RDY_o           : out std_logic;
    RX_MSG_DST_RDY_i           : in  std_logic;
    
    -- *****************************************************************************************
    -- GTP Interface

    SOFT_RESET_TX_o            : out  std_logic;
    SOFT_RESET_RX_o            : out  std_logic;
    DONT_RESET_ON_DATA_ERROR_o : out  std_logic;

    GTP_TX_FSM_RESET_DONE_i    : in  std_logic;
    GTP_RX_FSM_RESET_DONE_i    : in  std_logic;
    GTP_DATA_VALID_o           : out   std_logic;
 
    GTP_RXUSRCLK2_i            : in  std_logic;

    --_________________________________________________________________________
    -- GTP  (XxYy)
    -- ____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    GTP_DRPADDR_o              : out std_logic_vector(8 downto 0);
    GTP_DRPDI_o                : out std_logic_vector(15 downto 0);
    GTP_DRPDO_i                : in  std_logic_vector(15 downto 0);
    GTP_DRPEN_o                : out std_logic;
    GTP_DRPRDY_i               : in  std_logic;
    GTP_DRPWE_o                : out std_logic;
    --------------------- RX Initialization and Reset Ports --------------------
    GTP_EYESCANRESET_o         : out std_logic;
    GTP_RXUSERRDY_o            : out std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    GTP_EYESCANDATAERROR_i     : in  std_logic;
    GTP_EYESCANTRIGGER_o       : out std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GTP_RXDATA_i               : in  std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    GTP_RXCHARISCOMMA_i        : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    GTP_RXCHARISK_i            : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    GTP_RXDISPERR_i            : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    GTP_RXNOTINTABLE_i         : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    GTP_RXBYTEISALIGNED_i      : in  std_logic;
    GTP_RXBYTEREALIGN_i        : in  std_logic;
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    GTP_DMONITOROUT_i          : in  std_logic_vector(14 downto 0);
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    GTP_RXLPMHFHOLD_o          : out std_logic;
    GTP_RXLPMLFHOLD_o          : out std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    GTP_RXOUTCLKFABRIC_i       : in  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GTP_GTRXRESET_o            : out std_logic;
    GTP_RXLPMRESET_o           : out std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    GTP_RXRESETDONE_i          : in  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    GTP_GTTXRESET_o            : out std_logic;
    GTP_TXUSERRDY_o            : out std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GTP_TXDATA_o               : out std_logic_vector(15 downto 0);
    --------------- Transmit Ports - TX Configurable Driver Ports --------------

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GTP_TXOUTCLKFABRIC_i       : in  std_logic;
    GTP_TXOUTCLKPCS_i          : in  std_logic;
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GTP_TXRESETDONE_i          : in  std_logic;

    --____________________________COMMON PORTS________________________________
    GTP_PLL0RESET_i            : in  std_logic;
    GTP_PLL0OUTCLK_i           : in  std_logic;
    GTP_PLL0OUTREFCLK_i        : in  std_logic;
    GTP_PLL0LOCK_i             : in  std_logic;
    GTP_PLL0REFCLKLOST_i       : in  std_logic;    
    GTP_PLL1OUTCLK_i           : in  std_logic;
    GTP_PLL1OUTREFCLK_i        : in  std_logic 
    -- *****************************************************************************************
    );
end GTP_RX_Manager;


architecture Behavioral of GTP_RX_Manager is

-- -------------------------------------------------------------------------------------
-- ATTRIBUTE DEFINITIONS

attribute ASYNC_REG : string;

-- -------------------------------------------------------------------------------------
-- COMPONENTS
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

-- ----------------------------------------------------------------------------------------------
-- CONSTANTS

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

signal rst_gck              : std_logic;
signal rst_n_gck            : std_logic;
signal pon_reset_n_gck      : std_logic;
signal en1ms_gck            : std_logic;

-- --------------------------------------------------------------

signal data_fifo_din        : std_logic_vector(31 downto 0);
signal data_fifo_wr_en      : std_logic;
signal data_fifo_rd_en      : std_logic;
signal data_fifo_dout       : std_logic_vector(31 downto 0);
signal data_fifo_full       : std_logic;
signal data_fifo_overflow   : std_logic;
signal data_fifo_empty      : std_logic;
signal data_fifo_valid      : std_logic;
signal data_fifo_rst        : std_logic;

signal msg_fifo_din        : std_logic_vector(7 downto 0);
signal msg_fifo_wr_en      : std_logic;
signal msg_fifo_rd_en      : std_logic;
signal msg_fifo_dout       : std_logic_vector(7 downto 0);
signal msg_fifo_full       : std_logic;
signal msg_fifo_overflow   : std_logic;
signal msg_fifo_empty      : std_logic;
signal msg_fifo_valid      : std_logic;
signal msg_fifo_rst        : std_logic;

-- --------------------------------------------------------------

signal align_req          : std_logic;

signal k_chars            : std_logic;
signal k_chars_d          : std_logic;
signal k_chars_up         : std_logic;

signal gtp_align_flag     : std_logic;          
signal gtp_align_flag_d   : std_logic;          

-- signal msg_word         : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);         
signal msg_flag           : std_logic; 
signal msg_flag_d         : std_logic; 

signal data_w_exp_toggle  : std_logic;
signal data_flag          : std_logic;
signal data_flag_d        : std_logic;
signal data_w0_exp        : std_logic;
signal data_w1_exp        : std_logic;
-- signal data_w0            : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
signal data_w1            : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);

signal idle_flag          : std_logic;
signal idle_flag_d        : std_logic;

signal unknown_k_flag     : std_logic;
signal unknown_k_flag_d   : std_logic;
signal unknown_k_detect   : std_logic;
signal unknown_k_detected : std_logic;


-- Counters
signal data_cnt           : std_logic_vector(15 downto 0); 
signal data_rate          : std_logic_vector(15 downto 0); 
signal gtp_align_cnt      : std_logic_vector( 7 downto 0); 
signal gtp_align_rate     : std_logic_vector( 7 downto 0); 
signal msg_cnt            : std_logic_vector(15 downto 0); 
signal msg_rate           : std_logic_vector(15 downto 0); 
signal idle_cnt           : std_logic_vector(15 downto 0); 
signal idle_rate          : std_logic_vector(15 downto 0); 

-- Anti Metastabilty

signal gtp_pll_lock_meta    : std_logic;
--attribute ASYNC_REG of gtp_pll_lock_meta : signal is "TRUE";
signal gtp_pll_lock_sync    : std_logic;
--attribute ASYNC_REG of gtp_pll_lock_sync : signal is "TRUE";
signal gtp_pll_lock         : std_logic;
--attribute ASYNC_REG of gtp_pll_lock      : signal is "TRUE";
signal gtp_clk_lost_meta    : std_logic;
--attribute ASYNC_REG of gtp_clk_lost_meta : signal is "TRUE";
signal gtp_clk_lost_sync    : std_logic;
--attribute ASYNC_REG of gtp_clk_lost_sync : signal is "TRUE";
signal gtp_clk_lost         : std_logic;
--attribute ASYNC_REG of gtp_clk_lost      : signal is "TRUE";


signal align_request_meta   : std_logic;
--attribute ASYNC_REG of align_request_meta : signal is "TRUE";
signal align_request_sync   : std_logic;
--attribute ASYNC_REG of align_request_sync : signal is "TRUE";
signal align_request        : std_logic;
--attribute ASYNC_REG of align_request      : signal is "TRUE";



signal gtp_pll_fail         : std_logic;
signal gtp_pll_alarm_cnt    : std_logic_vector(1 downto 0);
signal gtp_pll_alarm        : std_logic;

signal gtp_reset_cnt        : std_logic_vector(3 downto 0);
signal gtp_reset            : std_logic;

----------------------------------------------------------------------------------------------

signal gtp_tx_fsm_reset_done : std_logic;
signal gtp_rx_fsm_reset_done : std_logic;

signal gtp_drpdo             : std_logic_vector(15 downto 0);
signal gtp_drprdy            : std_logic;

signal gtp_eyescandataerror  : std_logic;

signal gtp_rxdata            : std_logic_vector(15 downto 0);

signal gtp_rxchariscomma     : std_logic_vector(1 downto 0);
signal gtp_rxcharisk         : std_logic_vector(1 downto 0);
signal gtp_rxdisperr         : std_logic_vector(1 downto 0);
signal gtp_rxnotintable      : std_logic_vector(1 downto 0);

signal gtp_rxbyteisaligned   : std_logic;
signal gtp_rxbyterealign     : std_logic;

signal gtp_dmonitorout       : std_logic_vector(14 downto 0);

signal gtp_rxoutclkfabric    : std_logic;

signal gtp_rxresetdone       : std_logic;

signal gtp_txoutclkfabric    : std_logic;
signal gtp_txoutclkpcs       : std_logic;

signal gtp_txresetdone       : std_logic;

signal gtp_pll0reset         : std_logic;
signal gtp_pll0outclk        : std_logic;
signal gtp_pll0outrefclk     : std_logic;
signal gtp_pll1outclk        : std_logic;
signal gtp_pll1outrefclk     : std_logic; 


-- ATTRIBUTES



begin

-- ---------------------------------------------------------------------
-- GTP Interface input ports

gtp_tx_fsm_reset_done <= GTP_TX_FSM_RESET_DONE_i;
gtp_rx_fsm_reset_done <= GTP_RX_FSM_RESET_DONE_i;
gtp_drpdo             <= GTP_DRPDO_i;
gtp_drprdy            <= GTP_DRPRDY_i;
gtp_eyescandataerror  <= GTP_EYESCANDATAERROR_i;
gtp_rxdata            <= GTP_RXDATA_i;
gtp_rxchariscomma     <= GTP_RXCHARISCOMMA_i;
gtp_rxcharisk         <= GTP_RXCHARISK_i;
gtp_rxdisperr         <= GTP_RXDISPERR_i;
gtp_rxnotintable      <= GTP_RXNOTINTABLE_i;
gtp_rxbyteisaligned   <= GTP_RXBYTEISALIGNED_i;
gtp_rxbyterealign     <= GTP_RXBYTEREALIGN_i;
gtp_dmonitorout       <= GTP_DMONITOROUT_i;
gtp_rxoutclkfabric    <= GTP_RXOUTCLKFABRIC_i;
gtp_rxresetdone       <= GTP_RXRESETDONE_i;
gtp_txoutclkfabric    <= GTP_TXOUTCLKFABRIC_i;
gtp_txoutclkpcs       <= GTP_TXOUTCLKPCS_i;
gtp_txresetdone       <= GTP_TXRESETDONE_i;
gtp_pll0reset         <= GTP_PLL0RESET_i;
gtp_pll0outclk        <= GTP_PLL0OUTCLK_i;
gtp_pll0outrefclk     <= GTP_PLL0OUTREFCLK_i;
gtp_pll1outclk        <= GTP_PLL1OUTCLK_i;
gtp_pll1outrefclk     <= GTP_PLL1OUTREFCLK_i;


process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    gtp_pll_lock_meta <= '0';
    gtp_pll_lock_sync <= '0';
    gtp_pll_lock <= '0';
  elsif rising_edge(CLK_i) then
    gtp_pll_lock_meta  <= GTP_PLL0LOCK_i;
    gtp_pll_lock_sync  <= gtp_pll_lock_meta;
    gtp_pll_lock       <= gtp_pll_lock_sync;
  end if;
end process;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    gtp_clk_lost_meta <= '0';
    gtp_clk_lost_sync <= '0';
    gtp_clk_lost <= '0';
  elsif rising_edge(CLK_i) then
    gtp_clk_lost_meta  <= GTP_PLL0REFCLKLOST_i;
    gtp_clk_lost_sync  <= gtp_clk_lost_meta;
    gtp_clk_lost       <= gtp_clk_lost_sync;
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- TIME MACHINE

TIME_MACHINE_GCK_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  GTP_RXUSRCLK2_PERIOD_NS_g,  -- Main Clock period
    CLEAR_POLARITY_g        => "HIGH",                      -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,                        -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => SIM_TIME_COMPRESSION_g       -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => GTP_RXUSRCLK2_i,
    CLEAR_i                 => gtp_pll_alarm,
  
    -- Output reset
    RESET_o                 => rst_gck,
    RESET_N_o               => rst_n_gck,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => pon_reset_n_gck,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => open,
    EN1MS_o                 => en1ms_gck,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );


-- ----------------------------------------------------------------------------------
-- Kind of data
k_chars <= '0' when (gtp_rxcharisk = "00") else '1';

process (GTP_RXUSRCLK2_i, rst_n_gck)
begin
  if (rst_n_gck = '0') then
    k_chars_d <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    k_chars_d <= k_chars;
  end if;
end process;

k_chars_up <= k_chars and not k_chars_d;


-- -- IDLE CHECK
-- -- -- Idle Word toggle
-- process (GCK_i, rst_n_gck)
-- begin
--   if (rst_n_gck = '0') then
--     flag_enable <= '0';
--   elsif rising_edge(GCK_i) then
--     flag_enable <= '1';
--   end if;
-- end process;

-- idle_head_exp <= k_chars and not idle_exp_toggle and flag_enable;
-- idle_tail_exp <= k_chars and     idle_exp_toggle and flag_enable;



data_flag        <= '1' when (k_chars = '0') else '0';
gtp_align_flag   <= '1' when (k_chars = '1' and gtp_rxdata              = ALIGN_c) else '0'; 
msg_flag         <= '1' when (k_chars = '1' and gtp_rxdata(15 downto 8) = MSG_c) else '0'; 
idle_flag        <= '1' when (k_chars = '1' and gtp_rxdata              = IDLE_HEAD_c) else '0';

unknown_k_flag   <= k_chars_d and not (data_flag_d or gtp_align_flag_d or msg_flag_d or idle_flag_d);

process (GTP_RXUSRCLK2_i, rst_n_gck)
begin
  if (rst_n_gck = '0') then
    data_flag_d      <= '0';
    gtp_align_flag_d <= '0';
    msg_flag_d       <= '0';
    idle_flag_d      <= '0';
    --
    unknown_k_flag_d <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    data_flag_d      <= data_flag;
    gtp_align_flag_d <= gtp_align_flag;
    msg_flag_d       <= msg_flag;
    idle_flag_d      <= idle_flag;   
    --
    unknown_k_flag_d <= unknown_k_flag;
  end if;
end process;
-- ------------------------------------------------------------------------------------------
-- Counters

-- Data
process (GTP_RXUSRCLK2_i, rst_n_gck)
begin
  if (rst_n_gck = '0') then
    data_cnt            <= (others => '0');
    data_rate           <= (others => '0');
    --
    msg_cnt             <= (others => '0');
    msg_rate            <= (others => '0');
    --
    gtp_align_cnt       <= (others => '0');
    gtp_align_rate      <= (others => '0');
    --
    idle_cnt            <= (others => '0');
    idle_rate           <= (others => '0');
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (en1ms_gck = '1') then
      data_cnt        <= (0 => data_flag_d, others => '0');
      data_rate       <= data_cnt;
    elsif (data_flag_d = '1') then
      data_cnt        <= data_cnt + 1;
    end if;
    --
    if (en1ms_gck = '1') then
      msg_cnt         <= (0 => msg_flag_d, others => '0');
      msg_rate        <= msg_cnt;
    elsif (msg_flag_d = '1') then
      msg_cnt         <= msg_cnt + 1;
    end if;  
     --
    if (en1ms_gck = '1') then
      gtp_align_cnt   <= (0 => gtp_align_flag_d, others => '0');
      gtp_align_rate  <= gtp_align_cnt;
    elsif (gtp_align_flag_d = '1') then
      gtp_align_cnt   <= gtp_align_cnt + 1;
    end if;     
     --
    if (en1ms_gck = '1') then
      idle_cnt        <= (0 => idle_flag_d, others => '0');
      idle_rate       <= idle_cnt;
    elsif (idle_flag_d = '1') then
      idle_cnt        <= idle_cnt + 1;
    end if;   
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- GTP Alignement


process (GTP_RXUSRCLK2_i, rst_n_gck)
begin
  if (rst_n_gck = '0') then
    unknown_k_detect    <= '0';
    unknown_k_detected  <= '0';
    align_req <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (en1ms_gck = '1') then
      unknown_k_detect    <= unknown_k_flag;
      unknown_k_detected  <= unknown_k_detect;    
    elsif (unknown_k_flag = '1') then
      unknown_k_detect    <= '1';
    end if;
    
  align_req <= not gtp_rxbyteisaligned or unknown_k_detected;
  end if;
end process;

-- Clock domain cross
process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    align_request_meta <= '0';
    align_request_sync <= '0';
    align_request      <= '0';
  elsif rising_edge(CLK_i) then
    align_request_meta <= align_req;
    align_request_sync <= align_request_meta;
    align_request      <= align_request_sync;    
  end if;
end process;
-- ------------------------------------------------------------------------------------------


-- data_w1_flag       <= not align_req_r and     data_fifo_valid and     data_w_sel;
-- data_w0_flag       <= not align_req_r and     data_fifo_valid and not data_w_sel;


-- idle_head_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_0 & K28_1) else '0'; 
-- idle_tail_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_2 & K28_3) else '0'; 
-- data_w0_flag     <= '1' when (k_chars = '0' and gtp_rx_stream = ) else '0'; 
-- data_w1_flag     <= '1' when (k_chars = '0' and gtp_rx_stream = ) else '0'; 


-- Event Word toggle
process (GTP_RXUSRCLK2_i, rst_n_gck)
begin
  if (rst_n_gck = '0') then
    data_w_exp_toggle <= '0';
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (k_chars = '1') then
      data_w_exp_toggle <= '0';
    else 
      data_w_exp_toggle <= not data_w_exp_toggle;
    end if;
  end if;
end process;

data_w1_exp <= not k_chars and not data_w_exp_toggle; -- and flag_enable;
data_w0_exp <= not k_chars and     data_w_exp_toggle; -- and flag_enable;


-- ----------------------------------------------------------------------------------
-- Double Word


process (GTP_RXUSRCLK2_i, rst_n_gck)
begin
  if (rst_n_gck = '0') then
    data_w1 <= (others => '0');
  elsif rising_edge(GTP_RXUSRCLK2_i) then
    if (data_w1_exp = '1') then
      data_w1 <= gtp_rxdata;
    end if;
  end if;
end process;



data_fifo_rst   <= rst_gck;
data_fifo_din   <= data_w1 & gtp_rxdata;
data_fifo_wr_en <= data_w0_exp and not data_fifo_full;
data_fifo_rd_en <= not data_fifo_empty and RX_DATA_DST_RDY_i;

DATA_FIFO_RX_i :  DATA_SYNC_FIFO
  port map (
    rst       => data_fifo_rst,               
    wr_clk    => GTP_RXUSRCLK2_i,        
    rd_clk    => CLK_i,         
    din       => data_fifo_din,      
    wr_en     => data_fifo_wr_en,        
    rd_en     => data_fifo_rd_en,        
    dout      => data_fifo_dout,  
    full      => data_fifo_full,         
    overflow  => data_fifo_overflow,     
    empty     => data_fifo_empty,        
    valid     => data_fifo_valid         
  );


msg_fifo_rst   <= rst_gck;
msg_fifo_din   <= gtp_rxdata(7 downto 0);
msg_fifo_wr_en <= msg_flag and not msg_fifo_full;
msg_fifo_rd_en <= not msg_fifo_empty and RX_MSG_DST_RDY_i;

MSG_FIFO_RX_i :  MSG_SYNC_FIFO
  port map (
    rst       => msg_fifo_rst,               
    wr_clk    => GTP_RXUSRCLK2_i,        
    rd_clk    => CLK_i,         
    din       => msg_fifo_din,      
    wr_en     => msg_fifo_wr_en,        
    rd_en     => msg_fifo_rd_en,        
    dout      => msg_fifo_dout,  
    full      => msg_fifo_full,         
    overflow  => msg_fifo_overflow,     
    empty     => msg_fifo_empty,        
    valid     => msg_fifo_valid         
  );
  

-- ----------------------------------------------------------------------------------
-- GTP RESET

gtp_pll_fail <= (gtp_clk_lost or not gtp_pll_lock);

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    gtp_pll_alarm_cnt  <= "00";
    gtp_pll_alarm      <= '0';
  elsif rising_edge(CLK_i) then
    if (gtp_pll_alarm_cnt /= "00" ) then
      if (EN1S_i = '1') then
        if (gtp_clk_lost = '1') then
          gtp_pll_alarm_cnt <= "11";
        else
          gtp_pll_alarm_cnt <= gtp_pll_alarm_cnt - 1;
        end if;
      end if;
    elsif (gtp_pll_fail = '1') then
      gtp_pll_alarm_cnt <= "11";      
    end if;
   
    if (gtp_pll_alarm_cnt /= "00" or gtp_pll_fail = '1') then
      gtp_pll_alarm <= '1';
    else
      gtp_pll_alarm <= '0';
    end if;
  end if;
end process;

process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    gtp_reset_cnt  <= conv_std_logic_vector(0, gtp_reset_cnt'length);
    gtp_reset      <= '0';
  elsif rising_edge(CLK_i) then
    if (gtp_pll_alarm_cnt = "10" and EN1S_i = '1') then
      gtp_reset_cnt <= conv_std_logic_vector(15, gtp_reset_cnt'length);
    elsif (gtp_reset_cnt /= conv_std_logic_vector(0, gtp_reset_cnt'length)) then
      gtp_reset_cnt <= gtp_reset_cnt - 1;
    end if;
    
    gtp_reset <= or_reduce(gtp_reset_cnt);
    
  end if;
end process;

-- ----------------------------------------------------------------------------------
-- OUTPUTs

-- Data out
RX_DATA_o         <= data_fifo_dout;
RX_DATA_SRC_RDY_o <= not data_fifo_empty;

-- Message out
RX_MSG_o          <= msg_fifo_dout;
RX_MSG_SRC_RDY_o  <= not msg_fifo_empty;

-- Alignment
ALIGN_REQUEST_o   <= align_request;

-- Status
GTP_PLL_ALARM_o   <= gtp_pll_alarm;

-- ---------------------------------------------------------
-- GTP Interface outputs ports

SOFT_RESET_TX_o            <= gtp_reset; 
SOFT_RESET_RX_o            <= gtp_reset; 
DONT_RESET_ON_DATA_ERROR_o <= '0'; 

GTP_DATA_VALID_o           <= '1'; 
GTP_DRPADDR_o              <= (others => '0'); 
GTP_DRPDI_o                <= (others => '0'); 
GTP_DRPEN_o                <= '0'; 
GTP_DRPWE_o                <= '0'; 

GTP_EYESCANRESET_o         <= '0'; 
GTP_RXUSERRDY_o            <= not gtp_pll_alarm; 
GTP_EYESCANTRIGGER_o       <= '0'; 
GTP_RXLPMHFHOLD_o          <= '0'; 
GTP_RXLPMLFHOLD_o          <= '0'; 
GTP_GTRXRESET_o            <= '0'; 
GTP_RXLPMRESET_o           <= '0'; 
GTP_GTTXRESET_o            <= '0'; 
GTP_TXUSERRDY_o            <= '0'; 
GTP_TXDATA_o               <= (others => '0'); 

end Behavioral;
