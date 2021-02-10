-- ==============================================================================
-- DESCRIPTION:
-- Manages and controls SPI transactions
-- ------------------------------------------
-- File        : SPI_Manager.vhd
-- Revision    : 1.0
-- Author      : M. Casti (IIT)
-- Date        : 03/02/20221
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  10/09/2019 - M. Casti (IIT)
-- - Initial revision
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
-- delayed signal:  signal name followed by "_d"  (number of d declares how many clock periods)
-- registered sig.: signal name followed by "_r"  
-- rising edge:     signal name followed by "_up"  
-- falling edge:    signal name followed by "_dw" 
-- changing edge:   signal name followed by "_ch"
-- current state:   signal name followed by "_cs"
-- next state:      signal name followed by "_ns"
-- ==============================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity AD9517_Manager is
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
    DONE_o    : out std_logic;
    
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
end AD9517_Manager;

architecture Behavioral of AD9517_Manager is



-------------------------------------------------------------------------
-- Register Address constants
constant CHIP_ID_ADDR_c              : std_logic_vector(11 downto 0) := x"003"; 
constant CHIP_ID_c                   : std_logic_vector( 7 downto 0) := x"53";  -- "HHHHHHHH"; -- 
constant PON_DELAY_MS_c              : natural range 0 to 255        := 100;


-------------------------------------------------------------------------
-- Initial values for execution RAM 
-- that contains the start-up sequence intended to set-up the chip 
-- for operations.
-- Please refer to data-sheet
-------------------------------------------------------------------------
--  SIMPLE DUAL PORT RAM Signals
-- Legend:
-- LL       : Last Line: "1" stand for "This is the Last Line"
-- R/nW     : "1" is "Read", "0" is "Write"
-- REG ADDR : is the Address of Register in device
-- NUM/DATA : declare the number of bytes to be readen or the data to be written

type ram_type is array (31 downto 0) of std_logic_vector (21 downto 0);
constant SPI_SEQUENCE_c     : ram_type := ( 
--         LL   W/nR   REG ADDR  NUM/DATA
     0 => '0' &  '1'   & x"010" & x"7C",  -- PLL on
     1 => '0' &  '1'   & x"011" & x"03",  -- R parameter (LSB)
     2 => '0' &  '1'   & x"012" & x"00",  -- R parameter (MSB)
     3 => '0' &  '1'   & x"013" & x"0A",  -- A parameter
     4 => '0' &  '1'   & x"014" & x"0F",  -- B parameter(LSB)
     5 => '0' &  '1'   & x"015" & x"00",  -- B parameter(MSB)
     6 => '0' &  '1'   & x"016" & x"05",  -- P parameter
     7 => '0' &  '1'   & x"018" & x"06",  -- Reset
     8 => '0' &  '1'   & x"01C" & x"02",  -- Ref 1 on
     9 => '0' &  '1'   & x"232" & x"01",  -- Apply
    10 => '0' &  '1'   & x"1E0" & x"02",  -- ReVCO Divider
    11 => '0' &  '1'   & x"1E1" & x"02",  -- Input CLKs
    12 => '0' &  '1'   & x"018" & x"07",  -- Cal
    13 => '0' &  '1'   & x"232" & x"01",  -- Apply
    14 => '0' &  '1'   & x"199" & x"00",  -- LVDS Divider 2.1
    15 => '0' &  '1'   & x"19B" & x"00",  -- LVDS Divider 2.2
    16 => '0' &  '1'   & x"19E" & x"00",  -- LVDS Divider 3.1
    17 => '0' &  '1'   & x"1A0" & x"00",  -- LVDS Divider 3.2
    18 => '0' &  '1'   & x"140" & x"42",  -- Output 4 on
    19 => '0' &  '1'   & x"141" & x"42",  -- Output 5 on
    20 => '0' &  '1'   & x"142" & x"42",  -- Output 6 on
    21 => '0' &  '1'   & x"018" & x"07",  -- Cal
    22 => '1' &  '1'   & x"232" & x"01",  -- Apply
others => '0' &  '0'   & x"000" & x"00"   -- NOP
);

-- -------------------------------------------------
-- SIGNALS

-- Operation schedule RAM
signal little_ram           : ram_type := SPI_SEQUENCE_c;    -- RAM
signal we_ram               : std_logic;                     -- Write Enable
signal addr_wr_ram          : std_logic_vector(4 downto 0);  -- Write address
signal addr_rd_ram          : std_logic_vector(4 downto 0);  -- read address
signal din_ram              : std_logic_vector(21 downto 0); -- RAM data in
signal dout_ram             : std_logic_vector(21 downto 0); -- RAM data out

signal last_line_tab        : std_logic;
signal w_nr_cmd_tab         : std_logic;
signal reg_addr_tab         : std_logic_vector(11 downto 0); 
signal wr_reg_data_tab      : std_logic_vector( 7 downto 0); 

-- Outputs
signal cpol                 : std_logic;                                 -- spi clock polarity
signal cpha                 : std_logic;                                 -- spi clock phase
signal w_nr                 : std_logic;                                 -- '0' for read, '1' for write
signal tx_cmd               : std_logic_vector(cmd_width-1 downto 0);    -- command to transmit
signal tx_data              : std_logic_vector(d_width-1 downto 0);      -- data to transmit
signal enable               : std_logic;                                 -- initiate transaction   
signal error                : std_logic_vector (2 downto 0);             -- code error
signal done                 : std_logic;                                 -- done  

--  State Machine
type state_type is (RESET_st, IDLE_st, CHIP_ID_st, CHIP_INIT_st, PON_WAIT_st, WAIT_st, ERROR_st);
signal state : state_type;  -- Indicate state of State Machine

----------------------
signal pon_wait_cnt : std_logic_vector (7 downto 0);
signal busy_d       : std_logic;
signal busy_dw      : std_logic;
signal state_d      : state_type;
signal state_ch     : std_logic;

begin

-- ------------------------------------------------------------
-- RAM containing the initialization sequence for the chip

we_ram  <= '0';
din_ram <= (others => '0');
EXE_RAM_proc : process (CLK_i)
begin
  if rising_edge(CLK_i) then
    if (we_ram = '1') then
      little_ram(conv_integer(unsigned(addr_wr_ram))) <= din_ram;
    end if;
  end if;
end process;

dout_ram <= little_ram(conv_integer(unsigned(addr_rd_ram)));

last_line_tab   <= dout_ram(21);
w_nr_cmd_tab    <= dout_ram(20);
reg_addr_tab    <= dout_ram(19 downto 8);
wr_reg_data_tab <= dout_ram(7 downto 0);

-- -----------------------------------------------------------
-- Triggers
triggers_proc : process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    busy_d <= '0';
    state_d <= RESET_st;
  elsif rising_edge(CLK_i) then
    busy_d <= BUSY_i;
    state_d <= state;
  end if;
end process;

busy_dw  <= not BUSY_i and busy_d;
state_ch <= '1' when (state /= state_d) else '0';

-- -----------------------------------------------------------
-- State Machine

MAIN_FSM_proc : process(CLK_i, RST_N_i)
begin

  if (RST_N_i = '0') then                      
    pon_wait_cnt <= conv_std_logic_vector(PON_DELAY_MS_c,pon_wait_cnt'LENGTH);
    cpol         <= '0';
    cpha         <= '0';
    w_nr         <= '0';
    tx_cmd       <= (others => '0');
    tx_data      <= (others => '0');
    enable       <= '0';
    addr_rd_ram  <= (others => '0');
    error        <= (others => '0');
    done         <= '0';
    state        <= RESET_st;
    
  elsif rising_edge(CLK_i) then
    case state is
      when RESET_st     =>
        pon_wait_cnt <= conv_std_logic_vector(PON_DELAY_MS_c,pon_wait_cnt'LENGTH);
        cpol         <= '0';
        cpha         <= '0';
        w_nr         <= '0';
        tx_cmd       <= (others => '0');
        tx_data      <= (others => '0');
        enable       <= '0';
        addr_rd_ram  <= (others => '0');
        error        <= (others => '0');
        done         <= '0';
        if (EN1MS_i = '1') then
          state <= PON_WAIT_st;
        end if;
        
      when PON_WAIT_st  =>
        if (EN1MS_i = '1') then
          if (pon_wait_cnt = conv_std_logic_vector(0, pon_wait_cnt'LENGTH)) then
            state <= CHIP_ID_st;
          else
            pon_wait_cnt <= pon_wait_cnt - 1;
            state <= PON_WAIT_st;
          end if;
        end if;
        
      
      when CHIP_ID_st   =>
        w_nr   <= '0';
        tx_cmd <= "1000" & CHIP_ID_ADDR_c;
        enable <= not busy_d; 
        if (busy_dw = '1') then
          if (RX_DATA_i = CHIP_ID_c) then
            state <= CHIP_INIT_st;
          else
            error <= "001";
            state <= ERROR_st;
          end if;
        end if;
      
      when CHIP_INIT_st => 
        w_nr    <= w_nr_cmd_tab;
        tx_cmd  <= not w_nr_cmd_tab & "00" & '0' & reg_addr_tab;
        tx_data <= wr_reg_data_tab;
        enable  <= not busy_d;               -- busy_d and not BUSY_i in order to manage correctly the last enable in the table
        if (busy_dw = '1') then
          if (last_line_tab = '1') then
            state <= IDLE_st;
          else
            addr_rd_ram <= addr_rd_ram + 1;
            state <= CHIP_INIT_st;
          end if;
        end if;
           
      when IDLE_st      =>
        w_nr   <= '0';
        enable <= '0';
        done   <= '1'; 

      when WAIT_st      =>
        enable <= '0';
      
      when ERROR_st     =>
        enable <= '0';
            
    end case;
  end if;
end process;  



CPOL_o     <= '0';
CPHA_o     <= '0';
W_nR_o     <= w_nr;
TX_CMD_o   <= tx_cmd;
TX_DATA_o  <= tx_data;
ENABLE_o   <= enable;
ERROR_o    <= error;
DONE_o     <= done;

end Behavioral;
