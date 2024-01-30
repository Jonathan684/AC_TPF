`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2023 00:28:19
// Design Name: 
// Module Name: sim0
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


module sim0();
parameter msb = 31; // bit mas sigficativo   
// Entradas a modulo
reg clk, reset;
reg mdb_ena; // control de ena PC desde debug unit (clk enable)
        
// Entradas desde Debug unit
reg [4:0] inm_du_areg; // entrada de debug unit address reg
reg inm_duc1; // flags de control 1 desde unidad de debug (interface_mips)
reg [msb:0] inm_du_amem; // entrada de debug unit address mem
reg inm_duc2; // flags de control 2 desde unidad de debug (interface_mips)

// Salidas del modulo
wire [msb:0] m_PC;
// - Para reg IF/ID
wire [msb:0] ifid_PC; 	//salida del proximo PC por reg IF/ID
wire [msb:0] ifid_inst; 	//salida de la instruccion por el reg IF/ID
wire PC_endM; // wire de flag PC_end registrada desde etapa IF1
wire [msb:0] ifex_rsd1;
wire [msb:0] ifex_rtd2;
wire [4:0] ifex_rsa;
wire [4:0] ifex_rta;
wire [4:0] ifex_rda;
wire [msb:0] ifex_sign_ext;
wire [5:0] idex_regEX; // flags EX registradas en reg ID/EX
wire [2:0] idex_regMEM; // flags MEM registradas en reg ID/EX
wire [1:0] idex_regWB; // flags WB registradas en reg ID/EX
wire [5:0] opcode_FunctI; // FunctI como opcode de las instrucciones inmediatas
// - Para re EX_MEM
wire [msb:0] exmem_out_ALU; // salida de resultado de ALU desde reg EX_MEM
wire [4:0] exmem_out_addr; // salida de direccion de destino desde reg EX_MEM
wire [2:0] exmem_regMEM; // flags MEM registradas en reg EX/MEM
wire [1:0] exmem_regWB; // flags WB registradas en reg EX/MEM
wire exmem_zero; // Flags zero registrada en reg EX/MEM
wire [msb:0] exmem_wrd; //salida de dato a escribir en data mem desde reg EX/MEM
        
// - Para reg MEM_WR
wire [msb:0] memwr_rdd; //
wire [msb:0] memwr_addr_mem; //
wire [4:0] memwr_addr_dest; //
wire [1:0] memwr_WB;
wire [msb:0] w_rd_data1; // wire a dato de registro fuente rs
// - Para etapa 4
wire [msb:0] out_MEM_rdd; // tambien utilizada en debug unit (interface_mips)
/*w_rd_data2,*/
//wire [msb:0] instructionMem;
//wire [msb:0] reg_data_memory;
always begin
    #50
    clk = ~clk;
end

initial
begin
#0 
//COMENZAMOS TODO EN CERO 
clk = 1'b1;
reset = 1'b1;
inm_duc1 = 1'b0;
inm_du_areg = 4'b0000;
mdb_ena = 1'b1;
inm_du_amem = 32'b00000000000000000000000000000000;
inm_duc2 = 1'b0;

#10
reset = 1'b0;

//#75
////COMENZAMOS TODO EN CERO 
//reset = 1'b0;
end

MIPS U0(
    .clk(clk),
    .reset(reset),
    .mdb_ena(mdb_ena), // control de ena PC desde debug unit (clk enable)
    .inm_du_areg(inm_du_areg), // entrada de debug unit address reg
    .inm_duc1(inm_duc1), // flags de control 1 desde unidad de debug (interface_mips)
    .inm_du_amem(inm_du_amem), // entrada de debug unit address mem
    .inm_duc2(inm_duc2), // flags de control 2 desde unidad de debug (interface_mips)
    .m_PC(m_PC),
    .ifid_PC(ifid_PC), 	//salida del proximo PC por reg IF/ID
    .ifid_inst(ifid_inst), 	//salida de la instruccion por el reg IF/ID
    .PC_endM(PC_endM), // wire de flag PC_end registrada desde etapa IF1
    .ifex_rsd1(ifex_rsd1),
    .ifex_rtd2(ifex_rtd2),
    .ifex_rsa(ifex_rsa),
    .ifex_rta(ifex_rta),
    .ifex_rda(ifex_rda),
    .ifex_sign_ext(ifex_sign_ext),
    .idex_regEX(idex_regEX), // flags EX registradas en reg ID/EX
    .idex_regMEM(idex_regMEM), // flags MEM registradas en reg ID/EX
    .idex_regWB(idex_regWB), // flags WB registradas en reg ID/EX
    .opcode_FunctI(opcode_FunctI), // FunctI como opcode de las instrucciones inmediatas
    .exmem_out_ALU(exmem_out_ALU), // salida de resultado de ALU desde reg EX_MEM
    .exmem_out_addr(exmem_out_addr), // salida de direccion de destino desde reg EX_MEM
    .exmem_regMEM(exmem_regMEM), // flags MEM registradas en reg EX/MEM
    .exmem_regWB(exmem_regWB), // flags WB registradas en reg EX/MEM
    .exmem_zero(exmem_zero), // Flags zero registrada en reg EX/MEM
    .exmem_wrd(exmem_wrd), //salida de dato a escribir en data mem desde reg EX/MEM
    .memwr_rdd(memwr_rdd), //
    .memwr_addr_mem(memwr_addr_mem), //
    .memwr_addr_dest(memwr_addr_dest), //
    .memwr_WB(memwr_WB),
    .w_rd_data1(w_rd_data1), // wire a dato de registro fuente rs
    .out_MEM_rdd(out_MEM_rdd) // tambien utilizada en debug unit (interface_mips)
    //.instructionMem(instructionMem)
 //   .reg_data_memory(reg_data_memory)
);

endmodule
