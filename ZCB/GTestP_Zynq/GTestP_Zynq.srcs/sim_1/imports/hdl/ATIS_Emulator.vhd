
use std.env.stop;

library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use ieee.std_logic_arith.all;
  use STD.textio.all;

entity ATIS_Emulator is
  generic(
    NUM_X_PIXEL_g           : integer := 304; -- 16;
    NUM_Y_PIXEL_g           : integer := 240; --  4;
    TDY_WIDTH_g             : integer := 8; 
    TDX_WIDTH_g             : integer := 10;
    --
    EVENT_SOURCE_PATH_g     : string;
    EVENT_SOURCE_FILENAME_g : string  := "Events.txt"
    );
  port ( 
    TDX             : out std_logic_vector (TDX_WIDTH_g-1 downto 0);  -- Note: TDX comprehends the polarity bit
    TDY             : out std_logic_vector (TDY_WIDTH_g-1 downto 0);
    TDReqX          : out std_logic;
    TDAckXB         : in std_logic
    );
end ATIS_Emulator;

architecture Behavioral of ATIS_Emulator is

--                                    Min       Max
constant Tadr : time := 12 ns; --    0 ns     12 ns 
constant Tra  : time := 12 ns; --   12 ns      --
constant Tar  : time := 12 ns; --    0 ns     12 ns
constant Taw  : time := 25 ns; --   25 ns      --
constant Trd  : time := 25 ns; --   25 ns      --

signal TDAckXB_dummy : std_logic;

procedure TD_SPIKE 
  (
    timedly            : in time;
    constant x_i       : integer range 0 to NUM_X_PIXEL_g-1;
    constant y_i       : integer range 0 to NUM_Y_PIXEL_g-1;
    constant p_i       : integer range 0 to 1;
    signal tdx_o       : out std_logic_vector(TDX_WIDTH_g-1 downto 0);  
    signal tdy_o       : out std_logic_vector(TDY_WIDTH_g-1 downto 0);
    signal td_req_o    : out std_logic;
    signal td_ack_i    : in std_logic
    ) is
  variable pol         : std_logic_vector(0 downto 0);
begin
  wait for timedly;
  td_req_o <= '1';
	wait for Tadr;
	pol      := conv_std_logic_vector(p_i, 1);
  tdy_o    <= conv_std_logic_vector(y_i, TDY_WIDTH_g);
  tdx_o    <= conv_std_logic_vector(x_i, TDX_WIDTH_g-1) & pol;
  wait until td_ack_i'event and td_ack_i = '0';
  --   wait for 1 us;
  wait for Tar;
  td_req_o <= '0';
  wait for Trd;
  if (td_ack_i = '0') then wait until td_ack_i = '1'; end if;
end TD_SPIKE;

begin

stimuli : process
file     the_file         : text;
variable file_header      : line;
variable event_line       : line;
variable event_number     : integer := 0;
variable event_time       : time    := 0 ns;
variable event_x          : integer := 0;
variable event_y          : integer := 0;
variable event_pol        : integer := 0;
variable previous_time    : time    := 0 ns;   
variable delta_time       : time    := 0 ns;
variable event_cnt        : integer := 0;   
constant SOURCE_FILE_c    : string  := EVENT_SOURCE_PATH_g  & EVENT_SOURCE_FILENAME_g;
constant PROCESS_DELAY_c  : time    := 60 ns;
variable last_event_num   : integer := 0;
variable percentage       : integer := 0;
variable last_percentage  : integer := 0;
begin
  TDX       <= (others => '0');
  TDY       <= (others => '0');
  TDReqX    <= '0';

  file_open(the_file, SOURCE_FILE_c,  read_mode);
  readline(the_file, file_header);
  readline(the_file, file_header);
  while not endfile(the_file) loop
    readline(the_file, event_line);
    read(event_line, last_event_num);
    end loop;
  file_close(the_file);
  report "Found "& integer'image(last_event_num) & " events to be processed";
  
  file_open(the_file, SOURCE_FILE_c,  read_mode);
  readline(the_file, file_header);
  readline(the_file, file_header);
  
  while not endfile(the_file) loop
    readline(the_file, event_line);
    read(event_line, event_number);
    read(event_line, event_time);
    read(event_line, event_x);
    read(event_line, event_y);
    read(event_line, event_pol);
 --   report "@ "& time'image(event_time) & " - Event "& integer'image(event_x) & " " & integer'image(event_y) & " (" & integer'image(event_pol)& ")";
    delta_time := event_time - previous_time - PROCESS_DELAY_c; 
    TD_SPIKE ( delta_time, event_x, event_y, event_pol, TDX, TDY, TDReqX, TDACkXB);
    previous_time := event_time;
    event_cnt     := event_cnt + 1;
    percentage := integer(100.0 *  real(event_cnt) / real(last_event_num));
    if (percentage >= last_percentage + 10) then
      report integer'image(percentage) & "% done";
      last_percentage := percentage;
    end if;
    end loop;
  file_close(the_file);
  wait for 1 us;
  report "Processed "& integer'image(event_cnt) & " events in "& time'image(now);
  stop;
  wait;
end process;

end Behavioral;
