`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:39:58
// Design Name: 
// Module Name: ALU_Control
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

// Definiciones de MACROS
`define AND 	4'b0000 // 0
`define ANDI 	4'b0000 // 0
`define OR   	4'b0001 // 1
`define ORI 	4'b0001 // 1
`define ADD  	4'b0010 // 2
`define ADDI 	4'b0010 // 2
`define ADDU 	4'b0010 // 2
`define NOR 	4'b0011 // 3
`define XOR  	4'b0100 // 4
`define XORI 	4'b0100 // 4
`define SLL  	4'b0101 // 5
`define SUB  	4'b0110 // 6
`define SUBU 	4'b0110 // 6
`define SLT  	4'b0111 // 7
`define SLTI 	4'b0111 // 7
`define LUI 	4'b1000 // 8
`define SLLV 	4'b1001 // 9
`define SRL  	4'b1010 // 10
`define SRLV 	4'b1011 // 11
`define SRA  	4'b1100 // 12
`define SRAV 	4'b1101 // 13
//`define JR	 	4'b1110 // 14
`define JALR 	4'b1111 // 15
`define JAL 	4'b1111 // 15

module ALU_Control
(   
    // Entradas a modulo
	input [1:0] ALUOp,
	input [5:0] FuncCode,
    // Salidas de modulo
	output reg [3:0] ALUCtl
);

// Circuito combinacional
always@(FuncCode, ALUOp)
	begin
		case(ALUOp)
			2'b00: // LOAD & STORE - ADD
				ALUCtl = `ADD;
			2'b01: // //BRANCHES - SUB
				ALUCtl = `SUB;
			2'b11: //JAL
				ALUCtl = `JAL;
			2'b10: // FUNCT
			begin
				case(FuncCode)
					6'b100000: //ADD
						ALUCtl = `ADD;
					6'b100010: //SUB
						ALUCtl = `SUB;
					6'b100100: //AND
						ALUCtl = `AND;
					6'b001100: //ANDI
						ALUCtl = `ANDI;
					6'b100101: //OR
						ALUCtl = `OR;
					6'b001101: //ORI
						ALUCtl = `ORI;
					6'b101010: //SLT
						ALUCtl = `SLT;
					6'b001010: //SLTI
						ALUCtl = `SLTI;
					6'b000100: //SLLV
						ALUCtl = `SLLV;
					6'b100111: //NOR
						ALUCtl = `NOR;
					6'b100110: //XOR
						ALUCtl = `XOR;
					6'b001110: //XORI
						ALUCtl = `XORI;
					6'b001111: //LUI
						ALUCtl = `LUI;
					6'b000110: //SRLV
						ALUCtl = `SRLV;
					6'b000111: //SRAV
						ALUCtl = `SRAV;
					6'b000000: //SLL
						ALUCtl = `SLL;
					6'b000010: //SRL
						ALUCtl = `SRL;
					6'b000011: //SRA
						ALUCtl = `SRA;
					6'b100001: //ADDU
						ALUCtl = `ADDU;
					6'b100011: //SUBU
						ALUCtl = `SUBU;
					6'b001001: //JALR
						ALUCtl = `JALR;
					default: // Funcion desconocida
					begin
						$display("modulo ALU_control: campo funct desconocido");
						ALUCtl = 4'b0000;
					end
			endcase
		end
		default: 
		begin
			$display("modulo ALU_control: campo ALUOp desconocido");
			ALUCtl = 4'b0000;//4'bXXXX;
		end
		endcase
	end

endmodule
