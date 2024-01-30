   `timescale 1ns / 1ps
   //////////////////////////////////////////////////////////////////////////////////
   // Company: 
   // Engineer: 
   // 
   // Create Date: 23.08.2023 17:36:31
   // Design Name: 
   // Module Name: Rx
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


   module Rx#(parameter N = 8,     // # DBIT: n� bits de dato
               M = 16  // # SB_TICK: n� de ticks de bit stop
      )
   (clk, reset,rx, s_tick_clk,rx_done_tick,dout);// E/S - I/O

      // Entradas
      input wire clk, reset; // clk: clock de FPGA - reset: se�al para resetear FSM
      input wire rx, s_tick_clk; // rx: se�al bit de recepcion - s_tick_clk: clock de baud rate gen.
      
      // Salidas
      output reg rx_done_tick; // bandera de recepcion
      output wire [7:0] dout; // salida de bit de datos recibidos
      
      // Declaracion de estados
      localparam [3:0]
         idle  = 4'b0001,// esperando bit de inicio de recpcion (START)
         start = 4'b0010,// recibiendo bit de inicio (START)
         data  = 4'b0100,// recibiendo bit de datos
         stop  = 4'b1000;// recibiendo bit de STOP

      // Declaracion de se�ales con inicializacion en cada una
      reg [3:0] state, state_next=idle;// estados de 4 bits
      reg [3:0] s_reg, s_next=0; //s_reg: Tick counter -> cuenta los ticks desde el inicio, maxima cuenta 15(4 bits)
      reg [2:0] n_reg, n_next=0; //n_reg: data counter -> cuenta los bits de datos leidos, maxima cuenta 7(3 bits)
      reg [7:0] b_reg, b_next=0; //b_reg: registro de bits de datos (8 bits de datos)

      // Estados de la FSM & Resgistros de datos
      always @(posedge clk, posedge reset)
         if (reset)
            begin
               state <= idle;
               s_reg <= 0;
               n_reg <= 0;
               b_reg <= 0;
            end
         else
            begin
               state <= state_next;
               s_reg <= s_next;
               n_reg <= n_next;
               b_reg <= b_next;
            end

      // Logica de siguiente estado
      always @*
      begin
         state_next = state;
         rx_done_tick = 1'b0;
         s_next = s_reg;
         n_next = n_reg;
         b_next = b_reg;
         case (state)
            idle:
               if (~rx)
                  begin
                     state_next = start; // estado sig -> start
                     s_next = 0; // tick counter inicia en cero
                  end
            start:
               if (s_tick_clk)
                  if (s_reg==7)
                     begin
                        state_next = data;// estado sig -> data
                        s_next = 0;// se reinicia tick counter
                        n_next = 0;// inicia en cero contador de bit de datos
                     end
                  else
                     s_next = s_reg + 1;// aumenta en uno tick counter
            data:
               if (s_tick_clk)
                  if (s_reg==15)
                     begin
                        s_next = 0;// se reinicia tick counter por cada bit
                        b_next = {rx, b_reg[7:1]};
                        if (n_reg==(N-1))
                           state_next = stop ;// estado sig -> stop
                        else
                           n_next = n_reg + 1;// aumenta en uno contador de bit de datos
                     end
                  else
                     s_next = s_reg + 1;// aumenta en uno tick counter
            stop:
               if (s_tick_clk)
                  if (s_reg==(M-1))
                     begin
                        state_next = idle;
                        rx_done_tick =1'b1;
                     end
                  else
                     s_next = s_reg + 1;
         endcase
      end
      
      // Logica de Salida
      assign dout = b_reg;


   endmodule
