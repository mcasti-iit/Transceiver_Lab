library ieee; 
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  
library UNISIM;  
  use UNISIM.Vcomponents.all;  
  
use std.textio.all;
  use ieee.std_logic_textio.all;

entity GTP_TX_Manager_tb is
--  Port ( );
end GTP_TX_Manager_tb;

architecture Behavioral of GTP_TX_Manager_tb is

component GTP_TX_Manager is
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
    TX_CHAR_IS_K_o          : out std_logic_vector((TX_DATA_OUT_WIDTH_g/8)-1 downto 0)              
    );
end component;

constant CLK_PERIOD_c       : time := 10.0 ns;  
constant CLK_GTP_PERIOD_c   : time :=  6.4 ns;  


signal clk, clk_gtp         : std_logic;
signal rst_n, rst           : std_logic;                    --active high reset
signal rst_n_gtp, rst_gtp   : std_logic;                    --active high reset

signal en_20ns              : std_logic;  

signal tx_cnt_32bit  : std_logic_vector(31 downto 0);

signal tx_data           : std_logic_vector(31 downto 0);
signal tx_data_valid_cnt : std_logic_vector(7 downto 0);
signal tx_data_valid     : std_logic;
signal tx_data_gtp       : std_logic_vector(15 downto 0);

signal align_req : std_logic;

begin

-- RESETs
proc_reset_n : process 
begin
  rst_n <= '0';
  rst   <= '1';
  wait for CLK_PERIOD_c;
  wait for 2 ns;
  rst_n <= '1';
  rst   <= '0';
  wait;
end process proc_reset_n;  

proc_reset_n_gtp : process 
begin
  rst_n_gtp <= '0';
  rst_gtp   <= '1';
  wait for CLK_GTP_PERIOD_c;
  wait for 2 ns;
  rst_n_gtp <= '1';
  rst_gtp   <= '0';
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
  align_req <= '0';
  wait for 100 us;
  align_req <= '1';
  wait for 100 us;
  align_req <= '0';
  wait;
end process proc_align_req;


-- --------------------------------------------------------
-- Data Generator

process(clk, rst_n)
begin
  if (rst_n = '0') then
    tx_data_valid_cnt <= (others => '0');
    tx_cnt_32bit      <= (others => '0');
    tx_data_valid <= '0';
  elsif rising_edge(clk) then
    if (tx_data_valid_cnt = x"02") then
      tx_data_valid_cnt <= (others => '0');
      tx_cnt_32bit <= tx_cnt_32bit + 1;
      tx_data_valid <= '1';
    else
--      tx_cnt_32bit <= tx_cnt_32bit;
      tx_data_valid_cnt <= tx_data_valid_cnt + 1;
      tx_data_valid <= '0';
    end if;
  end if;	
end process;


tx_data <= tx_cnt_32bit;

GTP_TX_Manager_i : GTP_TX_Manager 
  generic map( 
    TX_DATA_IN_WIDTH_g      => 32,   
    TX_DATA_OUT_WIDTH_g     => 16   
    )
  port map(
    -- Clock in port
    CLK_i                   => clk,
    GCK_i                   => clk_gtp,   
    RST_CLK_N_i             => rst_n, 
    RST_GCK_N_i             => rst_n_gtp, 
    
    -- Control
    ALIGN_REQ_i             => align_req,

    -- Data in 
    TX_DATA_IN_i            => tx_data, 
    TX_DATA_IN_SRC_RDY_i    => tx_data_valid,
    TX_DATA_IN_DST_RDY_o    => open,
    
    -- Data out
    TX_DATA_OUT_o           => tx_data_gtp,
    TX_CHAR_IS_K_o          => open
    );




end Behavioral;
