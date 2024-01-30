`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:59:03
// Design Name: 
// Module Name: instruction_decode
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


module instruction_decode
	#(parameter bitsPC = 32)
	(
		clk, reset, f_control,
		instruction, PCnext, wr_ena,
		wr_addr, wr_data, rs_addr,
		rt_addr, rd_addr,
		in_du_areg, in_duc1, rd_data1,
		rd_data2, opcode, sign_ext,
		PC_jump, out_muxPCjump, f_iguales
	);

// Parametros internos
parameter msb = bitsPC-1; // bit mas sigficativo
parameter cinco = 5; // constante 5
parameter cuatro = 4; // constante 4

localparam [4:0] j_addr = 5'b11111; // direccion 31 cte

// Entradas a modulo
input clk, reset;
input [msb:0] instruction; // instruccion de entrada
input [msb:0] PCnext; // entrada de proximo PC (PC +4)
input wr_ena; // entrada de control para escritura en memoria de datos de registros (reg_data_memory)
input [4:0] wr_addr; // direccion de Registro a escribir en reg_data_memory
input [msb:0] wr_data;  // dato a escribir en reg_data_memory
input [4:0] in_du_areg; // entrada de debug unit address reg
input in_duc1; // flags de control 1 desde unidad de debug (interface_mips)
input [15:0] f_control; // flags de control desde unidad de control


// Salidas de modulo
output [msb:0] sign_ext; // señal extendida
output [msb:0] PC_jump; // PC correspondiente a un salto branch (beq - ben)
wire [msb:0] PC_jump2; // PC correspondiente a un salto jump (j - jal)
								 // tambien es dato a escribir en reg_data_memory cuando inst es del
								 // tipo jump link (jal)
output [4:0] rs_addr; // direccion de registro fuente 1 [25:21] desde instruccion
output [4:0] rt_addr; // direccion de registro fuente 2 [20:16] desde instruccion
output [4:0] rd_addr; // direccion de registro destino [15:11] desde instruccion o direccion
							 // fija 31 (j_addr) por mux
output [msb:0] rd_data1; // dato de registro fuente rs
output [msb:0] rd_data2; // dato 2 luego de mux
output [5:0] opcode; // codigo de operacion de la instruccion - 6 bits - salida necesaria para la unidad de control
output f_iguales; // flag de comparacion de datos de registros rdd1 y rdd2

// Variables internas
wire [msb:0] out_muxDJ; // salida de mux  para seleccionar datos en casos de jal o jalr
wire [4:0] rd_addrID; // direccion de registro destino [15:11] en etapa ID
wire [msb:0] rd_data2B; // dato de registro fuente rt
wire [msb:0] op_sl2; // shift_left_2 como operador de sumador (add)
wire [4:0] out_muxID1; // salida de mux de debug unit (es utilizado por debug unit cuando in_duc1 == 1)
wire [msb:0] ext_target; // extend target para hacerlo de 32 bits y compatibilizar con mux2
//wire [msb:0] out_muxwrdata; // dato a escribir en reg_data_memory cuando inst es jump
wire jsel; // jsel tiene en cuenta inst jump link (jal y jalr)
wire [msb:0] j_data; // dato a escribir en reg_data_memory cuando la inst es jump link (jal)
//wire sel_muxwrd; // selector de mux muxwrd para instrucciones jal y jalr (guardan j_data en reg)
wire sel_muxPCjump; // selector para muxPCjump selecciona rd_data1 si ints es jr o jalr
output [msb:0] out_muxPCjump; // salida de PCjump dependera de un calculo o registro, segun instruccion de salto (j, jal, jr, jalr)
wire secure_wr; // Escritura con proteccion en debug


// Extencion de target
assign ext_target = {4'b0000,instruction[25:0],2'b00}; // extiendo la señal de target a 32 bits y desplazo en 2 izq

// Salida del opcode
assign opcode = instruction[31:26];

// Salida direccion de registros
assign rs_addr = instruction[25:21];
assign rt_addr = instruction[20:16];
assign rd_addrID = instruction[15:11];
// Seleccion de registro destino
mux2a1 #(.nbits(cinco)) muxRdest //
(
	.A(j_addr), // si hay instruccion jal el registro destino es la direccion fija j_addr (R31)
	.B(rd_addrID),// si no hay instruccion jal el registro destino rd viene por instruccion[15:11]
	.sel(f_control[13]), // flags de control jal (f_control[13])
	.salida(rd_addr)
);

// Instancias
// - Multiplexor de debug unit (seleccion entre in_du_areg y rt_addr) - mux2a1
mux2a1 #(.nbits(cinco)) muxID1 //
(
	.A(in_du_areg), // entrada de debug unit address reg
	.B(rs_addr), //
	.sel(in_duc1), // flags de control 1 desde unidad de debug (interface_mips)
	.salida(out_muxID1)
);

// - Archivo de registros (Registers)
Registers FR // Register file
(
	.clk(clk),
	.reset(reset),
	.rd_addr1(out_muxID1), // rs_addr
	.rd_addr2(rt_addr), // rt_addr
	.wr_addr3(wr_addr), // wr_addr
	.wr_data(wr_data), // wr_data
	.wr_ena(secure_wr), // wr_ena
	.rd_data1(rd_data1),
	.rd_data2(rd_data2B)
	//.reg_data_memory(reg_data_memory)
);

// Modulo de comparacion sobre igual
comp_igual comp_rddata
(
	.rdd1(rd_data1),
	.rdd2(rd_data2B),
	.f_iguales(f_iguales)
);

// - Extencion de señal (Sign extend)
sign_extend sg1
(
	.word_in(instruction[15:0]),
	.extend_word(sign_ext)
);

// - Multiplicacion por 4, a traves de desplazamiento (shift_left_2)
shift_left_2 sl
(
	.in_sign_extend(sign_ext),
	.out_sl2(op_sl2)
);

// Sumador - Add : Calculo PC_jump
Add #(.nbits(bitsPC)) add1
(
	.A(op_sl2),
	.B(PCnext),
	.Result(PC_jump)
);

// Sumador - Add : Calculo PC_jump2
Add #(.nbits(bitsPC)) add2
(
	.A(ext_target),
	.B(PCnext),
	.Result(PC_jump2)
);

// Sumador - Add : Calculo de j_data
Add #(.nbits(bitsPC)) add3
(
	.A(cuatro), // se suman 4 mas al PCnext
	.B(PCnext), // siendo que este es el PC + 4
	.Result(j_data) // termina siendo el PC + 8
);

// MUX selector de dato a registrar en jal o jalr
mux2a1 #(.nbits(bitsPC)) muxDJ // mux data jump
(
	.A(j_data), // si inst jump es jalr, sale j_data (PC+8)
	.B(PCnext), // si inst es jal sale (PC+4)
	.sel(f_control[15]), // flags de control de unidid de control (jalr) (f_control[15])
	.salida(out_muxDJ)
);

// Selector de rd data 2 : tiene en cuenta inst jump link (jal y jalr)
assign jsel = (f_control[13]|f_control[15]) ? 1'b1: 1'b0;
// MUX selector entre rd_data2B o j_data
mux2a1 #(.nbits(bitsPC)) muxRD2 //
(
	.A(out_muxDJ), // si inst jump es jal | jalr, sale PCnext o j_data respectivamente
	.B(rd_data2B), // si inst no es jal|jalr sale rd_data2B
	.sel(jsel), // flags de control de unidid de control (jalr) (f_control[15])
	.salida(rd_data2)
);

// MUX selector de PCjump segun instruccion jump
// (j-jal: sale directo de calculo -- jr-jalr: sale de registro)
assign sel_muxPCjump = (f_control[14]|f_control[15]) ? 1'b1: 1'b0; // selector muxPCjump
mux2a1 #(.nbits(bitsPC)) muxPCjump //
(
	.A(rd_data1), // si inst jump es jr o jalr, jump es por registro
	.B(PC_jump2), // si inst jump es j o jal jump es por calculo
	.sel(sel_muxPCjump), // flags de control de unidid de control (jr | jalr) (f_control[14]|f_control[15])
	.salida(out_muxPCjump)
);

// Escritura con proteccion en debug
assign secure_wr = wr_ena && !in_duc1;
endmodule
