`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2023 09:02:17
// Design Name: 
// Module Name: sim
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

module sim();
 //local parameters
    localparam  DBIT    = 8;
    localparam  SBTICK  = 16;
    localparam  FIFO_W  = 2;

reg clk;
reg reset;
reg rx;

wire [7:0] auxiliar3;
wire tx;
wire tx_full, rx_empty;

initial begin
      clk           =   1'b0    ;
      reset         =   1'b1    ;
      #20
      rx            =   1'b1    ;

      reset           =   1'b0    ;

      //DATO 1 = 8'h1
      #3250
      rx            =   1'b1    ; //idle
      #50000
      rx            =   1'b0    ; //Start
      #50000
      rx            =   1'b1    ; //Data
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b0    ;
      #50000
      rx            =   1'b1    ;   //  Stop
      
      #50000
      rx            =   1'b1    ;   //  Se pone la entrada en alto asi el receptor deja de recibir
      
     
      
      #25000000
      $display("#############     Test OK    ############");
      $finish();
    end // initial
    
    always begin
      #10
      clk       =   ~clk    ;
    end
MIPS_UART #(
            .DBIT(DBIT),     // numero de bits de datos
			.SB_TICK(SB_TICK), // numero de tick en bit stop
			.FIFO_W(FIFO_W)  // numero de bits de direcciones en buff fifo
    )
    U0(   
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .tx_full(tx_full),
    .rx_empty(rx_empty),
    .tx(tx),
    .auxiliar3(auxiliar3)
    );
	
endmodule
