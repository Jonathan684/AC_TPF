`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:46:54
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    // Entrada a modulo
    input clk, reset,
    input db_ena,   // control de ena PC desde debug unit (clk enable)
    input IF_ID_Wr, // señal que indica cuando escribir en el reg IF/ID y el PCnext (controlado desde la unidad de riesgos)
    input IF_Flush, // señal que indica limpiar el reg IF/ID cuando hay instruccion de salto
    input [31:0] in_inst, // instruccion de entrada
    input [31:0] in_PCnext, // PC + 4 (entrada del proximo PC)
    input PC_end, // flag indicadora de fin de ejecucion
    // Salidas de modulo
    output reg [31:0] out_inst, // registro de instruccion
    output reg [31:0] out_PCnext // registro de proximo PC (PC +4)
);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Variables internas
reg [msb:0] inst_next;
reg [msb:0] PCnext_next;

always@(*)
begin
	inst_next=out_inst;
	PCnext_next=out_PCnext;
	if(IF_Flush) 
	begin
		inst_next=0;
		PCnext_next =0;
	end
	
	else if(IF_ID_Wr && !PC_end)
	begin
		inst_next = in_inst;
		PCnext_next = in_PCnext;
	end
end

always@(posedge clk,posedge reset)
begin 
		if(reset)
		begin
			out_inst <= 0;
			out_PCnext<=0;
		end
		
		else if(db_ena)
		begin
			out_inst <= inst_next;
			out_PCnext <= PCnext_next;
		end
end

endmodule