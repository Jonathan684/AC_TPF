`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:48:04
// Design Name: 
// Module Name: shift_left_2
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


module shift_left_2(in_sign_extend, out_sl2);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entradas a modulo
input [msb:0] in_sign_extend; // entrda de señal extendida

// Salidas de modulo
output [msb:0] out_sl2; // salida de la señal extendida multiplicada por 4

// Multiplicacion por 4, a traves de un desplazamiento
assign out_sl2 = in_sign_extend << 2;

endmodule
