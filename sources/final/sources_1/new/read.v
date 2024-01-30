`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:28:38
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


module read#
(
    parameter bitsDir=32
) // bits de Direconamiento
(
    // Entradas modulo
    input wire clk,
    input [ bitsDir -1:0]Addr,
    // Salidas modulo
    output reg[bitsDir -1:0] instruction // instruccion de memoria
);

localparam MemorySize = 128; // tama�o de mem 2048 Instrucciones - 11 bits de direccionamiento (2 KB)
reg [7:0] memory [0:MemorySize]; // buffer de memoria de instrucciones

initial 
begin
        $display("Loading rom.");
        $readmemb("memo_instruc.mem", memory);
        $display("Fin Loading rom.");
        $display("Contenido de la memoria:");
end

always@(negedge clk)
begin
        instruction <= { 
                            memory[Addr+0],
                            memory[Addr+1],
                            memory[Addr+2],
                            memory[Addr+3]
                            };
       $display("instruction= %b", instruction);
end
endmodule
