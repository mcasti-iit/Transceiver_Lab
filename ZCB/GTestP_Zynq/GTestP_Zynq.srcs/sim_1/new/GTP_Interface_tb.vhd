
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;

library unisim;
  use unisim.vcomponents.all;

entity GTP_Interface_tb is
--  Port ( );
end GTP_Interface_tb;

architecture Behavioral of GTP_Interface_tb is

component GTP_TX_Interface
  port ( 
    CLK_i               : in  std_logic;
    GTx_RXUSRCLK2_i     : in  std_logic;
    RST_N_i             : in  std_logic;
    -- GTP TX Side
    GTP_TX_DATA_o       : out std_logic_vector (15 downto 0);          
    GTP_TX_IS_K_o       : out std_logic_vector (1 downto 0);
    -- Fabric Side   
    DATA_IN_i           : in  std_logic_vector (30 downto 0);     
    DATA_IN_SRC_RDY_i   : in  std_logic;
    DATA_IN_DST_RDY_o   : out std_logic                             
    );                              
end component;

component GTP_RX_Interface
  port ( 
    CLK_i               : in  std_logic;
    GTx_RXUSRCLK2_i     : in  std_logic;
    RST_N_i             : in  std_logic;
    -- GTP RX Side
    GTP_RX_DATA_i       : in  std_logic_vector (15 downto 0);      
    GTP_RX_IS_K_i       : in  std_logic_vector ( 1 downto 0);    
    -- Fabric Side   
    DATA_OUT_o          : out std_logic_vector (31 downto 0);     
    DATA_OUT_SRC_RDY_o  : out std_logic;
    DATA_OUT_DST_RDY_i  : in  std_logic
    );                         
end component;

constant CLK_PERIOD_c       : time := 10.0 ns; 
constant GTP_CLK_PERIOD_c   : time :=  6.4 ns; 

signal clk, gtp_clk   : std_logic;
signal rst, rst_n     : std_logic;                    --active high reset

signal gtp_data       : std_logic_vector (15 downto 0);      
signal gtp_is_k       : std_logic_vector ( 1 downto 0);   

signal gtp_tx_data    : std_logic_vector (30 downto 0);
signal gtp_tx_src_rdy : std_logic;
signal gtp_tx_dst_rdy : std_logic;

signal gtp_rx_data    : std_logic_vector (30 downto 0);
signal gtp_rx_src_rdy : std_logic;
signal gtp_rx_dst_rdy : std_logic;

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
  wait for CLK_PERIOD_c;
  clk_loop : loop
    clk <= not clk;
    wait for CLK_PERIOD_c/2.0;
  end loop;
end process proc_clock;

proc_gtp_clock : process 
begin
  gtp_clk <= '0';
  wait for GTP_CLK_PERIOD_c;
  gtp_clk_loop : loop
    gtp_clk <= not gtp_clk;
    wait for GTP_CLK_PERIOD_c/2.0;
  end loop;
end process proc_gtp_clock;
-- -----------------------



-- -----------------------
TX : GTP_TX_Interface
  port map( 
    CLK_i               => clk,             -- : in  std_logic;
    GTx_RXUSRCLK2_i     => gtp_clk,         -- : in  std_logic;
    RST_N_i             => rst_n,           -- : in  std_logic;
    -- GTP TX Side
    GTP_TX_DATA_o       => gtp_data,        -- : out std_logic_vector (15 downto 0);          
    GTP_TX_IS_K_o       => gtp_is_k,        -- : out std_logic_vector (1 downto 0);
    -- Fabric Side
    DATA_IN_i           => gtp_tx_data,     -- : in  std_logic_vector (30 downto 0);     
    DATA_IN_SRC_RDY_i   => gtp_tx_src_rdy,  -- : in  std_logic;
    DATA_IN_DST_RDY_o   => gtp_tx_dst_rdy   -- : out std_logic                             
    );   

RX : GTP_RX_Interface
  port map( 
    CLK_i               => clk,             -- : in  std_logic;
    GTx_RXUSRCLK2_i     => gtp_clk,         -- : in  std_logic;
    RST_N_i             => rst_n,           -- : in  std_logic;
    -- GTP RX Side
    GTP_RX_DATA_i       => gtp_data,        -- : in  std_logic_vector (15 downto 0);      
    GTP_RX_IS_K_i       => gtp_is_k,        -- : in  std_logic_vector ( 1 downto 0);    
    -- Fabric Side
    DATA_OUT_o          => gtp_rx_data,     -- : out std_logic_vector (31 downto 0);     
    DATA_OUT_SRC_RDY_o  => gtp_rx_src_rdy,  -- : out std_logic;
    DATA_OUT_DST_RDY_i  => gtp_rx_dst_rdy   -- : in  std_logic
    );   



end Behavioral;
