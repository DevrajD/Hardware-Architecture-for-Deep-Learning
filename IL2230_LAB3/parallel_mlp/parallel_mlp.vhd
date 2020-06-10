library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.neuron_pkg.all;

entity parallel_mlp is
  generic(NUMBER_OF_LAYERS  :natural := 5; -- N 
          NEURONS_PER_LAYER :natural := 10);
  port(clk         : in  std_logic;
       reset       : in  std_logic;
       input_ready : in  std_logic; 
       input       : in  neuron_input_type; --array of std_logic_vectors
       output      : out neuron_input_type);                                      
end parallel_mlp;


architecture behave of parallel_mlp is

  component parallel_mac is
    generic(NUMBER_OF_INPUTS : natural;
            WIDTH_OF_INPUTS  : natural);
    port(
         input_valid   : in  std_logic;
         inputs        : in  neuron_input_type;
         weights       : in  neuron_input_type;
         output        : out std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
         output_valid  : out std_logic
         );
  end component;
-- Data type for propagating output between layers
  type output_propagation_type is array(NUMBER_OF_LAYERS-1 downto 0) of neuron_input_type; 


-- Holds the weight for all neurons in all layers. To address the weight w1 for
-- neuron 3 in layer 4 one would address it as (4)(3)(1) (Assuming we start
-- counting from 0)
  type weight_memory_type      is array(NEURONS_PER_LAYER-1 downto 0) of neuron_input_type;
  type weight_memory_full      is array(NUMBER_OF_LAYERS -1 downto 0) of weight_memory_type;
  type valid_type              is array(NUMBER_OF_LAYERS-1 downto 0) of std_logic_vector(NEURONS_PER_LAYER-1 downto 0);


  
-- Signals
  signal output_propagation    : output_propagation_type := (others => (others => (others => '0')));
  signal weight_memory         : weight_memory_full := (others =>(others =>(others => X"0002")));
  signal valid                 : valid_type  := (others => (others => '0')); 
  signal output_int            : neuron_input_type;
begin
  
  generate_first_layer : for k in 0 to NEURONS_PER_LAYER-1 generate
    first_layer : parallel_mac generic map(NUMBER_OF_INPUTS => CONST_NUMBER_OF_INPUTS,
                                        WIDTH_OF_INPUTS  => CONST_INPUT_WIDTH)
      port map(
               input_valid  => input_ready,
               inputs       => input, 
               output_valid => valid(0)(k),
               weights      => weight_memory(0)(k),
               output       => output_propagation(0)(k)
               );
  end generate;
     

  
  generate_layer_hidden : for i in 0 to NUMBER_OF_LAYERS-2 generate
  begin
    generate_neurons_hidden : for j in 0 to NEURONS_PER_LAYER-1 generate
      neuron : parallel_mac generic map(NUMBER_OF_INPUTS => CONST_NUMBER_OF_INPUTS,
                                        WIDTH_OF_INPUTS  => CONST_INPUT_WIDTH)
        port map(
                 input_valid  => valid(i)(j),
                 inputs       => output_propagation(i),
                 weights      => weight_memory(i+1)(j),
                 output       => output_propagation(i+1)(j),
                 output_valid => valid(i+1)(j)
                 );
    end generate;
  end generate;
  process(clk,reset)
  begin
  if reset = '1' then
    output_int <= (others => (others => '0'));
    elsif rising_edge(clk) and  (valid(NUMBER_OF_LAYERS-2)(NEURONS_PER_LAYER-1) = '1') then 
    output_int <= output_propagation(NUMBER_OF_LAYERS-1);
    end if;
    end process;
    
output <= output_int;


end architecture;
