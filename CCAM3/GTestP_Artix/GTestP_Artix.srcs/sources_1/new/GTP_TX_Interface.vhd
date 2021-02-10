
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;

library unisim;
  use unisim.vcomponents.all;


entity GTP_TX_Interface is
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
end GTP_TX_Interface;

architecture Behavioral of GTP_TX_Interface is

component GTP_SYNC_FIFO
  port (
    rst : in std_logic;
    wr_clk : in std_logic;
    rd_clk : in std_logic;
    din : in std_logic_vector(15 downto 0);
    wr_en : in std_logic;
    rd_en : in std_logic;
    dout : out std_logic_vector(15 downto 0);
    full : out std_logic;
    empty : out std_logic
  );
end component;


constant FILLING_c : std_logic_vector(31 downto 0) := x"7A70BAB0";

signal tx_dword   : std_logic_vector(31 downto 0); 
signal tx_toggle  : std_logic; 

signal fifo_wr_en : std_logic;
signal fifo_rd_en : std_logic;
signal fifo_full  : std_logic;
signal fifo_empty : std_logic;

begin

process (CLK_i)
begin
  if (RST_N_i = '1') then
    
  elsif rising_edge(CLK_i) then
      
  end if;
end process;  

fifo_wr_en <= DATA_IN_SRC_RDY_i and not fifo_full;
fifo_rd_en <= '1';

GTP_SYNC_FIFO_i : GTP_SYNC_FIFO
  PORT MAP (
    rst     => RST_N_i,
    wr_clk  => GTx_RXUSRCLK2_i,
    rd_clk  => CLK_i,
    din     => DATA_IN_i,
    wr_en   => fifo_wr_en,
    rd_en   => fifo_rd_en,
    dout    => tx_dword,
    full    => fifo_full,
    empty   => fifo_empty
  );

DATA_IN_DST_RDY_o <= not fifo_full;


end Behavioral;