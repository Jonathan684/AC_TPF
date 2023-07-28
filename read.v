`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2023 12:24:22
// Design Name: 
// Module Name: read
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
module read#(
    parameter bitsDir=32
) // bits de Direconamiento
(
    input wire clk,
    input [ bitsDir -1:0]Addr,
    output reg[bitsDir -1:0] instruction
);

// Parametros internos
localparam  msb = bitsDir -1; // bit mas sigficativo

// Entradas modulo
//input clk;
//input [msb:0] Addr; // direccion de instruccion

// Salidas modulo
//output reg[msb:0] instruction; // instruccion de memoria

// Variables internas
parameter MemorySize = 128; // tamaño de mem 2048 Instrucciones - 11 bits de direccionamiento (2 KB)
reg [msb:0] memory [0:MemorySize]; // buffer de memoria de instrucciones

// Memoria asociada a archivo

//initial
//begin
//	$readmemb("./mem.txt", memory,50, 60);
//end

initial begin
        //$display("Loading rom.");
        $readmemb("memoria.mem", memory);
        //$display("Fin Loading rom.");
    end

//initial
//begin
//	memory[0] = 32'b00000000000000000000000000000001; //addi $4, $0, 2
//	memory[4] = 32'b00000000000000000000000000000010; //addi $5, $0, 2
//	memory[8] = 32'b00000000000000000000000000000011; //beq $4, $5, 3
//	memory[12] = 32'b00000000000000000000000000000100; //addi $8, $0, 4
//	memory[16] = 32'b00000000000000000000000000000101; //addi $9, $0, 5
//	memory[20] = 32'b00000000000000000000000000000110; //addi $10, $0, 6
//	memory[24] = 32'b00000000000000000000000000000111; //addi $11, $0, 7
//	memory[28] = 32'b00000000000000000000000000001000; //addi $12, $0, 8
//	memory[32] = 32'b00000000000000000000000000001001; //addi $13, $0, 9
//	memory[36] = 32'b00000000000000000000000000001010; //halt
//end
always@(negedge clk)
begin
		instruction <= memory[Addr];
end
endmodule