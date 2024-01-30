`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2023 17:37:50
// Design Name: 
// Module Name: Tx
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


module Tx#(parameter N = 8,     // # DBIT: n° bits de dato
            M = 16  // # SB_TICK: n° de ticks de bit stop
   )
(clk, reset, tx_start, s_tick, din, tx_done_tick, tx);
	
	// Entradas
	input wire clk, reset; // clk: clock de FPGA - reset: señal para resetear FSM
   input wire tx_start, s_tick;// tx_start: señal bit de inicio - s_tick_clk: clock de baud rate gen.
   input wire [7:0] din; // din: bits de datos recibidos en paralelo
   
	// Salidas
	output reg tx_done_tick;
   output wire tx;

   // Declaracion de estados
   localparam [3:0]
      idle  = 4'b0001,// esperando señal de inicio (START)
      start = 4'b0010,// transmitiendo bit de inicio (START)
      data  = 4'b0100,// trasmitiendo bits de datos
      stop  = 4'b1000;// trasmitiendo bit de STOP

   // Declaracion de señales con inicializacion en cada una
	reg [3:0] state, state_next=idle;// estados de 4 bits
   reg [3:0] s_reg, s_next=0; //s_reg: Tick counter -> cuenta los ticks desde el inicio, maxima cuenta 15(4 bits)
   reg [2:0] n_reg, n_next=0; //n_reg: data counter -> cuenta los bits de datos leidos, maxima cuenta 7(3 bits)
   reg [7:0] b_reg, b_next=0; //b_reg: registro de bits de datos (8 bits de datos)
   reg tx_reg, tx_next=1; // tx_reg: reg de señal de bit a trasmitir

   // Estados de la FSM & Resgistros de datos
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            state <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;
         end
      else
         begin
            state <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
         end

  // Logica de siguiente estado
   always @*
   begin
      state_next = state;
      tx_done_tick = 1'b0;
      s_next = s_reg;
      n_next = n_reg;
      b_next = b_reg;
      tx_next = tx_reg ;
      case (state)
         idle:
            begin
               tx_next = 1'b1;
               if (tx_start)
                  begin
                     state_next = start;
                     s_next = 0;
                     b_next = din;
                  end
            end
         start:
            begin
               tx_next = 1'b0;
               if (s_tick)
                  if (s_reg==15)
                     begin
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                     end
                  else
                     s_next = s_reg + 1;
            end
         data:
            begin
               tx_next = b_reg[0];
               if (s_tick)
                  if (s_reg==15)
                     begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg==(N-1))
                           state_next = stop ;
                        else
                           n_next = n_reg + 1;
                     end
                  else
                     s_next = s_reg + 1;
            end
         stop:
            begin
               tx_next = 1'b1;
               if (s_tick)
                  if (s_reg==(M-1))
                     begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                     end
                  else
                     s_next = s_reg + 1;
            end
      endcase
   end
   
	// Logica de Salidas
   assign tx = tx_reg;


endmodule

