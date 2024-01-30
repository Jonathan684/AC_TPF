`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2023 17:35:42
// Design Name: 
// Module Name: Baut_Rate_Generator
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


module Baut_Rate_Generator(clock, tick);

	// Entrada
	input clock;
	
	// Salida
	output reg tick = 0;
	
	// Variables internas
	reg [8:0] cont=0;
	
	// Logica secuencial
	always@(posedge clock)
	begin
		if(cont == 27)
		 begin
			tick = 1; // se cambia estado de pulso, y reinicia cont
			cont = 0; end
		else
		 begin
			cont = cont + 1; // sigue contando
			tick = 0;
		 end
	end


endmodule
