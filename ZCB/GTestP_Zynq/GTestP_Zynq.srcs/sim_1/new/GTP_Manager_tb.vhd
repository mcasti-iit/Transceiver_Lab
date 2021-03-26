library ieee; 
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  
library UNISIM;  
  use UNISIM.Vcomponents.all;  
  
use std.textio.all;
  use ieee.std_logic_textio.all;

entity GTP_Manager_tb is
--  Port ( );
end GTP_Manager_tb;

architecture Behavioral of GTP_Manager_tb is

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

entity GTP_Manager is
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
    TX_ALIGN_FLAG_o         : out std_logic;   -- Monitor out: sending align
    
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

constant CLK_PERIOD_c       : time := 10.0 ns;  
constant CLK_GTP_PERIOD_c   : time :=  6.4 ns;  


signal clk_100, gcktx, gckrx : std_logic;
signal clear                 : std_logic; 
signal rst_n, rst            : std_logic;                    --active high reset
signal pon_reset_n           : std_logic;                    --active high reset

signal en1s                  : std_logic;  
signal en1ms                 : std_logic;  

-- ------------------------------------------------------------------
-- TX

signal tx_pll_alarm     : std_logic;
signal tx_align_request : std_logic;
signal tx_align_flag    : std_logic;

signal tx_data_rate      : std_logic_vector(15 downto 0);
signal tx_gtp_align_rate : std_logic_vector(15 downto 0);
signal tx_msg_rate       : std_logic_vector( 7 downto 0);
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

-- ---------------------------------------------------------------------------------------------------------------------------------

begin



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

proc_gcktx : process 
begin
  gcktx <= '0';
  wait for CLK_GTP_PERIOD_c/2.0;
  clk_loop : loop
    gcktx <= not gcktx;
    wait for CLK_GTP_PERIOD_c/2.0;
  end loop;
end process proc_gcktx;

proc_gckrx : process 
begin
  gckrx <= '0';
  wait for CLK_GTP_PERIOD_c/2.0;
  clk_loop : loop
    gckrx <= not gckrx;
    wait for CLK_GTP_PERIOD_c/2.0;
  end loop;
end process proc_gckrx;

-- Clear
proc_clear : process 
begin
  clear   <= '1';
  wait for 200 ns;
  clear   <= '0';
  wait;
end process proc_clear;  


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
    CLEAR_i                 => clear,
  
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


GTP_MANAGER_TX_i : GTP_Manager is
  generic map( 
    USER_DATA_WIDTH_g         =>   32;    -- Width of Data - Fabric side
    USER_MESSAGE_WIDTH_g      =>    8;    -- Width of Message - Fabric side 
    GTP_DATA_WIDTH_g          =>   16;    -- Width of Data - GTP side
    GTP_TXUSRCLK2_PERIOD_NS_g =>  6.4;    -- GTP User clock period
    GTP_RXUSRCLK2_PERIOD_NS_g =>  6.4;    -- GTP User clock period
    SIM_TIME_COMPRESSION_g    => true     -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port map(
    
    -- COMMONs
    -- Bare Control ports
    CLK_i                   => clk_100,   -- Input clock - Fabric side
    RST_N_i                 => rst_n,   -- Asynchronous active low reset (clk clock)
    EN1S_i                  => en1s,   -- Enable @ 1 sec in clk domain 

    -- Status
    PLL_ALARM_o             => tx_pll_alarm;
    
    -- ---------------------------------------------------------------------------------------
    -- TX SIDE

    -- Control in
    TX_AUTO_ALIGN_i         => '0',   -- Enables the "Auto alignment mode"
    TX_ALIGN_REQUEST_i      => tx_align_request,   -- Align request from Receiver
    TX_ERROR_INJECTION_i    => '0',   -- Error insertin (debug purpose)
    
    -- Status
    TX_ALIGN_FLAG_o         => tx_align_flag,   -- Monitor out: sending align
    
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
    GTP_TXUSRCLK2_i          => gcktx,
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
    GTP_RXUSERRDY_o          => open                                                    -- ASYNC     --
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
end 





end Behavioral;

