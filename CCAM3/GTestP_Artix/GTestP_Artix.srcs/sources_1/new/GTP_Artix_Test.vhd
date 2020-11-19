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
    EXAMPLE_CONFIG_INDEPENDENT_LANES        : integer   := 1;
    EXAMPLE_LANE_WITH_START_CHAR            : integer   := 0;    -- specifies lane with unique start frame ch
    EXAMPLE_WORDS_IN_BRAM                   : integer   := 512;  -- specifies amount of data in BRAM
    EXAMPLE_SIM_GTRESET_SPEEDUP             : string    := "FALSE";    -- simulation setting for GT SecureIP model
    STABLE_CLOCK_PERIOD                     : integer   := 8; 
    EXAMPLE_USE_CHIPSCOPE                   : integer   := 1           -- Set to 1 to use Chipscope to drive resets
);
port
(
Q0_CLK0_GTREFCLK_PAD_N_IN               : in   std_logic;
Q0_CLK0_GTREFCLK_PAD_P_IN               : in   std_logic;
-- DRP_CLK_IN_P                            : in   std_logic;
-- DRP_CLK_IN_N                            : in   std_logic;
   CLK_IN                                  : in   std_logic;
-- GTTX_RESET_IN                           : in   std_logic;
-- GTRX_RESET_IN                           : in   std_logic;
-- PLL0_RESET_IN                           : in   std_logic; 
-- PLL1_RESET_IN                           : in   std_logic;
TXN_OUT                                 : out  std_logic;
TXP_OUT                                 : out  std_logic;

CLK_MON                                 : out  std_logic
);


end GTP_Artix_Test;
    
architecture RTL of GTP_Artix_Test is

--**************************Component Declarations*****************************

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
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
	clk : in std_logic;
	probe0 : in std_logic_vector(31 downto 0);
	probe1 : in std_logic_vector(31 downto 0)
);
end component  ;

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
    gt0_txdata_in                           : in   std_logic_vector(31 downto 0);
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt0_txcharisk_in                        : in   std_logic_vector(3 downto 0);
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
signal     GT0_TXUSRCLK2_OUT                       : std_logic;
 
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
signal     gt0_txdata_in                           : std_logic_vector(31 downto 0);
------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
signal     gt0_txcharisk_in                        : std_logic_vector(3 downto 0);
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

signal     sysclk_in                               : std_logic;
signal     sysclk                                  : std_logic;

signal     tx_cnt                                  : std_logic_vector(31 downto 0);


-- -------------------------------------------------------------------------------------
signal    probe_in0  : std_logic_vector(15 downto 0);
signal    probe_out0 : std_logic_vector(15 downto 0);
signal    probe0     : std_logic_vector(31 downto 0);
signal    probe1     : std_logic_vector(31 downto 0);

-- -------------------------------------------------------------------------------------
signal    gt0_txcharisk_in_p  : std_logic_vector(3 downto 0);
signal    gt0_txcharisk_in_cg : std_logic;

--**************************** Main Body of Code *******************************
begin

    --  Static signal Assigments
tied_to_ground                             <= '0';
tied_to_ground_vec                         <= x"0000000000000000";
tied_to_vcc                                <= '1';
tied_to_vcc_vec                            <= "11111111";

 
    ----------------------------- The GT Wrapper -----------------------------


SOFT_RESET_TX_IN                        <= '0'; -- : std_logic;
DONT_RESET_ON_DATA_ERROR_IN             <= '0'; -- : std_logic;

GT0_DATA_VALID_IN                       <= '1'; -- : std_logic;

gt0_drpaddr_in                          <= (others => '0'); -- : std_logic_vector(8 downto 0);
gt0_drpdi_in                            <= (others => '0'); -- : std_logic_vector(15 downto 0);
gt0_drpen_in                            <= '0'; -- : std_logic;
gt0_drpwe_in                            <= '0'; -- : std_logic;

gt0_eyescanreset_in                     <= '0'; -- : std_logic;
gt0_eyescantrigger_in                   <= '0'; -- : std_logic;

gt0_gtrxreset_in                        <= '0'; -- : std_logic;
gt0_rxlpmreset_in                       <= '0'; -- : std_logic;

gt0_gttxreset_in                        <= '0'; -- : std_logic;
gt0_txuserrdy_in                        <= '1'; -- : std_logic;

gt0_txdata_in                           <= tx_cnt; -- : std_logic_vector(15 downto 0);



GTP_Artix_i : GTP_Artix
  port map
    (
      SOFT_RESET_TX_IN                =>      SOFT_RESET_TX_IN,
      DONT_RESET_ON_DATA_ERROR_IN     =>      DONT_RESET_ON_DATA_ERROR_IN,
      Q0_CLK0_GTREFCLK_PAD_N_IN       =>      Q0_CLK0_GTREFCLK_PAD_N_IN,
      Q0_CLK0_GTREFCLK_PAD_P_IN       =>      Q0_CLK0_GTREFCLK_PAD_P_IN,
      GT0_TX_FSM_RESET_DONE_OUT       =>      GT0_TX_FSM_RESET_DONE_OUT,
      GT0_RX_FSM_RESET_DONE_OUT       =>      GT0_RX_FSM_RESET_DONE_OUT,
      GT0_DATA_VALID_IN               =>      '0',
 
      GT0_TXUSRCLK_OUT                =>      GT0_TXUSRCLK_OUT,
      GT0_TXUSRCLK2_OUT               =>      GT0_TXUSRCLK2_OUT,

      --_____________________________________________________________________
      --_____________________________________________________________________
      --GT0  (X0Y0)

      ---------------------------- Channel - DRP Ports  --------------------------
      gt0_drpaddr_in                  =>      gt0_drpaddr_in,
      gt0_drpdi_in                    =>      gt0_drpdi_in,
      gt0_drpdo_out                   =>      gt0_drpdo_out,
      gt0_drpen_in                    =>      gt0_drpen_in,
      gt0_drprdy_out                  =>      gt0_drprdy_out,
      gt0_drpwe_in                    =>      gt0_drpwe_in,
      --------------------- RX Initialization and Reset Ports --------------------
      gt0_eyescanreset_in             =>      gt0_eyescanreset_in,
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out        =>      gt0_eyescandataerror_out,
      gt0_eyescantrigger_in           =>      gt0_eyescantrigger_in,
      ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
      gt0_dmonitorout_out             =>      gt0_dmonitorout_out,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in                =>      gt0_gtrxreset_in,
      gt0_rxlpmreset_in               =>      gt0_rxlpmreset_in,
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in                =>      gt0_gttxreset_in,
      gt0_txuserrdy_in                =>      gt0_txuserrdy_in,
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      gt0_txdata_in                   =>      gt0_txdata_in,
      ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
      gt0_txcharisk_in                =>      gt0_txcharisk_in,
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      gt0_gtptxn_out                  =>      TXN_OUT,
      gt0_gtptxp_out                  =>      TXP_OUT,
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
      sysclk_in                       =>      sysclk
    );


   IBUF_CLK : IBUF
   port map
     (
        I  => CLK_IN,
        O  => sysclk_in
     );


MAIN_CLOCK : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => sysclk,
   -- Clock in ports
   clk_in1 => sysclk_in
 );
 

process(GT0_TXUSRCLK2_OUT)
begin
  if rising_edge(GT0_TXUSRCLK2_OUT) then
    gt0_txcharisk_in_p  <= probe_out0(3 downto 0);
    
    if (gt0_txcharisk_in_cg = '1') then
      gt0_txcharisk_in <= probe_out0(3 downto 0);
    else
      gt0_txcharisk_in <= (others => '0');
    end if;
  end if;	
end process;

gt0_txcharisk_in_cg <= '0' when (gt0_txcharisk_in_p = probe_out0(3 downto 0)) else '1';

process(GT0_TXUSRCLK2_OUT)
begin
  if rising_edge(GT0_TXUSRCLK2_OUT) then
    if (gt0_txcharisk_in_cg = '1') then
      if (probe_out0(3) = '1') then
        tx_cnt(31 downto 24)  <= x"BC";
      end if;
      if (probe_out0(2) = '1') then
        tx_cnt(23 downto 16) <= x"BC";
      end if;
      if (probe_out0(1) = '1') then
        tx_cnt(15 downto  8) <= x"BC";
      end if;
      if (probe_out0(0) = '1') then
        tx_cnt( 7 downto  0) <= x"BC";
      end if;
    else
      tx_cnt <= tx_cnt + 1;
    end if;
  end if;	
end process;



-- process(GT0_TXUSRCLK2_OUT)
-- begin
--   if rising_edge(GT0_TXUSRCLK2_OUT) then
--     if (probe_out0(0) = '1' and gt0_txcharisk_in_p(0) = '0') then
--       tx_cnt <= x"BCBC0000";
--     else
--       tx_cnt <= tx_cnt + 1;
--     end if;
--   end if;	
-- end process;
-- 
-- process(GT0_TXUSRCLK2_OUT)
-- begin
--   if rising_edge(GT0_TXUSRCLK2_OUT) then
--     gt0_txcharisk_in_p  <= probe_out0(3 downto 0);
--     gt0_txcharisk_in(3) <= probe_out0(0) and not gt0_txcharisk_in_p(0);
--     gt0_txcharisk_in(2) <= probe_out0(0) and not gt0_txcharisk_in_p(0);
--     gt0_txcharisk_in(1) <= '0';
--     gt0_txcharisk_in(0) <= '0';
--   end if;	
-- end process;


probe_in0 <= "000000000000000" & GT0_PLL0LOCK_OUT;





VIO_i : vio_0
  PORT MAP (
    clk => GT0_TXUSRCLK2_OUT,
    probe_in0   => probe_in0,
    probe_out0  => probe_out0
  );


probe0 <= tx_cnt;
probe1 <= "0000000000000000000000000000" & gt0_txcharisk_in;

ILA_0_i : ila_0
PORT MAP (
	clk      => GT0_TXUSRCLK2_OUT,
	probe0   => probe0,
	probe1   => probe1
);

CLK_MON <= sysclk;

end RTL;


