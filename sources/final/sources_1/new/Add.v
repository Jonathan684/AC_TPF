`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:29:40
// Design Name: 
// Module Name: Add
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


module Add#
(
    parameter nbits=32
) //numero de bits
(
    input wire [nbits -1:0] A,// Entrada modulo
    input wire [nbits -1:0] B,
    output reg signed [nbits -1:0] Result// Salidas modulo
 );

always @(*)
		Result=A+B;//ADD
endmodule

