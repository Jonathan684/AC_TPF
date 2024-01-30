`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2023 01:33:56
// Design Name: 
// Module Name: Detector_byte
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


module Detector_lb_lh_lw(
    input wire [5:0]  w_opcodeWB, 
    input wire [31:0] memwr_rdd,
    output reg [31:0] m_memwr_rdd
    );
always@(*)
begin
	case(w_opcodeWB)
	 6'b100001: // lh
	 begin
      if(memwr_rdd[15])
			m_memwr_rdd = {16'b1111111111111111,memwr_rdd[15:0]};
		else
			m_memwr_rdd = {16'b0000000000000000,memwr_rdd[15:0]};
    end
	 
	 6'b100000: // lb
	 begin
		if(memwr_rdd[7])
			m_memwr_rdd = {24'b111111111111111111111111,memwr_rdd[7:0]};
		else
			m_memwr_rdd = {24'b000000000000000000000000,memwr_rdd[7:0]};
    end
	 
	 6'b100101: // lhu
	 begin
      m_memwr_rdd = {16'b00000000000000000,memwr_rdd[15:0]};
    end
	 
	 6'b100100: // lbu
	 begin
      m_memwr_rdd = {24'b000000000000000000000000,memwr_rdd[7:0]};
    end
	 
	 6'b100111: // lwu
	 begin
      m_memwr_rdd = {1'b0,memwr_rdd[30:0]};
    end
	 
	 default: // lw
		m_memwr_rdd = memwr_rdd;
	endcase
end
endmodule
