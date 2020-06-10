
library ieee;
use ieee.std_logic_1164.all;
use work.neuron_pkg.all;
use ieee.math_real.all;

entity deb_para_neuron_tb is
end deb_para_neuron_tb;

architecture test of deb_para_neuron_tb is

component parallel_neuron is
	generic (NUMBER_OF_INPUTS:natural:=CONST_NUMBER_OF_INPUTS; -- Arbitrary values.
			WIDTH_OF_INPUTS :natural:=CONST_INPUT_WIDTH);-- Arbitrary values,
	port(inputs         : in  neuron_input_type;--(NUMBER_OF_INPUTS-1 downto 0)(WIDTH_OF_INPUTS-1 downto 0);
		weights        : in  neuron_input_type;--(NUMBER_OF_INPUTS-1 downto 0)(WIDTH_OF_INPUTS-1 downto 0);
		output         : out std_logic_vector(WIDTH_OF_INPUTS-1 downto 0));
end component;

signal test_inputs : neuron_input_type := (X"0101",X"0102",X"0103",X"0104",X"0105",X"0106");
signal test_weights: neuron_input_type := (X"0101",X"0101",X"0101",X"0101",X"0105",X"0106");
signal test_output    : std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);


begin
 
DUT: parallel_neuron
		generic map (NUMBER_OF_INPUTS => CONST_NUMBER_OF_INPUTS, -- Arbitrary values.
					WIDTH_OF_INPUTS => CONST_INPUT_WIDTH)
		
		port map	(inputs => test_inputs,
					weights => test_weights,
					output  => test_output);


end architecture;  


  


