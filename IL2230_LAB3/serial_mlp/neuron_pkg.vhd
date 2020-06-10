library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;          
package neuron_pkg is
  constant CONST_INPUT_WIDTH      	: integer := 16;
  constant CONST_NUMBER_OF_INPUTS 	: integer := 6;
  constant NUMBER_OF_LAYERS 			: integer := 3;
  constant NEURONS_PER_LAYER    		: integer := CONST_NUMBER_OF_INPUTS;
  constant Bit_width	: integer:=CONST_INPUT_WIDTH;
		constant integer_width	: integer:= Bit_width/2; --4 when bit width 8
		constant fraction_width	: integer:=Bit_width-integer_width;
		constant Acti				: integer:= 1; --Chooses activation funciton
  --constant CONST_FP_INTEGER       : integer := 8; -- Q8.8
  --constant CONST_NUMBER_OF_ADDERS : integer := 3;
  --For checking if the value is saturated. size iss MSB downto the input size
  --constant SATURATED              : std_logic_vector(CONST_FP_INTEGER + CONST_NUMBER_OF_ADDERS downto 0  ) :=(0 => '1', others => '0');
  type neuron_input_type   is array(CONST_NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
  --type neuron_data_type    is array(CONST_NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);

  type adder_input_type   is array(CONST_NUMBER_OF_INPUTS-1 downto 0) of std_logic_vector(2*CONST_INPUT_WIDTH-1 downto 0);
end neuron_pkg;

