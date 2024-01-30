`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 14:01:31
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    clk, reset, db_ena,
    IDEX_Wr, in_rd_data1, in_rd_data2,
    in_sign_ext, in_rs_addr, in_rt_addr,
    in_rd_addr, in_EX,in_MEM,
    in_WB, in_opcode, out_rd_data1,
    out_rd_data2, out_sign_ext,
    out_rs_addr, out_rt_addr,
    out_rd_addr,out_EX,
    out_MEM, out_WB, out_opcode, out_PCendID
 );

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entrada a modulo
input clk, reset;
input db_ena; // control de ena PC desde debug unit (clk enable)
input [msb:0] in_rd_data1; 	// entrada de reg data 1
input [msb:0] in_rd_data2; 	// entrada de reg data 2
input [msb:0] in_sign_ext; 	// entrada de señal extendida (valor inmediato - inmediate value)
input [4:0] in_rs_addr; 	// entrada de direccion de reg fuente rs
input [4:0] in_rt_addr; 	// entrada de direccion de reg fuente rt
input [4:0] in_rd_addr; 	// entrada de direccion de reg destino rd
input [5:0] in_EX; 			// entrada de las flags de control para la etapa EX - 6 flags (ALUSrcA, FunctSrc, RegDst, ALUSrc, ALUOp)
input [2:0] in_MEM; 		// entrada de las flags de control para la etapa MEM - 3 flags (Branch, MemWr, MemRd)
input [1:0] in_WB; 			// entrada de las flags de control para la etapa WB - 2 flags (MemtoReg, RegWrite)
input [5:0] in_opcode; 		// entrada de opcode desde etapa ID2
input IDEX_Wr; 				// habilitador de escritura de registro IDEX

// Salidas de modulo
output reg [msb:0] out_rd_data1; 	// entrada de reg data 1
output reg [msb:0] out_rd_data2; 	// entrada de reg data 2
output reg [msb:0] out_sign_ext; 	// entrada de señal extendida
output reg [4:0] out_rs_addr; 		// entrada de direccion de reg fuente rs
output reg [4:0] out_rt_addr; 		// entrada de direccion de reg fuente rt
output reg [4:0] out_rd_addr; 		// entrada de direccion de reg destino rd
output reg [5:0] out_EX; 			// salida de las flags de control para la etapa EX - 6 flags (ALUSrcA, FunctSrc, RegDst, ALUSrc, ALUOp)
output reg [2:0] out_MEM; 			// salida de las flags de control para la etapa MEM - 3 flags (Branch, MemWr, MemRd)
output reg [1:0] out_WB; 			// salida de las flags de control para la etapa WB - 2 flags (MemtoReg, RegWrite)
output reg [5:0] out_opcode; 		// salida de opcode para ser usado en etapa EX3
output reg out_PCendID;

// Variables internas
reg [4:0] rsa_next;
reg [4:0] rta_next;
reg [4:0] rda_next;
reg [msb:0] rsd_next;
reg [msb:0] rtd_next;
reg [msb:0] sign_ext_next;
reg [5:0] EX_next; 
reg [2:0] MEM_next; 
reg [1:0] WB_next;
reg [5:0] opcode_next;
reg next_PCendID;


always@(*)
begin
	rsa_next = out_rs_addr;
	rta_next = out_rt_addr;
	rda_next = out_rd_addr;
	rsd_next = out_rd_data1;
	rtd_next = out_rd_data2;
	sign_ext_next = out_sign_ext;
	EX_next = out_EX; 
	MEM_next = out_MEM;
	WB_next = out_WB;
	opcode_next = out_opcode;
	next_PCendID = IDEX_Wr;
	if(!IDEX_Wr)
	begin
		rsa_next = in_rs_addr;
		rta_next = in_rt_addr;
		rda_next = in_rd_addr;
		rsd_next = in_rd_data1;
		rtd_next = in_rd_data2;
		sign_ext_next = in_sign_ext;
		EX_next = in_EX; 
		MEM_next = in_MEM; 
		WB_next = in_WB;
		opcode_next = in_opcode;
	end
	
	
end

always@(posedge clk,posedge reset)
begin 
		if(reset)
		begin
			out_rs_addr <= 0;
			out_rt_addr <= 0;
			out_rd_addr <= 0;
			out_rd_data1 <= 0;
			out_rd_data2 <= 0;
			out_sign_ext <= 0;
			out_EX <= 0;
			out_MEM <= 0;
			out_WB <= 0;
			out_opcode <= 0;
			out_PCendID <= 1'b0;
		end
		
		else if(db_ena)
		begin
			out_rs_addr <= rsa_next;
			out_rt_addr <= rta_next;
			out_rd_addr <= rda_next;
			out_rd_data1 <= rsd_next;
			out_rd_data2 <= rtd_next;
			out_sign_ext <= sign_ext_next;
			out_EX <= EX_next;
			out_MEM <= MEM_next;
			out_WB <= WB_next;
			out_opcode <= opcode_next;
			out_PCendID <= next_PCendID;
		end
end

endmodule
