----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.02.2021 09:56:24
-- Design Name: 
-- Module Name: AD9517_Manager_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AD9517_Manager_tb is
--  Port ( );
end AD9517_Manager_tb;

architecture Behavioral of AD9517_Manager_tb is

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
    CLK_PERIOD_g            : integer range 0 to 255 := 10;   -- Main Clock period
    PON_RESET_DURATION_MS_g : integer range 0 to 255 := 10;   -- Duration of Power-On reset  
    SIM_TIME_COMPRESSION_g  : in boolean := FALSE             -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port (
    -- Clock in port
    CLK_i                   : in  std_logic;   -- Input clock @ 50 MHz,
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset
  
    -- Output reset
    PON_RESET_OUT_o         : out std_logic;	  -- Power on Reset out (active high)
    PON_RESET_N_OUT_o       : out std_logic;	  -- Power on Reset out (active high)
    
    -- Output ports for generated clock enables
    EN200NS_o               : out std_logic;	  -- Clock enable every 200 ns
    EN1US_o                 : out std_logic;	  -- Clock enable every 1 us
    EN10US_o                : out std_logic;	  -- Clock enable every 10 us
    EN100US_o               : out std_logic;	  -- Clock enable every 100 us
    EN1MS_o                 : out std_logic 	  -- Clock enable every 1 ms
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


constant CLK_PERIOD_c   : time := 10 ns;

constant ZERO_VECTOR_c  : std_logic_vector(31 downto 0) := (others => '0'); 
constant UNO_VECTOR_c   : std_logic_vector(31 downto 0) := (others => '1');

constant SLAVES_c       : integer :=  1; --number of spi slaves
constant CMD_WIDTH_c    : integer := 16; --command bus width
constant D_WIDTH_c      : integer :=  8; --data bus width
constant CLK_DIV_c      : integer := 32; --command bus width
constant ADDR_c         : integer :=  0; --data bus width

signal clk              : std_logic;
signal rst, rst_n       : std_logic;                          -- active high reset

signal en1ms            : std_logic;

signal cpol             : std_logic;                         -- spi clock polarity
signal cpha             : std_logic;                         -- spi clock phase
signal w_nr             : std_logic;                         -- '0' for read, '1' for write
signal tx_cmd           : std_logic_vector(15 downto 0);     -- command to transmit
signal tx_data          : std_logic_vector(7 downto 0);      -- data to transmit
signal enable           : std_logic;                         -- initiate transaction    
signal busy             : std_logic;                         -- busy / data ready signal
signal rx_data          : std_logic_vector(7 downto 0);      -- data received
signal error            : std_logic_vector (2 downto 0);     -- code error

signal sclk             : std_logic;                              --spi clock               
signal ss_n             : std_logic_vector(SLAVES_c-1 downto 0);    --slave select            
signal sdio             : std_logic;                              --serial data input output

signal pon_reset        : std_logic;
signal pon_reset_n      : std_logic;

begin

proc_reset_n : process 
begin
  rst_n <= '0';
  rst   <= '1';
  wait for 102 ns;
  rst_n <= '1';
  rst   <= '0';
  wait;
end process proc_reset_n;  

proc_clock : process 
begin
  clk <= '0';
  wait for 10 ns;
  clk_loop : loop
    clk <= not clk;
    wait for CLK_PERIOD_c/2.0;
  end loop;
end process proc_clock;


TIME_MACHINE_i : time_machine
generic map( 
  CLK_PERIOD_g           => 10,   -- Main Clock period
  SIM_TIME_COMPRESSION_g => false  -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
  )
port map(
  -- Clock in port
  CLK_i                  => clk,
  RST_N_i                => rst_n,
  
  -- Output reset
  PON_RESET_OUT_o        => pon_reset,	    -- Power on Reset out (active high)
  PON_RESET_N_OUT_o      => pon_reset_n,	  -- Power on Reset out (active high)
    
    -- Output ports for generated clock enables
  EN200NS_o              => open,
  EN1US_o                => open,
  EN10US_o               => open,
  EN100US_o              => open,
  EN1MS_o                => en1ms
  );

SPI_MASTER_i : spi_3_wire_master
  generic map(
    slaves    => SLAVES_c, -- : integer := 1;  --number of spi slaves
    cmd_width => CMD_WIDTH_c, -- : integer := 8;  --command bus width
    d_width   => D_WIDTH_c  -- : integer := 8); --data bus width
    )
  port map(
    clock     => clk,    -- : in     std_logic;                              --system clock
    reset_n   => rst_n,   -- : in     std_logic;                              --asynchronous reset
    enable    => enable,    -- : in     std_logic;                              --initiate transaction
    cpol      => cpol,      -- : in     std_logic;                              --spi clock polarity
    cpha      => cpha,      -- : in     std_logic;                              --spi clock phase
    clk_div   => 5,         -- : in     integer;                                --system clock cycles per 1/2 period of sclk
    addr      => 0,         -- : in     integer;                                --address of slave
    rw        => w_nr,      -- : in     std_logic;                              --'0' for read, '1' for write
    tx_cmd    => tx_cmd,    -- : in     std_logic_vector(cmd_width-1 downto 0); --command to transmit
    tx_data   => tx_data,   -- : in     std_logic_vector(d_width-1 downto 0);   --data to transmit
    sclk      => sclk,      -- : buffer std_logic;                              --spi clock
    ss_n      => ss_n,      -- : buffer std_logic_vector(slaves-1 downto 0);    --slave select
    sdio      => sdio,      -- : inout  std_logic;                              --serial data input output
    busy      => busy,      -- : out    std_logic;                              --busy / data ready signal
    rx_data   => rx_data    -- : out    std_logic_vector(d_width-1 downto 0));  --data received
    );

AD9517_Manager_i : AD9517_Manager
  generic map(
    slaves    =>  1,        -- number of spi slaves
    cmd_width => 16,        -- command bus width
    d_width   =>  8         -- data bus width
    )
  port map(
    -- Main control
    CLK_i     => clk,               
    EN1MS_i   => en1ms,             
    RST_N_i   => rst_n,             
    
    -- Controland status ports
    ERROR_o   => error,
    
    -- SPI Master side
    CPOL_o    => cpol,      -- spi clock polarity
    CPHA_o    => cpha,      -- spi clock phase
    W_nR_o    => w_nr,        -- '0' for read, '1' for write
    TX_CMD_o  => tx_cmd,    -- command to transmit
    TX_DATA_o => tx_data,   -- data to transmit
    ENABLE_o  => enable,    -- initiate transaction    
    BUSY_i    => busy,      -- busy / data ready signal
    RX_DATA_i => rx_data    -- data received
    );

sdio <= 'H';

end Behavioral;
