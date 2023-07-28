`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2023 16:33:16
// Design Name: 
// Module Name: instruction_fetch
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


module instruction_fetch#
(  
    parameter bitsPC = 32
)
(
    input wire clk, 
    input [ bitsPC -1:0] outPC,
    
    //m1
    input [ bitsPC -1:0] jump_PC, // PC asociado a un salto branch (beq - bne)
    output[ bitsPC -1:0] PC_next, // PC + 4 (resultado de sumador)
    input PC_Src,                 // control de mux1
    
    //m2
    input [ bitsPC -1:0] jump2_PC, // PC asociado a un salto jump (j - jal)
    
    input jump, // para control de mux m2
    input jal, 	// para control de mux m2
    input jr, 	// para control de mux m2
    input jalr, // para control de mux m2
    
    
    output [ bitsPC -1:0] instructionMem
);

// Variables internas
wire [ bitsPC -1:0] outmux1; // salida de mux1
wire [ bitsPC -1:0] outmux2; // salida de mux2


// Selector de mux m2
assign sel_mux2 = jump | jal | jr | jalr;

// Mux2a1 m1
mux2a1 #(.nbits(bitsPC)) m1
(
	.A(jump_PC),   //
	.B(PC_next),   //
	.sel(PC_Src),  //
	.salida(outmux1)//
);


// Mux2a1 m2
mux2a1 #(.nbits(bitsPC)) m2
(
	.A(jump2_PC),   //
	.B(outmux1),   //
	.sel(sel_mux2),  //
	.salida(outmux2)//
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


// Memoria de instrucciones
read #(.bitsDir(bitsPC)) IM1
(
	.clk(clk),
	//.reset(reset),
	.Addr(outPC),
	.instruction(instructionMem)
);
endmodule
