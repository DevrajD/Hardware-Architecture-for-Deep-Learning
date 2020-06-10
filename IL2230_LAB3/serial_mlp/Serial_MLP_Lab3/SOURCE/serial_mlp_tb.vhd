library ieee;
use ieee.std_logic_1164.all;
use work.neuron_pkg.all;
use ieee.math_real.all;
entity serial_mlp_tb is
end serial_mlp_tb;

architecture test of serial_mlp_tb is

component serial_mlp1 is
--	generic(NUMBER_OF_LAYERS  :natural := 4; -- N 
--			NEURONS_PER_LAYER :natural := CONST_NUMBER_OF_INPUTS);
	port(clk       : in  std_logic;
	   rst_n       : in  std_logic;
	   mem_load		: in 	std_logic;
		Layer		: in  integer range 0 to NUMBER_OF_LAYERS;
		Neur		: in  integer range 0 to NEURONS_PER_LAYER;
	   input       : in  neuron_input_type; --array of std_logic_vectors
	   output      : out std_logic_vector(CONST_INPUT_WIDTH-1 downto 0));                                      
end component;

signal clk 		: std_logic:='0';
signal rst_n    : std_logic;
signal input    : neuron_input_type; --array of std_logic_vectors
signal output   : std_logic_vector(CONST_INPUT_WIDTH-1 downto 0);
signal addr1	: integer range 0 to 4 := 0;
signal addr2 	: integer range 0 to CONST_NUMBER_OF_INPUTS:= 0;
signal mem_load : std_logic :='0';
--alias weightmm is <<signal .serial_mlp_tb.DUT.neur_weights : neuron_input_type>>;


begin

DUT: serial_mlp1 
	generic map (NUMBER_OF_LAYERS => 3, -- N 
			  NEURONS_PER_LAYER => 3)
	port map(clk   => clk,
	   rst_n   => rst_n,
	   mem_load		=> mem_load,
	   Layer		=> addr1,
	   Neur			=> addr2,
	   input   => input, --array of std_logic_vectors
	   output  => output);   

clk <= not clk after 5 ns;
--weightmm <= (X"0001",X"0002",X"0003",X"0004",X"0005",X"0006");
rst_n <='1';

		input <= (X"A801",X"A802",X"A803",X"A804",X"A805",X"A806");


end architecture;