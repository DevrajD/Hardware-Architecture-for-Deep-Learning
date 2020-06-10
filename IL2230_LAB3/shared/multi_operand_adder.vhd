library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.neuron_pkg.all;

entity multi_operand_adder is
  generic(NUMBER_OF_INPUTS : integer := CONST_NUMBER_OF_INPUTS;
          INPUT_WIDTH      : integer := CONST_INPUT_WIDTH);
    port(
    enable       : in  std_logic;  
    operands     : in  adder_input_type;
    output       : out std_logic_vector(2*INPUT_WIDTH-1+CONST_NUMBER_OF_ADDERS downto 0);
    output_valid : out std_logic
      );

end entity;


architecture behave of multi_operand_adder is
  type accumulate_type is array (NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(2*INPUT_WIDTH-1+CONST_NUMBER_OF_ADDERS downto 0);
  signal acc : accumulate_type := (others => (others => '0'));
--Set all to 0
signal output_int : std_logic_vector(2*INPUT_WIDTH-1+CONST_NUMBER_OF_ADDERS downto 0);
signal append     : std_logic_vector(CONST_NUMBER_OF_ADDERS-1 downto 0):=(others => '0');
signal output_valid_int : std_logic := '0';
begin
  process(enable)
    variable acc_v : unsigned(2*INPUT_WIDTH-1+CONST_NUMBER_OF_ADDERS downto 0) := (others => '0');
  begin
    if rising_edge(enable) then
      output_valid_int <= '0';
      acc_loop: for i in 0 to NUMBER_OF_INPUTS-1 loop
        acc_v := acc_v + unsigned(operands(i));
        end loop;
        output_valid_int <= '1';
        output_int <= std_logic_vector(acc_v);
        end if;
    end process;
    output_valid <= output_valid_int;
    output <= output_int;
      
  
end architecture;

