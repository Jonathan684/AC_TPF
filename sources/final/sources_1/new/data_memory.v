`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 17:51:15
// Design Name: 
// Module Name: data_memory
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


module data_memory(clk, reset, Rd, Wr, Addr, wr_data, rd_data);
	
	// Parametros internos
	parameter msb = 31;
	parameter memorySize = 10; // 2KB

	// Entradas modulo
	input wire clk, reset;
	input wire Rd, Wr;
	input wire [msb:0] Addr;
	input wire [msb:0] wr_data;

	// Salidas modulo
	output reg [msb:0] rd_data;

	// Variables internas
	reg [msb:0] data_memory [0:memorySize]; // datos de 32 con 2KB de direcciones
	integer i;
	
	// Escritura de memoria de datos
	/*always@(Addr, Rd, Wr, wr_data)
	if(Wr) begin // Write
				data_memory[Addr] <= wr_data;
				$monitor("Escribiendo en data_mem[%d] con Dato wr_data: %d",Addr,wr_data);
	end
	
	// Lectura de memoria de datos
	always@(Addr, Rd, Wr, wr_data)
	if(Rd) // Read
		rd_data <= data_memory[Addr];*/
	
	// Otra forma
	// Escritura de memoria de datos
	always@(posedge clk, posedge reset)
	begin
		if(reset)
		
		begin
		    for( i = 0 ; i<= memorySize ; i=i+1)
				data_memory[i] <= 3;
		end
	
		else
			if(Wr) begin // Write
					data_memory[Addr] <= wr_data;
					$monitor("Escribiendo en data_mem[%d] con Dato wr_data: %d",Addr,wr_data);
			end
	end
	
	// Lectura de memoria de datos
	always@(posedge clk, posedge reset)
	begin
		if(reset)
			rd_data <= 0;
	
		else begin
			if(Rd) // Read
				rd_data <= data_memory[Addr];
		end
	end

endmodule

