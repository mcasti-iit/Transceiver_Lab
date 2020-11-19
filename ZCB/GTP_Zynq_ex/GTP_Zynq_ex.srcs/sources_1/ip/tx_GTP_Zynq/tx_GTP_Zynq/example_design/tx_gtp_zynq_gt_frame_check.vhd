-------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 3.6
--  \   \         Application : 7 Series FPGAs Transceivers Wizard  
--  /   /         Filename : tx_gtp_zynq_gt_frame_check.vhd
-- /___/   /\      
-- \   \  /  \ 
--  \___\/\___\ 
--
--
-- Module tx_GTP_Zynq_GT_FRAME_CHECK
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard  
-- 
-- 
-- (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity tx_GTP_Zynq_GT_FRAME_CHECK is
generic
(
    RX_DATA_WIDTH            : integer := 16;
    RXCTRL_WIDTH             : integer := 2;
    WORDS_IN_BRAM            : integer := 256;
    CHANBOND_SEQ_LEN         : integer := 1;
    START_OF_PACKET_CHAR     : std_logic_vector (15 downto 0)  := x"027c"
);
port
(
    -- User Interface
    RX_DATA_IN               : in  std_logic_vector((RX_DATA_WIDTH-1) downto 0); 

    RXENPCOMMADET_OUT        : out std_logic;
    RXENMCOMMADET_OUT        : out std_logic;

    -- Error Monitoring
    ERROR_COUNT_OUT          : out std_logic_vector(7 downto 0);
    
    -- Track Data
    TRACK_DATA_OUT           : out std_logic;

    -- System Interface
    USER_CLK                 : in std_logic;       
    SYSTEM_RESET             : in std_logic
  
);


end tx_GTP_Zynq_GT_FRAME_CHECK;

architecture RTL of tx_GTP_Zynq_GT_FRAME_CHECK is
    attribute DowngradeIPIdentifiedWarnings: string;
    attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";
--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;

--***************************Internal Register Declarations********************
    signal  system_reset_r              :   std_logic;
    signal  system_reset_r2              :   std_logic;
    attribute keep: string;
    attribute keep of system_reset_r    :   signal is "true";
    attribute keep of system_reset_r2    :   signal is "true";
    attribute ASYNC_REG                        : string;
     attribute ASYNC_REG of system_reset_r     : signal is "TRUE";
     attribute ASYNC_REG of system_reset_r2     : signal is "TRUE";

    signal  begin_r                     :   std_logic;
    signal  data_error_detected_r       :   std_logic;
    signal  error_count_r               :   unsigned(8 downto 0);
    signal  error_detected_r            :   std_logic;
    signal  read_counter_i              :   unsigned(9 downto 0);    
    signal  read_counter_conv           :   std_logic_vector(9 downto 0);    
    signal  rx_data_r                   :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  rx_data_r_track             :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  start_of_packet_detected_r  :   std_logic;    
    signal  track_data_r                :   std_logic;
    signal  track_data_r2               :   std_logic;
    signal  track_data_r3               :   std_logic;
    signal  rx_data_r2                  :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  rx_data_r3                  :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  rx_data_r4                  :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  rx_data_r5                  :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  rx_data_r6                  :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  sel                         :   std_logic;
 
 
 
    signal  rx_chanbond_reg_bitwise_or_i:   std_logic; 
 

--*********************************Wire Declarations***************************
   
    signal  bram_data_r                 :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  rx_data_ram_r               :   std_logic_vector(79 downto 0);
    signal  error_detected_c            :   std_logic;
    signal  rx_data_aligned             :   std_logic_vector((RX_DATA_WIDTH-1) downto 0);
    signal  next_begin_c                :   std_logic;
    signal  next_data_error_detected_c  :   std_logic;
    signal  next_track_data_c           :   std_logic;
    signal  start_of_packet_detected_c  :   std_logic;
    signal  rx_data_has_start_char_c    :   std_logic;
    signal  rx_data_matches_bram_c      :   std_logic;
    signal  tied_to_ground_i            :   std_logic;
    signal  tied_to_ground_vec_i        :   std_logic_vector(31 downto 0);
    signal  tied_to_vcc_i               :   std_logic;


--*********************************User Defined Attribute*****************************

    type RomType is array(0 to 511) of std_logic_vector(79 downto 0);
    type check_type is(
    ST_LINK_DOWN, ST_LINK_UP);
    
  signal sm_link : std_logic := '0';
  signal link_ctr : std_logic_vector(6 downto 0) := "0000000";

    impure function InitRomFromFile (RomFileName : in string) return RomType is

         FILE RomFile : text open read_mode is RomFileName;
         variable RomFileLine : line;
         variable ROM : RomType;
    begin
         for i in RomType'range loop
           readline (RomFile, RomFileLine);
           hread (RomFileLine, ROM(i));
         end loop;
         return ROM;
    end function;

    signal ROM : RomType := InitRomFromFile("gt_rom_init_rx.dat");


   function or_reduce(arg: std_logic_vector) return std_logic is
	variable result: std_logic;
    begin
	result := '0';
	for i in arg'range loop
	    result := result or arg(i);
	end loop;
        return result;
    end;

--*********************************Main Body of Code***************************
begin

    --_______________________  Static signal Assigments _______________________   

    tied_to_ground_i        <= '0';
    tied_to_ground_vec_i    <= (others=>'0');
    tied_to_vcc_i           <= '1';

    --___________ synchronizing the async reset for ease of timing simulation ________
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            system_reset_r <= SYSTEM_RESET after DLY; 
            system_reset_r2 <= system_reset_r after DLY; 
        end if;
    end process; 


    --______________________ Register RXDATA once to ease timing ______________   

    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            rx_data_r  <= RX_DATA_IN   after DLY;
            rx_data_r2 <= rx_data_r    after DLY;
        end if;
    end process;
    --________________________________ State machine __________________________    
    
    
    -- State registers
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if(system_reset_r2 = '1') then
                begin_r                <=  '1' after DLY;
                track_data_r           <=  '0' after DLY;
                data_error_detected_r  <=  '0' after DLY;
            else
                begin_r                <=  next_begin_c after DLY;
                track_data_r           <=  next_track_data_c after DLY;
                data_error_detected_r  <=  next_data_error_detected_c after DLY;
            end if;
        end if;
    end process;

    -- Next state logic
    next_begin_c               <=   (begin_r and not start_of_packet_detected_r) or data_error_detected_r ;

    next_track_data_c          <=   (begin_r and start_of_packet_detected_r) or (track_data_r and not error_detected_r);
                                      
    next_data_error_detected_c <=   (track_data_r and error_detected_r);                               
        
    start_of_packet_detected_c <=   rx_data_has_start_char_c;

    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        start_of_packet_detected_r    <=   start_of_packet_detected_c after DLY;
    end if;    
    end process;
    
    -- Registering for timing
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        track_data_r2    <=   track_data_r after DLY;
    end if;    
    end process;

    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        track_data_r3    <=   track_data_r2 after DLY;
    end if;    
    end process;

    --______________________________ Capture incoming data ____________________    


    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if(system_reset_r2 = '1') then 
                rx_data_r4      <=  (others => '0') after DLY;
                rx_data_r5      <=  (others => '0') after DLY;
                rx_data_r6      <=  (others => '0') after DLY;
                rx_data_r_track <=  (others => '0') after DLY;
            else
                rx_data_r4      <=  rx_data_r3 after DLY;
                rx_data_r5      <=  rx_data_r4 after DLY;
                rx_data_r6      <=  rx_data_r5 after DLY;
                rx_data_r_track <=  rx_data_r6 after DLY;
            end if;
        end if;    
    end process;

    rx_data_aligned <= rx_data_r3;



    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if(system_reset_r2 = '1') then
                  sel  <=  '0'  after DLY;
            else 
                if((rx_data_r(7 downto 0) & rx_data_r2(15 downto 8)) = START_OF_PACKET_CHAR) then
                     sel   <=   '1'  after DLY;
                elsif(rx_data_r(15 downto 0) = START_OF_PACKET_CHAR) then
                     sel   <=   '0'  after DLY;
                end if;
            end if;
        end if;
    end process;
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if(system_reset_r2 = '1') then
                  rx_data_r3  <=  (others=>'0')  after DLY;
            else 
                if(sel = '1') then
                   rx_data_r3  <=  (rx_data_r(7 downto 0) & rx_data_r2(15 downto 8)) after DLY;
                else
                   rx_data_r3  <=  rx_data_r2;
                end if;
            end if;
        end if;
    end process;

    rx_data_has_start_char_c <= '1' when (rx_data_aligned = START_OF_PACKET_CHAR) 
                                else '0';




    --_____________________________ Assign output ports _______________________    


    --TRACK_DATA_OUT      <=  track_data_r;  


    -- Drive the enpcommaalign port of the gt for alignment
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if(system_reset_r2 = '1') then 
            RXENPCOMMADET_OUT   <= '0' after DLY;
        else              
            RXENPCOMMADET_OUT   <= '1' after DLY;
        end if;
    end if;    
    end process;

    -- Drive the enmcommaalign port of the gt for alignment
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if(system_reset_r2 = '1') then 
            RXENMCOMMADET_OUT   <= '0' after DLY;
        else              
            RXENMCOMMADET_OUT   <= '1' after DLY;
        end if;
    end if;    
    end process;


    --___________________________ Check incoming data for errors ______________
         
    
    --An error is detected when data read for the BRAM does not match the incoming data

    rx_data_matches_bram_c <= '0' when (rx_data_r_track /= bram_data_r) else '1';

    error_detected_c    <=   track_data_r3 and not rx_data_matches_bram_c;   
    
    --We register the error_detected signal for use with the error counter logic
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if(not(track_data_r = '1')) then 
            error_detected_r    <= '0' after DLY;
        else
            error_detected_r    <=  error_detected_c after DLY;
        end if;
    end if;    
    end process;

    --We count the total number of errors we detect. By keeping a count we make it less likely that we will miss
    --errors we did not directly observe. This counter must be reset when it reaches its max value
    process ( USER_CLK )
    begin
    if( USER_CLK'event and USER_CLK = '1') then
        if(system_reset_r2='1') then
            error_count_r       <=  (others => '0') after DLY;
        elsif(error_detected_r = '1') then
            error_count_r       <=  error_count_r + 1 after DLY;
        end if;
    end if;
    end process;
            
    --Here we connect the lower 8 bits of the count (the MSbit is used only to check when the counter reaches
    --max value) to the module output
    ERROR_COUNT_OUT     <=   std_logic_vector(error_count_r(7 downto 0));



process(USER_CLK)
  begin
    if( USER_CLK'event and USER_CLK = '1') then
       if(track_data_r='0') then
             sm_link  <= '0';
       else
    case sm_link is
      -- The link is considered to be down when the link counter initially has a value less than 67. When the link is
      -- down, the counter is incremented on each cycle where all PRBS bits match, but reset whenever any PRBS mismatch
      -- occurs. When the link counter reaches 67, transition to the link up state.
       when '0' =>
        if (error_detected_r = '1') then
          link_ctr <= (others => '0');
        else 
          if (link_ctr < "1000011") then
            link_ctr <= link_ctr + '1';
          else
            sm_link <= '1';
        end if;
      end if;

      -- When the link is up, the link counter is decreased by 34 whenever any PRBS mismatch occurs, but is increased by
      -- only 1 on each cycle where all PRBS bits match, up to its saturation point of 67. If the link counter reaches
      -- 0 (including rollover protection), transition to the link down state.
       when '1' => 
        if (error_detected_r = '1') then
          if (link_ctr > "0100001") then
            link_ctr <= link_ctr - "0100010";
            if (link_ctr = "0100010") then
              sm_link  <= '0';
            end if;
          else 
            link_ctr <= (others => '0');
            sm_link  <= '0';
          end if;
        else 
          if (link_ctr < "1000011") then
            link_ctr <= link_ctr + '1';
        end if;
      end if;
       when OTHERS =>
            sm_link  <= '0';
    end case;
  end if;
  end if;
 end process; 

   TRACK_DATA_OUT <= sm_link;

    --____________________________ Counter to read from BRAM __________________________    
    process( USER_CLK )
    begin
    if(USER_CLK'event and USER_CLK = '1') then
        if((system_reset_r2='1') or (read_counter_i = (WORDS_IN_BRAM-1)))  then
            read_counter_i   <=  (others => '0') after DLY;
        elsif(((start_of_packet_detected_r and not track_data_r)='1')) then
            read_counter_i   <=  "0000000000" after DLY;
        else read_counter_i  <=  read_counter_i + 1 after DLY;
        end if;
    end if;
    end process;

    --________________________________ BRAM Inference Logic _____________________________    

--Array slice from dat file to compare against receive data
datapath_80 : if(RX_DATA_WIDTH = 80) generate
begin
    bram_data_r         <= rx_data_ram_r((RX_DATA_WIDTH-1) downto 0);
end generate datapath_80;

datapath_16_20_32_40_64 : if((RX_DATA_WIDTH = 16) or (RX_DATA_WIDTH = 20) or (RX_DATA_WIDTH = 32) or (RX_DATA_WIDTH = 40) or (RX_DATA_WIDTH = 64)) generate
begin
    bram_data_r         <= rx_data_ram_r((16+RX_DATA_WIDTH-1) downto 16);
end generate datapath_16_20_32_40_64;

    read_counter_conv   <= std_logic_vector(read_counter_i);

    process (USER_CLK)
    begin
       if(USER_CLK'event and USER_CLK='1') then
         rx_data_ram_r <= ROM(conv_integer(read_counter_conv)) after DLY;
       end if;
    end process;
    
    
end RTL;           

