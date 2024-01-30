`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:31:05
// Design Name: 
// Module Name: MIPS
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


module MIPS
(       
        // Entradas a modulo
        input clk, reset,
        input mdb_ena, // control de ena PC desde debug unit (clk enable)
        
        // Entradas desde Debug unit
        input [4:0] inm_du_areg, // entrada de debug unit address reg
        input inm_duc1, // flags de control 1 desde unidad de debug (interface_mips)
        input [31:0] inm_du_amem, // entrada de debug unit address mem
        input inm_duc2, // flags de control 2 desde unidad de debug (interface_mips)
        //input [31:0] memoria,
        //input write_enable,
        
        
		// Salidas del modulo
        output [31:0] m_PC,
        
        // - Para reg IF/ID
        output wire [31:0] ifid_PC, 	//salida del proximo PC por reg IF/ID
        output wire [31:0] ifid_inst, 	//salida de la instruccion por el reg IF/ID
        output reg PC_endM, // wire de flag PC_end registrada desde etapa IF1
    
        output wire [31:0] ifex_rsd1,
        output wire [31:0] ifex_rtd2,
        output wire [4:0] ifex_rsa,
        output wire [4:0] ifex_rta,
        output wire [4:0] ifex_rda,
        output wire [31:0] ifex_sign_ext,
		
		output wire [5:0] idex_regEX, // flags EX registradas en reg ID/EX
        output wire [2:0] idex_regMEM, // flags MEM registradas en reg ID/EX
        output wire [1:0] idex_regWB, // flags WB registradas en reg ID/EX
        output wire [5:0] opcode_FunctI, // FunctI como opcode de las instrucciones inmediatas

		// - Para re EX_MEM
        output wire [31:0] exmem_out_ALU, // salida de resultado de ALU desde reg EX_MEM
        output wire [4:0] exmem_out_addr, // salida de direccion de destino desde reg EX_MEM
        output wire [2:0] exmem_regMEM, // flags MEM registradas en reg EX/MEM
        output wire [1:0] exmem_regWB, // flags WB registradas en reg EX/MEM
        output wire exmem_zero, // Flags zero registrada en reg EX/MEM
        output wire [31:0] exmem_wrd, //salida de dato a escribir en data mem desde reg EX/MEM
        
        // - Para reg MEM_WR
        output wire [31:0] memwr_rdd, //
        output wire [31:0] memwr_addr_mem, //
        output wire [4:0] memwr_addr_dest, //
        output wire [1:0] memwr_WB,

		output wire [31:0] w_rd_data1, // wire a dato de registro fuente rs
        
        // - Para etapa 4
        output wire [31:0] out_MEM_rdd // tambien utilizada en debug unit (interface_mips)
        
        // auxiliares
        //output wire [31:0] instructionMem //primera erapa
        //output wire [31:0] reg_data_memory
);

// Parametros internos
localparam nbits = 32; // bits de registros
localparam msb = 31; // bit mas sigficativo
localparam [10:0] cero = 11'b00000000000; // misma cantidad de ceros que flag de control en muxID_2

// Salidas producto de la debug unit
wire [msb:0] out_muxMEM4;

// Variables internas
//wire clk2; // clk para latches intermedios y memoria de programa
reg PC_endM_next;
wire PC_endID, PC_endEX;

reg [2:0] cont, cont_next;

// - Para etapa 1
wire PC_Wr;
wire [msb:0] PC_next; // PC + 4 (resultado de sumador)

wire [msb:0] instructionMem;

wire IF_ID_Wr; //
wire IF_Flush; //

// - Para etapa 2
wire [msb:0] w_sign_extend; // wire a señal extendida
wire [msb:0] w_PC_jump;  	// wire a PC correspondiente a un salto branch (beq - bne)
wire [msb:0] w_PC_jump2; 	// wire a PC correspondiente a un salto jump (j - jal)
wire [4:0] w_rs_addr; 	 	// wire a direccion de registro fuente 1
wire [4:0] w_rt_addr; 	 	// wire a direccion de registro fuente 2
wire [4:0] w_rd_addr; 	 	// wire a direccion de registro destino
wire [msb:0] w_rd_data2; 		// wire a dato de registro fuente rt
wire [5:0] w_opcode; // wire a codigo de operacion de la instruccion - 6 bits - salida necesaria para la unidad de control
wire mf_iguales; // main f_iguales

//- Para reg ID/EX
wire [15:0] out_control; // wire out para conectar salidas de unidad de control (RegDst, ALUSrc, 
								 // ALUOp, ALUSrcA, beq, bne, jump, jal, jr, jalr, MemRead, MemWrite,
								 // RegWrite, MemtoReg, FunctSrc)
wire PC_end; // wire out para conectar salida PC_end de unidad de control
wire [10:0] out_muxID_2; // salida del multiplexor de la etapa 2 muxID_2 (seleccion entre las 10 flags de control o 0)

// - Para etapa 3
wire [msb:0] EX_out_ALU; // Salida de ALU de etapa 3 (EX)
wire [4:0] EX_addr_dest; // Salida de direccion destino de etapa 3 (EX)
wire out_zero; // salida de flag zero en etapa 3
wire [msb:0] w_out_wrd; //salida de dato a escribir en data mem desde etapa EX

// - Para unidad de anticipacion - Forward unit
wire [1:0] f_forwardA;
wire [1:0] f_forwardB;

// - Para re EX_MEM
wire [5:0] w_opcodeMEM; //
wire [msb:0] m_exmem_wrd; // main exmem_wrd

// - Para etapa 4
wire w_PCSrc; // selector de mux en etapa 1

// - Para reg MEM_WR
wire [5:0] w_opcodeWB;
wire [msb:0] m_memwr_rdd; // main memwr_rdd

// - Para etapa 5
wire [msb:0] out_WB5; // salida de estapa 5 WB


// Instancias
//- Etapa 1 busqueda de instruccion - Instruction Fetch - IF
instruction_fetch #(.bitsPC(nbits)) IF_1
(
	.clk(clk),
	.reset(reset),
	.db_ena(mdb_ena), 		// main db_ena
	.PC_end(PC_end), 		// fin del contador de programa
	.PC_Wr(PC_Wr), 			// flag desde unidad de deteccion de riesgos (hazard unit)
	.PC_Src(w_PCSrc), 		// contol desde etapa 4
	.jump(out_control[11]), // bandera jump desde unidad de control del pipelined mips
	.jal(out_control[13]),	// bandera jal desde unidad de control del pipelined mips
	.jr(out_control[14]), 	// bandera jr desde unidad de control del pipelined mips
	.jalr(out_control[15]), // bandera jalr desde unidad de control del pipelined mips
	.jump_PC(w_PC_jump),    // w_wr_data
	.jump2_PC(w_PC_jump2),  // 
	.PC_next(PC_next),
	.instructionMem(instructionMem),
	.outPC(m_PC)//, // salida de mips
	//.memoria(memoria),
	//.write_enable(write_enable)
);

// Obtencion de PCSrc: And entre flags Branch y f_iguales (para beq y bne)
assign w_PCSrc = (out_control[2] & mf_iguales) | (out_control[12] & !mf_iguales);

// Determinacion de señal IF_FLUSH
assign IF_Flush = w_PCSrc | out_control[11] | out_control[13] | out_control[14] | out_control[15];
	    // out_control[11] = jump	// out_control[13] = jal // out_control[14] = jr// out_control[15] = jalr

// - Registro IF/ID
IF_ID if_id
(
	.clk(clk), // clk2
	.IF_ID_Wr(IF_ID_Wr), // flag desde unidad de deteccion de riesgos (hazard unit)
	.PC_end(PC_endM),
	.IF_Flush(IF_Flush), // *
	.reset(reset),
	.db_ena(mdb_ena), // main db_ena
	.in_inst(instructionMem),
	.in_PCnext(PC_next),
	.out_PCnext(ifid_PC),
	.out_inst(ifid_inst)
);

// - Unidad de deteccion de riesgo - Hazard detection unid
hazard_unit hazardU
(
	.IDRegRs(ifid_inst[25:21]), // reg rs desde etapa ID
	.IDRegRt(ifid_inst[20:16]), // reg rt desde etapa ID
	.EXRegRt(ifex_rta),
	.EXMemRead(idex_regMEM[0]), // flag MemRd desde reg ID/EX
	.PCWrite(PC_Wr),
	.IFIDWrite(IF_ID_Wr), // flags para reg IF/ID
	.HazMuxCon(f_muxCtrl) // salida de flags para mux de control (muxID_2)
);

// - Unidad de Control - control_Unit
// nota: se reacomadan salidas wire para separar flags por etapas en multiplexor
control_Unit control
(
	.opcode(w_opcode),
	.Funct(ifid_inst[5:0]), // para instrucciones R-type
	.RegDst(out_control[8]),
	.ALUSrc(out_control[7]),
	.ALUSrcA(out_control[10]),
	.ALUOp(out_control[6:5]),
	.beq(out_control[2]),
	.bne(out_control[12]), // analizar camino
	.jump(out_control[11]), // analizar camino
	.jal(out_control[13]),
	.jr(out_control[14]),
	.jalr(out_control[15]),
	.MemRead(out_control[0]),
	.MemWrite(out_control[1]),
	.RegWrite(out_control[3]),
	.MemtoReg(out_control[4]),
	.FunctSrc(out_control[9]),
	.PC_end(PC_end)
);

// - Multiplexor de etapa 2 (seleccion entre out_control y 0) - mux2a1
mux2a1 #(.nbits(11)) muxID_2 // 11 flags de control
(
	.A(cero), // cero
	.B(out_control[10:0]), // no se tiene en cuenta flag jump
	.sel(f_muxCtrl), // flags desde unidad de deteccion de riesgo (hazard unit)
	.salida(out_muxID_2)
);

// - Etapa 2 decodificacion de instruccion - Instruction Decode - ID
instruction_decode #(.bitsPC(nbits)) ID_2
(
	.clk(clk),
	.reset(reset),
	.f_control(out_control),
	.instruction(ifid_inst),
	.PCnext(ifid_PC),
	.wr_ena(memwr_WB[0]), // flags RegWrite desde reg memwr_WB[0]
	.wr_addr(memwr_addr_dest), // direccion RegDst desde reg MEM/WB
	.wr_data(out_WB5), // desde etapa 5 salida de mux WB_5
	.rs_addr(w_rs_addr),
	.rt_addr(w_rt_addr),
	.rd_addr(w_rd_addr),
	.in_du_areg(inm_du_areg), 	//ingreso de direccion a mips desde unidad de debug
	.in_duc1(inm_duc1), 		//ingreso de flags de control a mips desde unidad de debug
	.rd_data1(w_rd_data1),
	.rd_data2(w_rd_data2),
	.opcode(w_opcode),
	.sign_ext(w_sign_extend),
	.PC_jump(w_PC_jump),
	.out_muxPCjump(w_PC_jump2),
	.f_iguales(mf_iguales) // main f_iguales
	//.reg_data_memory(reg_data_memory)
);

// - Registro ID/EX
ID_EX id_ex
(
	.clk(clk), // clk2
	.reset(reset),
	.db_ena(mdb_ena), // main db_ena
	.IDEX_Wr(PC_endM),
	.in_rd_data1(w_rd_data1),
	.in_rd_data2(w_rd_data2),
	.in_sign_ext(w_sign_extend),
	.in_rs_addr(w_rs_addr),
	.in_rt_addr(w_rt_addr),
	.in_rd_addr(w_rd_addr),
	.in_EX(out_muxID_2[10:5]),// 6 flags (ALUSrcA, FunctSrc, RegDst, ALUSrc, ALUOp)
	.in_MEM(out_muxID_2[2:0]), // 3 flags (beq, MemWr, MemRd)
	.in_WB(out_muxID_2[4:3]), // 2 flags (MemtoReg, RegWrite)
	.in_opcode(w_opcode),
	.out_rd_data1(ifex_rsd1),
	.out_rd_data2(ifex_rtd2),
	.out_sign_ext(ifex_sign_ext),
	.out_rs_addr(ifex_rsa), //*
	.out_rt_addr(ifex_rta),
	.out_rd_addr(ifex_rda),
	.out_EX(idex_regEX), // flags de etapa 3
	.out_MEM(idex_regMEM), // flags de etapa 4
	.out_WB(idex_regWB), // flags de etapa 5
	.out_opcode(opcode_FunctI), // opcode como funcion de instrucciones I-type - FunctI
	.out_PCendID(PC_endID) // flag PC_end desde etapa ID2
);

// - Etapa 3 Ejecucion - Execute - EX
execute EX_3
(
	.in_rd_data1(ifex_rsd1),
	.in_rd_data2(ifex_rtd2),
	.in_rt_addr(ifex_rta),
	.in_rd_addr(ifex_rda),
	.in_sign_ext(ifex_sign_ext), // inmediate value
	.ex_mem_ALU(exmem_out_ALU), // valor anterior de la ALU desde etapa 4
	.WB_mux(out_WB5), // ingreso de la salida de etapa 5
	.forwardA(f_forwardA), // flags desde unidad de anticipacion (forward unit)
	.forwardB(f_forwardB), // flags desde unidad de anticipacion (forward unit)
	.Funct(ifex_sign_ext[5:0]), // funcion de instruccion - primeros 6 bits de inst
	.FunctI(opcode_FunctI), //
	.in_regEX(idex_regEX),
	.out_ALU(EX_out_ALU),
	.addr_dest(EX_addr_dest),
	.out_wrd(w_out_wrd), // dato a escribir en data memory
	.zero(out_zero)
);

// - Unida de anticipacion - Forward Unit
forward_unit forwardU
(
	.MEMRegRd(exmem_out_addr),
	.WBRegRd(memwr_addr_dest),
	.EXRegRs(ifex_rsa),
	.EXRegRt(ifex_rta),
	.MEM_RegWrite(exmem_regWB[0]), // flags RegWrite desde reg exmem_regWB[0]
	.WB_RegWrite(memwr_WB[0]), // flags RegWrite desde reg memwr_WB[0]
	.ForwardA(f_forwardA), // salida de flag forwardA
	.ForwardB(f_forwardB) // salida de flag forwardB
);

// - Registro EX/MEM
EX_MEM ex_mem
(
	.clk(clk), // clk2
	.reset(reset),
	.db_ena(mdb_ena), // main db_ena
	.EXMEM_Wr(PC_endID),
	.inEX_ALU(EX_out_ALU),
	.in_zero(out_zero),
	.inEX_addr_dest(EX_addr_dest),
	.in_wr_data(w_out_wrd),
	.in_regMEM(idex_regMEM),
	.in_regWB(idex_regWB),
	.exmem_addr_dest(exmem_out_addr),
	.exmem_ALU(exmem_out_ALU),
	.in_opcodeEX(opcode_FunctI), //
	.out_MEM(exmem_regMEM),
	.out_WB(exmem_regWB),
	.out_zero(exmem_zero),
	.out_wr_data(exmem_wrd), // registro del dato a escribir en data memory
	.out_PCendEX(PC_endEX), // flag PC_end desde etapa EX3
	.out_opcodeMEM(w_opcodeMEM) //
);

// - Multiplexor de debug unit (seleccion entre direccionDU o direccionALU ) - mux2a1
mux2a1 #(.nbits(nbits)) muxMEM4 //
(
	.A(inm_du_amem), // entrada de debug unit address mem
	.B(exmem_out_ALU), //
	.sel(inm_duc2), // flags de control 1 desde unidad de debug (interface_mips)
	.salida(out_muxMEM4)
);



// - Etapa 4 Acceso a Memoria - Memory access - MEM
memory_access MEM_4
(
	.clk(clk),
	.reset(reset),
	.in_EXMEM_ALU(out_muxMEM4), // exmem_out_ALU - dirreccion a leer o escribir de mememoria
	.in_zero(exmem_zero),
	.in_regMEM(exmem_regMEM),
	.in_wrd(m_exmem_wrd), // exmem_wrd - dato a escribir en data mem
	.in_du_rd(inm_duc2), // se utiliza entrada de control 1 de debug unit tambien como flag de lectura en mem data
	.out_data(out_MEM_rdd),
	.out_PCSrc() // Flags PCSrc para mux de etapa 1 - Se deja de usar ya que se realiza en la etapa ID2
);

// - Registro MEM/WR
MEM_WR mem_wr
(
	.clk(clk), // clk2
	.reset(reset),
	.db_ena(mdb_ena), // main db_ena
	.MEMWB_Wr(PC_endEX),
	.in_rd_data(out_MEM_rdd), //
	.in_addr_mem(exmem_out_ALU), //
	.in_addr_dest(exmem_out_addr),
	.in_regWB(exmem_regWB),
	.in_opcodeMEM(w_opcodeMEM), //
	.out_rd_data(memwr_rdd), //
	.out_addr_mem(memwr_addr_mem), //
	.out_addr_dest(memwr_addr_dest), //
	.out_WB(memwr_WB),
	.out_opcodeWB(w_opcodeWB) //
);


// Detector de byte, halfword o word (sb - sh - sw)
Detector_sb_sh_sw detector_2(
    .w_opcodeMEM(w_opcodeMEM),
    .exmem_wrd(exmem_wrd),
    .m_exmem_wrd(m_exmem_wrd)
);




// Detector de byte, halfword o word (lb - lh - lw)
Detector_lb_lh_lw detector(
    .w_opcodeWB(w_opcodeWB),
    .memwr_rdd(memwr_rdd),
    .m_memwr_rdd(m_memwr_rdd)
 );

// Etapa 5 Retro escritura - Write Back - WB
mux2a1 #(.nbits(nbits)) WB_5
(
	.A(m_memwr_rdd), // main memwr_rdd
	.B(memwr_addr_mem),
	.sel(memwr_WB[1]), // flags mentoReg desde reg memwr_WB[1]
	.salida(out_WB5) // conexion a etapa 2 wr_data
);

// Inicio de flags PC_end
initial
begin
	PC_endM = 1'b0;
	cont = 0;
end

// Asignacion de valores a PC_endM
always@(posedge clk, posedge reset)
begin
	if(reset) begin
		PC_endM <= 1'b0;
		cont <= 0;
	end
		
	else begin
		PC_endM <= PC_endM_next;
		cont <= cont_next;
	end
end

// Logica de determinacion de PC_endM
always@(*)
begin
	PC_endM_next = PC_endM;
	cont_next = cont;
	if(!PC_endM && PC_end)
		cont_next = 1;
		
	/*else if(cont > 0 && cont < 2) // retraso de flag PC_end de un ciclo
		cont_next = cont + 1;*/
	
	else if(cont == 1) begin
		PC_endM_next = 1'b1;
		cont_next = 0;
	end
end

endmodule
