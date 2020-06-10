library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.neuron_pkg.all;

entity serial_mlp is
	generic(NUMBER_OF_LAYERS  :natural := 3; -- N 
			  NEURONS_PER_LAYER :natural := CONST_NUMBER_OF_INPUTS);
	port(clk       : in  std_logic;
	   rst_n       : in  std_logic;
		mem_load		: in 	std_logic;
		Layer			: in  integer range 0 to NUMBER_OF_LAYERS;
		Neur			: in  integer range 0 to NEURONS_PER_LAYER;
	   input       : in  neuron_input_type; --array of std_logic_vectors
	   output      : out std_logic_vector(CONST_INPUT_WIDTH-1 downto 0));                                      
end serial_mlp;


architecture behave of serial_mlp is

--Components 
component parallel_neuron is
	generic (NUMBER_OF_INPUTS:natural:=CONST_NUMBER_OF_INPUTS; -- Arbitrary values.
			WIDTH_OF_INPUTS :natural:=CONST_INPUT_WIDTH);-- Arbitrary values,
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
signal Mem_Bank_Control, prev_Mem_Bank_Control, output_valid		: std_logic;
signal Layer_control, prev_Layer_control		: integer range 0 to NUMBER_OF_LAYERS;
signal neuron_control, prev_neuron_control	: integer RANGE 0 TO NEURONS_PER_LAYER;
signal neur_weights, data_to_neuron, controlled_weights, prev_data_to_neuron, prev_controlled_weights 		: neuron_input_type;
signal neur_outputs		: std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
signal weight_memory		: weight_memory_type := (others => (others => (others => (others=>'1'))));

BEGIN

Weight_Memory_Proc: process(clk, rst_n)
	begin
	if rst_n = '0' then
		weight_memory <= (others => (others => (others => (others=>'0'))));
	elsif rising_edge(clk) then
		if mem_load = '1' then
			weight_memory(Layer)(Neur)<=input;
		end if;
	end if;
end process;



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
						current_state 	<= next_state;
						prev_activation_memory_banks <= activation_memory_banks;
						prev_data_to_neuron <= data_to_neuron;
						prev_Layer_control <= Layer_control;
						prev_neuron_control <= neuron_control;
						prev_Mem_Bank_Control <= Mem_Bank_Control;
						prev_controlled_weights <= controlled_weights;
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
						controlled_weights              )
				begin
				
				case current_state is
					when Entry =>
						
						neuron_control <= prev_neuron_control;
						activation_memory_banks <= prev_activation_memory_banks;	
						output <= (others => '0');
						next_state 			<= Processing;
						Mem_Bank_Control 	<= '0';
						Layer_control		<= 0;
						data_to_neuron <= (others => (others => '0'));
						
							activation_memory_banks(0) <= input;
						
						controlled_weights <= (others => (others=>'0'));
						
					when Processing =>
						controlled_weights <= prev_controlled_weights;
						Mem_Bank_Control <= prev_Mem_Bank_Control;
						data_to_neuron <= prev_data_to_neuron;
						activation_memory_banks <= prev_activation_memory_banks;	
						output <= (others => '0');
						next_state <= Processing;
						neuron_control <= prev_neuron_control;
						Layer_control <= prev_Layer_control;
						if Layer_control < NUMBER_OF_LAYERS then	
							if neuron_control < NEURONS_PER_LAYER then
								if Mem_Bank_Control = '0' then
									data_to_neuron 	<= activation_memory_banks(0);
									activation_memory_banks(1)(neuron_control) <= neur_outputs;
									controlled_weights <= weight_memory(Layer_control)(neuron_control);
								else
									data_to_neuron 	<= activation_memory_banks(1);
									activation_memory_banks(0)(neuron_control) <= neur_outputs;
									controlled_weights <= weight_memory(Layer_control)(neuron_control);
								end if;
								neuron_control <= prev_neuron_control + 1;
							else
								Layer_control <= prev_Layer_control + 1;
								Mem_Bank_Control <= not prev_Mem_Bank_Control;
								neuron_control <= 0;
							end if;
						else
							next_state <= Exeet;					
						end if;
							
							
					
					when Exeet =>
						neuron_control <= 0;
						data_to_neuron <= prev_data_to_neuron;
						Layer_control <= 0;
						Mem_Bank_Control <= prev_Mem_Bank_Control;
							if Mem_Bank_Control = '0' then
								data_to_neuron <= activation_memory_banks(0);
								output 			<= neur_outputs;
								--controlled_weights <= special_weight_memory;
							else 
								data_to_neuron <= activation_memory_banks(1);
								output 			<= neur_outputs;
								--controlled_weights <= special_weight_memory;
							end if;
						activation_memory_banks <= prev_activation_memory_banks;	
						next_state <= Entry;
						controlled_weights <= (others => (others=>'0'));
					end case;	
						
				end process;




end architecture;
