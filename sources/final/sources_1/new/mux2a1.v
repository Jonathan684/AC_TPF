`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:58:41
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
    // Entradas modulo
    input wire [31:0] A, 
    input wire [31:0] B,
    input wire sel,
    // Salidas modulo
	output wire [31:0] salida
);
    // Parametros internos
	localparam msb =nbits -1; // bit mas sigficativo
   	// Logica multiplexor
	assign salida = (sel) ? A: B; // sel=1 selection A

endmodule
