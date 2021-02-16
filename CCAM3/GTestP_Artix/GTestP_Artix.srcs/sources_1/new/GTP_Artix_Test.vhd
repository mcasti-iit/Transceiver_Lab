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
    ALIGN_REQ_N_i                     : in   std_logic;

    REFCLK0_P_i                       : in   std_logic;
    REFCLK0_N_i                       : in   std_logic;


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
port
 (
  clk_out1          : out    std_logic;
  clk_in1           : in     std_logic
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

component ila_1
port (
	clk    : in std_logic;
	probe0 : in std_logic_vector(15 downto 0);
	probe1 : in std_logic_vector(31 downto 0)
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

component GTP_Data_Handler is
  generic ( 
    TX_DATA_IN_WIDTH_g      : integer range 0 to 64 := 32;    -- Width of TX Data - Fabric side 
    TX_DATA_OUT_WIDTH_g     : integer range 0 to 64 := 16     -- Width of TX Data - GTP side
    );
  port (
    -- Clock in port
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    GCK_i                   : in  std_logic;   -- Input clock - GTP side     
    RST_CLK_N_i             : in  std_logic;   -- Asynchronous active low reset (clk clock)
    RST_GCK_N_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)
    EN1MS_GCK_i             : in  std_logic;   -- Enable @ 1 Khz (gck clock)

    -- Control
    ALIGN_REQ_i             : in   std_logic;
    
    -- Status
    OVERRIDE_GCK_o          : out std_logic;
  
    -- Data in 
    TX_DATA_IN_i            : in  std_logic_vector(TX_DATA_IN_WIDTH_g-1 downto 0);
    TX_DATA_IN_SRC_RDY_i    : in  std_logic;
    TX_DATA_IN_DST_RDY_o    : out std_logic;
    
    -- Data out
    TX_DATA_OUT_o           : out std_logic_vector(TX_DATA_OUT_WIDTH_g-1 downto 0);
    TX_DATA_OUT_SRC_RDY_o   : out std_logic;
    TX_DATA_OUT_DST_RDY_i   : in  std_logic;
    TX_CHAR_IS_K_o          : out std_logic_vector((TX_DATA_OUT_WIDTH_g/8)-1 downto 0)              
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

signal     SOFT_RESET_TX_IN                        : std_logic;
signal     DONT_RESET_ON_DATA_ERROR_IN             : std_logic;
 
signal     GT0_TX_FSM_RESET_DONE_OUT               : std_logic;
signal     GT0_RX_FSM_RESET_DONE_OUT               : std_logic;
signal     GT0_DATA_VALID_IN                       : std_logic;
  
signal     GT0_TXUSRCLK_OUT                        : std_logic;
signal     gck                                     : std_logic;
 
--_________________________________________________________________________
--GT0  (X0Y0)
--____________________________CHANNEL PORTS________________________________
---------------------------- Channel - DRP Ports  --------------------------
signal     gt0_drpaddr_in                          : std_logic_vector(8 downto 0);
signal     gt0_drpdi_in                            : std_logic_vector(15 downto 0);
signal     gt0_drpdo_out                           : std_logic_vector(15 downto 0);
signal     gt0_drpen_in                            : std_logic;
signal     gt0_drprdy_out                          : std_logic;
signal     gt0_drpwe_in                            : std_logic;
--------------------- RX Initialization and Reset Ports --------------------
signal     gt0_eyescanreset_in                     : std_logic;
-------------------------- RX Margin Analysis Ports ------------------------
signal     gt0_eyescandataerror_out                : std_logic;
signal     gt0_eyescantrigger_in                   : std_logic;
------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
signal     gt0_dmonitorout_out                     : std_logic_vector(14 downto 0);
------------- Receive Ports - RX Initialization and Reset Ports ------------
signal     gt0_gtrxreset_in                        : std_logic;
signal     gt0_rxlpmreset_in                       : std_logic;
--------------------- TX Initialization and Reset Ports --------------------
signal     gt0_gttxreset_in                        : std_logic;
signal     gt0_txuserrdy_in                        : std_logic;
------------------ Transmit Ports - FPGA TX Interface Ports ----------------
signal     gt0_txdata_in                           : std_logic_vector(15 downto 0);
------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
signal     gt0_txcharisk_in                        : std_logic_vector(1 downto 0);
--------------- Transmit Ports - TX Configurable Driver Ports --------------
signal     gt0_gtptxn_out                          : std_logic;
signal     gt0_gtptxp_out                          : std_logic;
----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
signal     gt0_txoutclkfabric_out                  : std_logic;
signal     gt0_txoutclkpcs_out                     : std_logic;
------------- Transmit Ports - TX Initialization and Reset Ports -----------
signal     gt0_txresetdone_out                     : std_logic;
 
--____________________________COMMON PORTS________________________________
signal     GT0_PLL0OUTCLK_OUT                      : std_logic;
signal     GT0_PLL0OUTREFCLK_OUT                   : std_logic;
signal     GT0_PLL0LOCK_OUT                        : std_logic;
signal     GT0_PLL0REFCLKLOST_OUT                  : std_logic;    
signal     GT0_PLL1OUTCLK_OUT                      : std_logic;
signal     GT0_PLL1OUTREFCLK_OUT                   : std_logic;




-- -------------------------------------------------------------------------------------

signal     clk_in                                  : std_logic;
signal     clk_100                                 : std_logic;
signal     rst_n                                   : std_logic;
signal     rst_n_gck                               : std_logic;

signal     pon_reset_n                             : std_logic;                             -- Power On Reset
signal     en50ns                                  : std_logic;
signal     en1ms                                   : std_logic;
signal     en1s                                    : std_logic;

signal     tx_cnt_16bit                            : std_logic_vector(15 downto 0);
signal     tx_cnt_32bit                            : std_logic_vector(31 downto 0);
signal     tx_cnt_32bit_gck                        : std_logic_vector(31 downto 0);


-- -------------------------------------------------------------------------------------
signal    probe_in0    : std_logic_vector(15 downto 0);
signal    probe_out0   : std_logic_vector(15 downto 0);
signal    probe_out0_d : std_logic_vector(15 downto 0);

signal    ila0_probe0       : std_logic_vector(15 downto 0);
signal    ila0_probe1       : std_logic_vector(15 downto 0);
-- signal    ila0_probe2       : std_logic_vector(31 downto 0);

signal    ila1_probe0       : std_logic_vector(15 downto 0);
signal    ila1_probe1       : std_logic_vector(31 downto 0);
-- signal    ila1_probe2       : std_logic_vector(31 downto 0);

-- -------------------------------------------------------------------------------------
signal    auto_align          : std_logic;

signal    send_align          : std_logic;
signal    send_k              : std_logic;
signal    charisk             : std_logic_vector(1 downto 0);
signal    en_20ns             : std_logic;




signal    pon_reset_n_gck     : std_logic;                             -- Power On Reset
signal    en1ms_gck           : std_logic;
signal    en1s_gck            : std_logic;


-- ------------------------
signal align_req_n_meta         : std_logic;
signal align_req_n_sync         : std_logic;
signal align_req                : std_logic;


signal tx_data       : std_logic_vector(31 downto 0);
signal tx_data_gtp   : std_logic_vector(15 downto 0);
signal tx_char_is_k  : std_logic_vector(1 downto 0);

--**************************** Main Body of Code *******************************
begin

    --  Static signal Assigments
tied_to_ground                             <= '0';
tied_to_ground_vec                         <= x"0000000000000000";
tied_to_vcc                                <= '1';
tied_to_vcc_vec                            <= "11111111";


-- -----------------------------------------------------------------------------
-- CLOCK 100 MHz

IBUF_CLK : IBUF
  port map(
    I  => CLK_IN_i,
    O  => clk_in
    );

MAIN_CLOCK : clk_wiz_0
  port map ( 
    clk_in1  => clk_in,
    clk_out1 => clk_100    
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


TIME_MACHINE_GCK_i : time_machine
  generic map( 
    CLK_PERIOD_NS_g         =>   6.4, -- Main Clock period
    CLEAR_POLARITY_g        => "LOW", -- Active "HIGH" or "LOW"
    PON_RESET_DURATION_MS_g =>   10,  -- Duration of Power-On reset (ms)
    SIM_TIME_COMPRESSION_g  => false  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
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
    EN100US_o               => open,
    EN1MS_o                 => open,
    EN10MS_o                => open,
    EN100MS_o               => open,
    EN1S_o                  => open
    );


-- --------------------------------------------------------
-- Data Generator

process(clk_100, pon_reset_n)
begin
  if (pon_reset_n = '0') then
    en_20ns <= '0';
    tx_cnt_32bit <= (others => '0');
  elsif rising_edge(clk_100) then
    en_20ns <= not en_20ns;
    if (en_20ns = '1') then
      tx_cnt_32bit <= tx_cnt_32bit + 1;
    end if;
  end if;	
end process;



-- --------------------------------------------------------
-- Align Request

process(gck, pon_reset_n)
begin
  if (pon_reset_n = '0') then 
    align_req_n_meta <= '1';
    align_req_n_sync <= '1';
    align_req <= '0';
  elsif rising_edge(gck) then
    align_req_n_meta  <= ALIGN_REQ_N_i;
    align_req_n_sync  <= align_req_n_meta;
    align_req         <= not align_req_n_sync;
  end if;
end process;



tx_data <= tx_cnt_32bit;

GTP_DATA_HANDLER_i : GTP_Data_Handler 
  generic map( 
    TX_DATA_IN_WIDTH_g      => 32,   
    TX_DATA_OUT_WIDTH_g     => 16   
    )
  port map(
    -- Clock in port
    CLK_i                   => clk_100,
    GCK_i                   => gck,   
    RST_CLK_N_i             => rst_n, 
    RST_GCK_N_i             => rst_n_gck, 
    EN1MS_GCK_i             => '0',

    -- Control
    ALIGN_REQ_i             => align_req,
    
    -- Status
    OVERRIDE_GCK_o          => open,
  
    -- Data in 
    TX_DATA_IN_i            => tx_data, 
    TX_DATA_IN_SRC_RDY_i    => en_20ns,
    TX_DATA_IN_DST_RDY_o    => open,
    
    -- Data out
    TX_DATA_OUT_o           => tx_data_gtp,
    TX_DATA_OUT_SRC_RDY_o   => open,
    TX_DATA_OUT_DST_RDY_i   => '1',
    TX_CHAR_IS_K_o          => tx_char_is_k
    );


-- -----------------------------------------------------------------------------
--VIO

probe_in0 <= "000000000000000" & GT0_PLL0LOCK_OUT;  
VIO_i : vio_0
  PORT MAP (
    clk => gck,
    probe_in0   => probe_in0,
    probe_out0  => probe_out0
  );




-- -----------------------------------------------------------------------------
-- ILAs



ila1_probe0 <= "00000000000000" & en_20ns & rst_n; 
ila1_probe1 <= tx_data;

ILA_1_A_i : ila_1
PORT MAP (
	clk      => clk_100,
	probe0   => ila1_probe0,
	probe1   => ila1_probe1
);



ila0_probe0 <= "000000000000" & tx_char_is_k & align_req & rst_n_gck;
ila0_probe1 <= tx_data_gtp;

ILA_0_i : ila_0
PORT MAP (
	clk      => gck,
	probe0   => ila0_probe0,
	probe1   => ila0_probe1
);
   
GTP_Artix_i : GTP_Artix
  port map
    (
      SOFT_RESET_TX_IN                =>      '0',
      DONT_RESET_ON_DATA_ERROR_IN     =>      '0',
      Q0_CLK0_GTREFCLK_PAD_N_IN       =>      REFCLK0_N_i,
      Q0_CLK0_GTREFCLK_PAD_P_IN       =>      REFCLK0_P_i,
      GT0_TX_FSM_RESET_DONE_OUT       =>      GT0_TX_FSM_RESET_DONE_OUT,
      GT0_RX_FSM_RESET_DONE_OUT       =>      GT0_RX_FSM_RESET_DONE_OUT,
      GT0_DATA_VALID_IN               =>      '0',
 
      GT0_TXUSRCLK_OUT                =>      GT0_TXUSRCLK_OUT,
      GT0_TXUSRCLK2_OUT               =>      gck,

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
      gt0_eyescanreset_in             =>      gt0_eyescanreset_in,
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out        =>      gt0_eyescandataerror_out,
      gt0_eyescantrigger_in           =>      gt0_eyescantrigger_in,
      ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
      gt0_dmonitorout_out             =>      gt0_dmonitorout_out,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in                =>      probe_out0(0),
      gt0_rxlpmreset_in               =>      '0',
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in                =>      '0',
      gt0_txuserrdy_in                =>      '1',
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      gt0_txdata_in                   =>      tx_data_gtp, -- gt0_txdata_in,
      ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
      gt0_txcharisk_in                =>      tx_char_is_k, -- gt0_txcharisk_in,
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      gt0_gtptxn_out                  =>      TXN_o,
      gt0_gtptxp_out                  =>      TXP_o,
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      gt0_txoutclkfabric_out          =>      gt0_txoutclkfabric_out,
      gt0_txoutclkpcs_out             =>      gt0_txoutclkpcs_out,
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      gt0_txresetdone_out             =>      gt0_txresetdone_out,
      --____________________________COMMON PORTS________________________________
      GT0_PLL0OUTCLK_OUT              =>      GT0_PLL0OUTCLK_OUT,
      GT0_PLL0OUTREFCLK_OUT           =>      GT0_PLL0OUTREFCLK_OUT,
      GT0_PLL0LOCK_OUT                =>      GT0_PLL0LOCK_OUT,
      GT0_PLL0REFCLKLOST_OUT          =>      GT0_PLL0REFCLKLOST_OUT,    
      GT0_PLL1OUTCLK_OUT              =>      GT0_PLL1OUTCLK_OUT,
      GT0_PLL1OUTREFCLK_OUT           =>      GT0_PLL1OUTREFCLK_OUT,
      sysclk_in                       =>      clk_100
    );





end RTL;

