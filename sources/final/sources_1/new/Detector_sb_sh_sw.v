`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2023 16:28:25
// Design Name: 
// Module Name: Detector_sb_sh_sw
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


module Detector_sb_sh_sw
(
    input wire [5:0] w_opcodeMEM,
    input wire [31:0] exmem_wrd,
    output reg [31:0] m_exmem_wrd
);
always@(*)
begin
	case(w_opcodeMEM)
	6'b101000: // sb
		m_exmem_wrd = {24'b000000000000000000000000,exmem_wrd[7:0]};
	 
	 6'b101001: // sh
		m_exmem_wrd = {16'b0000000000000000,exmem_wrd[15:0]};
	 
	 default: // sw
		m_exmem_wrd = exmem_wrd;
	endcase
end
endmodule
