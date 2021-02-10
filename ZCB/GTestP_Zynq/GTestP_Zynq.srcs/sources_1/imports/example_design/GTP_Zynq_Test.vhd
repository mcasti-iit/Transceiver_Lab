library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

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
    Q0_CLK1_GTREFCLK_PAD_N_IN  : in   std_logic;
    Q0_CLK1_GTREFCLK_PAD_P_IN  : in   std_logic;
    
    RXN_IN                     : in   std_logic;
    RXP_IN                     : in   std_logic;
        
    FIXED_IO_0_mio             : inout std_logic_vector ( 53 downto 0 );         
    FIXED_IO_0_ps_clk          : inout std_logic;                                
    FIXED_IO_0_ps_porb         : inout std_logic;                                
    FIXED_IO_0_ps_srstb        : inout std_logic;                                
    
    
    
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
    gt0_rxcommadet_out                      : out  std_logic;
    gt0_rxmcommaalignen_in                  : in   std_logic;
    gt0_rxpcommaalignen_in                  : in   std_logic;
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
    
    -- Controland status ports
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
  CLK_PERIOD_g           : integer    := 10;   -- Main Clock period
  SIM_TIME_COMPRESSION_g : in boolean := FALSE -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
  );
port (
  -- Clock in port
  CLK_i                  : in  std_logic;   -- Input clock @ 50 MHz,
  RST_N_i                : in  std_logic;   -- Asynchronous active low reset

  -- Output reset
  PON_RESET_OUT_o        : out std_logic;	  -- Power on Reset out (active high)
  PON_RESET_N_OUT_o      : out std_logic;	  -- Power on Reset out (active high)
  
  -- Output ports for generated clock enables
  EN200NS_o              : out std_logic;	  -- Clock enable every 200 ns
  EN1US_o                : out std_logic;	  -- Clock enable every 1 us
  EN10US_o               : out std_logic;	  -- Clock enable every 10 us
  EN100US_o              : out std_logic;	  -- Clock enable every 100 us
  EN1MS_o                 : out std_logic;	-- Clock enable every 1 ms
  EN10MS_o                : out std_logic;	-- Clock enable every 10 ms
  EN100MS_o               : out std_logic;	-- Clock enable every 100 ms
  EN1S_o                  : out std_logic 	-- Clock enable every 1 s
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

PORT (
	clk    : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END COMPONENT  ;

component VIO
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

signal count_0 :  std_logic_vector(31 downto 0);
signal count_1 :  std_logic_vector(31 downto 0);
signal count_2 :  std_logic_vector(31 downto 0);
signal count_3 :  std_logic_vector(31 downto 0);
signal count_4 :  std_logic_vector(31 downto 0);

signal rx_cnt   :  std_logic_vector(15 downto 0);
signal rx_cnt_d :  std_logic_vector(15 downto 0);
signal rx_cnt_m :  std_logic_vector(15 downto 0);
signal rx_err   :  std_logic;
signal rx_match :  std_logic;

-- *****************************************************************************************
signal pon_reset_n   :  std_logic;                             -- Power On Reset

signal cpol             : std_logic;                                          -- spi clock polarity
signal cpha             : std_logic;                                          -- spi clock phase
signal w_nr             : std_logic;                                          -- '0' for read, '1' for write
signal tx_cmd           : std_logic_vector(15 downto 0);                      -- command to transmit
signal tx_data          : std_logic_vector(7 downto 0);                       -- data to transmit
signal enable           : std_logic;                                          -- initiate transaction    
signal busy             : std_logic;                                          -- busy / data ready signal
signal rx_data          : std_logic_vector(7 downto 0);                       -- data received
signal error            : std_logic_vector (2 downto 0);                      -- error code
signal done             : std_logic;                                          -- done

signal sclk             :  std_logic;                                         --spi clock
signal ss_n             :  std_logic_vector(SPI_SLAVES_TOTNUM_c-1 downto 0);  --slave select
signal sdio             :  std_logic;                                         --serial data input output


signal en1ms            : std_logic;
signal en1s             : std_logic;

signal toggle_1s        : std_logic;

signal ad9517_pd_n      :  std_logic;    
signal ad9517_sync_n    :  std_logic;    
signal ad9517_reset_n   :  std_logic; 


-- *****************************************************************************************

signal SOFT_RESET_RX_IN                        : std_logic;
signal DONT_RESET_ON_DATA_ERROR_IN             : std_logic;
 
signal GT0_TX_FSM_RESET_DONE_OUT               : std_logic;
signal GT0_RX_FSM_RESET_DONE_OUT               : std_logic;
signal GT0_DATA_VALID_IN                       : std_logic;
 
signal GT0_RXUSRCLK_OUT                        : std_logic;
signal GT0_RXUSRCLK2_OUT                       : std_logic;
 
--_________________________________________________________________________
--GT0  (X0Y2)
--____________________________CHANNEL PORTS________________________________
---------------------------- Channel - DRP Ports  --------------------------
signal gt0_drpaddr_in                          : std_logic_vector(8 downto 0);
signal gt0_drpdi_in                            : std_logic_vector(15 downto 0);
signal gt0_drpdo_out                           : std_logic_vector(15 downto 0);
signal gt0_drpen_in                            : std_logic;
signal gt0_drprdy_out                          : std_logic;
signal gt0_drpwe_in                            : std_logic;
--------------------- RX Initialization and Reset Ports --------------------
signal gt0_eyescanreset_in                     : std_logic;
signal gt0_rxuserrdy_in                        : std_logic;
-------------------------- RX Margin Analysis Ports ------------------------
signal gt0_eyescandataerror_out                : std_logic;
signal gt0_eyescantrigger_in                   : std_logic;
------------------ Receive Ports - FPGA RX Interface Ports -----------------
signal gt0_rxdata_out                          : std_logic_vector(15 downto 0);
------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
signal gt0_rxchariscomma_out                   : std_logic_vector(1 downto 0);
signal gt0_rxcharisk_out                       : std_logic_vector(1 downto 0);
signal gt0_rxdisperr_out                       : std_logic_vector(1 downto 0);
signal gt0_rxnotintable_out                    : std_logic_vector(1 downto 0);
------------------------ Receive Ports - RX AFE Ports ----------------------
signal gt0_gtprxn_in                           : std_logic;
signal gt0_gtprxp_in                           : std_logic;
-------------- Receive Ports - RX Byte and Word Alignment Ports ------------
signal gt0_rxslide_in                          : std_logic;
signal gt0_rxbyteisaligned_out                 : std_logic;
signal gt0_rxbyterealign_out                   : std_logic;
signal gt0_rxcommadet_out                      : std_logic;
signal gt0_rxmcommaalignen_in                  : std_logic;
signal gt0_rxpcommaalignen_in                  : std_logic;
------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
signal gt0_dmonitorout_out                     : std_logic_vector(14 downto 0);
-------------------- Receive Ports - RX Equailizer Ports -------------------
signal gt0_rxlpmhfhold_in                      : std_logic;
signal gt0_rxlpmlfhold_in                      : std_logic;
--------------- Receive Ports - RX Fabric Output Control Ports -------------
signal gt0_rxoutclkfabric_out                  : std_logic;
------------- Receive Ports - RX Initialization and Reset Ports ------------
signal gt0_gtrxreset_in                        : std_logic;
signal gt0_rxlpmreset_in                       : std_logic;
-------------- Receive Ports -RX Initialization and Reset Ports ------------
signal gt0_rxresetdone_out                     : std_logic;
--------------------- TX Initialization and Reset Ports --------------------
signal gt0_gttxreset_in                        : std_logic;
 
--____________________________COMMON PORTS________________________________
signal GT0_PLL0RESET_OUT                       : std_logic;
signal GT0_PLL0OUTCLK_OUT                      : std_logic;
signal GT0_PLL0OUTREFCLK_OUT                   : std_logic;
signal GT0_PLL0LOCK_OUT                        : std_logic;
signal GT0_PLL0REFCLKLOST_OUT                  : std_logic;    
signal GT0_PLL1OUTCLK_OUT                      : std_logic;
signal GT0_PLL1OUTREFCLK_OUT                   : std_logic;
 
signal sysclk                                  : std_logic;


-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- VIO
signal probe_in0          : std_logic_vector(15 downto 0);
signal probe_out0         : std_logic_vector(15 downto 0);

-- ILA
signal probe2             : std_logic_vector(15 downto 0);

-- ------------------------------------------------------------------------

signal gt0_rxslide_in_p   : std_logic;

--**************************** Main Body of Code *******************************
begin

    --  Static signal Assigments
tied_to_ground     <= '0';
tied_to_ground_vec <= x"0000000000000000";
tied_to_vcc        <= '1';
tied_to_vcc_vec    <= "11111111";



 
    ----------------------------- The GTP -----------------------------

gt0_drpaddr_in       <= (others => '0');
gt0_drpdi_in         <= (others => '0');
gt0_drpen_in         <= '0';
gt0_drpwe_in         <= '0';

gt0_eyescanreset_in  <= '0';
gt0_rxuserrdy_in     <= '1';


process(GT0_RXUSRCLK2_OUT)
begin
  if rising_edge(GT0_RXUSRCLK2_OUT) then
    gt0_rxslide_in_p       <= probe_out0(0);
    gt0_rxslide_in         <= probe_out0(0) and not gt0_rxslide_in_p;
  end if;	
end process;

gt0_rxmcommaalignen_in  <= probe_out0(1);
gt0_rxpcommaalignen_in  <= probe_out0(2);


gt0_rxlpmhfhold_in   <= '0';
gt0_rxlpmlfhold_in   <= '0';

gt0_gtrxreset_in     <= '0'; 
gt0_rxlpmreset_in    <= '0';
    
gt0_gttxreset_in     <= '0';





GTP_Zynq_i : GTP_Zynq
port map
(
    SOFT_RESET_RX_IN                    =>      SOFT_RESET_RX_IN,
    DONT_RESET_ON_DATA_ERROR_IN         =>      '0',
    Q0_CLK1_GTREFCLK_PAD_N_IN           =>      Q0_CLK1_GTREFCLK_PAD_N_IN,
    Q0_CLK1_GTREFCLK_PAD_P_IN           =>      Q0_CLK1_GTREFCLK_PAD_P_IN,

    GT0_TX_FSM_RESET_DONE_OUT           =>      GT0_TX_FSM_RESET_DONE_OUT,
    GT0_RX_FSM_RESET_DONE_OUT           =>      GT0_RX_FSM_RESET_DONE_OUT,
    GT0_DATA_VALID_IN                   =>      GT0_DATA_VALID_IN,

    GT0_RXUSRCLK_OUT                    =>      GT0_RXUSRCLK_OUT,
    GT0_RXUSRCLK2_OUT                   =>      GT0_RXUSRCLK2_OUT,

    --_________________________________________________________________________
    --GT0  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      gt0_drpaddr_in,
        gt0_drpdi_in                    =>      gt0_drpdi_in,
        gt0_drpdo_out                   =>      gt0_drpdo_out,
        gt0_drpen_in                    =>      gt0_drpen_in,
        gt0_drprdy_out                  =>      gt0_drprdy_out,
        gt0_drpwe_in                    =>      gt0_drpwe_in,
    --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      gt0_eyescanreset_in,
        gt0_rxuserrdy_in                =>      gt0_rxuserrdy_in,
    -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out        =>      gt0_eyescandataerror_out,
        gt0_eyescantrigger_in           =>      gt0_eyescantrigger_in,
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        gt0_rxdata_out                  =>      gt0_rxdata_out,
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
--        gt0_rxchariscomma_out           =>      gt0_rxchariscomma_out,
        gt0_rxcharisk_out               =>      gt0_rxcharisk_out,
        gt0_rxdisperr_out               =>      gt0_rxdisperr_out,
        gt0_rxnotintable_out            =>      gt0_rxnotintable_out,
    ------------------------ Receive Ports - RX AFE Ports ----------------------
        gt0_gtprxn_in                   =>      RXN_IN,
        gt0_gtprxp_in                   =>      RXP_IN,
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
        gt0_rxbyteisaligned_out         =>      gt0_rxbyteisaligned_out,
        gt0_rxbyterealign_out           =>      gt0_rxbyterealign_out,
        gt0_rxcommadet_out              =>      gt0_rxcommadet_out,
--        gt0_rxslide_in                  =>      gt0_rxslide_in,        
        gt0_rxmcommaalignen_in          =>      gt0_rxmcommaalignen_in,
        gt0_rxpcommaalignen_in          =>      gt0_rxpcommaalignen_in,
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        gt0_dmonitorout_out             =>      gt0_dmonitorout_out,
    -------------------- Receive Ports - RX Equailizer Ports -------------------
        gt0_rxlpmhfhold_in              =>      gt0_rxlpmhfhold_in,
        gt0_rxlpmlfhold_in              =>      gt0_rxlpmlfhold_in,
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
        gt0_rxoutclkfabric_out          =>      gt0_rxoutclkfabric_out,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      gt0_gtrxreset_in,
        gt0_rxlpmreset_in               =>      gt0_rxlpmreset_in,
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out             =>      gt0_rxresetdone_out,
    --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      gt0_gttxreset_in,

    --____________________________COMMON PORTS________________________________
        GT0_PLL0RESET_OUT               =>      GT0_PLL0RESET_OUT,
        GT0_PLL0OUTCLK_OUT              =>      GT0_PLL0OUTCLK_OUT,
        GT0_PLL0OUTREFCLK_OUT           =>      GT0_PLL0OUTREFCLK_OUT,
        GT0_PLL0LOCK_OUT                =>      GT0_PLL0LOCK_OUT,
        GT0_PLL0REFCLKLOST_OUT          =>      GT0_PLL0REFCLKLOST_OUT,    
        GT0_PLL1OUTCLK_OUT              =>      GT0_PLL1OUTCLK_OUT,
        GT0_PLL1OUTREFCLK_OUT           =>      GT0_PLL1OUTREFCLK_OUT,
        sysclk_in                       =>      sysclk
);
    


PS_i : PS
  port map(
    FCLK_CLK0_0         => sysclk, -- : out STD_LOGIC;
    FIXED_IO_0_mio      => FIXED_IO_0_mio     , -- : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk   => FIXED_IO_0_ps_clk  , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_porb  => FIXED_IO_0_ps_porb , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb => FIXED_IO_0_ps_srstb -- : inout STD_LOGIC
  );


probe2 <= "000" & gt0_rxchariscomma_out & gt0_rxcharisk_out & gt0_rxdisperr_out & gt0_rxnotintable_out & '0' & gt0_rxbyterealign_out & gt0_rxcommadet_out & gt0_rxbyteisaligned_out & rx_match;


ILA_0_i : ila_0
PORT MAP (
	clk    => GT0_RXUSRCLK2_OUT,
	probe0 => gt0_rxdata_out,
	probe1 => rx_cnt_m,
	probe2 => probe2	
);


--probe_in0 <= "0000000000000" & GT0_PLL0LOCK_OUT & rx_match & gt0_rxbyteisaligned_out;
probe_in0 <= "00" & GT0_PLL0LOCK_OUT & gt0_rxchariscomma_out & gt0_rxcharisk_out & gt0_rxdisperr_out & gt0_rxnotintable_out & '0' & gt0_rxbyterealign_out & gt0_rxcommadet_out & gt0_rxbyteisaligned_out & rx_match;
VIO_i : VIO
  PORT MAP (
    clk => GT0_RXUSRCLK2_OUT,
    probe_in0  => probe_in0,
    probe_out0 => probe_out0
  );


process (sysclk)
begin
   if rising_edge(sysclk) then
      count_4 <= count_4 + 1;
   end if;
end process;

process (GT0_RXUSRCLK2_OUT)
begin
   if rising_edge(GT0_RXUSRCLK2_OUT) then
      count_3 <= count_3 + 1;
   end if;
end process;

process (GT0_RXUSRCLK2_OUT)
begin
   if rising_edge(GT0_RXUSRCLK2_OUT) then
      count_2 <= count_2 + 1;
   end if;
end process;

process (sysclk)
begin
   if rising_edge(sysclk) then
      count_1 <= count_1 + 1;
   end if;
end process;

process (sysclk)
begin
   if rising_edge(sysclk) then
      count_0 <= count_0 + 1;
   end if;
end process;


rx_cnt_m <= rx_cnt_d + 1;

process (GT0_RXUSRCLK2_OUT)
begin
   if rising_edge(GT0_RXUSRCLK2_OUT) then
      rx_cnt_d <= gt0_rxdata_out;
   end if; 
   if (rx_cnt_m = gt0_rxdata_out) then
      rx_match <= '1';
   else
      rx_match <= '0';
   end if; 
end process;




-- ------------------------------------------------------------
-- AD9517

  TIME_MACHINE_i : time_machine
generic map( 
  CLK_PERIOD_g           => 10,   -- Main Clock period
  SIM_TIME_COMPRESSION_g => false  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
  )
port map(
  -- Clock in port
  CLK_i                  => GT0_RXUSRCLK2_OUT,
  RST_N_i                => '1',

  -- Output reset
  PON_RESET_OUT_o        => open,
  PON_RESET_N_OUT_o      => pon_reset_n,
  
  -- Output ports for generated clock enables
  EN200NS_o              => open,
  EN1US_o                => open,
  EN10US_o               => open,
  EN100US_o              => open,
  EN1MS_o                => open,
  EN10MS_o               => en1ms,
  EN100MS_o              => open,
  EN1S_o                 => en1s
  );



AD9517_Manager_i : AD9517_Manager
  generic map(
    slaves    => SPI_SLAVES_TOTNUM_c, -- : integer := 1;  --number of spi slaves
    cmd_width => SPI_CMD_WIDTH_c, -- : integer := 8;  --command bus width
    d_width   => SPI_D_WIDTH_c  -- : integer := 8); --data bus width
    )
  port map(
    -- Main control
    CLK_i     => GT0_RXUSRCLK2_OUT,               
    EN1MS_i   => en1ms,             
    RST_N_i   => pon_reset_n,             
    
    -- Controland status ports
    ERROR_o   => error,
    DONE_o    => done,
    
    -- SPI Master side
    CPOL_o    => cpol,      -- spi clock polarity
    CPHA_o    => cpha,      -- spi clock phase
    W_nR_o    => w_nr,      -- '0' for read, '1' for write
    TX_CMD_o  => tx_cmd,    -- command to transmit
    TX_DATA_o => tx_data,   -- data to transmit
    ENABLE_o  => enable,    -- initiate transaction    
    BUSY_i    => busy,      -- busy / data ready signal
    RX_DATA_i => rx_data    -- data received
    );


SPI_MASTER_i : spi_3_wire_master
  generic map(
    slaves    => SPI_SLAVES_TOTNUM_c, -- : integer := 1;  --number of spi slaves
    cmd_width => SPI_CMD_WIDTH_c, -- : integer := 8;  --command bus width
    d_width   => SPI_D_WIDTH_c  -- : integer := 8); --data bus width
    )
  port map(
    clock     => GT0_RXUSRCLK2_OUT,    -- : in     std_logic;                              --system clock
    reset_n   => pon_reset_n,          -- : in     std_logic;                              --asynchronous reset
    enable    => enable,               -- : in     std_logic;                              --initiate transaction
    cpol      => cpol,                 -- : in     std_logic;                              --spi clock polarity
    cpha      => cpha,                 -- : in     std_logic;                              --spi clock phase
    clk_div   => SPI_CLK_DIV_c,        -- : in     integer;                                --system clock cycles per 1/2 period of sclk
    addr      => SPI_DEVICE_SEL_c,     -- : in     integer;                                --address of slave
    rw        => w_nr,                 -- : in     std_logic;                              --'0' for read, '1' for write
    tx_cmd    => tx_cmd,               -- : in     std_logic_vector(cmd_width-1 downto 0); --command to transmit
    tx_data   => tx_data,              -- : in     std_logic_vector(d_width-1 downto 0);   --data to transmit
    sclk      => sclk,                 -- : buffer std_logic;                              --spi clock
    ss_n      => ss_n,                 -- : buffer std_logic_vector(slaves-1 downto 0);    --slave select
    sdio      => sdio,                 -- : inout  std_logic;                              --serial data input output
    busy      => busy,                 -- : out    std_logic;                              --busy / data ready signal
    rx_data   => rx_data               -- : out    std_logic_vector(d_width-1 downto 0));  --data received
    );

ad9517_pd_n    <= '1';
ad9517_sync_n  <= '1';
ad9517_reset_n <= '1';

process (GT0_RXUSRCLK2_OUT, pon_reset_n)
begin
  if (pon_reset_n = '0') then
    toggle_1s <= '0';
  elsif rising_edge(GT0_RXUSRCLK2_OUT) then
    if (en1s = '1') then
      toggle_1s <= not toggle_1s;
    end if;
  end if;
end process;

-- --------------------------------------------------------------------------
-- OUTPUTS

AD9517_PD_N_o    <= ad9517_pd_n;     -- : out STD_LOGIC;
AD9517_SYNC_N_o  <= ad9517_sync_n;   -- : out STD_LOGIC;
AD9517_RESET_N_o <= ad9517_reset_n;  -- : out STD_LOGIC;
AD9517_SDIO_io   <= sdio;-- : inout STD_LOGIC;
AD9517_SCLK_o    <= sclk;-- : out STD_LOGIC;
-- AD9517_SDO      -- : in STD_LOGIC;
AD9517_CS_N_o    <= ss_n(0);-- : out STD_LOGIC);

EN_GTP_OSC_o     <= pon_reset_n;


LEDS_o(4) <= error(0);  -- RED    
LEDS_o(3) <= toggle_1s; -- GREEN  
LEDS_o(2) <= rx_match;  -- BLUE   
LEDS_o(1) <= '0';       -- PHY 1
LEDS_o(0) <= '0';       -- PHY 2

end RTL;


