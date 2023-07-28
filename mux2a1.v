`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2023 21:31:47
// Design Name: 
// Module Name: mux2a1
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


module mux2a1#
(
    parameter nbits = 32
)
(
    input   wire [nbits -1:0] A,  // Entradas modulo
    input   wire [nbits -1:0] B,  // Entradas modulo
    input   wire sel,             // Entradas modulo
    output  wire [nbits -1:0] salida // Salidas modulo
);
// Logica multiplexor
assign salida = (sel) ? A: B;

endmodule
