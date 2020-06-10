`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2019 03:49:28 PM
// Design Name: 
// Module Name: activation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module activationStep #(
									parameter INPUT_NUMBER=32,
									parameter LOG_INPUT_NUMBER=5, 
									parameter DATA_WIDTH=64)
								(
									input [DATA_WIDTH -1:0] activ_in,
									output reg [DATA_WIDTH -1:0] activ_out
								);
								
    initial begin
        activ_out = {{DATA_WIDTH}{1'b0}};
    end
    // fixd point system : Q8.0 for 8 bits, Q8.8 for 16 bits, Q8.24 for 32 bits
    always@(*)
		begin
        if ( activ_in <= {1'b1, {(DATA_WIDTH - 1){1'b0}}} ) //this is in case act_in is signed. else, change 0 to 8'10000000
        begin
            activ_out <= 0;
            
        end
        else
        begin
            activ_out <= {{(DATA_WIDTH - 1){1'b0}}, 1'b1 };
        end
    end
endmodule
