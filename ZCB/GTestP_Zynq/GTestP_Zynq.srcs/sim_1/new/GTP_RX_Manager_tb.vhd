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
    RX_DATA_IN_WIDTH_g      : integer range 0 to 64 := 16;    -- Width of RX Data - GTP side 
    RX_DATA_OUT_WIDTH_g     : integer range 0 to 64 := 32     -- Width of RX Data - Fabric side
    );
  port (
    -- Clock in port
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    GCK_i                   : in  std_logic;   -- Input clock - GTP side     
    RST_CLK_N_i             : in  std_logic;   -- Asynchronous active low reset (clk clock)
    RST_GCK_N_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)

    -- Control
    GTP_IS_ALIGNED_i        : in  std_logic;
    ALIGN_REQ_o             : out  std_logic;
    
    -- Status
    OVERRIDE_GCK_o          : out std_logic;
  
    -- Data in 
    RX_DATA_IN_i            : in  std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);
    RX_CHAR_IS_K_i          : in  std_logic_vector((RX_DATA_IN_WIDTH_g/8)-1 downto 0);
    
    -- Data out
    RX_DATA_OUT_o           : out std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
    RX_DATA_OUT_SRC_RDY_o   : out std_logic;
    RX_DATA_OUT_DST_RDY_i   : in  std_logic            
    );
end component;

component GTP_TX_Manager is
  generic ( 
    TX_DATA_IN_WIDTH_g      : integer range 0 to 64 := 32;    -- Width of TX Data - Fabric side 
    GTP_STREAM_WIDTH_g      : integer range 0 to 64 := 16     -- Width of TX Data - GTP side
    );
  port (
    -- Clock in port
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    GCK_i                   : in  std_logic;   -- Input clock - GTP side     
    RST_CLK_N_i             : in  std_logic;   -- Asynchronous active low reset (clk clock)
    RST_GCK_N_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)
    EN1MS_GCK_i             : in  std_logic;   -- Enable @ 1 ms in gck domain

    -- Control
    ALIGN_REQ_i             : in   std_logic;
    ALIGN_KEY_i             : in   std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    TX_MSG_IN_i             : in   std_logic_vector(7 downto 0);
    TX_MSG_IN_SRC_RDY_i     : in   std_logic;
    TX_MSG_IN_DST_RDY_o     : out  std_logic;
    TX_ERROR_INJECTION_i    : in   std_logic;
    
    -- Status
    OVERRIDE_GCK_o          : out std_logic;
    ALIGN_FLAG_o            : out std_logic;
  
    -- Data in 
    TX_DATA_IN_i            : in  std_logic_vector(TX_DATA_IN_WIDTH_g-1 downto 0);
    TX_DATA_IN_SRC_RDY_i    : in  std_logic;
    TX_DATA_IN_DST_RDY_o    : out std_logic;
    
    -- Data out
    GTP_STREAM_OUT_o        : out std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
    GTP_CHAR_IS_K_o         : out std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0)              
    );
end component;

constant CLK_PERIOD_c       : time := 10.0 ns;  
constant CLK_GTP_PERIOD_c   : time :=  6.4 ns;  


signal clk, clk_gtp         : std_logic;
signal rst_n, rst           : std_logic;                    --active high reset
signal pon_reset_n          : std_logic;                    --active high reset
signal rst_n_gck, rst_gck   : std_logic;                    --active high reset

signal en_20ns              : std_logic;  

signal tx_cnt_32bit         : std_logic_vector(31 downto 0);
signal tx_cnt_32bit_valid   : std_logic;

signal tx_data           : std_logic_vector(31 downto 0);
signal tx_data_valid_cnt : std_logic_vector(7 downto 0);
signal tx_data_valid     : std_logic;
signal gtp_stream        : std_logic_vector(15 downto 0);
signal gtp_char_is_k     : std_logic_vector(1 downto 0);

signal rx_data_gtp       : std_logic_vector(15 downto 0);
signal rx_char_is_k      : std_logic_vector(1 downto 0);
signal rx_data           : std_logic_vector(31 downto 0);
signal rx_data_src_rdy   : std_logic;
signal rx_data_dst_rdy   : std_logic;



signal gtp_stream_src_rdy : std_logic;

signal gtp_is_aligned : std_logic;
signal align_req      : std_logic;
signal align_key      : std_logic_vector(1 downto 0);

signal tx_msg_in_src_rdy  : std_logic;
signal tx_msg             : std_logic_vector(7 downto 0);
signal tx_msg_in_dst_rdy  : std_logic;
signal tx_error_injection : std_logic;



signal en1ms_gck         : std_logic;

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
  clk <= '0';
  wait for CLK_PERIOD_c/2.0;
  clk_loop : loop
    clk <= not clk;
    wait for CLK_PERIOD_c/2.0;
  end loop;
end process proc_clock;

proc_clock_gtp : process 
begin
  clk_gtp <= '0';
  wait for CLK_GTP_PERIOD_c/2.0;
  clk_loop : loop
    clk_gtp <= not clk_gtp;
    wait for CLK_GTP_PERIOD_c/2.0;
  end loop;
end process proc_clock_gtp;


proc_align_req : process 
begin 
  gtp_is_aligned    <= '1';
  tx_msg_in_src_rdy <= '0';
  tx_msg            <= x"00";
  wait for 0.1 ns;
  
  loop
    gtp_is_aligned <= '1';
    wait for CLK_GTP_PERIOD_c * 100;
 
    gtp_is_aligned <= '0';
    wait for CLK_GTP_PERIOD_c *  49;
    
    tx_msg_in_src_rdy <= '1';
    tx_msg            <= x"4B";
    
    wait for CLK_GTP_PERIOD_c *  1;
      
    tx_msg_in_src_rdy <= '0';
    tx_msg            <= x"00";
    
    wait for CLK_GTP_PERIOD_c *  50;
    gtp_is_aligned <= '1';
    
    wait for CLK_GTP_PERIOD_c * 100;
    gtp_is_aligned <= '0';
    
    wait for CLK_GTP_PERIOD_c * 100;
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
    CLK_i                   => clk,
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
    EN1MS_o                 => open,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
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
    CLK_i                   => clk_gtp,
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
    EN100US_o               => open,
    EN1MS_o                 => en1ms_gck,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );

-- --------------------------------------------------------
-- Data Generator

process(clk, rst_n)
begin
  if (pon_reset_n = '0') then
    tx_data_valid_cnt  <= (others => '0');
    tx_cnt_32bit       <= (others => '0');
    tx_cnt_32bit_valid <= '0';
  elsif rising_edge(clk) then
    if (tx_data_valid_cnt = x"03") then
      tx_data_valid_cnt  <= (others => '0');
      tx_cnt_32bit       <= tx_cnt_32bit + 1;
      tx_cnt_32bit_valid <= '1';
    else
--      tx_cnt_32bit <= tx_cnt_32bit;
      tx_data_valid_cnt  <= tx_data_valid_cnt + 1;
      tx_cnt_32bit_valid <= '0';
    end if;
  end if;	
end process;


tx_data       <= tx_cnt_32bit;
tx_data_valid <= tx_cnt_32bit_valid;

align_key <= "01";

GTP_TX_Manager_i : GTP_TX_Manager 
  generic map( 
    TX_DATA_IN_WIDTH_g      => 32,   
    GTP_STREAM_WIDTH_g      => 16   
    )
  port map(
    -- Clock in port
    CLK_i                   => clk,
    GCK_i                   => clk_gtp,   
    RST_CLK_N_i             => rst_n, 
    RST_GCK_N_i             => rst_n_gck, 
    EN1MS_GCK_i             => en1ms_gck,
    
    -- Control
    ALIGN_REQ_i             => align_req,
    ALIGN_KEY_i             => align_key,
    TX_MSG_IN_i             => tx_msg,           
    TX_MSG_IN_SRC_RDY_i     => tx_msg_in_src_rdy,
    TX_MSG_IN_DST_RDY_o     => tx_msg_in_dst_rdy,
    TX_ERROR_INJECTION_i    => tx_error_injection,
    
    -- Status
    OVERRIDE_GCK_o          => open,
    ALIGN_FLAG_o            => open,
    
    -- Data in 
    TX_DATA_IN_i            => tx_data, 
    TX_DATA_IN_SRC_RDY_i    => tx_data_valid,
    TX_DATA_IN_DST_RDY_o    => open,
    
    -- Data out
    GTP_STREAM_OUT_o        => gtp_stream,
    GTP_CHAR_IS_K_o         => gtp_char_is_k
    );



GTP_RX_Manager_i : GTP_RX_Manager 
  generic map( 
    RX_DATA_IN_WIDTH_g      => 16,   
    RX_DATA_OUT_WIDTH_g     => 32   
    )
  port map(
    -- Clock in port
    CLK_i                   => clk,
    GCK_i                   => clk_gtp,   
    RST_CLK_N_i             => rst_n, 
    RST_GCK_N_i             => rst_n_gck, 
    
    -- Control
    GTP_IS_ALIGNED_i        => gtp_is_aligned,
    ALIGN_REQ_o             => align_req,

    -- Data in 
    RX_DATA_IN_i            => gtp_stream, 
    RX_CHAR_IS_K_i          => gtp_char_is_k,
    
    -- Data out
    RX_DATA_OUT_o           => rx_data,
    RX_DATA_OUT_SRC_RDY_o   => rx_data_src_rdy,
    RX_DATA_OUT_DST_RDY_i   => rx_data_dst_rdy
 
    );




end Behavioral;

