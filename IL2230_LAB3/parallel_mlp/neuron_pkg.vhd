library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;          
package neuron_pkg is
  constant CONST_INPUT_WIDTH      : natural := 16;
  constant CONST_NUMBER_OF_INPUTS : natural := 10;
  constant CONST_NUMBER_OF_ADDERS : integer := integer(ceil(log2(real(CONST_NUMBER_OF_INPUTS))));
  constant CONST_FP_FRACTIONAL    : integer := 8;
  constant CONST_FP_INTEGER       : integer := 8; -- Q8.8
  --For checking if the value is saturated. size iss MSB downto the input size
  constant SATURATED              : std_logic_vector(CONST_FP_INTEGER + CONST_NUMBER_OF_ADDERS downto 0  ) :=(0 => '1', others => '0');
  type neuron_input_type   is array(CONST_NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
    type neuron_data_type   is array(CONST_NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);

--  type neuron_input_type  is neuron_data_type; 
--  type neuron_weight_type is neuron_data_type;
  type adder_input_type   is array(CONST_NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(2*CONST_INPUT_WIDTH-1 downto 0);
end neuron_pkg;

