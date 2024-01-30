`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:41:44
// Design Name: 
// Module Name: instruction_fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//              Busqueda de una instruccion en la memoria de instrucciones.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_fetch#(parameter bitsPC = 32)
(
    // Entradas a modulo
    input clk, reset,
    input db_ena,   // control de ena PC desde debug unit (clk enable)
    input PC_end,   // fin del contador de programa
    input PC_Wr,    //unidad de riesgo
    input PC_Src,   // control de mux1  //Seañales de control
    input jump,     // para control de mux m2
    input jal, 	    // para control de mux m2
    input jr, 	    // para control de mux m2
    input jalr,     // para control de mux m2
    input [31:0] jump_PC, // PC asociado a un salto branch (beq - bne)
    input [31:0] jump2_PC, // PC asociado a un salto jump (j - jal)
    //input [31:0] memoria,
    //input write_enable, 
    // Salidas de modulo
    output [31:0] instructionMem,
    output [31:0] PC_next,     // PC + 4 (resultado de sumador)
    output wire [31:0] outPC   // operando PC
);

// Parametros internos
localparam msb = bitsPC - 1; // bit mas sigficativo
localparam [msb:0] four = 4; // constante 4 (incremen de PC)

// Variables internas
wire [msb:0] outmux1; // salida de mux1
wire [msb:0] outmux2; // salida de mux2

// Selector de mux m2
assign sel_mux2 = jump | jal | jr | jalr;

// Instaciaciones
// Mux2a1 m1
mux2a1 #(.nbits(bitsPC)) m1
(
	.A(jump_PC),
	.B(PC_next),
	.sel(PC_Src),
	.salida(outmux1)
);

// Mux2a1 m2
mux2a1 #(.nbits(bitsPC)) m2
(
	.A(jump2_PC), //
	.B(outmux1),
	.sel(sel_mux2), // jump | jal | jr | jalr
	.salida(outmux2)
);

// Program Counter register - PC
PC #(.bitsPC(bitsPC)) PC1
(
	.clk(clk),
	.ena(PC_Wr),
	.reset(reset),
	.db_ena(db_ena),
	.PC_end(PC_end),
	.inBits(outmux2),
	.PC(outPC)
);

// Sumador - Add
Add #(.nbits(bitsPC)) add1
(
	.A(outPC),
	.B(four),
	.Result(PC_next)
);

// Memoria de instrucciones
read #(.bitsDir(bitsPC)) mem_instruc
(
	.clk(clk),
	
	//.memoria(memoria),
	//.write_enable(write_enable),
	//.reset(reset),
	.Addr(outPC),
	.instruction(instructionMem)
);
endmodule
