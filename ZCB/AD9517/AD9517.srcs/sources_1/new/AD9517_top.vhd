----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.09.2020 18:00:48
-- Design Name: 
-- Module Name: AD9517_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity AD9517_top is
    Port ( CLK_125        : in STD_LOGIC;
           GTREFCLK0P     : in std_logic;
           GTREFCLK0N     : in std_logic;
           GTREFCLK1P     : in std_logic;
           GTREFCLK1N     : in std_logic;
           
           AD9517_REFMON  : in STD_LOGIC;
           AD9517_STATUS  : in STD_LOGIC;
           AD9517_PD_N    : out STD_LOGIC;
           AD9517_SYNC_N  : out STD_LOGIC;
           AD9517_RESET_N : out STD_LOGIC;
           AD9517_SDIO    : inout STD_LOGIC;
           AD9517_SCLK    : out STD_LOGIC;
           AD9517_SDO     : in STD_LOGIC;
           AD9517_CS_N    : out STD_LOGIC;
           
           EN_GTP_OSC     : out STD_LOGIC;

          FIXED_IO_0_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
          FIXED_IO_0_ps_clk   : inout STD_LOGIC;
          FIXED_IO_0_ps_porb  : inout STD_LOGIC;
          FIXED_IO_0_ps_srstb : inout STD_LOGIC;
           
           LEDS           : out std_logic_vector(4 downto 0)
           );
end AD9517_top;

architecture Behavioral of AD9517_top is



component PS is
  port (
    FCLK_CLK0_0 : out STD_LOGIC;
    FIXED_IO_0_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk : inout STD_LOGIC;
    FIXED_IO_0_ps_porb : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb : inout STD_LOGIC
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

component vio_spi
  port (
    clk         : in std_logic;
    probe_in0   : in std_logic_vector(15 downto 0);
    probe_out0  : out std_logic_vector(31 downto 0)
  );
end component;

signal clk_ps         : std_logic;


signal probe_in0   : std_logic_vector(15 downto 0);
signal probe_out0  : std_logic_vector(31 downto 0);


constant C_SLAVES     : integer :=  1; --number of spi slaves
constant C_CMD_WIDTH  : integer := 16; --command bus width
constant C_D_WIDTH    : integer :=  8; --data bus width

constant clk_div      : integer := 64; --system clock cycles per 1/2 period of sclk
constant addr         : integer :=  0; --address of slave

signal reset   :  std_logic;                              --asynchronous reset
signal reset_n :  std_logic;                              --asynchronous reset

signal pon_reset_n :  std_logic;                             -- Power On Reset

-- signal clk_div :  integer;                                --system clock cycles per 1/2 period of sclk
-- signal addr    :  integer;                                --address of slave
  signal r_nw      :  std_logic;                              
  signal w         :  std_logic_vector(1 downto 0);  --command to transmit
  signal a         :  std_logic_vector(12 downto 0); --command to transmit

signal ad9517_pd     :  std_logic;    
signal ad9517_sync   :  std_logic;    
signal ad9517_reset  :  std_logic;    

signal sclk    :  std_logic;                              --spi clock
signal ss_n    :  std_logic_vector(C_SLAVES-1 downto 0);    --slave select
signal sdio    :  std_logic;                              --serial data input output

signal clk_100 :  std_logic;                              --main clock

signal gtrefclk0   :  std_logic;
signal gtrefclk1   :  std_logic;
signal refclk0_i   :  std_logic;
signal refclk1_i   :  std_logic;


signal count :  std_logic_vector(31 downto 0);  --data received

-- signal leds    :  std_logic_vector(4 downto 0);

signal cpol             : std_logic;                         -- spi clock polarity
signal cpha             : std_logic;                         -- spi clock phase
signal w_nr             : std_logic;                         -- '0' for read, '1' for write
signal tx_cmd           : std_logic_vector(15 downto 0);     -- command to transmit
signal tx_data          : std_logic_vector(7 downto 0);      -- data to transmit
signal enable           : std_logic;                         -- initiate transaction    
signal busy             : std_logic;                         -- busy / data ready signal
signal rx_data          : std_logic_vector(7 downto 0);      -- data received
signal error            : std_logic_vector (2 downto 0);     -- error code
signal done             : std_logic;                         -- done

signal en1ms            : std_logic;
signal en1s             : std_logic;

signal toggle_1s        : std_logic;


attribute mark_debug: boolean;

attribute mark_debug of reset   : signal is true;
attribute mark_debug of enable  : signal is true;
attribute mark_debug of cpol    : signal is true;
attribute mark_debug of cpha    : signal is true;
attribute mark_debug of w_nr    : signal is true;
attribute mark_debug of r_nw    : signal is true;
attribute mark_debug of w       : signal is true;
attribute mark_debug of a       : signal is true;
attribute mark_debug of tx_data : signal is true;
attribute mark_debug of ad9517_pd     : signal is true;    
attribute mark_debug of ad9517_sync   : signal is true;    
attribute mark_debug of ad9517_reset  : signal is true; 
-- attribute mark_debug of sclk    : signal is true;
-- attribute mark_debug of ss_n    : signal is true;
-- attribute mark_debug of sdio    : signal is true;
attribute mark_debug of busy    : signal is true;
attribute mark_debug of rx_data : signal is true;

begin


PS_i : PS
  port map(
    FCLK_CLK0_0         => clk_ps, -- : out STD_LOGIC;
    FIXED_IO_0_mio      => FIXED_IO_0_mio     , -- : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_0_ps_clk   => FIXED_IO_0_ps_clk  , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_porb  => FIXED_IO_0_ps_porb , -- : inout STD_LOGIC;
    FIXED_IO_0_ps_srstb => FIXED_IO_0_ps_srstb -- : inout STD_LOGIC
  );


IBUFDS_GTE2_0_i : IBUFDS_GTE2
  port map (
    O       => gtrefclk0,
    ODIV2   => open,
    CEB     => '0',
    I       => GTREFCLK0P,
    IB      => GTREFCLK0N
  );

IBUFDS_GTE2_1_i : IBUFDS_GTE2
  port map (
    O       => gtrefclk1,
    ODIV2   => open,
    CEB     => '0',
    I       => GTREFCLK1P,
    IB      => GTREFCLK1N
  );
  
  VIO_SPI_i : vio_spi
  port map(
    clk         => clk_ps,    -- : in std_logic;
    probe_in0   => probe_in0, -- : in std_logic_vector(15 downto 0);
    probe_out0  => probe_out0 -- : out std_logic_vector(31 downto 0)
  );
   
probe_in0(8) <= busy;    
probe_in0(7 downto 0) <= rx_data; 

reset   <= probe_out0(0);
reset_n <= not reset;
  
  
  TIME_MACHINE_i : time_machine
generic map( 
  CLK_PERIOD_g           => 10,   -- Main Clock period
  SIM_TIME_COMPRESSION_g => false  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
  )
port map(
  -- Clock in port
  CLK_i                  => clk_ps,
  RST_N_i                => reset_n,

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
    slaves    => C_SLAVES, -- : integer := 1;  --number of spi slaves
    cmd_width => C_CMD_WIDTH, -- : integer := 8;  --command bus width
    d_width   => C_D_WIDTH  -- : integer := 8); --data bus width
    )
  port map(
    -- Main control
    CLK_i     => clk_ps,               
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


-- enable  <= probe_out0(1);
-- cpol    <= probe_out0(2);
-- cpha    <= probe_out0(3);
-- w_nr    <= probe_out0(4);
-- tx_data <= probe_out0(28 downto 21);
-- tx_cmd <= r_nw & w & a;

w       <= probe_out0(19 downto 18);
a       <= probe_out0(17 downto 5);
r_nw    <= not w_nr; -- probe_out0(20);



SPI_MASTER_i : spi_3_wire_master
  generic map(
    slaves    => C_SLAVES, -- : integer := 1;  --number of spi slaves
    cmd_width => C_CMD_WIDTH, -- : integer := 8;  --command bus width
    d_width   => C_D_WIDTH  -- : integer := 8); --data bus width
    )
  port map(
    clock     => clk_ps,    -- : in     std_logic;                              --system clock
    reset_n   => pon_reset_n,   -- : in     std_logic;                              --asynchronous reset
    enable    => enable,    -- : in     std_logic;                              --initiate transaction
    cpol      => cpol,      -- : in     std_logic;                              --spi clock polarity
    cpha      => cpha,      -- : in     std_logic;                              --spi clock phase
    clk_div   => clk_div,   -- : in     integer;                                --system clock cycles per 1/2 period of sclk
    addr      => addr,      -- : in     integer;                                --address of slave
    rw        => w_nr,      -- : in     std_logic;                              --'0' for read, '1' for write
    tx_cmd    => tx_cmd,    -- : in     std_logic_vector(cmd_width-1 downto 0); --command to transmit
    tx_data   => tx_data,   -- : in     std_logic_vector(d_width-1 downto 0);   --data to transmit
    sclk      => sclk,      -- : buffer std_logic;                              --spi clock
    ss_n      => ss_n,      -- : buffer std_logic_vector(slaves-1 downto 0);    --slave select
    sdio      => sdio,      -- : inout  std_logic;                              --serial data input output
    busy      => busy,      -- : out    std_logic;                              --busy / data ready signal
    rx_data   => rx_data    -- : out    std_logic_vector(d_width-1 downto 0));  --data received
    );


probe_in0(9)    <= AD9517_REFMON;   -- : in STD_LOGIC;
probe_in0(10)   <= AD9517_STATUS;   -- : in STD_LOGIC;
AD9517_PD_N     <= not ad9517_pd    ;-- : out STD_LOGIC;
AD9517_SYNC_N   <= not ad9517_sync  ;-- : out STD_LOGIC;
AD9517_RESET_N  <= not ad9517_reset ;-- : out STD_LOGIC;
AD9517_SDIO     <= sdio;-- : inout STD_LOGIC;
AD9517_SCLK     <= sclk;-- : out STD_LOGIC;
-- AD9517_SDO      -- : in STD_LOGIC;
AD9517_CS_N     <= ss_n(0);-- : out STD_LOGIC);
           
process (clk_ps, pon_reset_n)
begin
  if (pon_reset_n = '0') then
    toggle_1s <= '0';
  elsif rising_edge(clk_ps) then
    if (en1s = '1') then
      toggle_1s <= not toggle_1s;
    end if;
  end if;
end process;

LEDS(4) <= error(0);  -- RED
LEDS(3) <= toggle_1s; -- GREEN 
LEDS(2) <= done;      -- BLUE
LEDS(1) <= '0';
LEDS(0) <= '0';
-- LEDS <= "01010";

EN_GTP_OSC <= pon_reset_n; -- probe_out0(29);

end Behavioral;
