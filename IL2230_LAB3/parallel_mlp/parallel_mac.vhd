library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.neuron_pkg.all;

entity parallel_mac is
  generic(NUMBER_OF_INPUTS:natural:=CONST_NUMBER_OF_INPUTS; -- Arbitrary values.
          WIDTH_OF_INPUTS :natural:=CONST_INPUT_WIDTH);-- Arbitrary values,
  port(input_valid    : in  std_logic;
       inputs         : in  neuron_input_type;
       weights        : in  neuron_input_type;
       output         : out std_logic_vector(WIDTH_OF_INPUTS-1 downto 0);
       output_valid   : out std_logic
       );
end parallel_mac;

architecture behave of parallel_mac is
  component multiplier is
    generic(INPUT_SIZE : natural);
    port(input_valid   : in  std_logic;
         reset         : in  std_logic;
         A             : in  std_logic_vector(INPUT_SIZE-1   downto 0);
         B             : in  std_logic_vector(INPUT_SIZE-1   downto 0);
         C             : out std_logic_vector(2*INPUT_SIZE-1 downto 0);
         output_valid  : out std_logic
        );
  end component; 

  component multi_operand_adder is
    generic(NUMBER_OF_INPUTS : integer;
            INPUT_WIDTH      : integer);
    port(enable       : in  std_logic;
         operands     : in  adder_input_type;
         output       : out std_logic_vector(2*INPUT_WIDTH-1+CONST_NUMBER_OF_ADDERS downto 0);
         output_valid : out std_logic);
  end component;

  component activationStep is
      generic(INPUT_NUMBER: integer;
             LOG_INPUT_NUMBER :integer;
             DATA_WIDTH      : integer
);
    port(clk   : in  std_logic;
         activ_in         : in  std_logic_vector( DATA_WIDTH-1   downto 0);
         activ_out        : out  std_logic_vector(DATA_WIDTH-1  downto 0)
        );
  end component; 
  
  
  
    component activationSigmoid is
      generic(INPUT_NUMBER: integer;
             DATA_WIDTH      : integer
);
    port(
         activ_in         : in   std_logic_vector(DATA_WIDTH-1   downto 0);
         activ_out        : out  std_logic_vector(DATA_WIDTH-1  downto 0);
         enable           : in   std_logic;
         output_valid     : out  std_logic
         );
  end component; 
  
  
  
    component activationReLU is
      generic(INPUT_NUMBER: integer;
             LOG_INPUT_NUMBER :integer;
             DATA_WIDTH      : integer
);
    port(clk   : in  std_logic;
         activ_in         : in  std_logic_vector(DATA_WIDTH-1   downto 0);
         activ_out        : out  std_logic_vector(DATA_WIDTH-1  downto 0)
        );
  end component; 
  
  
  
  
  
  constant NUMBER_OF_ADDERS  : integer := integer(ceil(log2(real(NUMBER_OF_INPUTS))));
  signal multiplier_outputs  : adder_input_type;
  signal multiplier_valid    : std_logic_vector(NUMBER_OF_INPUTS-1 downto 0);
  constant validation        : std_logic_vector(NUMBER_OF_INPUTS-1 downto 0) := (others => '1');
  signal enable_int          : std_logic := '0';
  signal adder_output_int    : std_logic_vector(2*WIDTH_OF_INPUTS-1+CONST_NUMBER_OF_ADDERS downto 0);
  signal adder_output_valid  : std_logic; 
  signal input_activation    : std_logic_vector(WIDTH_OF_INPUTS-1 downto 0);
  signal output_reg          : std_logic_vector(WIDTH_OF_INPUTS-1 downto 0);
  signal neuron_output_valid : std_logic; 
   signal TEST               : std_logic_vector(CONST_FP_INTEGER + CONST_NUMBER_OF_ADDERS downto 0  );
begin
 -- Generate the parallel multipliers
  generate_multipliers : for i in 0 to NUMBER_OF_INPUTS-1 generate
  begin
    mul : multiplier generic map(INPUT_SIZE => WIDTH_OF_INPUTS)
      port map   (input_valid  => input_valid,
                  reset        => '0',
                  A            => inputs (i),
                  B            => weights(i),
                  C            => multiplier_outputs(i),
                  output_valid => multiplier_valid(i));
  end generate;

  enable_int <= '1' when multiplier_valid = validation else
                '0';
  
-- accumulate with a parallel adder tree (Not sure if balanced)
  add : multi_operand_adder generic map(NUMBER_OF_INPUTS => CONST_NUMBER_OF_INPUTS,
                                        INPUT_WIDTH      => CONST_INPUT_WIDTH)
    port map(enable       => enable_int,
             operands     => multiplier_outputs,
             output       => adder_output_int,
             output_valid => adder_output_valid); 

-- If the output of the adder is overflowed and not fitting the input format the input to the activation function
-- Will be saturated
input_activation <= adder_output_int( CONST_FP_INTEGER + 2*CONST_FP_FRACTIONAL - 1 downto CONST_FP_FRACTIONAL) when 
adder_output_int(2*WIDTH_OF_INPUTS-1+CONST_NUMBER_OF_ADDERS downto 2*WIDTH_OF_INPUTS-1+CONST_NUMBER_OF_ADDERS-CONST_FP_INTEGER) <= SATURATED
else (others => '1');


output <= input_activation;
output_valid <= input_activation(0);


-- dummy  activation for testing
--  unit_activation : process(clk, adder_output_valid)
--  begin
--    if rising_edge(clk) then
--      if(output_valid = '1') then
--        adder_output_int <= adder_output_int * '1';
--        activation_done <= '1';
--      else
--        activation_done <= '0'; 
--    end process;

--  sigmoid : activationSigmoid generic map(INPUT_NUMBER     => CONST_NUMBER_OF_INPUTS,
--                                          DATA_WIDTH       => CONST_INPUT_WIDTH)
--    port map(activ_in     => input_activation,
--             activ_out    => output,
--             enable       => adder_output_valid,
--             output_valid => output_valid);
  
  
 
--register for storing the output of the activation function and keep it for
--the next layer
--  process(clk,reset,activation_done)
--  begin
--    if(reset = '1') then
--      output_int <= (others => '0');
--    else
--      if rising_edge(clk) then
--        if activation_done = '1' then
--          reg_output              <= output_int;
--          neruon_output_valid_int <= '1';
--        else
--          neuron_output_valid_int <= '0';
--  end process;
 
  --         output              <= reg_output;   
    --       neuron_output_valid <= neuron_output_valid_int;  
  
end architecture;

