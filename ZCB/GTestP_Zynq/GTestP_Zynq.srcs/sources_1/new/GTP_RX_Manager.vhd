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

entity GTP_RX_Manager is
  generic ( 
    RX_DATA_IN_WIDTH_g      : integer range 0 to 64 := 16;    -- Width of RX Data - GTP side 
    RX_DATA_OUT_WIDTH_g     : integer range 0 to 64 := 32     -- Width of RX Data - Fabric side
    );
  port (
    -- Clock in port
    CLK_i                   : in  std_logic;   -- Input clock - Fabric side
    GCK_i                   : in  std_logic;   -- Input clock - GTP side     
    RST_CLK_N_i             : in  std_logic;   -- Asynchronous active low reset (clk clock)
    RST_GCK_N_i             : in  std_logic;   -- Asynchronous active low reset (gck clock)

    -- Control
    GTP_IS_ALIGNED_i        : in  std_logic;
    ALIGN_REQ_o             : out  std_logic;
    
    -- Status
    OVERRIDE_GCK_o          : out std_logic;
  
    -- Data in 
    RX_DATA_IN_i            : in  std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);
    RX_CHAR_IS_K_i          : in  std_logic_vector((RX_DATA_IN_WIDTH_g/8)-1 downto 0);
     
    -- Data out
    RX_DATA_OUT_o           : out std_logic_vector(RX_DATA_OUT_WIDTH_g-1 downto 0);
    RX_DATA_OUT_SRC_RDY_o   : out std_logic;
    RX_DATA_OUT_DST_RDY_i   : in  std_logic
    );
end GTP_RX_Manager;


architecture Behavioral of GTP_RX_Manager is

component DATA_FIFO_TX
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


signal fifo_din        : std_logic_vector(31 downto 0);
signal fifo_wr_en      : std_logic;
signal fifo_rd_en      : std_logic;
signal fifo_dout       : std_logic_vector(31 downto 0);
signal fifo_full       : std_logic;
signal fifo_overflow   : std_logic;
signal fifo_empty      : std_logic;
signal fifo_valid      : std_logic;
signal fifo_rst        : std_logic;

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

signal gtp_rx_stream      : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);

signal flag_enable        : std_logic; 
signal idle_exp_toggle   : std_logic;
signal idle_head          : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);
signal idle_head_flag     : std_logic;
signal idle_head_exp      : std_logic;
signal idle_tail          : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);
signal idle_tail_flag     : std_logic;
signal idle_tail_exp      : std_logic;

signal gtp_align          : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);         
signal gtp_align_flag     : std_logic;          

signal error_word         : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);         
signal error_word_flag    : std_logic; 

signal data_w_exp_toggle  : std_logic;
signal data_w0            : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);
signal data_w0_flag       : std_logic;
signal data_w0_exp        : std_logic;
signal data_w1            : std_logic_vector(RX_DATA_IN_WIDTH_g-1 downto 0);
signal data_w1_flag       : std_logic;
signal data_w1_exp        : std_logic;


signal idle_head_ok       : std_logic;
signal idle_head_error    : std_logic;
signal idle_tail_ok       : std_logic;
signal idle_tail_error    : std_logic;
signal gtp_align_ok       : std_logic;
signal gtp_align_error    : std_logic;

signal dword_align_ok     : std_logic;
signal dword_align_error  : std_logic;

begin



-- ----------------------------------------------------------------------------------
-- Kind of data
k_chars <= '1' when (RX_CHAR_IS_K_i = "11") else '0';

process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    k_chars_d <= '0';
  elsif rising_edge(GCK_i) then
    k_chars_d <= k_chars;
  end if;
end process;

k_chars_up <= k_chars and not k_chars_d;



process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    idle_exp_toggle <= '0';
  elsif rising_edge(GCK_i) then
    if (k_chars = '0') then
      idle_exp_toggle <= '0';
    else 
      idle_exp_toggle <= not idle_exp_toggle;
    end if;
  end if;
end process;


-- IDLE CHECK
-- Idle Word toggle
process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    flag_enable <= '0';
  elsif rising_edge(GCK_i) then
    flag_enable <= '1';
  end if;
end process;

idle_head_exp <= k_chars and not idle_exp_toggle and flag_enable;
idle_tail_exp <= k_chars and     idle_exp_toggle and flag_enable;



idle_head_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_0 & K28_1) else '0'; 
idle_tail_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_2 & K28_3) else '0'; 
-- data_w0_flag     <= '1' when (k_chars = '0' and gtp_rx_stream = ) else '0'; 
-- data_w1_flag     <= '1' when (k_chars = '0' and gtp_rx_stream = ) else '0'; 
gtp_align_flag   <= '1' when (k_chars = '1' and gtp_rx_stream = K28_5 & K28_5) else '0'; 
error_word_flag  <= '1' when (k_chars = '1' and gtp_rx_stream = K30_7 & K30_7
) else '0'; 


process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    idle_head_ok       <= '0';
    idle_head_error    <= '0';
    idle_tail_ok       <= '0';
    idle_tail_error    <= '0';
    gtp_align_ok       <= '0';
    gtp_align_error    <= '0';
    dword_align_ok     <= '0';
    dword_align_error  <= '0';
  elsif rising_edge(GCK_i) then
  
  end if;
end process;




-- Event Word toggle
process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    data_w_exp_toggle <= '0';
  elsif rising_edge(GCK_i) then
    if (k_chars = '1') then
      data_w_exp_toggle <= '0';
    else 
      data_w_exp_toggle <= not data_w_exp_toggle;
    end if;
  end if;
end process;

data_w1_exp <= not k_chars and not data_w_exp_toggle and flag_enable;
data_w0_exp <= not k_chars and     data_w_exp_toggle and flag_enable;


-- ----------------------------------------------------------------------------------
-- Double Word

gtp_rx_stream <= RX_DATA_IN_i;

process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    data_w1 <= (others => '0');
  elsif rising_edge(GCK_i) then
    if (data_w1_exp = '1') then
      data_w1 <= gtp_rx_stream;
    end if;
  end if;
end process;



fifo_rst   <= not RST_GCK_N_i;
fifo_din   <= data_w1 & gtp_rx_stream;
fifo_wr_en <= data_w0_exp and not fifo_full;
fifo_rd_en <= not fifo_empty and RX_DATA_OUT_DST_RDY_i;

DATA_FIFO_TX_i :  DATA_FIFO_TX
  port map (
    rst       => fifo_rst,               
    wr_clk    => GCK_i,        
    rd_clk    => CLK_i,         
    din       => fifo_din,      
    wr_en     => fifo_wr_en,        
    rd_en     => fifo_rd_en,        
    dout      => fifo_dout,  
    full      => fifo_full,         
    overflow  => fifo_overflow,     
    empty     => fifo_empty,        
    valid     => fifo_valid         
  );


-- ----------------------------------------------------------------------------------
-- GTP Alignement

process (GCK_i, RST_GCK_N_i)
begin
  if (RST_GCK_N_i = '0') then
    align_req <= '0';
  elsif rising_edge(GCK_i) then
    align_req <= not GTP_IS_ALIGNED_i;
  end if;
end process;


-- ----------------------------------------------------------------------------------
-- OUTPUTs

-- Data out
RX_DATA_OUT_o         <= fifo_dout;
RX_DATA_OUT_SRC_RDY_o <= not fifo_empty;

-- Alignment
ALIGN_REQ_o <= align_req;
  


end Behavioral;
