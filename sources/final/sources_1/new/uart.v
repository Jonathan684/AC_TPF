`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2023 17:28:21
// Design Name: 
// Module Name: uart
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


module uart#(//Default setting :
// 1 9 , 2 0 0 b a u d , 8 data b i t s
	parameter DBIT = 8,
			  SB_TICK = 16, //
			  FIFO_W = 2 // bits de direcciones en buff fifo
			 //DVSR = 163,
			 //DVSR_BIT = 8, //
)
(
	input wire clk, reset,
	input wire rd_uart , wr_uart , rx,
	input wire [7:0] w_data,
	output wire tx_full, rx_empty, tx,
	output wire [7:0] r_data,
	output wire tick//,
	//output wire [7:0] auxiliar3
	//output [7:0] auxiliar2
);

// signal declaration
	wire  rx_done_tick , tx_done_tick;
	wire tx_empty, tx_fifo_not_empty;
	wire [7:0] tx_fifo_out , rx_data_out;

//body
// Instacicacion de modulo Baud Rate Generator
	Baut_Rate_Generator ibrg (
		.clock(clk), 
		.tick(tick)
	);
	
	
// Instancia de receptor rx
	Rx #(.N(DBIT), .M(SB_TICK))
	irx (
		.clk(clk),
		.reset(reset),
		.rx(rx),
		.s_tick_clk(tick),
		.rx_done_tick(rx_done_tick),
		.dout(rx_data_out)	
	);
	
// Instancia de interfaz receptor (buff fifo)
	fifo #(.N(DBIT), .W(FIFO_W))
	iic_rx (
		.clk(clk),
		.reset(reset),
		.rd(rd_uart),
		.wr(rx_done_tick),
		.w_data(rx_data_out),
		.empty(rx_empty),
		.full(),
		.r_data(r_data)
	);
	//assign auxiliar2 = r_data;
// Instancia de interfaz transmisor (buff fifo)
	fifo #(.N(DBIT), .W(FIFO_W))
	iic_tx (
		.clk(clk),
		.reset(reset),
		.rd(tx_done_tick),
		.wr(wr_uart),
		.w_data(w_data),
		.empty(tx_empty),
		.full(tx_full),
		.r_data(tx_fifo_out)
	);
	
// Instancia de transmisor tx
	Tx #(.N(DBIT), .M(SB_TICK))
	itx (
		.clk(clk),
		.reset(reset),
		.tx_start(tx_fifo_not_empty),
		.s_tick(tick),
		.din(tx_fifo_out),
		.tx_done_tick(tx_done_tick),
		.tx(tx)
		
	);
	assign tx_fifo_not_empty = ~tx_empty;
	//assign auxiliar3  = r_data;
endmodule

