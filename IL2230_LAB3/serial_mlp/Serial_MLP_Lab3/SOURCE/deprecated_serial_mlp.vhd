library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.neuron_pkg.all;

entity serial_mlp is
	port(clk       : in  std_logic;
	   rst_n       : in  std_logic;
		mem_load	: in 	std_logic;
		Layer		: in  integer range 0 to NUMBER_OF_LAYERS;
		Neur		: in  integer range 0 to NEURONS_PER_LAYER;
	   input       : in  neuron_input_type; --array of std_logic_vectors
	   output      : out std_logic_vector(CONST_INPUT_WIDTH-1 downto 0));                                      
end serial_mlp;


architecture behave of serial_mlp is

--Components 
component parallel_neuron is
	generic (NUMBER_OF_INPUTS:integer:=CONST_NUMBER_OF_INPUTS; -- Arbitrary values.
			WIDTH_OF_INPUTS :integer:=CONST_INPUT_WIDTH);-- Arbitrary values,
	port(inputs         : in  neuron_input_type;--(NUMBER_OF_INPUTS-1 downto 0)(WIDTH_OF_INPUTS-1 downto 0);
		weights        : in  neuron_input_type;--(NUMBER_OF_INPUTS-1 downto 0)(WIDTH_OF_INPUTS-1 downto 0);
		output         : out std_logic_vector(WIDTH_OF_INPUTS-1 downto 0));
end component;


-- Types
type activation_memory_type is array(1 downto 0) of neuron_input_type;
type Type_State is (Entry, Processing, Exeet);

type weight_memory_perLayer_type is array(NEURONS_PER_LAYER-1 downto 0) of neuron_input_type;
type weight_memory_type is array(NUMBER_OF_LAYERS-1 downto 0) of weight_memory_perLayer_type;

-- Signals
signal activation_memory_banks, prev_activation_memory_banks : activation_memory_type;
Signal next_state			: Type_State := Processing;
Signal current_state 		: Type_State := Entry;
signal Mem_Bank_Control, prev_Mem_Bank_Control		: std_logic;
signal Layer_control, prev_Layer_control	: std_logic_vector(7 downto 0);
signal neuron_control, prev_neuron_control	: std_logic_vector(7 downto 0);
signal data_to_neuron, controlled_weights, prev_data_to_neuron, prev_controlled_weights 		: neuron_input_type;
signal neur_outputs, prev_neur_outputs		: std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
signal weight_memory		: weight_memory_type := (others => (others => (others => (0 => '1', others=>'0'))));

BEGIN

Weight_Memory_Proc: process(clk, rst_n)
	begin
	if rst_n = '0' then
		weight_memory <= (others => (others => (others => (0 => '1', others=>'0'))));
	elsif rising_edge(clk) then
		if mem_load = '1' then
			weight_memory(Layer)(Neur)<=input;
		end if;
	end if;
end process;


data_to_neuron 	<= activation_memory_banks(0) when Mem_Bank_Control = '0' else activation_memory_banks(1);

ACT : for i in 0 to NEURONS_PER_LAYER-1 generate
activation_memory_banks(1)(i) <= neur_outputs when Mem_Bank_Control = '0' else prev_activation_memory_banks(1)(i);
activation_memory_banks(0)(i) <= input(i) when Mem_Bank_Control = '0' and  current_state = Entry else neur_outputs when Mem_Bank_Control = '1'  else prev_activation_memory_banks(0)(i);
end generate;

controlled_weights <= weight_memory(to_integer(unsigned(Layer_control)))(to_integer(unsigned(neuron_control)));
								

NEURON : parallel_neuron
		generic map (NUMBER_OF_INPUTS => CONST_NUMBER_OF_INPUTS, -- Arbitrary values.
					WIDTH_OF_INPUTS => CONST_INPUT_WIDTH)
		
		port map	(inputs => data_to_neuron,
					weights => controlled_weights,
					output  => neur_outputs);		

STATE_CHANGER : process(clk,rst_n) --STATE CHANGER
				begin
					if(rst_n='0') then
						current_state 	<= Entry;
					elsif rising_edge(clk) then
						current_state 					<= next_state;
						prev_activation_memory_banks 	<= activation_memory_banks;
						prev_data_to_neuron 			<= data_to_neuron;
						prev_Layer_control 				<= Layer_control;
						prev_neuron_control 			<= neuron_control;
						prev_Mem_Bank_Control 			<= Mem_Bank_Control;
						prev_controlled_weights 		<= controlled_weights;
						prev_neur_outputs				<= neur_outputs;
					end if;
				end process;

FSM_Controller :process(current_state 					,
						next_state                      ,
						prev_activation_memory_banks    ,
						activation_memory_banks         ,
						prev_data_to_neuron             ,
						data_to_neuron                  ,
						prev_Layer_control              ,
						Layer_control                   ,
						prev_neuron_control             ,
						neuron_control                  ,
						prev_Mem_Bank_Control           ,
						Mem_Bank_Control                ,
						prev_controlled_weights         ,
						controlled_weights              ,
						input							,
						neur_outputs					,
						weight_memory					)
				begin
				
				case current_state is
					when Entry =>
						neuron_control <= (others => '0');
						--activation_memory_banks <= (others => (others => (others=>'1')));	
						output <= (others => '0');
						next_state 			<= Processing;
						Mem_Bank_Control 	<= '0';
						Layer_control		<= (others => '0');
						--data_to_neuron <= (others => (others => '0'));
						--activation_memory_banks(0) <= input;
						--controlled_weights 	<= (others => (others=>'0'));
						--prev_neur_outputs	<= neur_outputs;
					when Processing =>
						--controlled_weights <= prev_controlled_weights;
						Mem_Bank_Control <= prev_Mem_Bank_Control;
						--data_to_neuron <= prev_data_to_neuron;
						--activation_memory_banks <= prev_activation_memory_banks;	
						output <= (others => '0');
						next_state <= current_state;
						neuron_control <= prev_neuron_control;
						Layer_control <= prev_Layer_control;
						if unsigned(Layer_control) < NUMBER_OF_LAYERS-1 then	
							if unsigned(neuron_control) < NEURONS_PER_LAYER-1 then
								-- if Mem_Bank_Control = '0' then
									-- data_to_neuron 	<= activation_memory_banks(0);
									-- activation_memory_banks(1)(to_integer(unsigned(neuron_control))) <= neur_outputs;
									-- controlled_weights <= weight_memory(to_integer(unsigned(Layer_control)))(to_integer(unsigned(neuron_control)));
								-- else
									-- data_to_neuron 	<= activation_memory_banks(1);
									-- activation_memory_banks(0)(to_integer(unsigned(neuron_control))) <= neur_outputs;
									-- controlled_weights <= weight_memory(to_integer(unsigned(Layer_control)))(to_integer(unsigned(neuron_control)));
								-- end if;
								neuron_control <= std_logic_vector(unsigned(prev_neuron_control) + 1);
							else
								Layer_control <= std_logic_vector(unsigned(prev_Layer_control) + 1);
								Mem_Bank_Control <= not prev_Mem_Bank_Control;
								neuron_control <= (others => '0');
							end if;
						else
							next_state <= Exeet;					
						end if;
							
							
					
					when Exeet =>
						neuron_control <= (others=>'0');
						--data_to_neuron <= prev_data_to_neuron;
						Layer_control <= (others=>'0');
						Mem_Bank_Control <= prev_Mem_Bank_Control;
							-- if Mem_Bank_Control = '0' then
								-- data_to_neuron <= activation_memory_banks(0);
						output 			<= prev_neur_outputs;
								-- --controlled_weights <= special_weight_memory;
							-- else 
								-- data_to_neuron <= activation_memory_banks(1);
								-- output 			<= prev_neur_outputs;
								-- --controlled_weights <= special_weight_memory;
							-- end if;
						--activation_memory_banks <= prev_activation_memory_banks;	
						next_state <= Entry;
						--controlled_weights <= (others => (others=>'0'));
					end case;	
						
				end process;




end architecture;
