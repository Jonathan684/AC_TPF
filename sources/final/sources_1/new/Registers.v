`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:43:40
// Design Name: 
// Module Name: Registers
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


module Registers
(   
    clk, reset, rd_addr1,
    rd_addr2, wr_addr3,
    wr_data, wr_ena,
    rd_data1, rd_data2
);

// Parametros internos
parameter msb = 31; // bit mas sigficativo

// Entradas a modulo
input clk, reset; // clock

// - Registros: indicaran las direcciones de los registros a leer y escribir
input [4:0] rd_addr1; // direccion de Registro a leer 1 (read register 1)
input [4:0] rd_addr2; // direccion de Registro a leer 2 (read register 2)
input [4:0] wr_addr3; // direccion de Registro a escribir 3 (write register 3)

// - Dato a escribir
input [msb:0] wr_data; // write data

// - Entrada de control
input wr_ena; // write enable

// Salidas de modulo
output reg [msb:0] rd_data1;// - Dato leeido 1 (read data 1)
output reg [msb:0] rd_data2;// - Dato leeido 2 (read data 2)

// Variables internas
reg [msb:0] reg_data_memory [0:31]; // memoria de datos de registros (32 registros de 32 bits de datos)
reg [6:0] i; // contador hasta 31



// Lectuara de registros
always@(negedge clk)
begin
		rd_data1 <= reg_data_memory[rd_addr1];
		rd_data2 <= reg_data_memory[rd_addr2];
		$monitor("wr_ena : %b",wr_ena);
		$monitor ("R2: %d R3: %d R4: %d R5 %d R6: %d R7: %d R8 %d R9: %d R10: %d R11 %d R12: %d R13: %d R14%d",
		reg_data_memory[2],reg_data_memory[3],reg_data_memory[4],reg_data_memory[5],reg_data_memory[6],
		reg_data_memory[7],reg_data_memory[8],reg_data_memory[9],reg_data_memory[10],
		reg_data_memory[11],reg_data_memory[12],reg_data_memory[13],reg_data_memory[14]);
end

// Escritura de registro
always@(posedge clk, posedge reset)
begin
	if(reset) // inicializacion en reset
	begin
	    $monitor("reset el registro");
		reg_data_memory[0] <= 0;
		for( i = 1 ; i<32 ; i=i+1)
					reg_data_memory[i] <= 1;
	end
	else begin
		if(wr_ena) begin
		 
			reg_data_memory[wr_addr3] <= wr_data;
			$monitor("Escribiendo en wr_addr: %d con Dato wr_data: %d",wr_addr3,wr_data);
			$monitor("valor de 0 : %d",reg_data_memory[0]);
		end
	end
end

endmodule