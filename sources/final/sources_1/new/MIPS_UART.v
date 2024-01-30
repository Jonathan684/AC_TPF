`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2023 17:26:49
// Design Name: 
// Module Name: MIPS_UART
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


module MIPS_UART
#(parameter		DBIT = 8,     // numero de bits de datos
				SB_TICK = 16, // numero de tick en bit stop
				FIFO_W = 2    // numero de bits de direcciones en buff fifo
)
(   clk, reset,
    rx, tx_full,
    rx_empty, tx,auxiliar3
);

	// Parametros internos
	parameter msb = 31; // bit mas sigficativo
	
	// Entradas modulo
	input clk;
	input reset;
	input rx;
	
	// Salidas modulo
	//output auxiliar;
	//output auxiliar4;
	//output [7:0] auxiliar2;
	output [7:0] auxiliar3;
	output tx;
	output wire tx_full, rx_empty;
	wire [DBIT-1:0] r_data;        //realidad
	
	// Variables internas
	wire rd, wr; // wr_tick, rd_tick;
    wire [DBIT-1:0] rec_data, rec_data1;
	wire reset_aux, reset_or;
	// Registro PC
	wire [msb:0] w_PC; // PC wire
	// Registro IFID
	wire [msb:0] w_ifidPC;
	wire [msb:0] w_ifidInst;
	wire w_PCend;
	// Registro IDEX
	wire [msb:0] w_ifex_rsd1;
	wire [msb:0] w_ifex_rtd2;
	wire [msb:0] w_ifex_sign_ext;
	wire [msb:0] w_idex_reg4; // union en registro de 32
									  // {w_ifex_rsa,w_ifex_rta,w_ifex_rda,w_idex_regEX,w_idex_regMEM,w_idex_regWB,w_opcode_FunctI};
	//wire [4:0] w_ifex_rsa; // w_idex_reg4[31:27]
	//wire [4:0] w_ifex_rta; // w_idex_reg4[26:22]
	//wire [4:0] w_ifex_rda; // w_idex_reg4[21:17]
	//wire [5:0] w_idex_regEX; // w_idex_reg4[16:11]
	//wire [2:0] w_idex_regMEM; // w_idex_reg4[10:8]
	//wire [1:0] w_idex_regWB; // w_idex_reg4[7:6]
	//wire [5:0] w_opcode_FunctI; // w_idex_reg4[5:0]
	
	// Registro EXMEM
	wire [msb:0] w_exmem_out_ALU;
	wire [msb:0] w_exmem_wrd;
	wire [15:0] exmen_reg3; // union en registro de 16
									// {5'b00000,w_exmem_regMEM,w_exmem_regWB,w_exmem_zero,w_exmem_out_addr};
	//wire [2:0] w_exmem_regMEM; // exmen_reg3[10:8]
	//wire [1:0] w_exmem_regWB; // exmen_reg3[7:6]
	//wire w_exmem_zero; // exmen_reg3[5]
	//wire [4:0] w_exmem_out_addr; // exmen_reg3[4:0]
	
	// Registro MEMWB
	wire [msb:0] w_memwr_rdd; //
	wire [msb:0] w_memwr_addr_mem; //
	wire [7:0] memwb_reg3; // union en registro de 8
								  // {1'b0,w_memwr_WB,w_memwr_addr_dest};
	//wire [4:0] w_memwr_addr_dest; // memwb_reg3[6:2]
	//wire [1:0] w_memwr_WB; // memwb_reg3[1:0]
	
	// Acceso a Modulo de Registros
	wire [4:0] w_out_du_areg;
	wire w_out_duc1;
	wire [msb:0] w_rdd; // reg data 1 o 2 desde mem datos de mips
	
	
	// Acceso a memoria de datos
	wire w_out_duc2;
	wire [msb:0] w_rddmem;
	wire [msb:0] w_out_du_amem;
	wire w_tick; // clk tick desde UART
	
	// control de clk
	wire w_out_duc3;
	wire mwr_secure;
	//memoria
    //wire [31:0] memoria;
    //wire write_enable;
	// Var DCM
	wire clk_25MHz;
    
	// Instacia de DCM - Reduccion de clk
//	DCM_CLKGEN #(
//		 .CLKIN_PERIOD("100 MHZ"),
//		 .CLKFX_MULTIPLY(2),
//		 .CLKFX_DIVIDE(8)
//	) clkgen_25 (
//		 .RST     (1'b0),
//		 .CLKIN   (clk),
//		 .CLKFX   (clk_25MHz)
//	);
	 clk_wiz_0 instance_name
   (
    // Clock out ports
    .CLK_100MHZ(CLK_100MHZ),     // output CLK_100MHZ
    .CLK_25MHZ(clk_25MHz),     // output CLK_25MHZ
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk)
    );      // input clk_in1

	

	// Instancia uart
   uart #(.DBIT(DBIT), .SB_TICK(SB_TICK), .FIFO_W(FIFO_W))
	uart_unit
      (.clk(clk_25MHz), .reset(reset), 
       .rd_uart(rd),
       .wr_uart(wr),
       .rx(rx),
       .w_data(rec_data1),
       .tx_full(tx_full),
       .rx_empty(rx_empty),
       .r_data(rec_data),
       .tx(tx),.tick(w_tick)//,
       //.auxiliar3(auxiliar3)
       //.auxiliar2(auxiliar2)
       );//, .tick(w_tick));
	
	// Instancia de MIPS
	MIPS mips_unit (
		.clk(clk_25MHz),
		.reset(reset_or),
		.mdb_ena(w_out_duc3),
		.inm_du_areg(w_out_du_areg),
		.inm_duc1(mwr_secure), // w_out_duc1
		.inm_duc2(mwr_secure), // w_out_duc2
		//.memoria(memoria),
		//.write_enable(write_enable),
		.inm_du_amem(w_out_du_amem),
		.m_PC(w_PC),
		.ifid_PC(w_ifidPC), 
		.ifid_inst(w_ifidInst),
		.PC_endM(w_PCend),
		.ifex_rsd1(w_ifex_rsd1), 
		.ifex_rtd2(w_ifex_rtd2), 
		.ifex_sign_ext(w_ifex_sign_ext), 
		.ifex_rsa(w_idex_reg4[31:27]), 
		.ifex_rta(w_idex_reg4[26:22]), 
		.ifex_rda(w_idex_reg4[21:17]),
		.idex_regEX(w_idex_reg4[16:11]),	
		.idex_regMEM(w_idex_reg4[10:8]), 
		.idex_regWB(w_idex_reg4[7:6]),
		.opcode_FunctI(w_idex_reg4[5:0]), 
		.exmem_wrd(w_exmem_wrd), 
		.exmem_out_ALU(w_exmem_out_ALU),
		.exmem_regMEM(exmen_reg3[10:8]),	
		.exmem_regWB(exmen_reg3[7:6]),
		.exmem_out_addr(exmen_reg3[4:0]), 
		.exmem_zero(exmen_reg3[5]),
		.memwr_rdd(w_memwr_rdd), 
		.memwr_addr_mem(w_memwr_addr_mem),
		.memwr_addr_dest(memwb_reg3[6:2]), 
		.memwr_WB(memwb_reg3[1:0]),
		.w_rd_data1(w_rdd), /*.w_rd_data2(),*/ 
		.out_MEM_rdd(w_rddmem)
		
	);
	
	// Instancia de modulo interface
	interface_mips #(.N(DBIT))
	intf_unit (
		.clk(clk_25MHz), .reset(reset), .in_tick(w_tick),
		.empty_uart(rx_empty), .tx_full(tx_full),	.uart_in(rec_data),
		.in_PC(w_PC), .in_PCend(w_PCend), .in_ifid_PC(w_ifidPC),
		.in_ifid_inst(w_ifidInst),	.in_idex1(w_ifex_rsd1), 
		.in_idex2(w_ifex_rtd2), .in_idex3(w_ifex_sign_ext), .in_idex4(w_idex_reg4),
		.in_exmem1(w_exmem_out_ALU), .in_exmem2(w_exmem_wrd), .in_exmem3(exmen_reg3),
		.in_memwb1(w_memwr_rdd), .in_memwb2(w_memwr_addr_mem), .in_memwb3(memwb_reg3),
		.in_rdd1(w_rdd), // ingreso de read data 1 o 2 desde modulo Registro
		.in_rddmem(w_rddmem), // ingreso de read data mem desde mips
		.uart_out(rec_data1), // relaidad (rec_data1) 
		.rd_uart(rd),
		.wr_uart(wr),// poner wr
		.reset_outw(reset_aux),
		.out_du_areg(w_out_du_areg), .out_duc1(w_out_duc1), .out_duc2(w_out_duc2),
		.out_du_amem(w_out_du_amem), .out_duc3(w_out_duc3), .wr_secure(mwr_secure),
        .auxiliar3(auxiliar3)
//        .memoria(memoria),
//        .write_enable(write_enable)
		//.auxiliar(auxiliar),
		//.auxiliar4(auxiliar4)
		//.auxiliar3(auxiliar3)
	);
	
	assign reset_or = (reset | reset_aux); // or entre reset y reset_aux para resetear BIP segun cualquier de los reset
	
	// Union de conjunto de registros peque�os enuno general
	//assign w_idex_reg4 = {w_ifex_rsa,w_ifex_rta,w_ifex_rda,w_idex_regEX,w_idex_regMEM,w_idex_regWB,w_opcode_FunctI};
	assign exmen_reg3[15:11] = 5'b00000; // {5'b00000,w_exmem_regMEM,w_exmem_regWB,w_exmem_zero,w_exmem_out_addr};
	assign memwb_reg3[7] = 1'b0; // {1'b0,w_memwr_WB,w_memwr_addr_dest};

endmodule
