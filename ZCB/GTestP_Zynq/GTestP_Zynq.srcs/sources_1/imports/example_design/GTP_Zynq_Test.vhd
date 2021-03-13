library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
  
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity GTP_Zynq_Test is
  generic(
    EXAMPLE_CONFIG_INDEPENDENT_LANES : integer   := 1;
    EXAMPLE_LANE_WITH_START_CHAR     : integer   := 0;    -- specifies lane with unique start frame ch
    EXAMPLE_WORDS_IN_BRAM            : integer   := 512;  -- specifies amount of data in BRAM
    EXAMPLE_SIM_GTRESET_SPEEDUP      : string    := "FALSE";    -- simulation setting for GT SecureIP model
    STABLE_CLOCK_PERIOD              : integer   := 8; 
    EXAMPLE_USE_CHIPSCOPE            : integer   := 1           -- Set to 1 to use Chipscope to drive resets
    );
  port(
    REFCLK0_RX_N_i             : in   std_logic;
    REFCLK0_RX_P_i             : in   std_logic;
    
    REFCLK1_RX_N_i             : in   std_logic;
    REFCLK1_RX_P_i             : in   std_logic;
    
    RXN_i                      : in   std_logic;
    RXP_i                      : in   std_logic;
        
    FIXED_IO_0_mio             : inout std_logic_vector ( 53 downto 0 );         
    FIXED_IO_0_ps_clk          : inout std_logic;                                
    FIXED_IO_0_ps_porb         : inout std_logic;                                
    FIXED_IO_0_ps_srstb        : inout std_logic;                                
    
    ALIGN_REQ_R_N_o            : out std_logic;
    CCAM_PLL_RESET_o           : in  std_logic;
    
    AD9517_REFMON_i            : in std_logic;                                   
    AD9517_STATUS_i            : in std_logic;                                   
    AD9517_PD_N_o              : out std_logic;                                  
    AD9517_SYNC_N_o            : out std_logic;                                  
    AD9517_RESET_N_o           : out std_logic;                                  
    AD9517_SDIO_io             : inout std_logic;                                
    AD9517_SCLK_o              : out std_logic;                                  
    AD9517_SDO_i               : in std_logic;                                   
    AD9517_CS_N_o              : out std_logic;                                  
    
    EN_GTP_OSC_o               : out std_logic;                                  
    
    LEDS_o                     : out std_logic_vector(4 downto 0)                
    );


end GTP_Zynq_Test;
    
architecture RTL of GTP_Zynq_Test is

--**************************Component Declarations*****************************
    
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

component spi_3_wire_master
  generic(
    slaves    : integer := 1;  --number of spi slaves
    cmd_width : integer := 8;  --command bus width
    d_width   : integer := 8); --data bus width
  port(
    clock   : in     std_logic;                              --system clock
    reset_n : in     std_logic;                              --asynchronous reset
    enable  : in     std_logic;                              --initiate transaction
    cpol    : in     std_logic;                              --spi clock polarity
    cpha    : in     std_logic;                              --spi clock phase
    clk_div : in     integer;                                --system clock cycles per 1/2 period of sclk
    addr    : in     integer;                                --address of slave
    rw      : in     std_logic;                              --'0' for read, '1' for write
    tx_cmd  : in     std_logic_vector(cmd_width-1 downto 0); --command to transmit
    tx_data : in     std_logic_vector(d_width-1 downto 0);   --data to transmit
    sclk    : buffer std_logic;                              --spi clock
    ss_n    : buffer std_logic_vector(slaves-1 downto 0);    --slave select
    sdio    : inout  std_logic;                              --serial data input output
    busy    : out    std_logic;                              --busy / data ready signal
    rx_data : out    std_logic_vector(d_width-1 downto 0));  --data received
end component; 

component AD9517_Manager is
  generic(
    slaves    : INTEGER := 1;   --number of spi slaves
    cmd_width : INTEGER := 8;   --command bus width
    d_width   : INTEGER := 8    --data bus width
    ); 
  port(
    -- Main control
    CLK_i     : in  std_logic;                                 -- system clock
    EN1MS_i   : in  std_logic;                                 -- 1 ms clock enable
    RST_N_i   : in  std_logic;                                 -- asynchronous reset
    
    -- Control and status ports
    INIT_i    : in  std_logic;                                 -- Start of configuration
    ERROR_o   : out std_logic_vector(2 downto 0);              -- Error code
    DONE_o    : out std_logic;
    
    -- SPI Master side
    CPOL_o    : out std_logic;                                 -- spi clock polarity
    CPHA_o    : out std_logic;                                 -- spi clock phase
    W_nR_o    : out std_logic;                                 -- '0' for read, '1' for write
    TX_CMD_o  : out std_logic_vector(cmd_width-1 downto 0);    -- command to transmit
    TX_DATA_o : out std_logic_vector(d_width-1 downto 0);      -- data to transmit
    ENABLE_o  : out std_logic;                                 -- initiate transaction    
    BUSY_i    : in  std_logic;                                 -- busy / data ready signal
    RX_DATA_i : in  std_logic_vector(d_width-1 downto 0)       -- data received
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

component PS is
  port (
    FCLK_CLK0_0 : out STD_LOGIC;
    FIXED_IO_0_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk : inout STD_LOGIC;
    FIXED_IO_0_ps_porb : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb : inout STD_LOGIC
  );
end component;

component ila_0
port (
	clk    : in std_logic;
	probe0 : in std_logic_vector(15 downto 0); 
	probe1 : in std_logic_vector(15 downto 0);
	probe2 : in std_logic_vector(15 downto 0)
);
end component  ;

component ila_1
port (
	clk : in std_logic;
	probe0 : in std_logic_vector(31 downto 0); 
	probe1 : in std_logic_vector(31 downto 0); 
	probe2 : in std_logic_vector(7 downto 0); 
	probe3 : in std_logic_vector(7 downto 0);
	probe4 : in std_logic_vector(15 downto 0)
);
end component;

component VIO_GTP
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
end component;
  
  component VIO_FPGA
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
end component;


-- *****************************************************************************************

constant SPI_SLAVES_TOTNUM_c  : integer :=  1; --number of spi slaves
constant SPI_CMD_WIDTH_c      : integer := 16; --command bus width
constant SPI_D_WIDTH_c        : integer :=  8; --data bus width
constant SPI_CLK_DIV_c        : integer := 64; --system clock cycles per 1/2 period of sclk
constant SPI_DEVICE_SEL_c     : integer :=  0; --address of slave

-- *****************************************************************************************

signal  tied_to_ground                  : std_logic;
signal  tied_to_ground_vec              : std_logic_vector(63 downto 0);
signal  tied_to_vcc                     : std_logic;
signal  tied_to_vcc_vec                 : std_logic_vector(7 downto 0);

-- *****************************************************************************************

signal count_0        :  std_logic_vector(31 downto 0);
signal count_1        :  std_logic_vector(31 downto 0);
signal count_2        :  std_logic_vector(31 downto 0);
signal count_3        :  std_logic_vector(31 downto 0);
signal count_4        :  std_logic_vector(31 downto 0);

signal rx_cnt         :  std_logic_vector(15 downto 0);
signal rx_cnt_d       :  std_logic_vector(15 downto 0);
signal rx_cnt_m       :  std_logic_vector(15 downto 0);
signal rx_err         :  std_logic;
signal rx_data_match  :  std_logic;
signal rx_msg_match   :  std_logic;

-- *****************************************************************************************
signal pon_reset_n   :  std_logic;                                            -- Power On Reset
signal pon_reset     :  std_logic;                                            -- Power On Reset

signal spi_cpol         : std_logic;                                          -- spi clock polarity
signal spi_cpha         : std_logic;                                          -- spi clock phase
signal spi_w_nr         : std_logic;                                          -- '0' for read, '1' for write
signal spi_tx_cmd       : std_logic_vector(15 downto 0);                      -- command to transmit
signal spi_tx_data      : std_logic_vector(7 downto 0);                       -- data to transmit
signal spi_enable       : std_logic;                                          -- initiate transaction    
signal spi_busy         : std_logic;                                          -- busy / data ready signal
signal spi_rx_data      : std_logic_vector(7 downto 0);                       -- data received
signal spi_error        : std_logic_vector (2 downto 0);                      -- error code
signal spi_done         : std_logic;                                          -- done
signal spi_init         : std_logic;                                          -- done

signal spi_sclk         :  std_logic;                                         --spi clock
signal spi_ss_n         :  std_logic_vector(SPI_SLAVES_TOTNUM_c-1 downto 0);  --slave select
signal spi_sdio         :  std_logic;                                         --serial data input output


signal en1ms            : std_logic;
signal en10ms           : std_logic;
signal en1s             : std_logic;

signal toggle_1s        : std_logic;

signal ad9517_pd_n      :  std_logic;    
signal ad9517_sync_n    :  std_logic;    
signal ad9517_reset_n   :  std_logic; 

signal align_req_r_n    :  std_logic;                                            

-- *****************************************************************************************


signal clk_100                                 : std_logic;
signal rst_n                                   : std_logic;
signal rst_n_gck                               : std_logic;
signal gckrx                                   : std_logic;
signal en1ms_gck                               : std_logic;

signal autoreset_en                            : std_logic;


-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- VIO
signal vio_gtp_probe_in0           : std_logic_vector(15 downto 0);
signal vio_gtp_probe_out0          : std_logic_vector(15 downto 0);
signal vio_fpga_probe_in0          : std_logic_vector(15 downto 0);
signal vio_fpga_probe_out0         : std_logic_vector(15 downto 0);

-- ILA
signal ila_gtp_probe0          : std_logic_vector(15 downto 0);
signal ila_gtp_probe1          : std_logic_vector(15 downto 0);
signal ila_gtp_probe2          : std_logic_vector(15 downto 0);


signal ila_fpga_probe0 : std_logic_vector(31 downto 0); 
signal ila_fpga_probe1 : std_logic_vector(31 downto 0); 
signal ila_fpga_probe2 : std_logic_vector(7 downto 0); 
signal ila_fpga_probe3 : std_logic_vector(7 downto 0);
signal ila_fpga_probe4 : std_logic_vector(15 downto 0);
	
signal stretch_a          : std_logic_vector(15 downto 0);

signal spare_in_meta    : std_logic;
signal spare_in_sync    : std_logic;
signal spare_in         : std_logic;


-- ------------------------------------------------------------------------

signal gt0_rxslide_in_p   : std_logic;

signal align_req          : std_logic;
signal man_align_req      : std_logic;
signal align_req_en       : std_logic;
signal gtp_reset          : std_logic;
signal gtp_is_aligned       : std_logic;
signal gtp_realign          : std_logic;
signal gtp_minus_align_en   : std_logic;
signal gtp_plus_align_en    : std_logic;
signal gtp_rx_reset_done    : std_logic;
signal gtp_data_valid_in    : std_logic;
signal gtp_gtrxreset        : std_logic;
signal gtp_rxlpmreset       : std_logic;


signal rx_data_out_src_rdy  : std_logic;
signal rx_data_out_dst_rdy  : std_logic;


signal gtp_rx_data          : std_logic_vector(31 downto 0);
signal gtp_rx_data_src_rdy  : std_logic;
signal gtp_rx_data_dst_rdy  : std_logic;

signal gtp_rx_msg           : std_logic_vector(7 downto 0);
signal gtp_rx_msg_src_rdy   : std_logic;
signal gtp_rx_msg_dst_rdy   : std_logic;

signal gtp_stream           : std_logic_vector(15 downto 0);
signal gtp_char_is_k        : std_logic_vector(1 downto 0);
signal gtp_char_is_comma    : std_logic_vector(1 downto 0);

signal tx_cnt_32bit_a       : std_logic_vector(31 downto 0);
signal tx_cnt_32bit_b       : std_logic_vector(31 downto 0);

signal gtp_rx_data_p1       : std_logic_vector(31 downto 0);
signal gtp_rx_msg_p1        : std_logic_vector(7 downto 0);

signal dummy_cnt            : std_logic_vector(31 downto 0);
signal dummy_cnt_gck        : std_logic_vector(31 downto 0);
signal dummy_cnt_ref_clk    : std_logic_vector(31 downto 0);
signal dummy_cnt_generic    : std_logic_vector(31 downto 0);

signal rx_fsm_reset_done    : std_logic;

signal gtp_soft_reset_rx    : std_logic;
signal gtp_pll_lock         : std_logic;
signal gtp_clk_lost         : std_logic;

signal gtp_ref_clk          : std_logic;
signal rxusrclk             : std_logic;

signal gtp_reset_cnt        : std_logic_vector(7 downto 0);

signal flag, flag_d, flag_dw : std_logic;
signal start        : std_logic;




-- MARK DEBUG
attribute mark_debug : string;
attribute keep : string;
attribute keep of rx_data_match     : signal is "true";
attribute keep of rx_msg_match      : signal is "true";
attribute keep of gtp_reset         : signal is "true";
attribute keep of man_align_req     : signal is "true";
attribute keep of gtp_is_aligned    : signal is "true";
attribute keep of gtp_realign       : signal is "true";
attribute keep of gtp_pll_lock      : signal is "true";
attribute keep of gtp_rx_data       : signal is "true";
attribute keep of gtp_rx_data_p1    : signal is "true";
attribute keep of gtp_rx_msg        : signal is "true";
attribute keep of gtp_rx_msg_p1     : signal is "true";
attribute keep of gtp_stream        : signal is "true";
attribute keep of gtp_char_is_k     : signal is "true";
attribute keep of gtp_char_is_comma : signal is "true";
attribute keep of gtp_data_valid_in : signal is "true";
attribute keep of gtp_gtrxreset     : signal is "true";
attribute keep of gtp_rxlpmreset    : signal is "true";



begin
    --  Static signal Assigments
tied_to_ground     <= '0';
tied_to_ground_vec <= x"0000000000000000";
tied_to_vcc        <= '1';
tied_to_vcc_vec    <= "11111111";



process(clk_100, rst_n)
begin
  if (rst_n = '0') then 
    spare_in_meta <= '0';
    spare_in_sync <= '0';
    spare_in <= '0';
  elsif rising_edge(clk_100) then
    spare_in_meta  <= CCAM_PLL_RESET_o;
    spare_in_sync  <= spare_in_meta;
    spare_in       <= spare_in_sync;
  end if;
end process;


TIME_MACHINE_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>  10.0,  -- Main Clock period
    CLEAR_POLARITY_g        => "LOW",  -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   100,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => false   -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => clk_100,
    CLEAR_i                 => '1',
  
    -- Output reset
    RESET_o                 => open,
    RESET_N_o               => rst_n,
    PON_RESET_OUT_o         => pon_reset,
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

TIME_MACHINE_GCK_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>   6.4, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => false  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    )
  port map(
    -- Clock in port
    CLK_i                   => gckrx,
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


 
    ----------------------------- The GTP -----------------------------

gtp_rx_data_dst_rdy <= '1';
gtp_rx_msg_dst_rdy  <= '1';

    
GTP_RX_Manager_i : GTP_RX_Manager 
  generic map( 
    RX_DATA_OUT_WIDTH_g     => 32,
    GTP_STREAM_WIDTH_g      => 16
      
    )
  port map(
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          => gtp_pll_lock,
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   => clk_100,
    RST_N_i                 => rst_n, 
    EN1MS_i                 => en1ms,
    EN1S_i                  => en1s, 
    
    -- Control in
    GTP_PLL_REFCLKLOST_i    => gtp_clk_lost,
     
    -- Control out
    GTP_SOFT_RESET_RX_o     => gtp_soft_reset_rx,
         
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
    RST_N_GCK_i             => rst_n_gck,
    EN1MS_GCK_i             => en1ms_gck,
    
    -- Controls         
    GTP_IS_ALIGNED_i        => gtp_is_aligned,
    ALIGN_REQ_o             => align_req,

    -- Data in 
    GTP_STREAM_IN_i         => gtp_stream, 
    GTP_CHAR_IS_K_i         => gtp_char_is_k 
    ); 
    

ALIGN_REQ_R_N_o <= align_req_en and (align_req or man_align_req);    
-- ALIGN_REQ_R_N_o <= (gt0_rxbyteisaligned_out and rx_match) and not man_align_req;    
    



-- gtp_plus_align_en  <= vio_gtp_probe_out0(6);
-- gtp_minus_align_en <= vio_gtp_probe_out0(5);

align_req_en       <= '1'; -- vio_gtp_probe_out0(4);
man_align_req      <= '0'; -- vio_gtp_probe_out0(3);

-- gtp_gtrxreset      <= vio_gtp_probe_out0(2);
-- gtp_rxlpmreset     <= vio_gtp_probe_out0(1);


-- CCAM_PLL_RESET_o   <= vio_gtp_probe_out0(0);



GTP_Zynq_i : GTP_Zynq
port map
(
    SOFT_RESET_RX_IN                    =>      spare_in, -- '0', -- gtp_reset, -- '0', -- gtp_soft_reset_rx,
    DONT_RESET_ON_DATA_ERROR_IN         =>      '0',
    Q0_CLK1_GTREFCLK_PAD_N_IN           =>      REFCLK1_RX_N_i,
    Q0_CLK1_GTREFCLK_PAD_P_IN           =>      REFCLK1_RX_P_i,

    GT0_TX_FSM_RESET_DONE_OUT           =>      open,
    GT0_RX_FSM_RESET_DONE_OUT           =>      rx_fsm_reset_done,
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
        gt0_rxdata_out                  =>      gtp_stream, --gt0_rxdata_out,
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
        gt0_rxchariscomma_out           =>      gtp_char_is_comma,
        gt0_rxcharisk_out               =>      gtp_char_is_k, 
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
        gt0_rxoutclkfabric_out          =>      gtp_ref_clk,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      '0', -- , -- gtp_gtrxreset,
        gt0_rxlpmreset_in               =>      '0', -- gtp_rxlpmreset,
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out             =>      gtp_rx_reset_done,
    --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      '0',

GT0_PLL0PD_IN => '0',
    --____________________________COMMON PORTS________________________________
        GT0_PLL0RESET_OUT               =>      open,
        GT0_PLL0OUTCLK_OUT              =>      open,
        GT0_PLL0OUTREFCLK_OUT           =>      open,
        GT0_PLL0LOCK_OUT                =>      gtp_pll_lock,
        GT0_PLL0REFCLKLOST_OUT          =>      gtp_clk_lost,    
        GT0_PLL1OUTCLK_OUT              =>      open,
        GT0_PLL1OUTREFCLK_OUT           =>      open,
        sysclk_in                       =>      clk_100
);
 


PS_i : PS
  port map(
    FCLK_CLK0_0         => clk_100, -- : out STD_LOGIC;
    FIXED_IO_0_mio      => FIXED_IO_0_mio     , -- : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk   => FIXED_IO_0_ps_clk  , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_porb  => FIXED_IO_0_ps_porb , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb => FIXED_IO_0_ps_srstb -- : inout STD_LOGIC
  );


-- ila_gtp_probe0 <= gtp_stream;
-- ila_gtp_probe1 <= x"0000";
-- ila_gtp_probe2 <= "0000" & "0000" & "00" & gtp_realign & gtp_is_aligned & gtp_char_is_comma & gtp_char_is_k;
-- -- ila_gtp_probe2 <= dummy_cnt_gck(15 downto 0);
-- 
-- 
-- ILA_GTP : ila_0
-- PORT MAP (
-- 	clk    => gckrx,
-- 	probe0 => ila_gtp_probe0,
-- 	probe1 => ila_gtp_probe1,
-- 	probe2 => ila_gtp_probe2	
-- );
-- 
-- ila_fpga_probe0 <= gtp_rx_data;
-- ila_fpga_probe1 <= gtp_rx_data_p1;
-- ila_fpga_probe2 <= gtp_rx_msg;
-- ila_fpga_probe3 <= gtp_rx_msg_p1;
-- ila_fpga_probe4 <= "0000000000000" & align_req & rx_msg_match & rx_data_match;
-- -- ila_fpga_probe4 <= dummy_cnt(15 downto 0);
-- 
-- 
-- ILA_FPGA : ila_1
-- PORT MAP (
-- 	clk    => clk_100,
-- 	probe0 => ila_fpga_probe0,
-- 	probe1 => ila_fpga_probe1,
-- 	probe2 => ila_fpga_probe2,
-- 	probe3 => ila_fpga_probe3,
-- 	probe4 => ila_fpga_probe4
-- );
-- 
-- 
-- 
-- 
-- vio_gtp_probe_in0 <= "00000000000000" & gtp_is_aligned & gtp_pll_lock;
-- 
-- VIO_GTP_i : VIO_GTP
--   PORT MAP (
--     clk => gckrx,
--     probe_in0  => vio_gtp_probe_in0,
--     probe_out0 => vio_gtp_probe_out0
--   );
-- 
-- 
-- vio_fpga_probe_in0 <= "00000000000000" & rx_msg_match & rx_data_match;
-- 
-- 
-- VIO_FPGA_i : VIO_FPGA
--   PORT MAP (
--     clk => clk_100,
--     probe_in0  => vio_fpga_probe_in0,
--     probe_out0 => vio_fpga_probe_out0
--   );
-- 

-- ----------------------------------------------------
-- Stretch

process (gckrx)
begin
  if rising_edge(gckrx) then
    if (gtp_is_aligned = '1') then
      stretch_a <= x"FFFF";
    else
      if (en10ms = '1') then 
        stretch_a <= stretch_a(14 downto 0) & '0'; 
      end if;
    end if;
  end if;
end process;


-- ----------------------------------------------------
-- Stream verification

process (clk_100)
begin
  if rising_edge(clk_100) then
  
    if (gtp_rx_data_src_rdy = '1' and gtp_rx_data_dst_rdy = '1') then
      gtp_rx_data_p1 <= gtp_rx_data + 1;
      if (gtp_rx_data_p1 = gtp_rx_data) then
         rx_data_match <= '1';
      else
         rx_data_match <= '0';
      end if; 
    end if;    
  end if; 
end process;


process (clk_100)
begin
  if rising_edge(clk_100) then
  
    if (gtp_rx_msg_src_rdy = '1' and gtp_rx_msg_dst_rdy = '1') then
      gtp_rx_msg_p1 <= gtp_rx_msg + 1;
      if (gtp_rx_msg_p1 = gtp_rx_msg) then
         rx_msg_match <= '1';
      else
         rx_msg_match <= '0';
      end if; 
    end if;    
  end if; 
end process;


-- ------------------------------------------------------------
-- AD9517

spi_init <= '0'; -- vio_fpga_probe_out0(1);


AD9517_Manager_i : AD9517_Manager
  generic map(
    slaves    => SPI_SLAVES_TOTNUM_c, -- : integer := 1;  --number of spi slaves
    cmd_width => SPI_CMD_WIDTH_c, -- : integer := 8;  --command bus width
    d_width   => SPI_D_WIDTH_c  -- : integer := 8); --data bus width
    )
  port map(
    -- Main control
    CLK_i     => clk_100,               
    EN1MS_i   => en1ms,             
    RST_N_i   => pon_reset_n,             
    
    -- Controland status ports
    INIT_i    => spi_init,
    ERROR_o   => spi_error,
    DONE_o    => spi_done,
    
    -- SPI Master side
    CPOL_o    => spi_cpol,      -- spi clock polarity
    CPHA_o    => spi_cpha,      -- spi clock phase
    W_nR_o    => spi_w_nr,      -- '0' for read, '1' for write
    TX_CMD_o  => spi_tx_cmd,    -- command to transmit
    TX_DATA_o => spi_tx_data,   -- data to transmit
    ENABLE_o  => spi_enable,    -- initiate transaction    
    BUSY_i    => spi_busy,      -- busy / data ready signal
    RX_DATA_i => spi_rx_data    -- data received
    );


SPI_MASTER_i : spi_3_wire_master
  generic map(
    slaves    => SPI_SLAVES_TOTNUM_c, -- : integer := 1;  --number of spi slaves
    cmd_width => SPI_CMD_WIDTH_c, -- : integer := 8;  --command bus width
    d_width   => SPI_D_WIDTH_c  -- : integer := 8); --data bus width
    )
  port map(
    clock     => clk_100,    -- : in     std_logic;                              --system clock
    reset_n   => pon_reset_n,          -- : in     std_logic;                              --asynchronous reset
    enable    => spi_enable,               -- : in     std_logic;                              --initiate transaction
    cpol      => spi_cpol,                 -- : in     std_logic;                              --spi clock polarity
    cpha      => spi_cpha,                 -- : in     std_logic;                              --spi clock phase
    clk_div   => SPI_CLK_DIV_c,        -- : in     integer;                                --system clock cycles per 1/2 period of sclk
    addr      => SPI_DEVICE_SEL_c,     -- : in     integer;                                --address of slave
    rw        => spi_w_nr,                 -- : in     std_logic;                              --'0' for read, '1' for write
    tx_cmd    => spi_tx_cmd,               -- : in     std_logic_vector(cmd_width-1 downto 0); --command to transmit
    tx_data   => spi_tx_data,              -- : in     std_logic_vector(d_width-1 downto 0);   --data to transmit
    sclk      => spi_sclk,                 -- : buffer std_logic;                              --spi clock
    ss_n      => spi_ss_n,                 -- : buffer std_logic_vector(slaves-1 downto 0);    --slave select
    sdio      => spi_sdio,                 -- : inout  std_logic;                              --serial data input output
    busy      => spi_busy,                 -- : out    std_logic;                              --busy / data ready signal
    rx_data   => spi_rx_data               -- : out    std_logic_vector(d_width-1 downto 0));  --data received
    );



ad9517_pd_n    <= '1';
ad9517_sync_n  <= '1';
ad9517_reset_n <= '1';

-- --------------------------------------------------------------------------
-- OUTPUTS

AD9517_PD_N_o    <= '1'; -- not vio_fpga_probe_out0(0); -- ad9517_pd_n; --     -- : out STD_LOGIC;
AD9517_SYNC_N_o  <= ad9517_sync_n;   -- : out STD_LOGIC;
AD9517_RESET_N_o <= ad9517_reset_n;  -- : out STD_LOGIC;
AD9517_SDIO_io   <= spi_sdio;-- : inout STD_LOGIC;
AD9517_SCLK_o    <= spi_sclk;-- : out STD_LOGIC;
-- AD9517_SDO      -- : in STD_LOGIC;
AD9517_CS_N_o    <= spi_ss_n(0);-- : out STD_LOGIC);

EN_GTP_OSC_o     <= pon_reset_n;

-- gtp_ref_clk

process(rxusrclk)
begin
  if rising_edge(rxusrclk) then
    dummy_cnt_generic <= dummy_cnt_generic + 1;
  end if;	
end process;

process(gtp_ref_clk)
begin
  if rising_edge(gtp_ref_clk) then
    dummy_cnt_ref_clk <= dummy_cnt_ref_clk + 1;
  end if;	
end process;

process(gckrx)
begin
  if rising_edge(gckrx) then
    dummy_cnt_gck <= dummy_cnt_gck + 1;
  end if;	
end process;

process(clk_100)
begin
  if rising_edge(clk_100) then
    dummy_cnt <= dummy_cnt + 1;
  end if;	
end process;



process (clk_100, rst_n)
begin
  if (rst_n = '0') then
    flag         <= '0';
    flag_d       <= '0';
    flag_dw      <= '0';
    start        <= '0';
  elsif rising_edge(clk_100) then
    flag    <= '0'; -- vio_fpga_probe_out0(15);
    flag_d  <= flag;
    flag_dw <= not flag and flag_d;
    start   <= flag_dw;
  end if;
end process;

process (clk_100, rst_n)
begin
  if (rst_n = '0') then
    gtp_reset_cnt  <= conv_std_logic_vector(0, gtp_reset_cnt'length);
    gtp_reset      <= '0';
  elsif rising_edge(clk_100) then
    if (start = '1') then
      gtp_reset_cnt <= conv_std_logic_vector(15, gtp_reset_cnt'length);
    elsif (gtp_reset_cnt /= conv_std_logic_vector(0, gtp_reset_cnt'length)) then
      gtp_reset_cnt <= gtp_reset_cnt - 1;
    end if;
    
    gtp_reset <= or_reduce(gtp_reset_cnt);
    
  end if;
end process;

-- process(ALIGN_REQ_R_N_o)
-- begin
--   if rising_edge(ALIGN_REQ_R_N_o) then
--     tx_cnt_32bit_b <= tx_cnt_32bit_b + 1;
--   end if;	
-- end process;



LEDS_o(4) <= not gtp_pll_lock or gtp_clk_lost; -- ; -- align_req; -- spi_error(0);                   -- RED    
LEDS_o(3) <= rx_msg_match and rx_data_match;               -- GREEN  
LEDS_o(2) <= align_req; -- gtp_is_aligned;     -- rx_data_match;         -- BLUE   
LEDS_o(1) <= dummy_cnt_gck(26); -- vio_fpga_probe_out0(0);           -- PHY 1 -- GREEN
LEDS_o(0) <= gtp_rx_reset_done;           -- PHY 2 -- YELLOW

end RTL;


