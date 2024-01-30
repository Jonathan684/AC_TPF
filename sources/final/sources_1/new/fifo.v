`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2023 17:37:15
// Design Name: 
// Module Name: fifo
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


module fifo#(parameter N=8, // # DBIT: n° bits de dato
            W=2  // numero de bits de direcciones en la fifo
)
(
     clk, reset,rd,
     wr,w_data,empty,
     full,r_data
 );
	
	// Entradas modulo buf FIFO
	input wire clk, reset;
    input wire rd; // rd: es la entrada de rd_uart del Rx y tx_done_tick de Tx
	input wire wr; // wr: es la salida rx_done_tick del Rx y wr_uart de Tx
    input wire [N-1:0] w_data; // entrada a transmitir
   
	// Salidas modulo buf FIFO
	output wire empty; // bandera que indica buffer vacio, cuando no hay mas nada que leer en el buff
							 // empty: indica si el buff de recepcion esta vacia (1) o no (0)
	output wire	full;  // full: bandera que indica cuando el buff esta lleno y no se puede escribir hasta que se vacie
							 // full: indica si el buff fifo de Tx esta lleno (1) o no (0)
   output wire [N-1:0] r_data; // registro de dato recepcion

   // Declaracion de señales con inicializacion en cada una
	reg [N-1:0] array_reg [2**W-1:0];  // lista de registros
   reg [W-1:0] w_ptr_reg, w_ptr_next=0, w_ptr_succ;
   reg [W-1:0] r_ptr_reg, r_ptr_next=0, r_ptr_succ;
	reg empty_reg, empty_next = 1;// buff de recepcion Rx inicia vacio
	reg full_reg, full_next=0; // buff de transmision Tx inicia vacio
   wire wr_en;

   // Estados de la FSM & Resgistros de datos
   // Operacion de escritura de fila de reg
   always @(posedge clk)
      if (wr_en)
         array_reg[w_ptr_reg] <= w_data;
   
	// Operacion de lectura de fila de lista registro
   assign r_data = array_reg[r_ptr_reg];
   
	// Se habilita la escritura solo cuando la fifo no esta llena
   assign wr_en = wr & ~full_reg;
   
   // Logica de control de cola fifo
   // registros para punteros de lectura y escritura
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
         end
      else
         begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
         end

   // Logica de siguiente estado para la escritur y lectura
   always @*
   begin
      // Valores de punteros sucesivos
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;
      // default: mantenimiento de valores anteriores
      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;
      case ({wr, rd})
         // 2'b00:  no op
         2'b01: // read
            if (~empty_reg) // not empty
               begin
                  r_ptr_next = r_ptr_succ;
                  full_next = 1'b0;
                  if (r_ptr_succ==w_ptr_reg)
                     empty_next = 1'b1;
               end
         2'b10: // write
            if (~full_reg) // not full
               begin
                  w_ptr_next = w_ptr_succ;
                  empty_next = 1'b0;
                  if (w_ptr_succ==r_ptr_reg)
                     full_next = 1'b1;
               end
         2'b11: // write and read
            begin
               w_ptr_next = w_ptr_succ;
               r_ptr_next = r_ptr_succ;
            end
      endcase
   end

   // Logica de salida de moduLo buff FIFO
   assign full = full_reg;
   assign empty = empty_reg;
  
endmodule

