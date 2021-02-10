
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;


library unisim;
  use unisim.vcomponents.all;

entity GTP_RX_Interface is
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
end GTP_RX_Interface;

architecture Behavioral of GTP_RX_Interface is

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

signal rx_dword   : std_logic_vector(31 downto 0); 
signal rx_toggle  : std_logic; 

signal fifo_dout  : std_logic_vector(31 downto 0);
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

fifo_wr_en <= rx_dword(31) and not fifo_full;
fifo_rd_en <= DATA_OUT_DST_RDY_i and not fifo_empty;

GTP_SYNC_FIFO_i : GTP_SYNC_FIFO
  PORT MAP (
    rst     => RST_N_i,
    wr_clk  => GTx_RXUSRCLK2_i,
    rd_clk  => CLK_i,
    din     => rx_dword,
    wr_en   => fifo_wr_en,
    rd_en   => fifo_rd_en,
    dout    => DATA_OUT_o,
    full    => fifo_full,
    empty   => fifo_empty
  );

DATA_OUT_SRC_RDY_o <= not fifo_empty;


end Behavioral;
