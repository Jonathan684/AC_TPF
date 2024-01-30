`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:30:25
// Design Name: 
// Module Name: PC
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


module PC#
(   
    parameter bitsPC=32
)
(
    input clk,
    input ena,
    input reset,
    input db_ena,               //control de ena PC desde debug unit (clk enable)
    input [bitsPC-1:0] inBits,  // entrada de bits
    input PC_end,               // fin del contador de programa - Finalizacion de conteo PC
    output reg [bitsPC-1:0]PC
    
);
// Variables internas
reg [(bitsPC -1):0]PC_next;
reg PC_end_reg = 1'b0; // registro de bandera de finalizacion
reg PC_end_next= 1'b0;

// Logica avance del PC y logica de fin del PC
always@(*)
begin
	PC_next=PC;
	if(ena && !PC_end_reg) begin
		PC_end_next = PC_end;
		PC_next = inBits;
		$monitor("PC: %d",PC);
	end
	
	else if(!ena)
		$display("PC: omision de escritura de PC - nop"); // nop - no actualizar PC
	
	else if(!db_ena)
		$display("PC: omision de escritura de PC - db_ena"); // no actualizar PC (desde debug unit)
end

// Avance del PC
always@(posedge clk or posedge reset)
begin 
		if(reset)
			PC <= 0;
		
		else if(db_ena)
			PC <= PC_next;
end

// Finalizacion de conteo PC
always@(negedge clk or posedge reset)
begin
	if(reset)
		PC_end_reg <= 1'b0;
	
	else
		PC_end_reg <= PC_end_next;
end
endmodule