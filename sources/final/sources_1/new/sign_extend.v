`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:48:46
// Design Name: 
// Module Name: sign_extend
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


module sign_extend(word_in, extend_word);

// Entrada a modulo
input [15:0] word_in; // palabra de entrada

// Salidas de modulo
output [31:0] extend_word; // palabra extendida

// Extencion de palabra (tiene en cuenta el signo negativo)
assign extend_word = (word_in[15]==0) ? {16'b0000000000000000, word_in}: {16'b1111111111111111, word_in};

endmodule
