`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:50:39
// Design Name: 
// Module Name: control_Unit
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

`define R_type  6'b000000
`define lw  6'b100011
`define sw  6'b101011
`define beq   6'b000100
`define bne   6'b000101
`define j   6'b000010
`define addi   6'b001000
`define halt   6'b111111

module control_Unit
(  
    // Entradas a modulo
    input [5:0] opcode,
    input [5:0] Funct, // opcode de instruccion y campo Funct
    
    // Salidas de modulo
    output reg RegDst,
    output reg ALUSrc, beq, bne,
    output reg jump, jal, jr, jalr,
    output reg MemRead, MemWrite, RegWrite,
    output reg MemtoReg, PC_end,
    output reg [1:0] ALUOp,
    output reg ALUSrcA,  // multiplexor con la mismo funcionalidad que ALUSrc pero en op A de la ALU
    output reg FunctSrc // selector de posicion de funcion para ALU - la funcion vendra de Funct o FunctI dependiendo de la instruccion
);                         // FunctSrc: 0(Funct: campo funct de inst) - 1(FunctI: campo opcode de inst)
    
// Se respeta misma logica que sigue
always @(*) begin
    case (opcode)
    
    6'b000000: // R-type
	 begin
      RegDst = 1'b1; ALUSrc = 1'b0;	ALUOp = 2'b10; FunctSrc = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
		case(Funct)
		6'b000000: // sll
			ALUSrcA = 1'b1;
		6'b000010: // srl
			ALUSrcA = 1'b1;
		6'b000011: // sra
			ALUSrcA = 1'b1;
		6'b001000: begin // jr
			ALUSrcA = 1'b0; jr = 1'b1; RegWrite = 1'b0; // no escribe en regFile
		end
		6'b001001: begin // jalr
			ALUSrcA = 1'b0; jalr = 1'b1;
		end
		default: // otra instruccion diferente a sll, srl o sra
			ALUSrcA = 1'b0;
		endcase
    end

    6'b100011: // lw
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b1; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b1; PC_end = 1'b0;
    end
	 
	 6'b100001: // lh
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b1; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b1; PC_end = 1'b0;
    end
	 
	 6'b100000: // lb
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b1; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b1; PC_end = 1'b0;
    end
	 
	 6'b100111: // lwu
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b1; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b1; PC_end = 1'b0;
    end
	 
	 6'b100101: // lhu
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b1; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b1; PC_end = 1'b0;
    end
	 
	 6'b100100: // lbu
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b1; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b1; PC_end = 1'b0;
    end

    6'b101011: // sw
	 begin
		ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
      MemRead = 1'b0; MemWrite = 1'b1;
      RegWrite = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b101001: // sh
	 begin
		ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
      MemRead = 1'b0; MemWrite = 1'b1;
      RegWrite = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b101000: // sb
	 begin
		ALUSrc = 1'b1; ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
      MemRead = 1'b0; MemWrite = 1'b1;
      RegWrite = 1'b0; PC_end = 1'b0;
    end

    6'b000100: // beq
	 begin
      ALUSrc = 1'b0; ALUOp = 2'b01; ALUSrcA = 1'b0;
		beq = 1'b1; bne = 1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
      MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b0; PC_end = 1'b0;
    end
     
    6'b000101: //bne
	 begin
      ALUSrc = 1'b0; ALUOp = 2'b01; ALUSrcA = 1'b0;
      MemRead = 1'b0; MemWrite = 1'b0;
      beq = 1'b0; bne = 1'b1; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
      RegWrite = 1'b0; PC_end = 1'b0;
    end

    6'b000010: //jump
	 begin
      beq = 1'b0; bne = 1'b0; jump = 1'b1; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemWrite = 1'b0;
      MemRead = 1'b0;
      RegWrite = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b000011: //jal - FunctSrc = 1'b1: para el uso de la ALU el codigo viene en los msb de la inst
	 begin
      RegDst = 1'b1; ALUSrc = 1'b0;	ALUOp = 2'b11; FunctSrc = 1'b1; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b1; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b001000: // addi
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1;	ALUOp = 2'b00; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b001100: // andi
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1;	ALUOp = 2'b10; FunctSrc = 1'b1; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b001010: // slti
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1;	ALUOp = 2'b10; FunctSrc = 1'b1; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b001101: // ori
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1;	ALUOp = 2'b10; FunctSrc = 1'b1; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b001110: // xori
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1;	ALUOp = 2'b10; FunctSrc = 1'b1; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b001111: // lui
	 begin
      RegDst = 1'b0; ALUSrc = 1'b1;	ALUOp = 2'b10; FunctSrc = 1'b1; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b1; MemtoReg = 1'b0; PC_end = 1'b0;
    end
	 
	 6'b111111: // halt
	 begin
      RegDst = 1'b0; ALUSrc = 1'b0;	ALUOp = 2'b00; FunctSrc = 1'b0; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b0; MemtoReg = 1'b0; PC_end = 1'b1;
    end
	 
	 default: 
	 begin
		$display("modulo control_unit: campo opcode desconocido %b",opcode);
		RegDst = 1'b0; ALUSrc = 1'b0;	ALUOp = 2'b00; FunctSrc = 1'b0; ALUSrcA = 1'b0;
		beq = 1'b0; bne =1'b0; jump = 1'b0; jal = 1'b0; jr = 1'b0; jalr = 1'b0;
		MemRead = 1'b0; MemWrite = 1'b0;
		RegWrite = 1'b0; MemtoReg = 1'b0; PC_end = 1'b0;
	 end
    endcase
  end

endmodule