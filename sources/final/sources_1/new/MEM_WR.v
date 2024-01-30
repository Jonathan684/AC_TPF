`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 14:34:52
// Design Name: 
// Module Name: MEM_WR
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


module MEM_WR
(clk, reset, db_ena, MEMWB_Wr, in_rd_data, in_addr_mem, in_addr_dest, in_regWB, in_opcodeMEM,
 out_rd_data, out_addr_mem, out_addr_dest, out_WB, out_opcodeWB);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entrada a modulo
input clk, reset;
input db_ena; // control de ena PC desde debug unit (clk enable)
input [msb:0] in_rd_data;
input [msb:0] in_addr_mem;
input [4:0] in_addr_dest;
input [1:0] in_regWB; // entrada de las flags de control para la etapa WB - 2 flags (MemtoReg, RegWrite)
input MEMWB_Wr; // habilitador de escritura de registro MEMWB
input [5:0] in_opcodeMEM; // entrada de opcode desde EXMEM

// Salidas de modulo
output reg [msb:0] out_rd_data; // 
output reg [msb:0] out_addr_mem; //
output reg [4:0] out_addr_dest;
output reg [1:0] out_WB; // salida de 2 flags (MemtoReg, RegWrite) desde reg MEM/WB
output reg [5:0] out_opcodeWB; // Salida de opcode desde MEMWB

// Variables internas
reg [msb:0] rdd_next; // dato leido next
reg [msb:0] addr_mem_next; // direccion de memoria next
reg [4:0] addr_dest_next; // direccion destino next
reg [1:0] WB_next;
reg [5:0] opcodeWB_next;


always@(*)
begin
	rdd_next = out_rd_data;
	addr_mem_next = out_addr_mem;
	addr_dest_next = out_addr_dest;
	WB_next = out_WB;
	opcodeWB_next = out_opcodeWB;
	if(!MEMWB_Wr)
	begin
		rdd_next = in_rd_data;
		addr_mem_next = in_addr_mem;
		addr_dest_next = in_addr_dest;
		WB_next = in_regWB;
		opcodeWB_next = in_opcodeMEM;
	end
end

always@(negedge clk,posedge reset)
begin 
		if(reset)
		begin
			out_rd_data <= 0;
			out_addr_mem <= 0;
			out_addr_dest <= 0;
			out_WB <= 0;
			out_opcodeWB <= 0;
		end
		
		else if(db_ena)
		begin
			out_rd_data <= rdd_next;
			out_addr_mem <= addr_mem_next;
			out_addr_dest <= addr_dest_next;
			out_WB <= WB_next;
			out_opcodeWB <= opcodeWB_next;
		end
end

endmodule

