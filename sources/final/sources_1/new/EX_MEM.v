`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 14:03:11
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(clk, reset, db_ena, EXMEM_Wr, inEX_ALU, in_zero, inEX_addr_dest, in_wr_data, in_regMEM, in_regWB,
in_opcodeEX, exmem_addr_dest, exmem_ALU, out_wr_data, out_MEM, out_WB, out_zero, out_PCendEX,
out_opcodeMEM);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entrada a modulo
input clk, reset;
input db_ena; // control de ena PC desde debug unit (clk enable)
input [msb:0] inEX_ALU;
input in_zero; // entrada de flag zero desde etapa EX
input [4:0] inEX_addr_dest;
input [msb:0] in_wr_data; // entrada de dato a escribir en memoria - data memory
input [2:0] in_regMEM; // entrada de las flags de control para la etapa MEM - 3 flags (beq, MemWr, MemRd)
input [1:0] in_regWB; // entrada de las flags de control para la etapa WB - 2 flags (MemtoReg, RegWrite)
input EXMEM_Wr; // habilitador de escritura de registro EXMEM
input [5:0] in_opcodeEX; // opcode desde IDEX


// Salidas de modulo
output reg [msb:0] exmem_ALU; //
output reg [4:0] exmem_addr_dest;
output reg [msb:0] out_wr_data;
output reg [2:0] out_MEM; // salida de las flags de control para la etapa MEM - 3 flags (Branch, MemWr, MemRd)
output reg [1:0] out_WB; // salida de las flags de control para la etapa WB - 2 flags (MemtoReg, RegWrite)
output reg out_zero;
output reg out_PCendEX; // flag PCend desde etapa EX3
output reg [5:0] out_opcodeMEM; // opcode saliendo de EXMEM


// Variables internas
reg [msb:0] ALU_next;
reg zero_next;
reg [4:0] addr_dest_next;
reg [msb:0] wrdata_next;
reg [2:0] MEM_next;
reg [1:0] WB_next;
reg PCendEX_next;
reg [5:0] opcodeMEM_next;


always@(*)
begin
	ALU_next = exmem_ALU;
	zero_next = out_zero;
	addr_dest_next = exmem_addr_dest;
	MEM_next = out_MEM;
	WB_next = out_WB;
	wrdata_next = out_wr_data;
	PCendEX_next = EXMEM_Wr;
	opcodeMEM_next = out_opcodeMEM;
	
	if(!EXMEM_Wr) begin
		ALU_next = inEX_ALU;
		zero_next = in_zero;
		addr_dest_next = inEX_addr_dest;
		MEM_next = in_regMEM;
		WB_next = in_regWB;
		wrdata_next = in_wr_data;
		opcodeMEM_next = in_opcodeEX;
	end
end

always@(negedge clk,posedge reset)
begin 
		if(reset)
		begin
			exmem_ALU <= 0;
			out_zero <= 1'b0;
			exmem_addr_dest <= 0;
			out_MEM <= 0;
			out_WB <= 0;
			out_wr_data <= 0;
			out_PCendEX <= 1'b0;
			out_opcodeMEM <= 0;
		end
		
		else if(db_ena)
		begin
			exmem_ALU <= ALU_next;
			out_zero <= zero_next;
			exmem_addr_dest <= addr_dest_next;
			out_MEM <= MEM_next;
			out_WB <= WB_next;
			out_wr_data <= wrdata_next;
			out_PCendEX <= PCendEX_next;
			out_opcodeMEM <= opcodeMEM_next;
		end
end
endmodule
