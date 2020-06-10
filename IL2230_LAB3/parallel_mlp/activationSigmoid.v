`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2019 04:22:46 PM
// Design Name: 
// Module Name: activationSigmoid
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


module activationSigmoid
 #(parameter INPUT_NUMBER=32,
    parameter DATA_WIDTH=8)(
    input [DATA_WIDTH-1:0] activ_in,
    output reg [DATA_WIDTH-1:0] activ_out,
    input enable,
    output reg  output_valid			    
    ); 
   
   
   
   always@(*)
   begin
   
    if (enable == 1'b1)
    begin   

    
    // 7 samples were taken from the 256 sample sigmoid (from the .mem file) .
        if( activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] <= 8'b01111010) // 0-122
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b0},{{(DATA_WIDTH/2)-4}{1'b0}}}; // put 8 bits in the middle
        end
        
        
        if( 8'b01111010 < activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] <= 8'b01111100) // 122-124
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b00000100},{{(DATA_WIDTH/2)-4}{1'b0}}};
        end        


        if( 8'b01111100 < activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] <= 8'b01111110) // 124-126
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b00011110},{{(DATA_WIDTH/2)-4}{1'b0}}};
        end   
        

        if( 8'b01111110 < activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] <= 8'b10000000) // 126-128
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b01111111},{{(DATA_WIDTH/2)-4}{1'b0}}};
        end         


        if( 8'b10000000 < activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] <= 8'b10000010) // 128-130
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b11100000},{{(DATA_WIDTH/2)-4}{1'b0}}};
        end         
        

        if( 8'b10000010 < activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] <= 8'b10000100) // 130-132
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b11111010},{{(DATA_WIDTH/2)-4}{1'b0}}};
        end   
        
        
        
        if( activ_in[DATA_WIDTH -1 : DATA_WIDTH -1 -7] >= 8'b10000100) // 132-255
        begin
            activ_out <= {{{(DATA_WIDTH/2)-4}{1'b0}},{8'b11111110},{{(DATA_WIDTH/2)-4}{1'b0}}}; // put 8 bits in the middle
        end
      
       output_valid <= 1'b1;
    end 
     else 
     begin 
       output_valid <= 1'b0;
    end 
 end
endmodule
