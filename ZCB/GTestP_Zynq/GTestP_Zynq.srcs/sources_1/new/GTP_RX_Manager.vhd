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

entity GTP_RX_Manager is
  generic ( 
    RX_DATA_OUT_WIDTH_g     : integer range 0 to 64 := 32;    -- Width of RX Data - Fabric side
    GTP_STREAM_WIDTH_g      : integer range 0 to 64 := 16     -- Width of RX Data - GTP side 
    );
  port (
    -- *** ASYNC PORTS  
    GTP_PLL_LOCK_i          : in  std_logic;
      
    -- *** SYSTEM CLOCK DOMAIN ***
    -- Bare Control ports
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side    
    RST_N_i                 : in  std_logic;   -- Asynchronous active low reset (clk clock)
    EN1MS_i                 : in  std_logic;   -- Enable @ 1 msec in clk domain 
    EN1S_i                  : in  std_logic;   -- Enable @ 1 sec in clk domain 

    -- Control in
    GTP_PLL_REFCLKLOST_i    : in  std_logic;
     
    -- Control out
    GTP_SOFT_RESET_RX_o     : out std_logic;     
         
    -- Data out
    RX_DATA_o               : out std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
    RX_DATA_SRC_RDY_o       : out std_logic;
    RX_DATA_DST_RDY_i       : in  std_logic;
    
    RX_MSG_o                : out std_logic_vector(7 downto 0);
    RX_MSG_SRC_RDY_o        : out std_logic;
    RX_MSG_DST_RDY_i        : in  std_logic;
    
        
    -- *** GTP CLOCK DOMAIN ***
    -- Bare Control ports   
    GCK_i                   : in  std_logic;   -- Input clock - GTP side       
    RST_N_GCK_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)    
    EN1MS_GCK_i             : in  std_logic;   -- Enable @ 1 msec in gck domain 

    -- Control out         
    GTP_IS_ALIGNED_i        : in  std_logic;
    ALIGN_REQ_o             : out std_logic;

    -- Data in 
    GTP_STREAM_IN_i         : in  std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
    GTP_CHAR_IS_K_i         : in  std_logic_vector((GTP_STREAM_WIDTH_g/8)-1 downto 0)
    );
end GTP_RX_Manager;


architecture Behavioral of GTP_RX_Manager is

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


signal data_fifo_din        : std_logic_vector(31 downto 0);
signal data_fifo_wr_en      : std_logic;
signal data_fifo_rd_en      : std_logic;
signal data_fifo_dout       : std_logic_vector(31 downto 0);
signal data_fifo_full       : std_logic;
signal data_fifo_overflow   : std_logic;
signal data_fifo_empty      : std_logic;
signal data_fifo_valid      : std_logic;
signal data_fifo_rst        : std_logic;

signal msg_fifo_din        : std_logic_vector(7 downto 0);
signal msg_fifo_wr_en      : std_logic;
signal msg_fifo_rd_en      : std_logic;
signal msg_fifo_dout       : std_logic_vector(7 downto 0);
signal msg_fifo_full       : std_logic;
signal msg_fifo_overflow   : std_logic;
signal msg_fifo_empty      : std_logic;
signal msg_fifo_valid      : std_logic;
signal msg_fifo_rst        : std_logic;

signal fifo_valid_d    : std_logic;

signal p_rx_data_out   : std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
signal rx_data_out     : std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
signal p_rx_char_is_k  : std_logic_vector((RX_DATA_OUT_WIDTH_g/8)-1 downto 0);
signal rx_char_is_k    : std_logic_vector((RX_DATA_OUT_WIDTH_g/8)-1 downto 0);

signal tx_data_sel        : std_logic_vector(2 downto 0);

signal align_req          : std_logic;

signal k_chars            : std_logic;
signal k_chars_d          : std_logic;
signal k_chars_up         : std_logic;

signal gtp_rx_stream      : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);

signal flag_enable        : std_logic; 
signal idle_exp_toggle   : std_logic;
signal idle_head          : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
signal idle_head_flag     : std_logic;
signal idle_head_exp      : std_logic;
signal idle_tail          : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);
signal idle_tail_flag     : std_logic;
signal idle_tail_exp      : std_logic;






signal gtp_align          : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);         
signal gtp_align_flag     : std_logic;          
signal gtp_align_flag_d   : std_logic;          

signal msg_word         : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);         
signal msg_flag           : std_logic; 
signal msg_flag_d         : std_logic; 

signal data_w_exp_toggle  : std_logic;
signal data_flag          : std_logic;
signal data_flag_d        : std_logic;
signal data_w0_exp        : std_logic;
signal data_w1_exp        : std_logic;
signal data_w1            : std_logic_vector(GTP_STREAM_WIDTH_g-1 downto 0);

signal idle_flag          : std_logic;
signal idle_flag_d        : std_logic;

signal unknown_k_flag     : std_logic;
signal unknown_k_flag_d   : std_logic;
signal unknown_k_detect   : std_logic;
signal unknown_k_detected : std_logic;


-- Counters
signal data_cnt           : std_logic_vector(15 downto 0); 
signal data_rate          : std_logic_vector(15 downto 0); 
signal gtp_align_cnt      : std_logic_vector( 7 downto 0); 
signal gtp_align_rate     : std_logic_vector( 7 downto 0); 
signal msg_cnt            : std_logic_vector(15 downto 0); 
signal msg_rate           : std_logic_vector(15 downto 0); 
signal idle_cnt           : std_logic_vector(15 downto 0); 
signal idle_rate          : std_logic_vector(15 downto 0); 

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

-- ----------------------------------------------------------------------------------
-- Kind of data
k_chars <= '0' when (GTP_CHAR_IS_K_i = "00") else '1';

process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    k_chars_d <= '0';
  elsif rising_edge(GCK_i) then
    k_chars_d <= k_chars;
  end if;
end process;

k_chars_up <= k_chars and not k_chars_d;


-- -- IDLE CHECK
-- -- -- Idle Word toggle
-- process (GCK_i, RST_N_GCK_i)
-- begin
--   if (RST_N_GCK_i = '0') then
--     flag_enable <= '0';
--   elsif rising_edge(GCK_i) then
--     flag_enable <= '1';
--   end if;
-- end process;

-- idle_head_exp <= k_chars and not idle_exp_toggle and flag_enable;
-- idle_tail_exp <= k_chars and     idle_exp_toggle and flag_enable;



data_flag        <= '1' when (k_chars = '0') else '0';
gtp_align_flag   <= '1' when (k_chars = '1' and gtp_rx_stream              = ALIGN_c) else '0'; 
msg_flag         <= '1' when (k_chars = '1' and gtp_rx_stream(15 downto 8) = MSG_c) else '0'; 
idle_flag        <= '1' when (k_chars = '1' and gtp_rx_stream              = IDLE_HEAD_c) else '0';

unknown_k_flag   <= k_chars_d and not (data_flag_d or gtp_align_flag_d or msg_flag_d or idle_flag_d);

process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    data_flag_d      <= '0';
    gtp_align_flag_d <= '0';
    msg_flag_d       <= '0';
    idle_flag_d      <= '0';
    --
    unknown_k_flag_d <= '0';
  elsif rising_edge(GCK_i) then
    data_flag_d      <= data_flag;
    gtp_align_flag_d <= gtp_align_flag;
    msg_flag_d       <= msg_flag;
    idle_flag_d      <= idle_flag;   
    --
    unknown_k_flag_d <= unknown_k_flag;
  end if;
end process;
-- ------------------------------------------------------------------------------------------
-- Counters

-- Data
process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    data_cnt            <= (others => '0');
    data_rate           <= (others => '0');
    --
    msg_cnt             <= (others => '0');
    msg_rate            <= (others => '0');
    --
    gtp_align_cnt       <= (others => '0');
    gtp_align_rate      <= (others => '0');
    --
    idle_cnt            <= (others => '0');
    idle_rate           <= (others => '0');
  elsif rising_edge(GCK_i) then
    if (EN1MS_GCK_i = '1') then
      data_cnt        <= (0 => data_flag_d, others => '0');
      data_rate       <= data_cnt;
    elsif (data_flag_d = '1') then
      data_cnt        <= data_cnt + 1;
    end if;
    --
    if (EN1MS_GCK_i = '1') then
      msg_cnt         <= (0 => msg_flag_d, others => '0');
      msg_rate        <= msg_cnt;
    elsif (msg_flag_d = '1') then
      msg_cnt         <= msg_cnt + 1;
    end if;  
     --
    if (EN1MS_GCK_i = '1') then
      gtp_align_cnt   <= (0 => gtp_align_flag_d, others => '0');
      gtp_align_rate  <= gtp_align_cnt;
    elsif (gtp_align_flag_d = '1') then
      gtp_align_cnt   <= gtp_align_cnt + 1;
    end if;     
     --
    if (EN1MS_GCK_i = '1') then
      idle_cnt        <= (0 => idle_flag_d, others => '0');
      idle_rate       <= idle_cnt;
    elsif (idle_flag_d = '1') then
      idle_cnt        <= idle_cnt + 1;
    end if;   
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- GTP Alignement


process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    unknown_k_detect    <= '0';
    unknown_k_detected  <= '0';
    align_req <= '0';
  elsif rising_edge(GCK_i) then
    if (EN1MS_GCK_i = '1') then
      unknown_k_detect    <= unknown_k_flag;
      unknown_k_detected  <= unknown_k_detect;    
    elsif (unknown_k_flag = '1') then
      unknown_k_detect    <= '1';
    end if;
    
  align_req <= not GTP_IS_ALIGNED_i or unknown_k_detected;
  end if;
end process;


process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    
  elsif rising_edge(GCK_i) then
    
  end if;
end process;
-- ------------------------------------------------------------------------------------------


-- data_w1_flag       <= not align_req_r and     data_fifo_valid and     data_w_sel;
-- data_w0_flag       <= not align_req_r and     data_fifo_valid and not data_w_sel;


-- idle_head_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_0 & K28_1) else '0'; 
-- idle_tail_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_2 & K28_3) else '0'; 
-- data_w0_flag     <= '1' when (k_chars = '0' and gtp_rx_stream = ) else '0'; 
-- data_w1_flag     <= '1' when (k_chars = '0' and gtp_rx_stream = ) else '0'; 


-- Event Word toggle
process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    data_w_exp_toggle <= '0';
  elsif rising_edge(GCK_i) then
    if (k_chars = '1') then
      data_w_exp_toggle <= '0';
    else 
      data_w_exp_toggle <= not data_w_exp_toggle;
    end if;
  end if;
end process;

data_w1_exp <= not k_chars and not data_w_exp_toggle; -- and flag_enable;
data_w0_exp <= not k_chars and     data_w_exp_toggle; -- and flag_enable;


-- ----------------------------------------------------------------------------------
-- Double Word

gtp_rx_stream <= GTP_STREAM_IN_i;

process (GCK_i, RST_N_GCK_i)
begin
  if (RST_N_GCK_i = '0') then
    data_w1 <= (others => '0');
  elsif rising_edge(GCK_i) then
    if (data_w1_exp = '1') then
      data_w1 <= gtp_rx_stream;
    end if;
  end if;
end process;



data_fifo_rst   <= not RST_N_GCK_i;
data_fifo_din   <= data_w1 & gtp_rx_stream;
data_fifo_wr_en <= data_w0_exp and not data_fifo_full;
data_fifo_rd_en <= not data_fifo_empty and RX_DATA_DST_RDY_i;

DATA_FIFO_RX_i :  DATA_SYNC_FIFO
  port map (
    rst       => data_fifo_rst,               
    wr_clk    => GCK_i,        
    rd_clk    => CLK_i,         
    din       => data_fifo_din,      
    wr_en     => data_fifo_wr_en,        
    rd_en     => data_fifo_rd_en,        
    dout      => data_fifo_dout,  
    full      => data_fifo_full,         
    overflow  => data_fifo_overflow,     
    empty     => data_fifo_empty,        
    valid     => data_fifo_valid         
  );


msg_fifo_rst   <= not RST_N_GCK_i;
msg_fifo_din   <= gtp_rx_stream(7 downto 0);
msg_fifo_wr_en <= msg_flag and not msg_fifo_full;
msg_fifo_rd_en <= not msg_fifo_empty and RX_MSG_DST_RDY_i;

MSG_FIFO_RX_i :  MSG_SYNC_FIFO
  port map (
    rst       => msg_fifo_rst,               
    wr_clk    => GCK_i,        
    rd_clk    => CLK_i,         
    din       => msg_fifo_din,      
    wr_en     => msg_fifo_wr_en,        
    rd_en     => msg_fifo_rd_en,        
    dout      => msg_fifo_dout,  
    full      => msg_fifo_full,         
    overflow  => msg_fifo_overflow,     
    empty     => msg_fifo_empty,        
    valid     => msg_fifo_valid         
  );
  

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

-- Data out
RX_DATA_o         <= data_fifo_dout;
RX_DATA_SRC_RDY_o <= not data_fifo_empty;

-- Message out
RX_MSG_o          <= msg_fifo_dout;
RX_MSG_SRC_RDY_o  <= not msg_fifo_empty;

-- Alignment
ALIGN_REQ_o <= align_req;
  
-- Reset
GTP_SOFT_RESET_RX_o <= gtp_reset;

end Behavioral;
