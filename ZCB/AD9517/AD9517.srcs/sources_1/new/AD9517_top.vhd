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
constant C_CLK_DIV    : integer := 32; --command bus width
constant C_ADDR       : integer :=  0; --data bus width
constant clk_div      : integer := 64; --system clock cycles per 1/2 period of sclk
constant addr         : integer :=  0; --address of slave

signal reset   :  std_logic;                              --asynchronous reset
signal reset_n :  std_logic;                              --asynchronous reset
signal enable  :  std_logic;                              --initiate transaction
signal cpol    :  std_logic;                              --spi clock polarity
signal cpha    :  std_logic;                              --spi clock phase
-- signal clk_div :  integer;                                --system clock cycles per 1/2 period of sclk
-- signal addr    :  integer;                                --address of slave
signal w_nr      :  std_logic;                              --'0' for read, '1' for write
signal tx_cmd  :  std_logic_vector(C_CMD_WIDTH-1 downto 0); --command to transmit
  signal r_nw      :  std_logic;                              
  signal w         :  std_logic_vector(1 downto 0);  --command to transmit
  signal a         :  std_logic_vector(12 downto 0); --command to transmit
signal tx_data :  std_logic_vector(C_D_WIDTH-1 downto 0);   --data to transmit

signal ad9517_pd     :  std_logic;    
signal ad9517_sync   :  std_logic;    
signal ad9517_reset  :  std_logic;    

signal sclk    :  std_logic;                              --spi clock
signal ss_n    :  std_logic_vector(C_SLAVES-1 downto 0);    --slave select
signal sdio    :  std_logic;                              --serial data input output
signal busy    :  std_logic;                              --busy / data ready signal
signal rx_data :  std_logic_vector(C_D_WIDTH-1 downto 0);  --data received

signal clk_100 :  std_logic;                              --main clock

signal gtrefclk0   :  std_logic;
signal gtrefclk1   :  std_logic;
signal refclk0_i   :  std_logic;
signal refclk1_i   :  std_logic;


signal count :  std_logic_vector(31 downto 0);  --data received

-- signal leds    :  std_logic_vector(4 downto 0);


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



reset   <= probe_out0(0);
enable  <= probe_out0(1);
cpol    <= probe_out0(2);
cpha    <= probe_out0(3);
w_nr    <= probe_out0(4);
r_nw    <= not w_nr; -- probe_out0(20);
w       <= probe_out0(19 downto 18);
a       <= probe_out0(17 downto 5);
tx_data <= probe_out0(28 downto 21);


VIO_SPI_i : vio_spi
  port map(
    clk         => clk_ps,    -- : in std_logic;
    probe_in0   => probe_in0, -- : in std_logic_vector(15 downto 0);
    probe_out0  => probe_out0 -- : out std_logic_vector(31 downto 0)
  );

   
probe_in0(8) <= busy;    
probe_in0(7 downto 0) <= rx_data; 

tx_cmd <= r_nw & w & a;
reset_n <= not reset;


SPI_MASTER_i : spi_3_wire_master
  generic map(
    slaves    => C_SLAVES, -- : integer := 1;  --number of spi slaves
    cmd_width => C_CMD_WIDTH, -- : integer := 8;  --command bus width
    d_width   => C_D_WIDTH  -- : integer := 8); --data bus width
    )
  port map(
    clock     => clk_ps,    -- : in     std_logic;                              --system clock
    reset_n   => reset_n,   -- : in     std_logic;                              --asynchronous reset
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
           
process (clk_ps)
begin
   if rising_edge(clk_ps) then
      count <= count + 1;
   end if;
end process;

LEDS(4) <= count(24); -- "01010";
LEDS(3) <= count(23); -- "01010";
LEDS(2) <= count(22); -- "01010";
LEDS(1) <= '0';
LEDS(0) <= '0';
-- LEDS <= "01010";

EN_GTP_OSC <= probe_out0(29);
end Behavioral;
