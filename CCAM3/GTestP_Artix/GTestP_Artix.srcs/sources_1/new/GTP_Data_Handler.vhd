-- ==============================================================================
-- DESCRIPTION:
-- Provides clock enables to FPGA fabric
-- ------------------------------------------
-- File        : time_machine.vhd
-- Revision    : 1.0
-- Author      : M. Casti
-- Date        : 15/02/2021
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.1:  15/02/2021 - M. Casti
-- - Output Reset
-- - Added 10ms, 100ms, 1sec enable output
-- - Clock Period generic is REAL now
-- 
-- Revision 1.0:  04/05/2020 - M. Casti
-- - Initial release
-- 
-- ==============================================================================
-- WRITING STYLE 
-- 
-- INPUTs:    UPPERCASE followed by "_i"
-- OUTPUTs:   UPPERCASE followed by "_o"
-- BUFFERs:   UPPERCASE followed by "_b"
-- CONSTANTs: UPPERCASE followed by "_c"
-- GENERICs:  UPPERCASE followed by "_g"
-- 
-- ==============================================================================


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity GTP_Data_Handler is
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
    EN1MS_GCK_i             : in  std_logic;   -- Enable @ 1 Khz (gck clock)

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
    TX_DATA_OUT_SRC_RDY_o   : out std_logic;
    TX_DATA_OUT_DST_RDY_i   : in  std_logic;
    TX_CHAR_IS_K_o          : out std_logic_vector((TX_DATA_OUT_WIDTH_g/8)-1 downto 0)              
    );
end GTP_Data_Handler;


architecture Behavioral of GTP_Data_Handler is

component GTP_SYNC_FIFO
  port (
    rst : in std_logic;
    wr_clk : in std_logic;
    rd_clk : in std_logic;
    din : in std_logic_vector(31 downto 0);
    wr_en : in std_logic;
    rd_en : in std_logic;
    dout : out std_logic_vector(31 downto 0);
    full : out std_logic;
    overflow : out std_logic;
    empty : out std_logic;
    valid : out std_logic
  );
end component;


signal fifo_wr_en      : std_logic;
signal fifo_rd_en      : std_logic;
signal fifo_dout       : std_logic_vector(31 downto 0);
signal fifo_full       : std_logic;
signal fifo_overflow   : std_logic;
signal fifo_empty      : std_logic;
signal fifo_valid      : std_logic;
signal fifo_rst        : std_logic;

signal fifo_valid_d    : std_logic;

signal tx_data_out     : std_logic_vector(TX_DATA_OUT_WIDTH_g-1 downto 0);
signal tx_char_is_k    : std_logic_vector((TX_DATA_OUT_WIDTH_g/8)-1 downto 0);

signal tx_data_sel     : std_logic_vector(1 downto 0);

begin


TX_DATA_IN_DST_RDY_o <= not fifo_full;
fifo_wr_en <= not fifo_full and TX_DATA_IN_SRC_RDY_i;

fifo_rd_en <= not fifo_empty and TX_DATA_OUT_DST_RDY_i;
fifo_rst <= not RST_CLK_N_i;

GTP_SYNC_FIFO_i :  GTP_SYNC_FIFO
  port map (
    rst       => fifo_rst,               
    wr_clk    => CLK_i,        
    rd_clk    => GCK_i,         
    din       => TX_DATA_IN_i,      
    wr_en     => fifo_wr_en,        
    rd_en     => fifo_rd_en,        
    dout      => fifo_dout,  
    full      => fifo_full,         
    overflow  => fifo_overflow,     
    empty     => fifo_empty,        
    valid     => fifo_valid         
  );
  

process(GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    fifo_valid_d <= '0';
  elsif rising_edge(GCK_i) then
    fifo_valid_d <= fifo_valid;
  end if;
end process;   

tx_data_sel <= fifo_valid & fifo_valid_d;

process(GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    tx_data_out  <= (others => '0');
    tx_char_is_k <= (others => '0');
  elsif rising_edge(GCK_i) then
    if (ALIGN_REQ_i = '1') then
      tx_data_out  <= x"BCBC";
      tx_char_is_k <= (others => '1');
    else 
      case (tx_data_sel) is
        when "00"   => tx_data_out  <= x"1C1C";
                       tx_char_is_k <= (others => '1');
        when "10"   => tx_data_out  <= fifo_dout(31 downto 16);
                       tx_char_is_k <= (others => '0');
        when "01"   => tx_data_out  <= fifo_dout(15 downto 0);
                       tx_char_is_k <= (others => '0');
                 
        when others => tx_data_out  <= x"FEFE";
                       tx_char_is_k <= (others => '1');       
        
      end case;
    end if;  
  end if;
end process;   



-- Error detection  
process(GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    OVERRIDE_GCK_o <= '0';
  elsif rising_edge(CLK_i) then
    if ( fifo_valid = '1' and fifo_valid_d = '1') then
      OVERRIDE_GCK_o <= '1';
    end if;
  end if;
end process;

TX_DATA_OUT_o  <= tx_data_out;
TX_CHAR_IS_K_o <= tx_char_is_k;
TX_DATA_OUT_SRC_RDY_o <= fifo_valid;

end Behavioral;
