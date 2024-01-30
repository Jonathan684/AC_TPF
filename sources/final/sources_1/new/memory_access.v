`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 14:44:17
// Design Name: 
// Module Name: memory_access
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

// Parametros internos
module memory_access
(clk, reset, in_EXMEM_ALU, in_zero, in_regMEM, in_wrd, in_du_rd,
out_data, out_PCSrc);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entradas a modulo
input clk, reset;
input [msb:0] in_EXMEM_ALU;
input in_zero;
input [2:0] in_regMEM; // entrada de las flags de control para la etapa MEM - 3 flags (beq, MemWr, MemRd)
input [msb:0] in_wrd; // ingreso de dato a escribir en data mem
input in_du_rd; // entrada de lectura de memoria desde debug unit (interface mips)

// Salidas de modulo
output [msb:0] out_data; // dato de memoria
output out_PCSrc; // flags para control de multiplexor seleccionador de PC en etapa 1


// Variables internas
wire or_rd; // or read para la lectura de memoria desde debug unit
wire secure_wr; // Escritura con proteccion en debug

// Instancias
// - Memoria de Datos (Data Memory)
data_memory dm
(
	.clk(clk),
	.reset(reset),
	.Rd(or_rd), // in_regMEM[0] - rd controlado desde flags para etapa 4
	.Wr(secure_wr), // in_regMEM[1] - wr controlado desde flags para etapa 4
	.Addr(in_EXMEM_ALU),
	.wr_data(in_wrd),
	.rd_data(out_data)
);

// Obtencion de PCSrc: And entre flags Branch y flags zero
assign out_PCSrc = in_zero & in_regMEM[2];

// Lectura desde ambas flags
assign or_rd = in_regMEM[0] | in_du_rd;

// Escritura con proteccion en debug
assign secure_wr = in_regMEM[1] && !in_du_rd;

endmodule

