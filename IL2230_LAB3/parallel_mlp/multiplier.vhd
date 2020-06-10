library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use work.neruron_pkg.all;

entity multiplier is
  generic(INPUT_SIZE : natural := 8);
  port(input_valid  : in  std_logic;
       reset        : in  std_logic;
       A            : in  std_logic_vector(INPUT_SIZE-1   downto 0);
       B            : in  std_logic_vector(INPUT_SIZE-1   downto 0);
       C            : out std_logic_vector(2*INPUT_SIZE-1 downto 0);
       output_valid : out std_logic
       );
end multiplier;


architecture behave of multiplier is
  signal C_int             : std_logic_vector(2*INPUT_SIZE-1 downto 0);
  signal output_valid_int  : std_logic := '0';
begin
  process(input_valid,reset)
  begin
    if reset = '1' then
      C_int <= (others => '0');
      end if;
    if rising_edge(input_valid) then
      output_valid_int<='0';
      C_int <= A*B;
      output_valid_int<='1';
    end if;
end process;
  C <= C_int;
  output_valid <= output_valid_int;
end architecture;
