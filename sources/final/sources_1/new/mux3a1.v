`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:41:09
// Design Name: 
// Module Name: mux3a1
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


module mux3a1#(parameter nbits = 32)
(A,B,C,sel,salida);

	// Parametros internos
	parameter msb =nbits -1; // bit mas sigficativo
	
	// Entradas modulo
	input wire [msb:0] A, B, C;
	input wire [1:0] sel;
	
	// Salidas modulo
	output wire [msb:0] salida;
	
	// Logica multiplexor
	assign salida =	(sel == 2'b00) ? A:
							(sel == 2'b01) ? B:
							(sel == 2'b10) ? C: 0;

endmodule
