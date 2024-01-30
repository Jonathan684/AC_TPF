`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:39:13
// Design Name: 
// Module Name: ALU_MIPS
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


module ALU_MIPS#(parameter nbits=32)
(op_A, op_B, ALU_Ctrl, ALU_result, zero);

// Parametros internos
parameter msb = nbits -1;

//Entradas a modulo
input wire signed [msb:0]op_A;
input wire signed [msb:0]op_B;
input wire [3:0]ALU_Ctrl;

// Salidas de modulo
output reg signed [msb:0]ALU_result;
output zero;

// Determinacion de flag zero
assign zero = (ALU_result==0) ? 1'b1: 1'b0; // zero es true si ALU_result es 0.

always @(ALU_Ctrl, op_A, op_B)
	begin
	        $display("MODULO ALU_MIPS A = %b B = %b ALU_Ctrl = %b",op_A,op_B,ALU_Ctrl);
			case(ALU_Ctrl)
				0: //AND - ANDI
					ALU_result = op_A & op_B;
				1: //OR - ORI
					ALU_result = op_A | op_B;
				2: //ADD - ADDI - ADDU
					ALU_result = op_A + op_B;
				3: // NOR
					ALU_result = ~(op_A | op_B);
				4: // XOR
					ALU_result = op_A ^ op_B;
				5: // SLL
					ALU_result = op_B << ((op_A[10:6])&5'b11111);
				6: //SUB - SUBI - SUBU
					ALU_result = op_A - op_B;
				7: //SLT
					ALU_result = (op_A < op_B) ? 1 : 0;
				8: //LUI
					ALU_result = {op_B[15:0],16'b0000000000000000}; // se cargan los 16 bits del inm
				9: // SLLV
					ALU_result = op_B << (op_A&5'b11111);
				10: // SRL
					ALU_result = op_B >> ((op_A[10:6])&5'b11111);
				11: // SRLV
					ALU_result = op_B >> (op_A&5'b11111);
				12: // SRA
					ALU_result = op_B >>> ((op_A[10:6])&5'b11111); // &5'b11111: deja solo posible 31 desplazamientos
				13: // SRAV
					ALU_result = op_B >>> (op_A&5'b11111);
				14: // Sin uso
					ALU_result = op_A;
				15: // JAL - JALR
					ALU_result = op_B;
				default: //
				begin
					$display("modulo ALU_MIPS: Operacion ALU desconocida");
					ALU_result = 0;
				end
				
			endcase
			$display("MODULO ALU_MIPS ALU_result = %b",ALU_result);
	end

endmodule
