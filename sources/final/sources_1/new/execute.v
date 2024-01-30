`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 14:02:23
// Design Name: 
// Module Name: execute
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

module execute
(       // Entrada a modulo
        input [31:0] in_rd_data1, 	// entrada de reg data 1
        input [31:0] in_rd_data2, 	// entrada de reg data 2
        input [31:0] ex_mem_ALU, 	// valor anterior de la ALU desde etapa 4
        input [31:0] WB_mux, 		// ingreso de la salida de etapa 5
        input [4:0] in_rt_addr, 	// entrada de direccion de reg fuente rt
        input [4:0] in_rd_addr, 	// entrada de direccion de reg destino rd
        input [31:0] in_sign_ext, 	// valor inmediato
        input [1:0] forwardA, 		// Control de multiplexor de operando 1 de ALU
        input [1:0] forwardB, 		// Control de multiplexor de operando 2 de ALU
        input [5:0] Funct, 			// Funcion de ALU - Instruccion[5:0] los 6 bits lsb de la instruccion
        input [5:0] FunctI, 		// Funcion de ALU - Instruccion[31:26] los 6 bits msb de la instruccion
        input [5:0] in_regEX, 		// ingreso de flags de control para etapa EX desde mux_ID2
                                    // 6 flags (ALUSrcA, FunctSrc, RegDst, ALUSrc, ALUOp[1:0])
                                    // Tipo de operacion en ALU (00:sum; 01:sub; 10:Funct)

        // Salidas de modulo
        output [31:0] out_ALU,
        output [4:0] addr_dest, // salida de direccion de registro destino
        output [31:0] out_wrd, // salida del dato  escribir en data memory
        output zero 			// flag zero de la ALU
         
);

// Parametros internos
parameter nbits = 32; // indicador de numero de bits
parameter msb = 31; // bit mas sigficativo

// Variables internas
wire [msb:0] salida_mux1;
wire [msb:0] salida_mux3a;
wire [msb:0] salida_mux3b;
wire [5:0] salida_mux4; // seleccion de funcion para ALU
wire [3:0] ALU_control; // slida de modulo ALUctrl

// Instancias
// - Multiplexor de 1º operando de ALU - mux3a1
mux3a1 #(.nbits(nbits)) mux1
(
	.A(in_rd_data1),
	.B(WB_mux),
	.C(ex_mem_ALU),
	.sel(forwardA),
	.salida(salida_mux1)
);

// - Multiplexor de 2º operando de ALU - mux3a1
mux3a1 #(.nbits(nbits)) mux2
(
	.A(in_rd_data2),
	.B(WB_mux),
	.C(ex_mem_ALU),
	.sel(forwardB),
	.salida(out_wrd)
);

// - Multiplexor2 de 2º op de ALU: selecciona entre rdd2 o valor immediato - mux2a1
mux2a1 #(.nbits(nbits)) mux3b
(
	.A(in_sign_ext), // valor inmediato - señal extendida
	.B(out_wrd),
	.sel(in_regEX[2]), // flag de control ALUSrc
	.salida(salida_mux3b)
);

// - Multiplexor2 de 1º op de ALU: selecciona entre rdd1 o valor immediato - mux2a1
mux2a1 #(.nbits(nbits)) mux3a
(
	.A(in_sign_ext), // valor inmediato - señal extendida
	.B(salida_mux1),
	.sel(in_regEX[5]), // flag de control ALUSrcA
	.salida(salida_mux3a)
);

// Mux4: selector del campo Funct para ALU, 
// * si es instruccion inmediata viene desde FunctI (desde campo opcode)
// * caso contrario Funct (desde campo Funct)
// * el selector del mux sera el bit 1 de ALUOp
mux2a1 #(.nbits(6)) mux4
(
	.A(FunctI), // el codigo de funcion viene desde el campo Opcode
	.B(Funct), // el codigo de funcion viene desde el campo Funct
	.sel(in_regEX[4]), // flag de control FunctSrc
	.salida(salida_mux4)
);

// - Control de ALU - ALU_Control
ALU_Control ALU_ctrl
(
	.ALUOp(in_regEX[1:0]), // flags de control ALUOp[1:0]
	.FuncCode(salida_mux4),
	.ALUCtl(ALU_control)
);

// - ALU_MIPS
ALU_MIPS #(.nbits(nbits)) ALU_MIPS
(
	.op_A(salida_mux3a),
	.op_B(salida_mux3b),
	.ALU_Ctrl(ALU_control), // controlada desde modulo ALU_ctrl
	.ALU_result(out_ALU),
	.zero(zero)
);

// - Multiplexor de direciones destino - mux2a1
mux2a1 #(.nbits(5)) mux5
(
	.A(in_rd_addr),
	.B(in_rt_addr),
	.sel(in_regEX[3]), // flag de control RegDst
	.salida(addr_dest)
);
endmodule
