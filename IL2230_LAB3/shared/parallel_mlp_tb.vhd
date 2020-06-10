library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.neuron_pkg.all;

entity parallel_mlp_tb is
end entity;




architecture test of parallel_mlp_tb is
  component parallel_mlp is
    generic(NUMBER_OF_LAYERS   : natural;
            NEURONS_PER_LAYER  : natural);
    port(clk         : in  std_logic;
         reset       : in  std_logic;
         input_ready : in  std_logic; 
         input       : in  neuron_input_type; --array of std_logic_vectors
         output      : out neuron_input_type);
    end component;

  signal test_input     : neuron_input_type := (X"0001",X"0002",X"0003",X"0004");
  signal test_output    : neuron_input_type;
  signal input_ready_tb : std_logic := '0'; 
begin



  input_ready_tb <= '1' after 10 ns; 

  
  mlp : parallel_mlp generic map(NUMBER_OF_LAYERS => 5,
                                 NEURONS_PER_LAYER => 3)
    port map   (clk          => '1',
                reset        => '1',
                input_ready  => input_ready_tb,
                input        => test_input,
                output       => test_output);




end architecture;
