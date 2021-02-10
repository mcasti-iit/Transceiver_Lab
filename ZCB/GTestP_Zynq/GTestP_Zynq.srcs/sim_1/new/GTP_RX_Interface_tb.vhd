
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;

library unisim;
  use unisim.vcomponents.all;

entity GTP_RX_Interface_tb is
--  Port ( );
end GTP_RX_Interface_tb;

architecture Behavioral of GTP_RX_Interface_tb is


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

constant CLK_PERIOD_c            : time := 10 ns; 

signal clk        : std_logic;
signal rst, rst_n : std_logic;                    --active high reset

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







end Behavioral;
