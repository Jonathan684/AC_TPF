`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 14:02:48
// Design Name: 
// Module Name: forward_unit
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


module forward_unit(MEMRegRd,WBRegRd,EXRegRs,EXRegRt, MEM_RegWrite, WB_RegWrite, ForwardA, ForwardB);
 
 // Entradas al modulo
 input[4:0] MEMRegRd,WBRegRd,EXRegRs,EXRegRt;
 input MEM_RegWrite, WB_RegWrite;
 
 // Salidas del modulo
 output[1:0] ForwardA, ForwardB;
 
 // Variables internas
 reg[1:0] ForwardA, ForwardB;

 //Forward A
 always@(MEM_RegWrite or MEMRegRd or EXRegRs or WB_RegWrite or WBRegRd)
 begin
	 if((MEM_RegWrite)&&(MEMRegRd != 0)&&(MEMRegRd == EXRegRs))
	 ForwardA = 2'b10;
	 else if((WB_RegWrite)&&(WBRegRd != 0)&&(WBRegRd == EXRegRs)&&(MEMRegRd != EXRegRs))
	 ForwardA = 2'b01;
	 else
	 ForwardA = 2'b00;
 end
 //Forward B
 always@(WB_RegWrite or WBRegRd or EXRegRt or MEMRegRd or MEM_RegWrite)
 begin
	 if((WB_RegWrite)&&(WBRegRd != 0)&&(WBRegRd == EXRegRt)&&(MEMRegRd != EXRegRt) )
	 ForwardB = 2'b01;
	 else if((MEM_RegWrite)&&(MEMRegRd != 0)&&(MEMRegRd == EXRegRt))
	 ForwardB = 2'b10;
	 else
	 ForwardB = 2'b00;
 end 

endmodule
