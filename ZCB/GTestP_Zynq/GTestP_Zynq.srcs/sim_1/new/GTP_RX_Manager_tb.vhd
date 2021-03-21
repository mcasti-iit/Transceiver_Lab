library ieee; 
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  
library UNISIM;  
  use UNISIM.Vcomponents.all;  
  
use std.textio.all;
  use ieee.std_logic_textio.all;

entity GTP_RX_Manager_tb is
--  Port ( );
end GTP_RX_Manager_tb;

architecture Behavioral of GTP_RX_Manager_tb is

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

component GTP_RX_Manager is
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
end component;

component GTP_TX_Manager is
  generic ( 
    TX_DATA_IN_WIDTH_g      : integer range 0 to 64 := 32;    -- Width of TX Data - Fabric side 
    GTP_STREAM_WIDTH_g      : integer range 0 to 64 := 16     -- Width of TX Data - GTP side
    );
  port (
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          : in  std_logic;
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1S_i                  : in  std_logic;   -- Enable @ 100 us in clk domain 

    -- Control in
    AUTO_ALIGN_i            : in  std_logic;
    ALIGN_REQ_i             : in  std_logic;
    ALIGN_KEY_i             : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    TX_ERROR_INJECTION_i    : in  std_logic;
    GTP_PLL_REFCLKLOST_i    : in  std_logic;
 
    -- Control out
    GTP_SOFT_RESET_TX_o     : out std_logic;
    
    -- Status
    ALIGN_FLAG_o            : out std_logic;
  
    -- Data in 
    TX_DATA_i               : in  std_logic_vector(TX_DATA_IN_WIDTH_g-1 downto 0);
    TX_DATA_SRC_RDY_i       : in  std_logic;
    TX_DATA_DST_RDY_o       : out std_logic;
    
    TX_MSG_i                : in   std_logic_vector(7 downto 0);
    TX_MSG_SRC_RDY_i        : in   std_logic;
    TX_MSG_DST_RDY_o        : out  std_logic;
    
        
    -- *** GTP CLOCK DOMAIN ***
    -- Bare Control ports  
    GCK_i                   : in  std_logic;   -- Input clock - GTP side     
    RST_N_GCK_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)
    EN100US_GCK_i           : in  std_logic;   -- Enable @ 100 us in gck domain    
         
    -- Data out
    GTP_STREAM_OUT_o        : out std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
    GTP_CHAR_IS_K_o         : out std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0)              
    );
end component;

constant CLK_PERIOD_c       : time := 10.0 ns;  
constant CLK_GTP_PERIOD_c   : time :=  6.4 ns;  


signal clk_100, gck         : std_logic;
signal rst_n, rst           : std_logic;                    --active high reset
signal pon_reset_n          : std_logic;                    --active high reset
signal rst_n_gck, rst_gck   : std_logic;                    --active high reset
signal en1s                 : std_logic;  
signal en1ms                : std_logic;  


signal gtp_stream           : std_logic_vector(15 downto 0);
signal gtp_char_is_k        : std_logic_vector(1 downto 0);

signal rx_data_gtp       : std_logic_vector(15 downto 0);
signal rx_char_is_k      : std_logic_vector(1 downto 0);

signal gtp_rx_data           : std_logic_vector(31 downto 0);
signal gtp_rx_data_src_rdy   : std_logic;
signal gtp_rx_data_dst_rdy   : std_logic;

signal gtp_rx_msg            : std_logic_vector(7 downto 0);
signal gtp_rx_msg_src_rdy    : std_logic;
signal gtp_rx_msg_dst_rdy    : std_logic;



signal gtp_stream_src_rdy : std_logic;

signal gtp_is_aligned : std_logic;
signal align_request  : std_logic;
signal align_key      : std_logic_vector(1 downto 0);

signal gtp_soft_reset_tx : std_logic;
signal gtp_soft_reset_rx : std_logic;

signal tx_error_injection : std_logic;

signal auto_align : std_logic;
signal align_flag : std_logic;
signal gtp_pll_lock : std_logic;
signal gtp_clk_lost : std_logic;

-- signal tx_msg               : std_logic_vector(7 downto 0);
-- signal tx_msg_valid_cnt     : std_logic_vector(7 downto 0);
-- signal tx_msg_cnt           : std_logic_vector(7 downto 0);
-- signal tx_msg_cnt_valid     : std_logic;
-- signal tx_msg_in_dst_rdy    : std_logic;
-- signal tx_msg_in_src_rdy    : std_logic;

signal tx_data              : std_logic_vector(31 downto 0);
signal tx_data_src_rdy      : std_logic;
signal tx_data_dst_rdy      : std_logic;
signal tx_data_rate_cnt     : std_logic_vector(7 downto 0);

signal tx_msg               : std_logic_vector(7 downto 0);
signal tx_msg_src_rdy       : std_logic;
signal tx_msg_dst_rdy       : std_logic;
signal tx_msg_rate_cnt      : std_logic_vector(7 downto 0);

signal en100us_gck       : std_logic;
signal en1ms_gck         : std_logic;

signal gtp_pll_alarm     : std_logic;

-- ---------------------------------------------------------------------------------------------------------------------------------

signal soft_reset_tx            : std_logic;
signal soft_reset_rx            : std_logic;
signal dont_reset_on_data_error : std_logic;

signal gtp_tx_fsm_reset_done    : std_logic;
signal gtp_rx_fsm_reset_done    : std_logic;
signal gtp_data_valid           : std_logic;

signal gtp_rxusrclk2            : std_logic;

signal gtp_drpaddr              : std_logic_vector(8 downto 0);
signal gtp_drpdi                : std_logic_vector(15 downto 0);
signal gtp_drpdo                : std_logic_vector(15 downto 0);
signal gtp_drpen                : std_logic;
signal gtp_drprdy               : std_logic;
signal gtp_drpwe                : std_logic;

signal gtp_eyescanreset         : std_logic;
signal gtp_rxuserrdy            : std_logic;

signal gtp_eyescandataerror     : std_logic;
signal gtp_eyescantrigger       : std_logic;

signal gtp_rxdata               : std_logic_vector(15 downto 0);

signal gtp_rxchariscomma        : std_logic_vector(1 downto 0);
signal gtp_rxcharisk            : std_logic_vector(1 downto 0);
signal gtp_rxdisperr            : std_logic_vector(1 downto 0);
signal gtp_rxnotintable         : std_logic_vector(1 downto 0);

signal gtp_rxbyteisaligned      : std_logic;
signal gtp_rxbyterealign        : std_logic;

signal gtp_dmonitorout          : std_logic_vector(14 downto 0);

signal gtp_rxlpmhfhold          : std_logic;
signal gtp_rxlpmlfhold          : std_logic;

signal gtp_rxoutclkfabric       : std_logic;

signal gtp_gtrxreset            : std_logic;
signal gtp_rxlpmreset           : std_logic;

signal gtp_rxresetdone          : std_logic;

signal gtp_gttxreset            : std_logic;
signal gtp_txuserrdy            : std_logic;

signal gtp_txdata               : std_logic_vector(15 downto 0);

signal gtp_txoutclkfabric       : std_logic;
signal gtp_txoutclkpcs          : std_logic;

signal gtp_txresetdone          : std_logic;

signal gtp_pll0reset            : std_logic;
signal gtp_pll0outclk           : std_logic;
signal gtp_pll0outrefclk        : std_logic;
signal gtp_pll0lock             : std_logic;
signal gtp_pll0refclklost       : std_logic;    
signal gtp_pll1outclk           : std_logic;
signal gtp_pll1outrefclk        : std_logic;

-- ---------------------------------------------------------------------------------------------------------------------------------

begin

-- -- RESETs
-- proc_reset_n : process 
-- begin
--   rst_n <= '0';
--   rst   <= '1';
--   wait for CLK_PERIOD_c;
--   wait for CLK_PERIOD_c;
--   wait for 2 ns;
--   rst_n <= '1';
--   rst   <= '0';
--   wait;
-- end process proc_reset_n;  
-- 
-- proc_reset_n_gtp : process 
-- begin
--   rst_n_gck <= '0';
--   rst_gck   <= '1';
--   wait for CLK_GTP_PERIOD_c;
--   wait for CLK_GTP_PERIOD_c;
--   wait for 2 ns;
--   rst_n_gck <= '1';
--   rst_gck   <= '0';
--   wait;
-- end process proc_reset_n_gtp; 

proc_reset_n_gtp : process 
begin
  pon_reset_n <= '0';
  wait for CLK_GTP_PERIOD_c * 50;
  wait for 2 ns;
  pon_reset_n <= '1';
  wait;
end process proc_reset_n_gtp; 

-- CLOCKs
proc_clock : process 
begin
  clk_100 <= '0';
  wait for CLK_PERIOD_c/2.0;
  clk_loop : loop
    clk_100 <= not clk_100;
    wait for CLK_PERIOD_c/2.0;
  end loop;
end process proc_clock;

proc_clock_gtp : process 
begin
  gck <= '0';
  wait for CLK_GTP_PERIOD_c/2.0;
  clk_loop : loop
    gck <= not gck;
    wait for CLK_GTP_PERIOD_c/2.0;
  end loop;
end process proc_clock_gtp;




proc_pll_lock : process 
begin 
  gtp_pll_lock    <= '1';
  gtp_clk_lost    <= '0';
  
  wait for 10 us;
  gtp_pll_lock <= '0';
  
  wait for 10 ns;
  gtp_pll_lock <= '1';
  
  wait for 200 us;
  gtp_pll_lock <= '0';
  
  wait for 10 us;
  gtp_pll_lock <= '1';
  
  wait for 200 us;
  gtp_pll_lock <= '0';

  wait for 25.6 us;
  gtp_pll_lock <= '1';

  wait for 200 us;
  gtp_pll_lock <= '0';

  wait for 51.2 us;
  gtp_pll_lock <= '1';
  
  wait for 200 us;
  gtp_pll_lock <= '0';

  wait for 204.8 us;
  gtp_pll_lock <= '1';
  
  wait for 500 us;
  
  wait for 10 us;
  gtp_clk_lost <= '1';
  
  wait for 10 ns;
  gtp_clk_lost <= '0';
  
  wait for 200 us;
  gtp_clk_lost <= '1';
  
  wait for 10 us;
  gtp_clk_lost <= '0';
  
  wait for 200 us;
  gtp_clk_lost <= '1';

  wait for 25.6 us;
  gtp_clk_lost <= '0';

  wait for 200 us;
  gtp_clk_lost <= '1';

  wait for 51.2 us;
  gtp_clk_lost <= '0';
  
  wait for 200 us;
  gtp_clk_lost <= '1';

  wait for 204.8 us;
  gtp_clk_lost <= '0';
  
  wait;
    
end process proc_pll_lock;

proc_align_req : process 
begin 
  gtp_is_aligned    <= '1';
  wait for 0.1 ns;
  
  loop
    wait for CLK_PERIOD_c * 100;
    gtp_is_aligned <= '1';
    
    wait for CLK_PERIOD_c * 100;
    gtp_is_aligned <= '0';

    wait for CLK_PERIOD_c * 100;
    gtp_is_aligned <= '1';
    
    wait for CLK_PERIOD_c * 100;
    gtp_is_aligned <= '0';
    
  end loop;
  
end process proc_align_req;


TIME_MACHINE_CLK_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  10.0, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   3,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => true  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => clk_100,
    CLEAR_i                 => '1',
  
    -- Output reset
    RESET_o                 => open,
    RESET_N_o               => rst_n,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => open,
    
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

TIME_MACHINE_GCK_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>   6.4, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => true  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => gck,
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

-- --------------------------------------------------------
-- Data Generator

-- tx_data              : std_logic_vector(31 downto 0);
-- tx_data_src_rdy      : std_logic;
-- tx_data_dst_rdy      : std_logic;
-- tx_data_rate_cnt     : std_logic_vector(7 downto 0);

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


align_key <= "01";

GTP_TX_Manager_i : GTP_TX_Manager 
  generic map( 
    TX_DATA_IN_WIDTH_g      => 32,   
    GTP_STREAM_WIDTH_g      => 16   
    )
  port map(
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          => gtp_pll_lock,
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   => clk_100,
    RST_N_i                 => rst_n, 
    EN1S_i                  => en1s, 
    
    -- Control
    AUTO_ALIGN_i            => auto_align,
    ALIGN_REQ_i             => align_request,
    ALIGN_KEY_i             => align_key,
    GTP_PLL_REFCLKLOST_i    => gtp_clk_lost,
    TX_ERROR_INJECTION_i    => tx_error_injection,
 
    -- Control out
    GTP_SOFT_RESET_TX_o     => gtp_soft_reset_tx,
    
    -- Status
    ALIGN_FLAG_o            => align_flag,

    -- Data in 
    TX_DATA_i               => tx_data, 
    TX_DATA_SRC_RDY_i       => tx_data_src_rdy,
    TX_DATA_DST_RDY_o       => tx_data_dst_rdy,
    
    TX_MSG_i                => tx_msg,           
    TX_MSG_SRC_RDY_i        => tx_msg_src_rdy,
    TX_MSG_DST_RDY_o        => tx_msg_dst_rdy, 
    
        
    -- *** GTP CLOCK DOMAIN ***
    -- Bare Control ports          
    GCK_i                   => gck,   
    RST_N_GCK_i             => rst_n_gck, 
    EN100US_GCK_i           => en100us_gck,
    
    -- Data out
    GTP_STREAM_OUT_o        => gtp_stream,
    GTP_CHAR_IS_K_o         => gtp_char_is_k
    );


gtp_rxusrclk2 <= gck;
gtp_rxdata    <= gtp_stream;
gtp_rxcharisk <= gtp_char_is_k;

gtp_rx_data_dst_rdy <= '1';
gtp_rx_msg_dst_rdy  <= '1';

GTP_RX_Manager_i : GTP_RX_Manager 
  generic map( 
    RX_DATA_OUT_WIDTH_g        => 32, 
    GTP_STREAM_WIDTH_g         => 16, 
    GTP_RXUSRCLK2_PERIOD_NS_g  => 6.4, 
    SIM_TIME_COMPRESSION_g     => TRUE
    )
  port map(
    -- Bare Control ports
    CLK_i                      => clk_100,
    RST_N_i                    => rst_n, 
    EN1S_i                     => en1s, 
    
    -- Status
    GTP_PLL_ALARM_o            => gtp_pll_alarm,
    
    -- Control out
    ALIGN_REQUEST_o            => align_request,

    -- Data out
    RX_DATA_o                  => gtp_rx_data,
    RX_DATA_SRC_RDY_o          => gtp_rx_data_src_rdy,
    RX_DATA_DST_RDY_i          => gtp_rx_data_dst_rdy,

    RX_MSG_o                   => gtp_rx_msg,
    RX_MSG_SRC_RDY_o           => gtp_rx_msg_src_rdy,
    RX_MSG_DST_RDY_i           => gtp_rx_msg_dst_rdy,
        
    -- *****************************************************************************************
    -- GTP Interface

    SOFT_RESET_TX_o            => soft_reset_tx,
    SOFT_RESET_RX_o            => soft_reset_rx,
    DONT_RESET_ON_DATA_ERROR_o => dont_reset_on_data_error,

    GTP_TX_FSM_RESET_DONE_i    => gtp_tx_fsm_reset_done,
    GTP_RX_FSM_RESET_DONE_i    => gtp_rx_fsm_reset_done,
    GTP_DATA_VALID_o           => gtp_data_valid,
 
    GTP_RXUSRCLK2_i            => gtp_rxusrclk2,

    --_________________________________________________________________________
    -- GTP  (XxYy)
    -- ____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    GTP_DRPADDR_o              => gtp_drpaddr,     
    GTP_DRPDI_o                => gtp_drpdi,       
    GTP_DRPDO_i                => gtp_drpdo,       
    GTP_DRPEN_o                => gtp_drpen,       
    GTP_DRPRDY_i               => gtp_drprdy,      
    GTP_DRPWE_o                => gtp_drpwe,       
    --------------------- RX Initialization and Reset Ports --------------------
    GTP_EYESCANRESET_o         => gtp_eyescanreset,
    GTP_RXUSERRDY_o            => gtp_rxuserrdy,   
    -------------------------- RX Margin Analysis Ports ------------------------
    GTP_EYESCANDATAERROR_i     => gtp_eyescandataerror,
    GTP_EYESCANTRIGGER_o       => gtp_eyescantrigger,  
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GTP_RXDATA_i               => gtp_rxdata,
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    GTP_RXCHARISCOMMA_i        => gtp_rxchariscomma,  
    GTP_RXCHARISK_i            => gtp_rxcharisk,      
    GTP_RXDISPERR_i            => gtp_rxdisperr,      
    GTP_RXNOTINTABLE_i         => gtp_rxnotintable,   
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    GTP_RXBYTEISALIGNED_i      => gtp_rxbyteisaligned,        
    GTP_RXBYTEREALIGN_i        => gtp_rxbyterealign,          
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    GTP_DMONITOROUT_i          => gtp_dmonitorout,
    -------------------- Receive Ports - RX Equailizer Ports -------------------
    GTP_RXLPMHFHOLD_o          => gtp_rxlpmhfhold,
    GTP_RXLPMLFHOLD_o          => gtp_rxlpmlfhold,
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    GTP_RXOUTCLKFABRIC_i       => gtp_rxoutclkfabric,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GTP_GTRXRESET_o            => gtp_gtrxreset,
    GTP_RXLPMRESET_o           => gtp_rxlpmreset,
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    GTP_RXRESETDONE_i          => gtp_rxresetdone,
    --------------------- TX Initialization and Reset Ports --------------------
    GTP_GTTXRESET_o            => gtp_gttxreset,
    GTP_TXUSERRDY_o            => gtp_txuserrdy,
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GTP_TXDATA_o               => gtp_txdata,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GTP_TXOUTCLKFABRIC_i       => gtp_txoutclkfabric,
    GTP_TXOUTCLKPCS_i          => gtp_txoutclkpcs,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GTP_TXRESETDONE_i          => gtp_txresetdone,

    --____________________________COMMON PORTS________________________________
    GTP_PLL0RESET_i            => gtp_pll0reset,         
    GTP_PLL0OUTCLK_i           => gtp_pll0outclk,        
    GTP_PLL0OUTREFCLK_i        => gtp_pll0outrefclk,     
    GTP_PLL0LOCK_i             => gtp_pll0lock,          
    GTP_PLL0REFCLKLOST_i       => gtp_pll0refclklost,    
    GTP_PLL1OUTCLK_i           => gtp_pll1outclk,        
    GTP_PLL1OUTREFCLK_i        => gtp_pll1outrefclk      
    -- *****************************************************************************************
    );

end Behavioral;

