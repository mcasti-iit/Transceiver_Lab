library ieee; 
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  
library UNISIM;  
  use UNISIM.Vcomponents.all;  
  
use std.textio.all;
  use ieee.std_logic_textio.all;

entity GTP_Test_tb is
--  Port ( );
end GTP_Test_tb;

architecture Behavioral of GTP_Test_tb is

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
    RX_DATA_OUT_WIDTH_g     : integer range 0 to 64 := 32;    -- Width of RX Data - Fabric side
    GTP_STREAM_WIDTH_g      : integer range 0 to 64 := 16     -- Width of RX Data - GTP side 
    );
  port (
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          : in  std_logic;
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side    
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1MS_i                 : in  std_logic;   -- Enable @ 1 msec in clk domain 
    EN1S_i                  : in  std_logic;   -- Enable @ 1 sec in clk domain 

    -- Control in
    GTP_PLL_REFCLKLOST_i    : in  std_logic;
     
    -- Control out
    GTP_SOFT_RESET_RX_o     : out std_logic;     
         
    -- Data out
    RX_DATA_o               : out std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
    RX_DATA_SRC_RDY_o       : out std_logic;
    RX_DATA_DST_RDY_i       : in  std_logic;
    
    RX_MSG_o                : out std_logic_vector(7 downto 0);
    RX_MSG_SRC_RDY_o        : out std_logic;
    RX_MSG_DST_RDY_i        : in  std_logic;
    
        
    -- *** GTP CLOCK DOMAIN ***
    -- Bare Control ports   
    GCK_i                   : in  std_logic;   -- Input clock - GTP side       
    RST_N_GCK_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)    
    EN1MS_GCK_i             : in  std_logic;   -- Enable @ 1 msec in gck domain 

    -- Control out         
    GTP_IS_ALIGNED_i        : in  std_logic;
    ALIGN_REQ_o             : out std_logic;

    -- Data in 
    GTP_STREAM_IN_i         : in  std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
    GTP_CHAR_IS_K_i         : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0)
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
    EN1S_i                  : in  std_logic;   -- Enable @ 1 sec in clk domain 
    
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
    gt0_rxoutclkfabric_out                  : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                        : in   std_logic;
    gt0_rxlpmreset_in                       : in   std_logic;
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    gt0_rxresetdone_out                     : out  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                        : in   std_logic;

GT0_PLL0PD_IN                           : in   std_logic;
    --____________________________COMMON PORTS________________________________
   GT0_PLL0RESET_OUT  : out std_logic;
         GT0_PLL0OUTCLK_OUT  : out std_logic;
         GT0_PLL0OUTREFCLK_OUT  : out std_logic;
         GT0_PLL0LOCK_OUT  : out std_logic;
         GT0_PLL0REFCLKLOST_OUT  : out std_logic;    
         GT0_PLL1OUTCLK_OUT  : out std_logic;
         GT0_PLL1OUTREFCLK_OUT  : out std_logic;

          sysclk_in                               : in   std_logic

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


constant CLK_PERIOD_c             : time := 10.0 ns;  
constant CLK_GTP_PERIOD_c         : time :=  6.4 ns;  
constant REFCLK0_TX_PERIOD_C      : time :=  8.0 ns;  
constant REFCLK0_RX_PERIOD_C      : time :=  8.0 ns;  

signal REFCLK0_TX_P_i             : std_logic;
signal REFCLK0_TX_N_i             : std_logic;
signal REFCLK0_RX_P_i             : std_logic;
signal REFCLK0_RX_N_i             : std_logic;

signal TXP_o                      : std_logic;
signal TXN_o                      : std_logic;
signal RXP_i                      : std_logic;
signal RXN_i                      : std_logic;

signal clk_100, gcktx, gckrx      : std_logic;
signal rst_n, rst                 : std_logic;                    --active high reset
signal pon_reset_n                : std_logic;                    --active high reset
signal rst_n_gcktx, rst_gcktx     : std_logic;                    --active high reset
signal rst_n_gckrx, rst_gckrx     : std_logic;                    --active high reset
signal en1s                       : std_logic;  
signal en1ms                      : std_logic;  

signal en100us_gcktx              : std_logic;
signal en1ms_gcktx                : std_logic;
signal en100us_gckrx              : std_logic;
signal en1ms_gckrx                : std_logic;

signal gtp_tx_stream              : std_logic_vector(15 downto 0);
signal gtp_tx_char_is_k           : std_logic_vector(1 downto 0);
signal gtp_rx_stream              : std_logic_vector(15 downto 0);
signal gtp_rx_char_is_k           : std_logic_vector(1 downto 0);

signal rx_data_gtp                : std_logic_vector(15 downto 0);
signal rx_char_is_k               : std_logic_vector(1 downto 0);

signal gtp_rx_data           : std_logic_vector(31 downto 0);
signal gtp_rx_data_src_rdy   : std_logic;
signal gtp_rx_data_dst_rdy   : std_logic;

signal gtp_rx_msg            : std_logic_vector(7 downto 0);
signal gtp_rx_msg_src_rdy    : std_logic;
signal gtp_rx_msg_dst_rdy    : std_logic;

signal gtp_stream_src_rdy : std_logic;

signal gtp_is_aligned : std_logic;
signal gtp_realign : std_logic;
signal align_req_tx   : std_logic;
signal align_req_rx   : std_logic;
signal align_key      : std_logic_vector(1 downto 0);

signal gtp_tx_soft_reset : std_logic;
signal gtp_rx_soft_reset : std_logic;

signal tx_error_injection : std_logic;

signal auto_align : std_logic;
signal align_flag : std_logic;
signal gtp_rx_pll_lock : std_logic;
signal gtp_rx_clk_lost : std_logic;
signal gtp_tx_pll_lock : std_logic;
signal gtp_tx_clk_lost : std_logic;

signal tx_data              : std_logic_vector(31 downto 0);
signal tx_data_src_rdy      : std_logic;
signal tx_data_dst_rdy      : std_logic;
signal tx_data_rate_cnt     : std_logic_vector(7 downto 0);

signal tx_msg               : std_logic_vector(7 downto 0);
signal tx_msg_src_rdy       : std_logic;
signal tx_msg_dst_rdy       : std_logic;
signal tx_msg_rate_cnt      : std_logic_vector(7 downto 0);



begin
 

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

-- proc_clock_gtp : process 
-- begin
--   gck <= '0';
--   wait for CLK_GTP_PERIOD_c/2.0;
--   clk_loop : loop
--     gck <= not gck;
--     wait for CLK_GTP_PERIOD_c/2.0;
--   end loop;
-- end process proc_clock_gtp;

proc_refclk0_tx : process 
begin
  REFCLK0_TX_N_i <= '1';
  REFCLK0_TX_P_i <= '0';
  wait for REFCLK0_TX_PERIOD_C/2.0;
  clk_loop : loop
    REFCLK0_TX_N_i <= not REFCLK0_TX_N_i;
    REFCLK0_TX_P_i <= not REFCLK0_TX_P_i;
    wait for REFCLK0_TX_PERIOD_C/2.0;
  end loop;
end process proc_refclk0_tx;

proc_refclk0_rx : process 
begin
  REFCLK0_RX_N_i <= '1';
  REFCLK0_RX_P_i <= '0';
  wait for REFCLK0_RX_PERIOD_C/2.0;
  clk_loop : loop
    REFCLK0_RX_N_i <= not REFCLK0_RX_N_i;
    REFCLK0_RX_P_i <= not REFCLK0_RX_P_i;
    wait for REFCLK0_RX_PERIOD_C/2.0;
  end loop;
end process proc_refclk0_rx;


-- proc_pll_lock : process 
-- begin 
--   gtp_pll_lock    <= '1';
--   gtp_clk_lost    <= '0';
--   
--   wait for 10 us;
--   gtp_pll_lock <= '0';
--   
--   wait for 10 us;
--   gtp_pll_lock <= '1';
--   
--   wait for 200 us;
--   gtp_pll_lock <= '0';
-- 
--   wait for 25.6 us;
--   gtp_pll_lock <= '1';
-- 
--   wait for 200 us;
--   gtp_pll_lock <= '0';
-- 
--   wait for 51.2 us;
--   gtp_pll_lock <= '1';
--   
--   wait for 200 us;
--   gtp_pll_lock <= '0';
-- 
--   wait for 204.8 us;
--   gtp_pll_lock <= '1';
--   
--   wait;
--     
-- end process proc_pll_lock;
-- 
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

TIME_MACHINE_GCKTX_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>   6.4, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => true  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => gcktx,
    CLEAR_i                 => '1',
  
    -- Output reset
    RESET_o                 => open,
    RESET_N_o               => rst_n_gcktx,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => open,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => en100us_gcktx,
    EN1MS_o                 => en1ms_gcktx,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );
    
TIME_MACHINE_GCKRX_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>   6.4, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => true  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => gckrx,
    CLEAR_i                 => '1',
  
    -- Output reset
    RESET_o                 => open,
    RESET_N_o               => rst_n_gckrx,
    PON_RESET_OUT_o         => open,
    PON_RESET_N_OUT_o       => open,
    
    -- Output ports for generated clock enables
    EN200NS_o               => open,
    EN1US_o                 => open,
    EN10US_o                => open,
    EN100US_o               => en100us_gckrx,
    EN1MS_o                 => en1ms_gckrx,
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


align_key     <= "01";
align_req_tx  <= '0'; -- align_req_rx;

GTP_TX_Manager_i : GTP_TX_Manager 
  generic map( 
    TX_DATA_IN_WIDTH_g      => 32,   
    GTP_STREAM_WIDTH_g      => 16   
    )
  port map(
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          => gtp_tx_pll_lock,
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   => clk_100,
    RST_N_i                 => rst_n, 
    EN1S_i                  => en1s, 
    
    -- Control
    AUTO_ALIGN_i            => auto_align,
    ALIGN_REQ_i             => align_req_tx,
    ALIGN_KEY_i             => align_key,
    GTP_PLL_REFCLKLOST_i    => gtp_tx_clk_lost,
    TX_ERROR_INJECTION_i    => tx_error_injection,
 
    -- Control out
    GTP_SOFT_RESET_TX_o     => gtp_tx_soft_reset,
    
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
    GCK_i                   => gcktx,   
    RST_N_GCK_i             => rst_n_gcktx, 
    EN100US_GCK_i           => en100us_gcktx,
    
    -- Data out
    GTP_STREAM_OUT_o        => gtp_tx_stream,
    GTP_CHAR_IS_K_o         => gtp_tx_char_is_k
    );




   
GTP_TX_i : GTP_Artix
  port map
    (
      SOFT_RESET_TX_IN                =>      gtp_tx_soft_reset, -- '0',
      DONT_RESET_ON_DATA_ERROR_IN     =>      '0',
      Q0_CLK0_GTREFCLK_PAD_N_IN       =>      REFCLK0_TX_N_i,
      Q0_CLK0_GTREFCLK_PAD_P_IN       =>      REFCLK0_TX_P_i,
      GT0_TX_FSM_RESET_DONE_OUT       =>      open,
      GT0_RX_FSM_RESET_DONE_OUT       =>      open,
      GT0_DATA_VALID_IN               =>      '0',
 
      GT0_TXUSRCLK_OUT                =>      open,
      GT0_TXUSRCLK2_OUT               =>      gcktx,

      --_____________________________________________________________________
      --_____________________________________________________________________
      --GT0  (X0Y0)

      ---------------------------- Channel - DRP Ports  --------------------------
      gt0_drpaddr_in                  =>      (others => '0'),
      gt0_drpdi_in                    =>      (others => '0'),
      gt0_drpdo_out                   =>      open,
      gt0_drpen_in                    =>      '0',
      gt0_drprdy_out                  =>      open,
      gt0_drpwe_in                    =>      '0',
      --------------------- RX Initialization and Reset Ports --------------------
      gt0_eyescanreset_in             =>      '0',
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out        =>      open,
      gt0_eyescantrigger_in           =>      '0',
      ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
      gt0_dmonitorout_out             =>      open,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in                =>      '0',
      gt0_rxlpmreset_in               =>      '0',
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in                =>      '0', -- fpga_probe_out0(0),
      gt0_txuserrdy_in                =>      '1',
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      gt0_txdata_in                   =>      gtp_tx_stream, -- gt0_txdata_in,
      ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
      gt0_txcharisk_in                =>      gtp_tx_char_is_k, -- gt0_txcharisk_in,
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      gt0_gtptxn_out                  =>      TXN_o,
      gt0_gtptxp_out                  =>      TXP_o,
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      gt0_txoutclkfabric_out          =>      open,
      gt0_txoutclkpcs_out             =>      open,
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      gt0_txresetdone_out             =>      open,

      --____________________________COMMON PORTS________________________________
      GT0_PLL0OUTCLK_OUT              =>      open,
      GT0_PLL0OUTREFCLK_OUT           =>      open,
      GT0_PLL0LOCK_OUT                =>      gtp_tx_pll_lock,
      GT0_PLL0REFCLKLOST_OUT          =>      gtp_tx_clk_lost,    
      GT0_PLL1OUTCLK_OUT              =>      open,
      GT0_PLL1OUTREFCLK_OUT           =>      open,
      sysclk_in                       =>      clk_100
    );



RXP_i <= TXP_o;
RXN_i <= TXN_o;


GTP_RX_i : GTP_Zynq
port map
(
    SOFT_RESET_RX_IN                    =>      gtp_rx_soft_reset,  -- '0', -- gtp_reset, -- '0', -- 
    DONT_RESET_ON_DATA_ERROR_IN         =>      '0',
    Q0_CLK1_GTREFCLK_PAD_N_IN           =>      REFCLK0_RX_N_i,
    Q0_CLK1_GTREFCLK_PAD_P_IN           =>      REFCLK0_RX_N_i,

    GT0_TX_FSM_RESET_DONE_OUT           =>      open,
    GT0_RX_FSM_RESET_DONE_OUT           =>      open,
    GT0_DATA_VALID_IN                   =>      '1',

    GT0_RXUSRCLK_OUT                    =>      open,
    GT0_RXUSRCLK2_OUT                   =>      gckrx,

    --_________________________________________________________________________
    --GT0  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      (others => '0'),
        gt0_drpdi_in                    =>      (others => '0'),
        gt0_drpdo_out                   =>      open,
        gt0_drpen_in                    =>      '0',
        gt0_drprdy_out                  =>      open,
        gt0_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      '0',
        gt0_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out        =>      open,
        gt0_eyescantrigger_in           =>      '0',
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        gt0_rxdata_out                  =>      gtp_rx_stream, --gt0_rxdata_out,
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
        gt0_rxchariscomma_out           =>      open,
        gt0_rxcharisk_out               =>      gtp_rx_char_is_k, 
        gt0_rxdisperr_out               =>      open,
        gt0_rxnotintable_out            =>      open,
    ------------------------ Receive Ports - RX AFE Ports ----------------------
        gt0_gtprxn_in                   =>      RXN_i,
        gt0_gtprxp_in                   =>      RXP_i,
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
        gt0_rxbyteisaligned_out         =>      gtp_is_aligned,
        gt0_rxbyterealign_out           =>      gtp_realign,
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        gt0_dmonitorout_out             =>      open,
    -------------------- Receive Ports - RX Equailizer Ports -------------------
        gt0_rxlpmhfhold_in              =>      '0',
        gt0_rxlpmlfhold_in              =>      '0',
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
        gt0_rxoutclkfabric_out          =>      open,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      '0', -- , -- gtp_gtrxreset,
        gt0_rxlpmreset_in               =>      '0', -- gtp_rxlpmreset,
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out             =>      open,
    --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      '0',


GT0_PLL0PD_IN                           => '0',
    --____________________________COMMON PORTS________________________________
        GT0_PLL0RESET_OUT               =>      open,
        GT0_PLL0OUTCLK_OUT              =>      open,
        GT0_PLL0OUTREFCLK_OUT           =>      open,
        GT0_PLL0LOCK_OUT                =>      gtp_rx_pll_lock,
        GT0_PLL0REFCLKLOST_OUT          =>      gtp_rx_clk_lost,    
        GT0_PLL1OUTCLK_OUT              =>      open,
        GT0_PLL1OUTREFCLK_OUT           =>      open,
        sysclk_in                       =>      clk_100
);








gtp_rx_data_dst_rdy <= '1';
gtp_rx_msg_dst_rdy  <= '1';


GTP_RX_Manager_i : GTP_RX_Manager 
  generic map( 
    RX_DATA_OUT_WIDTH_g     => 32,
    GTP_STREAM_WIDTH_g      => 16
      
    )
  port map(
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          => gtp_rx_pll_lock,
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   => clk_100,
    RST_N_i                 => rst_n, 
    EN1MS_i                 => en1ms,
    EN1S_i                  => en1s, 
    
    -- Control in
    GTP_PLL_REFCLKLOST_i    => gtp_rx_clk_lost,
     
    -- Control out
    GTP_SOFT_RESET_RX_o     => gtp_rx_soft_reset,
         
    -- Data out
    RX_DATA_o               => gtp_rx_data,
    RX_DATA_SRC_RDY_o       => gtp_rx_data_src_rdy,
    RX_DATA_DST_RDY_i       => gtp_rx_data_dst_rdy,

    RX_MSG_o                => gtp_rx_msg,
    RX_MSG_SRC_RDY_o        => gtp_rx_msg_src_rdy,
    RX_MSG_DST_RDY_i        => gtp_rx_msg_dst_rdy,
    
        
    -- *** GTP CLOCK DOMAIN ***
    -- Bare Control ports   
    GCK_i                   => gckrx,       
    RST_N_GCK_i             => rst_n_gckrx,
    EN1MS_GCK_i             => en1ms_gckrx,
    
    -- Controls         
    GTP_IS_ALIGNED_i        => gtp_is_aligned,
    ALIGN_REQ_o             => align_req_rx,

    -- Data in 
    GTP_STREAM_IN_i         => gtp_rx_stream, 
    GTP_CHAR_IS_K_i         => gtp_rx_char_is_k 
    );    



end Behavioral;

