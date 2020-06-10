library ieee;
use ieee.std_logic_1164.all;
use work.neuron_pkg.all;
use ieee.math_real.all;
entity parallel_mac_tb is
end parallel_mac_tb;

architecture test of parallel_mac_tb is
  component parallel_mac is
  generic(NUMBER_OF_INPUTS:natural;
          WIDTH_OF_INPUTS :natural);
    port(input_valid    : in  std_logic;
         inputs         : in  neuron_input_type;
         weights        : in  neuron_input_type;
         output         : out std_logic_vector(WIDTH_OF_INPUTS-1 downto 0);
         output_valid   : out std_logic
         );
  end component;
  signal test_inputs : neuron_input_type := (X"0001",X"0002",X"0003",X"0004");
  signal test_weights: neuron_input_type :=
    (X"0001",X"0001",X"0001",X"0001");
  signal test_output    : std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
  signal input_valid_tb  : std_logic := '0';
  constant half_period : time := 10ns;
  signal clk_tb : std_logic := '0' ;
  signal valid_tb : std_logic := '0';

begin
    process(clk_tb)
    begin
        clk_tb  <= not clk_tb after half_period;
    end process;
    
    
    input_valid_tb <= '1' after 10 ns,
                      '0' after 20 ns;   
    
    
    
    
    
    
    DUT : parallel_mac generic map (NUMBER_OF_INPUTS => CONST_NUMBER_OF_INPUTS,WIDTH_OF_INPUTS => CONST_INPUT_WIDTH)
      port map (input_valid => input_valid_tb,
                inputs      => test_inputs,
                weights     => test_weights,
                output      => test_output,
                output_valid=> valid_tb
                );
end architecture;  


  

