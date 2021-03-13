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
  use ieee.std_logic_misc.all;

entity GTP_TX_Manager is
  generic ( 
    TX_DATA_IN_WIDTH_g      : integer range 0 to 64 := 32;    -- Width of TX Data - Fabric side 
    GTP_STREAM_WIDTH_g      : integer range 0 to 64 := 16     -- Width of TX Data - GTP side
    );
  port (
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          : in  std_logic;
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1S_i                  : in  std_logic;   -- Enable @ 100 us in clk domain 

    -- Control in
    AUTO_ALIGN_i            : in  std_logic;
    ALIGN_REQ_i             : in  std_logic;
    ALIGN_KEY_i             : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
    TX_ERROR_INJECTION_i    : in  std_logic;
    GTP_PLL_REFCLKLOST_i    : in  std_logic;
 
    -- Control out
    GTP_SOFT_RESET_TX_o     : out std_logic;
    
    -- Status
    ALIGN_FLAG_o            : out std_logic;
  
    -- Data in 
    TX_DATA_i               : in  std_logic_vector(TX_DATA_IN_WIDTH_g-1 downto 0);
    TX_DATA_SRC_RDY_i       : in  std_logic;
    TX_DATA_DST_RDY_o       : out std_logic;
    
    TX_MSG_i                : in   std_logic_vector(7 downto 0);
    TX_MSG_SRC_RDY_i        : in   std_logic;
    TX_MSG_DST_RDY_o        : out  std_logic;
    
        
    -- *** GTP CLOCK DOMAIN ***
    -- Bare Control ports  
    GCK_i                   : in  std_logic;   -- Input clock - GTP side     
    RST_N_GCK_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)
    EN100US_GCK_i           : in  std_logic;   -- Enable @ 100 us in gck domain    
         
    -- Data out
    GTP_STREAM_OUT_o        : out std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
    GTP_CHAR_IS_K_o         : out std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0)              
    );
end GTP_TX_Manager;


architecture Behavioral of GTP_TX_Manager is

component DATA_SYNC_FIFO
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

component MSG_SYNC_FIFO
  port (
    rst : in std_logic;
    wr_clk : in std_logic;
    rd_clk : in std_logic;
    din : in std_logic_vector(7 downto 0);
    wr_en : in std_logic;
    rd_en : in std_logic;
    dout : out std_logic_vector(7 downto 0);
    full : out std_logic;
    overflow : out std_logic;
    empty : out std_logic;
    valid : out std_logic
  );
end component;


-- ----------------------------------------------------------------------------------------------
-- CONSTANTS
--
-- Valid Control K Characters (8B/10B)
constant K28_0 : std_logic_vector(7 downto 0) := "00011100"; -- 1C
constant K28_1 : std_logic_vector(7 downto 0) := "00111100"; -- 3C
constant K28_2 : std_logic_vector(7 downto 0) := "01011100"; -- 5C
constant K28_3 : std_logic_vector(7 downto 0) := "01111100"; -- 7C
constant K28_4 : std_logic_vector(7 downto 0) := "10011100"; -- 9C
constant K28_5 : std_logic_vector(7 downto 0) := "10111100"; -- BC
constant K28_6 : std_logic_vector(7 downto 0) := "11011100"; -- DC
constant K28_7 : std_logic_vector(7 downto 0) := "11111100"; -- FC
constant K23_7 : std_logic_vector(7 downto 0) := "11110111"; -- F7
constant K27_7 : std_logic_vector(7 downto 0) := "11111011"; -- FB
constant K29_7 : std_logic_vector(7 downto 0) := "11111101"; -- FD
constant K30_7 : std_logic_vector(7 downto 0) := "11111110"; -- FE

--
constant IDLE_HEAD_c : std_logic_vector(15 downto 0) := K28_0 & K28_1;
constant IDLE_TAIL_c : std_logic_vector(15 downto 0) := K28_2 & K28_3;
constant ALIGN_c     : std_logic_vector(15 downto 0) := K28_5 & K28_5;
constant MSG_c       : std_logic_vector( 7 downto 0) := K30_7; -- & K30_7;

--  State Machine
type state_type is (RESET_st, IDLE_HEAD_st, IDLE_TAIL_st, DATA_W1_st, DATA_W0_st, ALIGN_st, ERROR_st);
signal state, next_state : state_type;  -- Indicate state of State Machine

signal data_fifo_wr_en      : std_logic;
signal data_fifo_rd_en      : std_logic;
signal data_fifo_din        : std_logic_vector(31 downto 0);
signal data_fifo_dout       : std_logic_vector(31 downto 0);
signal data_fifo_full       : std_logic;
signal data_fifo_overflow   : std_logic;
signal data_fifo_empty      : std_logic;
signal data_fifo_valid      : std_logic;
signal data_fifo_rst        : std_logic;

signal msg_fifo_wr_en      : std_logic;
signal msg_fifo_rd_en      : std_logic;
signal msg_fifo_din        : std_logic_vector(7 downto 0);
signal msg_fifo_dout       : std_logic_vector(7 downto 0);
signal msg_fifo_full       : std_logic;
signal msg_fifo_overflow   : std_logic;
signal msg_fifo_empty      : std_logic;
signal msg_fifo_valid      : std_logic;
signal msg_fifo_rst        : std_logic;

-- signal data_fifo_valid_d    : std_logic;

signal p_gtp_stream_out   : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
signal gtp_stream_out     : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
signal p_tx_char_is_k  : std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);
signal tx_char_is_k    : std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0);

signal data_w_sel       : std_logic;
signal idle_w_sel       : std_logic;
signal word_toggle      : std_logic;
signal data_w_enable    : std_logic;
signal idle_w_enable    : std_logic;
signal msg_enable       : std_logic;
signal gtp_align_enable : std_logic;

signal data_out_sel    : std_logic_vector(2 downto 0);

signal align_flag      : std_logic;



signal idle_head_flag       : std_logic;
signal idle_tail_flag       : std_logic;
signal gtp_align_flag       : std_logic;          
signal msg_flag             : std_logic; 
signal data_w0_flag         : std_logic;
signal data_w1_flag         : std_logic;

signal p_align_req          : std_logic;
signal align_req            : std_logic;
signal align_req_r          : std_logic;
signal send_error_req       : std_logic;


signal msg_r                : std_logic_vector(7 downto 0);
signal msg_src_rdy          : std_logic;
signal msg_dst_rdy          : std_logic;

signal gtp_pll_lock_meta    : std_logic;
signal gtp_pll_lock_sync    : std_logic;
signal gtp_pll_lock         : std_logic;
signal gtp_clk_lost_meta    : std_logic;
signal gtp_clk_lost_sync    : std_logic;
signal gtp_clk_lost         : std_logic;

signal gtp_pll_fail         : std_logic;
signal gtp_pll_alarm_cnt    : std_logic_vector(1 downto 0);
signal gtp_pll_alarm        : std_logic;

signal gtp_reset_cnt        : std_logic_vector(3 downto 0);
signal gtp_reset            : std_logic;
signal gtp_reset_sent       : std_logic;

begin



-- --------------------------------------------------------------------------
-- FIFOES

-- Main DATA

TX_DATA_DST_RDY_o <= not data_fifo_full;
data_fifo_wr_en <= not data_fifo_full and TX_DATA_SRC_RDY_i;

data_fifo_rd_en <= data_w0_flag;
data_fifo_rst <= not RST_N_i;

data_fifo_din <= TX_DATA_i;

DATA_SYNC_FIFO_TX_i :  DATA_SYNC_FIFO
  port map (
    rst       => data_fifo_rst,               
    wr_clk    => CLK_i,        
    rd_clk    => GCK_i,         
    din       => TX_DATA_i,      
    wr_en     => data_fifo_wr_en,        
    rd_en     => data_fifo_rd_en,        
    dout      => data_fifo_dout,  
    full      => data_fifo_full,         
    overflow  => data_fifo_overflow,     
    empty     => data_fifo_empty,        
    valid     => data_fifo_valid         
  );
  


-- Messages

TX_MSG_DST_RDY_o <= not msg_fifo_full;
msg_fifo_wr_en <= not msg_fifo_full and TX_MSG_SRC_RDY_i;

msg_fifo_rd_en <= msg_flag;
msg_fifo_rst <= not RST_N_i;

msg_fifo_din <= TX_MSG_i;

MSG_SYNC_FIFO_TX_i :  MSG_SYNC_FIFO
  port map (
    rst       => msg_fifo_rst,               
    wr_clk    => CLK_i,        
    rd_clk    => GCK_i,         
    din       => msg_fifo_din,      
    wr_en     => msg_fifo_wr_en,        
    rd_en     => msg_fifo_rd_en,        
    dout      => msg_fifo_dout,  
    full      => msg_fifo_full,         
    overflow  => msg_fifo_overflow,     
    empty     => msg_fifo_empty,        
    valid     => msg_fifo_valid         
  );
  
  
process(GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    p_align_req  <= '0';
    align_req    <= '0';
    align_req_r  <= '0';
  elsif rising_edge(GCK_i) then
    p_align_req <= ALIGN_REQ_i;
    align_req   <= p_align_req;
    if (data_w1_flag = '0') then
      align_req_r  <= align_req;
    end if;    
  end if;
end process;


data_w_enable    <= data_fifo_valid and not align_req_r;
-- idle_w_enable    <= not data_w_enable;


process(GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    data_w_sel <= '1';
  elsif rising_edge(GCK_i) then
    if (data_w_enable = '1') then
      data_w_sel <= not data_w_sel;
    else
      data_w_sel <= '1';
    end if;
  end if;
end process;  







-- idle_w_enable    <= not data_fifo_valid or align_req;
-- msg_enable       <= not data_fifo_valid and msg_fifo_valid and not align_req;
-- gtp_align_enable <= idle_w_enable and idle_w_sel and align_req;



-- process(GCK_i, RST_GCK_N_i)
-- begin
--   if (RST_GCK_N_i = '0') then
--     idle_w_sel <= '0';
--   elsif rising_edge(GCK_i) then
--     if (idle_w_enable = '1') then
--       idle_w_sel <= not idle_w_sel;
--     else
--       idle_w_sel <= '1';
--     end if;
--   end if;
-- end process;


     

-- gtp_align_flag     <= gtp_align_enable;
-- msg_flag           <= msg_enable;
-- idle_flag          <= idle_w_enable and     idle_w_sel and not msg_fifo_valid and not align_req;

-- idle_head_flag     <= idle_w_enable and     idle_w_sel and not msg_fifo_valid and not align_req;   
-- idle_tail_flag     <= idle_w_enable and not idle_w_sel and not msg_fifo_valid;

gtp_align_flag     <=     align_req_r                                              and EN100US_GCK_i;
data_w1_flag       <= not align_req_r and     data_fifo_valid and     data_w_sel;
data_w0_flag       <= not align_req_r and     data_fifo_valid and not data_w_sel;
msg_flag           <= not align_req_r and not data_fifo_valid and msg_fifo_valid;

process (gtp_align_flag, data_w1_flag, data_w0_flag, msg_flag, data_fifo_dout, msg_fifo_dout)
begin

  if (gtp_align_flag = '1') then 
    p_gtp_stream_out   <= ALIGN_c;
    p_tx_char_is_k  <= "01"; -- ALIGN_KEY_i; 
  elsif (data_w1_flag = '1')   then 
    p_gtp_stream_out  <= data_fifo_dout(31 downto 16);
    p_tx_char_is_k <= "00";
  elsif (data_w0_flag = '1')   then
    p_gtp_stream_out  <= data_fifo_dout(15 downto  0);
    p_tx_char_is_k <= "00";
  elsif (msg_flag = '1') then 
    p_gtp_stream_out   <= MSG_c & msg_fifo_dout;
    p_tx_char_is_k  <= "10";
  else 
    p_gtp_stream_out  <= IDLE_HEAD_c;
    p_tx_char_is_k <= "11";
  end if;  
end process;


SYNC_PROC: process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    gtp_stream_out   <= (others => '0');
    tx_char_is_k  <= "00";
  elsif rising_edge(GCK_i) then
    gtp_stream_out   <= p_gtp_stream_out;
    tx_char_is_k  <= p_tx_char_is_k;
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- GTP RESET

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    gtp_pll_lock_meta <= '0';
    gtp_pll_lock_sync <= '0';
    gtp_pll_lock <= '0';
  elsif rising_edge(CLK_i) then
    gtp_pll_lock_meta  <= GTP_PLL_LOCK_i;
    gtp_pll_lock_sync  <= gtp_pll_lock_meta;
    gtp_pll_lock       <= gtp_pll_lock_sync;
  end if;
end process;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    gtp_clk_lost_meta <= '0';
    gtp_clk_lost_sync <= '0';
    gtp_clk_lost <= '0';
  elsif rising_edge(CLK_i) then
    gtp_clk_lost_meta  <= GTP_PLL_REFCLKLOST_i;
    gtp_clk_lost_sync  <= gtp_clk_lost_meta;
    gtp_clk_lost       <= gtp_clk_lost_sync;
  end if;
end process;


gtp_pll_fail <= (gtp_clk_lost or not gtp_pll_lock);

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then 
    gtp_pll_alarm_cnt  <= "00";
  elsif rising_edge(CLK_i) then
    if (gtp_pll_alarm_cnt /= "00" ) then
      if (EN1S_i = '1') then
        gtp_pll_alarm_cnt <= gtp_pll_alarm_cnt - 1;
      end if;
    elsif (gtp_pll_fail = '1') then
      gtp_pll_alarm_cnt <= "11";      
    end if;
  end if;
end process;




process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    gtp_reset_cnt  <= conv_std_logic_vector(0, gtp_reset_cnt'length);
    gtp_reset      <= '0';
  elsif rising_edge(CLK_i) then
    if (gtp_pll_alarm_cnt = "10" and EN1S_i = '1') then
      gtp_reset_cnt <= conv_std_logic_vector(15, gtp_reset_cnt'length);
    elsif (gtp_reset_cnt /= conv_std_logic_vector(0, gtp_reset_cnt'length)) then
      gtp_reset_cnt <= gtp_reset_cnt - 1;
    end if;
    
    gtp_reset <= or_reduce(gtp_reset_cnt);
    
  end if;
end process;

-- ----------------------------------------------------------------------------------
-- OUTPUTs


GTP_STREAM_OUT_o     <= gtp_stream_out;
GTP_CHAR_IS_K_o      <= tx_char_is_k;
ALIGN_FLAG_o         <= gtp_align_flag;

GTP_SOFT_RESET_TX_o  <= gtp_reset;

end Behavioral;
