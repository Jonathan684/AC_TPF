`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:47:18
// Design Name: 
// Module Name: comp_igual
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


module comp_igual(rdd1,rdd2, f_iguales);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entrada modulo
input [msb:0] rdd1; // read data 1
input [msb:0] rdd2; // read data 2

// Salidas modulo
output f_iguales; // flag de iguales - 1 iguales 0 distintos

// Variables internas
reg flag;

// Variables internas
wire [msb:0] comparacion;

assign comparacion = rdd1 ^ rdd2; // xor entre rdd1 y rdd2 

//assign f_iguales = (!comparacion) ? 1'b1: 1'b0;

// Determinacion de flag
always@(*)
begin
	if(comparacion == 0)
		flag = 1'b1;
	
	else
		flag = 1'b0;
end

assign f_iguales = flag;

endmodule

