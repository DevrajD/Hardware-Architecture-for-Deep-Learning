library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.neuron_pkg.all;

entity parallel_neuron is
  generic(NUMBER_OF_INPUTS:natural:=CONST_NUMBER_OF_INPUTS; -- Arbitrary values.
          WIDTH_OF_INPUTS :natural:=CONST_INPUT_WIDTH);-- Arbitrary values,
  port(inputs         : in  neuron_input_type;--(NUMBER_OF_INPUTS-1 downto 0)(WIDTH_OF_INPUTS-1 downto 0);
       weights        : in  neuron_input_type;--(NUMBER_OF_INPUTS-1 downto 0)(WIDTH_OF_INPUTS-1 downto 0);
       output         : out std_logic_vector(WIDTH_OF_INPUTS-1 downto 0));
end parallel_neuron;

architecture behave of parallel_neuron is


component activationStep is
	generic(INPUT_NUMBER	:integer;
	LOG_INPUT_NUMBER 		:integer;
	DATA_WIDTH      		:integer
	);
	port(
	activ_in         : in   std_logic_vector(DATA_WIDTH-1  downto 0);
	activ_out        : out  std_logic_vector(DATA_WIDTH-1  downto 0)
	);
end component; 
  
  
  
component newSigmoid is
	generic(INPUT_NUMBER	:integer;
	DATA_WIDTH      		:integer
	);
	port(
	activ_in         : in   std_logic_vector(DATA_WIDTH-1  downto 0);
	activ_out        : out  std_logic_vector(DATA_WIDTH-1  downto 0)
	);
end component; 
  
  
  
component activationReLU is
	generic(INPUT_NUMBER	:integer;
	LOG_INPUT_NUMBER 		:integer;
	DATA_WIDTH      		:integer
	);
	port(
	activ_in         : in   std_logic_vector(DATA_WIDTH-1  downto 0);
	activ_out        : out  std_logic_vector(DATA_WIDTH-1  downto 0)
	);
end component; 


type muls is array(NUMBER_OF_INPUTS-1 downto 0) of adder_input_type;
type adds is array(NUMBER_OF_INPUTS-1 downto 0) of adder_input_type;

signal post_mul  : adder_input_type;
signal post_adds : adder_input_type;
signal input_activation    : std_logic_vector(WIDTH_OF_INPUTS-1 downto 0);
signal zeros : std_logic_vector(post_adds(NUMBER_OF_INPUTS-1)'length - 1 downto 0):= (others => '0');
begin

MUL: for i in 0 to NUMBER_OF_INPUTS-1 generate 
	post_mul(i) <= std_logic_vector(unsigned(weights(i)) * unsigned(inputs(i)));
	end generate;

ADD: for i in 1 to NUMBER_OF_INPUTS-1 generate
	post_adds(i) <= std_logic_vector(unsigned(post_adds(i-1)) + unsigned(post_mul(i)));
	end generate;
post_adds(0) <= post_mul(0);
--input_activation <= post_adds(NUMBER_OF_INPUTS-1)(WIDTH_OF_INPUTS-1 downto 0) when unsigned(post_adds(NUMBER_OF_INPUTS-1)(2*CONST_INPUT_WIDTH-1 downto WIDTH_OF_INPUTS)) = 0 else (others=>'1');

--below is ReLU simplified
-- process(post_adds, post_mul)
-- begin
-- if (unsigned(post_adds(NUMBER_OF_INPUTS-1)(integer_width - 1 + 2*fraction_width downto (2-1)*fraction_width)) > 0) then
	-- if unsigned(post_adds(NUMBER_OF_INPUTS-1)(post_adds(NUMBER_OF_INPUTS-1)'length - 1 downto integer_width+2*fraction_width)) = 0 then 
		-- output <= post_adds(NUMBER_OF_INPUTS-1)(integer_width - 1 + 2*fraction_width downto (2-1)*fraction_width);
	-- else
		-- output <= (others => '1');
	-- end if;
	-- else
		-- output <= (others => '0');
-- end if;
-- end process;
-- output <= post_adds(NUMBER_OF_INPUTS-1)(integer_width - 1 + 2*fraction_width downto (2-1)*fraction_width)  when 
		-- unsigned(post_adds(NUMBER_OF_INPUTS-1)(integer_width - 1 + 2*fraction_width downto (2-1)*fraction_width)) >= 0 else (others => '0');

input_activation <= post_adds(NUMBER_OF_INPUTS-1)(integer_width - 1 + 2*fraction_width downto (2-1)*fraction_width)  when 
		 unsigned(post_adds(NUMBER_OF_INPUTS-1)(post_adds(NUMBER_OF_INPUTS-1)'length - 1 downto integer_width+2*fraction_width)) = 0 else (others => '1');


Activation0 : IF Acti = 0 generate
Activation_Step: activationStep generic map( INPUT_NUMBER => CONST_NUMBER_OF_INPUTS ,
					  LOG_INPUT_NUMBER =>      integer(ceil(log2( real(CONST_NUMBER_OF_INPUTS)))),
					  DATA_WIDTH =>      CONST_INPUT_WIDTH )
					  port map( 
					  activ_in => input_activation  ,
					  activ_out => output );
end generate;

Activation1 : IF Acti = 1 generate
activation_ReLU: activationReLU generic map( INPUT_NUMBER => CONST_NUMBER_OF_INPUTS ,
					 LOG_INPUT_NUMBER =>      integer(ceil(log2( real(CONST_NUMBER_OF_INPUTS)))),
					 DATA_WIDTH =>      CONST_INPUT_WIDTH )
					 port map( 
					 activ_in => input_activation  ,
					 activ_out => output );
end generate;

Activation2 : IF Acti = 2 generate
activation_Sigmoid: newSigmoid generic map( INPUT_NUMBER => CONST_NUMBER_OF_INPUTS ,
					
					  DATA_WIDTH =>      CONST_INPUT_WIDTH )
					  port map(
					  activ_in => input_activation ,
					  activ_out => output );
end generate;

end architecture;
