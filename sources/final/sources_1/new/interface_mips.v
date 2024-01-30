`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2023 17:17:46
// Design Name: 
// Module Name: interface_mips
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


module interface_mips #(parameter N = 8) // N: numero de bits de datos
(
	clk, reset, in_tick, in_PCend,in_PC,
	in_ifid_PC, in_ifid_inst,
	empty_uart, tx_full, uart_in,
	uart_out, rd_uart, wr_uart,
	reset_outw,
	in_idex1, in_idex2,in_idex3, in_idex4,
	in_exmem1,in_exmem2,in_exmem3,
	in_memwb1,in_memwb2,in_memwb3,
	in_rdd1,in_rddmem,out_du_areg,
	out_duc1, out_duc2, out_du_amem,
	out_duc3, wr_secure,auxiliar3,memoria,write_enable
);
	
	// Parametros internos
	parameter msb = 31; // bit mas sigficativo
	parameter CTE_EST = 64; // Constante de estabilizacion (espera de ticks)
	parameter lstate = 6; // limite del numero de estados. Pe: para 8 seran 9 estados [8:0]
	//localparam MemorySize = 128;
	//output memory [0:MemorySize]; // Vector de memoria de 8 bits
	localparam [4:0]
		reg_pc = 5'b00001, // Indicacion de envio de PC
		reg_seg = 5'b00010, // Indicacion de envio de registros de segmentacion
		file_reg = 5'b00100, // Indicacion de envio del regs del modulo FileRegister
		//file_reg2 = 6'b000100, // Indicacion de envio del regs del modulo FileRegister individualmente
		reg_mem = 5'b01000, // Indicacion de envio de registros de memoria de datos
		//reg_mem2 = 6'b010000, // indicacion de envio de registros data mem por UART individualmente
		send_end = 5'b10000; // Indicacion de fin de envio de registros por tx
	integer file;
	// Entradas intf
	input wire empty_uart, tx_full; // bandera empty de uart como entrada y full de uart
											  // empty_uart: indica fifo de recepcion vacia
											  // tx_full: indica fifo de transmision llena
	input wire [N-1:0] uart_in;
	input wire clk, reset; // clk: clock de FPGA - reset: se�al para resetear FSM
	input wire [msb:0] in_PC;
	input in_PCend;
	input [msb:0] in_ifid_PC;
	input [msb:0] in_ifid_inst;
	input [msb:0] in_idex1, in_idex2, in_idex3, in_idex4;
	input [msb:0] in_exmem1, in_exmem2;
	input [15:0] in_exmem3;
	input [msb:0] in_memwb1, in_memwb2;
	input [7:0] in_memwb3;
	input [msb:0] in_rdd1; // ingreso de read data 1 o 2 desde modulo Registro
	input [msb:0] in_rddmem; // ingreso de read data desde memoria de datos
	input in_tick; // contador de ticks en UART (16 ticks un envio o recepcion)
	
	
	output reg [31:0] memoria;
	output reg write_enable;
	
	
	// Salidas intf
	output wire [N-1:0] uart_out;	
	output reg rd_uart, wr_uart;
	output wire reset_outw;
	output reg [4:0] out_du_areg; // salida de debug unit address reg
	reg [4:0] out_du_areg_next; // salida de debug unit address reg
	output reg [msb:0] out_du_amem; // salida de debug unit address mem
	reg [msb:0] out_du_amem_next; // salida de debug unit address mem
	output reg out_duc1; // flags de control 1 desde unidad de debug (interface_mips)
	reg out_duc1_next;
	output reg out_duc2; // flags de control 2 desde unidad de debug (interface_mips)
	reg out_duc2_next;
	output reg out_duc3; // flags de control 3 desde unidad de debug (interface_mips)
	reg out_duc3_next;
	output wire wr_secure;
	
	output reg [7:0] auxiliar3;
	// Declaracion de estados
   localparam [lstate:0]
		start_MIPS = 7'b0000001,// estado de escucha de rx para iniciar MIPS
		rec_program = 7'b0000010,// estado de recepcion del programa
        count_clks = 7'b0000011,// estado de conteo de clks de progeama en ejecucion
		idle_HALT = 7'b0000100,// estado de espera de instruccion HALT en modo continuo
        modo_PP = 7'b0001000,  // estado realizar envios de registros
		idle_HALT_PP = 7'b0010000,// estado de espera de estabilizacion de se�al rx
		in_event = 7'b0100000,// estado de espera de instruccion HALT en modo paso a paso
		send_reg = 7'b1000000;// estado de analisis de entradas de teclado

   // Declaracion de se�ales con inicializacion en cada una
   reg [lstate:0] state, state_next;// estados de (lstate+1) bits
	reg reset_out, reset_out_next;
	reg [N-1:0] reg_uart_out;
	reg [6:0] ct, ct_next; // contador de transmisiones
	reg [6:0] cr, cr_next; // contador de registros
	reg [4:0] i_reg, i_reg_next; // indicador del tipo de registros a enviar por tx
	reg [6:0] b_shift, b_shift_next; // b_shift: desplazamiento de bits sobre registros
	reg [63:0] reg_aux, reg_aux_next; // regs para mem data
	reg [6:0] est, est_next; // se�al de estabilizacion de transmision en modulo Register
	reg penv, penv_next;
	reg flag_PP; // indica si MIPS esta en modo paso a paso
	reg flag_PP_next;
	reg mtecla, mtecla_next; // mtecla: selector para dos teclas
	//reg mtecla2, mtecla2_next; // mtecla2: 2� selector para dos teclas
	reg [2:0] clk_end, clk_end_next; // clk_end: contador de clks finales luego que in_PCend == 1
	reg [6:0] n_pclk, n_pclk_next; // contador de clks de programa en ejecucion
	
	// Palabras constantes
	localparam [55:0] // palabra de 56 bits
		cte1=56'b00111010011000110111000001011111011001110110010101110010; // palabra reg_pc:
	localparam [63:0] // palabras de 64 bits
		cte2=64'b0011101001100111011001010111001101011111011001110110010101110010, // palabra reg_seg:
		cte3=64'b0011101001100111011001010111001001100101011011000110100101100110, // palabra filereg:
		cte4=64'b0011101001101101011001010110110101011111011001110110010101110010; // palabra reg_mem:
	
	// Inicializacion de se�ales
	initial
	begin
		reset_out = 1'b1;
		state = start_MIPS;
		ct = 0;
		cr = 0;
		i_reg = reg_pc;
		b_shift = 8;
		reg_aux = cte1;
		out_du_areg = 0;
		out_du_amem = 0;
		out_duc1 = 1'b0;
		out_duc2 = 1'b0;
		out_duc3 = 1'b0;
		penv = 1'b1;
		est = 0;
		flag_PP = 1'b0;
		mtecla = 1'b0;
		clk_end = 0;
		n_pclk = 0;
		memoria = 0;
	    write_enable = 0;
	end
	
   // Estados de la FSM - flanco positivo
   always @(posedge clk, posedge reset) begin
      if (reset)
         begin
				reset_out <= 1'b1;
				out_duc3 <= 1'b0; // bajo flag deshabilitar PC y latches desde Debug Unit
                state <= start_MIPS;
				i_reg <= reg_pc;
				reg_aux <= cte1;
				ct <= 0;
				cr <= 0;
				b_shift <= 8;
				out_du_areg <= 0;
				out_duc1 <= 1'b0;
				out_du_amem <= 0;
				out_duc2 <= 1'b0;
				penv <= 1'b1;
				est <= 0;
				flag_PP <= 1'b0;
				mtecla <= 1'b0;
				clk_end <= 0;
				n_pclk <= 0;
         end
      else
         begin
				reset_out <= reset_out_next;
				out_duc1 <= out_duc1_next;
				out_duc2 <= out_duc2_next;
				out_duc3 <= out_duc3_next;
				mtecla <= mtecla_next;
				clk_end <= clk_end_next;
				state <= state_next;
				reg_aux <= reg_aux_next;
				out_du_areg <= out_du_areg_next;
				out_du_amem <= out_du_amem_next;
				i_reg <= i_reg_next;
				b_shift <= b_shift_next;
				ct <= ct_next;
				cr <= cr_next;
				penv <= penv_next;
				est <= est_next;
				flag_PP <= flag_PP_next;
				n_pclk <= n_pclk_next;
         end
	end

   // Logica de siguiente estado
   always @*
   begin
		// default: por defecto se mantienen los valores anteriores
        state_next = state;
		rd_uart = 1'b0; // recepcion no leida
		wr_uart = 1'b0; // no realizar transmision
		reset_out_next = reset_out;
		ct_next = ct;
		cr_next = cr;
		reset_out_next = reset_out;
		b_shift_next = b_shift;
		i_reg_next = i_reg;
		reg_aux_next = reg_aux;
		out_du_areg_next = out_du_areg;
		out_du_amem_next = out_du_amem;
		out_duc1_next = out_duc1;
		out_duc2_next = out_duc2;
		out_duc3_next = out_duc3;
		penv_next = penv;
		est_next = est;
		flag_PP_next = flag_PP;
		mtecla_next = mtecla;
		clk_end_next = clk_end;
		n_pclk_next = n_pclk;
      case (state)
			start_MIPS: // Se comienza a escuchar el receptor, para iniciar el MIPS (si entrada es un enter)
			begin
			if(~empty_uart) // si se detecteta recepcion (por fifo rx de uart no vacia)
			begin
				if(uart_in == 82) // si entrada es un R(ascii): se cuentan los clks del programa
				begin				 	// en ejecucion y envia por UART
					//auxiliar3 = uart_in;
					//reset_out_next = 1'b1; // se realiza reset en MIPS
					//out_duc3_next = 1'b1; // subo flag habilitar PC y latches desde Debug Unit
					//out_duc1_next = 1'b0; // se deja addr reg1 por defecto
					//out_duc2_next = 1'b0; // se deja addr mem por defecto
					state_next = rec_program;// estado sig -> count_clks
					//n_pclk_next = 0; // se inicia siempre en cero
					rd_uart = 1'b1; // aviso a uart de recepcion leida
				end
				else if(uart_in == 78) // si entrada es un N(ascii): se cuentan los clks del programa
				begin				 	// en ejecucion y envia por UART
					reset_out_next = 1'b1; // se realiza reset en MIPS
					out_duc3_next = 1'b1; // subo flag habilitar PC y latches desde Debug Unit
					out_duc1_next = 1'b0; // se deja addr reg1 por defecto
					out_duc2_next = 1'b0; // se deja addr mem por defecto
					write_enable = 1'b0;
					state_next = count_clks;// estado sig -> count_clks
					n_pclk_next = 0; // se inicia siempre en cero
					rd_uart = 1'b1; // aviso a uart de recepcion leida
				end
				
				else if(uart_in == 67) // si entrada es un C(ascii): se inicia procesador en modo continuo
 				begin
 					reset_out_next = 1'b1; // se realiza reset en MIPS
 					out_duc3_next = 1'b1; // subo flag habilitar PC y latches desde Debug Unit
 					out_duc1_next = 1'b0; // se deja addr reg1 por defecto
 					out_duc2_next = 1'b0; // se deja addr mem por defecto
 					state_next = idle_HALT;// estado sig ->
					ct_next = 0; // se inicia contador en 0
 					i_reg_next = reg_pc;
 					b_shift_next = 8;
 					rd_uart = 1'b1; // aviso a uart de recepcion leida
				end
				
				else if(uart_in == 80) // si entrada un P(ascii): se inicia procesador en modo paso a paso
				begin
					reset_out_next = 1'b1;// se realiza reset en MIPS
					flag_PP_next = 1'b1;  // Se indica modo paso a paso
					out_duc3_next = 1'b1; // subo bandera para controlar clk desde Debug Unit
					out_duc1_next = 1'b0; // se deja addr reg1 por defecto
					out_duc2_next = 1'b0; // se deja addr mem por defecto
					state_next = modo_PP; // estado sig -> espera de inst HALT desde modo paso a paso
					i_reg_next = reg_pc;
					b_shift_next = 8;
					rd_uart = 1'b1; // aviso a uart de recepcion leida
				end
				
				else // Para cualquier otra recepcion se la ignora permaneciendo en el mismo estado
				begin // y descartando la recepcion desde la fifo rx (rd_uart = 1'b1)
					state_next = start_MIPS; // start_MIPS
					if(~empty_uart) // mientras exista recepcion (por fifo rx de uart no vacia)
						rd_uart = 1'b1; // aviso a uart de recepcion leida (para liberar fifo rx)
				end
			end
			end
			
			modo_PP:
			begin
				if(reset_out == 1) begin
					reset_out_next = 1'b0; // se termina de realizar reset en MIPS y comienza primer instruccion
					//out_duc3_next = 1'b0; // bajo flag para deshabilitar PC y latches desde Debug Unit
					//state_next = send_reg; // se realiza envio de registros
				end
				
				else if(flag_PP && est < 1)
				begin
					out_duc3_next = 1'b0; // bajo flag para deshabilitar PC y latches desde Debug Unit
					est_next = est +1;
				end
				
				else if(flag_PP && (est == 1))
				begin
					state_next = send_reg; // se realiza envio de registros
					est_next = 0; // se reinicia contador de ticks
				end
				
				else // Para cualquier otra recepcion se la ignora permaneciendo en el mismo estado
				begin // y descartando la recepcion desde la fifo rx (rd_uart = 1'b1)
					state_next = modo_PP; // Ejecucion paso a paso
					if(~empty_uart) // mientras exista recepcion (por fifo rx de uart no vacia)
						rd_uart = 1'b1; // aviso a uart de recepcion leida (para liberar fifo rx)
				end
			end
			
			idle_HALT_PP: // espera de inst halt (detencion de PC) desde modo PP
			begin
				if(!in_PCend && clk_end == 0) begin // miestras instruccion no es halt
					state_next = in_event; // estado sig -> in_event: analisis de entradas
				end
				
				else if(in_PCend && clk_end < 3) // envio de clks finales luego de fin
				begin
					state_next = in_event;
					clk_end_next = clk_end + 1;
				end
				
				else if(clk_end == 3) //(ct == 5)// si se detecto instruccion HALT : PC_end = 1
				begin // Salimos de modo paso a paso
					state_next = start_MIPS; // estado sig -> start_MIPS (inicio de ejecucion BIP)
					flag_PP_next = 1'b0; // se quita indicacion de modo paso a paso
					out_duc3_next = 1'b0; // bajo flag para deshabilitar PC y latches desde Debug Unit
					out_duc1_next = 1'b0; // se deja addr reg1 por defecto
					out_duc2_next = 1'b0; // se deja addr mem por defecto
					clk_end_next = 0; // se reinicia cuenta de clks finales
					ct_next = 0; // se reestable contador
				end
			end
			
			in_event: // estado de analisis de entrada de eventos
			begin
				if(uart_in == 48 && !mtecla) // 0 ascii
				begin
					state_next = modo_PP; // avance de flancos de ciclo en modo paso a paso
					out_duc3_next = 1'b1; // subo flag para habilitar PC y latches desde Debug Unit
					rd_uart = 1'b1; // aviso a uart de recepcion leida (para liberar fifo rx)
					mtecla_next = 1'b1; // proxima tecla admitida cuando mtecla == 1
				end
				
				else if(uart_in == 49 && mtecla) // 1 ascii
				begin
					state_next = modo_PP; // avance de flancos de ciclo en modo paso a paso
					out_duc3_next = 1'b1; // subo flag para habilitar PC y latches desde Debug Unit
					rd_uart = 1'b1; // aviso a uart de recepcion leida (para liberar fifo rx)
					mtecla_next = 1'b0; // proxima tecla admitida cuando mtecla == 0
				end
				
				else // Para cualquier otra recepcion se la ignora permaneciendo en el mismo estado
				begin // y descartando la recepcion desde la fifo rx (rd_uart = 1'b1)
					state_next = in_event; //
					if(~empty_uart) // mientras exista recepcion (por fifo rx de uart no vacia)
						rd_uart = 1'b1; // aviso a uart de recepcion leida (para liberar fifo rx)
				end
			end
			
			count_clks: // conteo de clks asociados a programa en ejecucion
			begin
				if(reset_out == 1) begin
					reset_out_next = 1'b0; // se termina de realizar reset en MIPS
				end
				
				else if(!in_PCend)
					n_pclk_next = n_pclk + 1; // incrementa la cantidad de clk del programa en ejecucion
				
				else if(in_PCend && ct < 3)// Si finalizo la ejecucion de instrucciones
					ct_next = ct + 1;
				
				else if(ct == 3)
				begin
					// envio de numero de clks de programa en ejecucion
					if(~tx_full) // mientras trasmisor no este lleno
					begin
						reg_uart_out = n_pclk + 48; // envio de clks de programa
						n_pclk_next = n_pclk + 3; // se suman los 3 clks finales a cantidad de clk del programa en ejecucion
						out_duc3_next = 1'b0; // deshalito 
						wr_uart = 1'b1; // realizar transmision tx uart	
						ct_next = 0; // se reestable ce contador
						reset_out_next = 1'b1; // se realiza reset en MIPS
						state_next = start_MIPS; //
					end
				end
			end
			rec_program: // rec_program cargando el programa a ejecutar
			begin
				//memory
				//auxiliar3 <= uart_in;
				 memoria= 32'b00100000000001000000000000000010; //addi $4, $0, 2
				//memory[4] = 32'b11111100000000000000000000000000;  //addi $5, $0, 2
				
				write_enable = 1'b1;
				reg_uart_out = 88; // envio de espacio (32 binario)
				wr_uart = 1'b1; // realizar transmision tx uart
				state_next = start_MIPS; //
			end
			
			idle_HALT: // espera de inst halt (detencion de PC)
				begin
					if(reset_out == 1)
						reset_out_next = 1'b0; // se termina de realizar reset en MIPS
					
					else if(ct < n_pclk)
						ct_next = ct + 1; // se utiliza ct para contar cks ejecutados
					
					else if(ct == n_pclk)
					begin
						// momento de envio de datos estabilizados
						out_duc3_next = 1'b0; // bajo flag para deshabilitar PC y latches desde Debug Unit
						ct_next = ct + 1;
					end
					
					else if(ct > n_pclk)// Si detecto ultimo clks de programa enviamos registros por uart
					begin
						state_next = send_reg;// estado sig -> comienzo de envio de registros
						ct_next = 0;
					end
				end
			
			send_reg: // Envio de registros por uart
				begin
					if(~tx_full) // mientras trasmisor no este lleno
					begin
						case(i_reg)
							reg_pc: // reg_pc - Envio de registro PC
								begin
									if(cr == 0 && ct < 7) // Envio de cabecera reg_pc:
										begin
											reg_uart_out = reg_aux; // Envio de a 8 bits del PC
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = cte1 >> b_shift;
											b_shift_next = b_shift + 8;
											ct_next = ct + 1;
										end

									else if(cr == 0 && ct == 7) // Envio de salto de linea
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_PC >> 24;
											b_shift_next = 16;
											cr_next = cr + 1;
											ct_next = 0;
										end

									else if(cr == 1 && ct < 4) // Envio de registro PC
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del PC
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_PC >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end

									else if(cr == 1 && ct == 4)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											i_reg_next = reg_seg;
											reg_aux_next = cte2;
											b_shift_next = 8;
											cr_next = 0;
											ct_next = 0;
										end
								end
							reg_seg: // reg_seg - Envio de registros de segmentacion
								begin
									if(cr == 0 && ct < 8) // Envio de cabecera reg_seg:
										begin
											reg_uart_out = reg_aux; // Envio de a 8 bits del PC
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = cte2 >> b_shift;
											b_shift_next = b_shift + 8;
											ct_next = ct + 1;
										end

									else if(cr == 0 && ct == 8) // Envio de salto de linea
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_ifid_PC >> 24;
											b_shift_next = 16;
											cr_next = cr + 1;
											ct_next = 0;
										end

									else if(cr == 1 && ct < 4) // Envio de registro ifid_PC
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del ifid_PC
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_ifid_PC >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end

									else if(cr == 1 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_ifid_inst >> 24;
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr + 1;
										end

									else if(cr == 2 && ct < 4) // Envio de registro ifid_inst
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del ifid_inst
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_ifid_inst >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 2 && ct == 4)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex1 >> 24; // 
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr + 1;
										end

									else if(cr == 3 && ct < 4) // Envio de registro idex1
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del idex1
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex1 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 3 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex2 >> 24;
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr + 1;
										end

									else if(cr == 4 && ct < 4) // Envio de registro idex2
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del idex2
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex2 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 4 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex3 >> 24; // idex3
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr + 1;
										end

									else if(cr == 5 && ct < 4) // Envio de registro idex3
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del idex3
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex3 >> b_shift; // idex 3
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 5 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex4 >> 24; // idex4
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr + 1;
										end

									else if(cr == 6 && ct < 4) // Envio de registro idex4
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del idex4
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_idex4 >> b_shift; // idex4
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 6 && ct == 4)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_exmem1 >> 24; // 
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr +1;
										end

									else if(cr == 7 && ct < 4) // Envio de registro exmem1
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del exmem1
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_exmem1 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 7 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_exmem2 >> 24; //
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr +1;
										end

									else if(cr == 8 && ct < 4) // Envio de registro exmem2
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del exmem2
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_exmem2 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 8 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_exmem3 >> 8; //
											b_shift_next = 0;
											ct_next = 0;
											cr_next = cr +1;
										end

									else if(cr == 9 && ct < 2) // Envio de registro exmem3
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del exmem3
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_exmem3 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 9 && ct == 2)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_memwb1 >> 24; // 
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr +1;
										end

									else if(cr == 10 && ct < 4) // Envio de registro memwb1
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del memwb1
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_memwb1 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 10 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_memwb2 >> 24; // 
											b_shift_next = 16;
											ct_next = 0;
											cr_next = cr +1;
										end

									else if(cr == 11 && ct < 4) // Envio de registro memwb2
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del memwb2
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_memwb2 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr == 11 && ct == 4)
										begin
											reg_uart_out = 32; // envio de espacio (32 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_memwb3; // 
											b_shift_next = 0;
											ct_next = 0;
											cr_next = cr +1;
										end

									else if(cr == 12 && ct < 1) // Envio de registro memwb3
										begin
											reg_uart_out = reg_aux + 48; // Envio de a 8 bits del memwb3
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_memwb3 >> b_shift;
											b_shift_next = b_shift - 8;
											ct_next = ct + 1;
										end
									else if(cr ==12  && ct == 1)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											i_reg_next = file_reg; // proximo estado de envio file_reg
											out_du_areg_next = 0; // se selecciona primer registro de modulo Registro
											out_duc1_next = 1'b1; // se utiliza addr reg1 desde unit debug
											reg_aux_next = cte3; // preparando cabecera 3
											b_shift_next = 8;
											ct_next = 0;
											cr_next = 0;
										end
								end
							file_reg: // Envio de registros del modulo Registro
								begin
									if(cr == 0 && ct < 8) // Envio de cabecera filereg:
										begin
											reg_uart_out = reg_aux; // Envio de a 8 bits del PC
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = cte3 >> b_shift;
											b_shift_next = b_shift + 8;
											ct_next = ct + 1;
										end

									else if(cr == 0 && ct == 8) // Envio de salto de linea
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_rdd1;
											cr_next = cr + 1;
											ct_next = 0;
											penv_next = 1'b1; // se habilita envio de registros
											est_next = 0;
										end

									else if(penv && out_duc1 && (cr > 0) && (cr <= 32) && (ct < 4)) // Envio de registro FileRegister
										begin // si se estabilizo se�al
											reg_uart_out = reg_aux[31:24] + 48; // Envio de a 8 bits de rgs
											wr_uart = 1'b1; // realizar transmision tx uart
											penv_next = 1'b0; // se cancela proximo envio hasta finalizacion de actual
										end
									else if(penv && out_duc1 && (cr > 0) && (cr < 32) && (ct == 4)) //
									begin // si se estabilizo se�al
										reg_uart_out = 10; // envio de salto de linea (10 binario)
										wr_uart = 1'b1; // realizar transmision tx uart
										penv_next = 1'b0; // se cancela proximo envio hasta finalizacion de actual
									end

									else if(!penv && (est < CTE_EST) && (ct<=5)) // esperando realizacion de envio previo
										begin
											if(in_tick)
												est_next = est +1; // se�al estabilizada
										end

									else if(!penv && (est==CTE_EST) && (ct<4)) // luego de envios previos
										begin // en ese momento cambiamos de valores y desplazamiento
											reg_aux_next = reg_aux << 8;
											penv_next = 1'b1; // levanto bandera nuevamente para proximo envio de reg
											ct_next = ct + 1;
											est_next = 0;
										end

									else if((est==CTE_EST) && !penv && (ct==4)) // luego de envios previos, para cambio de addr
										begin // en ese momento cambiamos de valores y desplazamiento y nueva addr
											out_du_areg_next = cr; // se selecciona siguiente registro de modulo Registro
											ct_next = ct + 1;
											est_next = 0;
										end

									else if((est==CTE_EST) && !penv && (ct==5)) // espermos el cambio de addr reg para 
										begin // en ese momento si cargar el valor a enviar
											reg_aux_next = in_rdd1;
											ct_next = 0;
											cr_next = cr + 1;
											est_next = 0;
											penv_next = 1'b1; // levanto bandera nuevamente para proximo envio de reg
										end

									else if(cr == 32 && ct == 4)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											i_reg_next = reg_mem; // proximo estado de envio reg_mem
											reg_aux_next = cte4; // se prepara cabecera 4
											out_du_amem_next = 0; // se selecciona primer registro de mem datos
											//out_duc1_next = 1'b0; // se vuelve a utilizar addr reg1 por defecto en mips
											out_duc2_next = 1'b1; // se coloco addr mem en modo debug unit
											b_shift_next = 8;
											cr_next = 0;
											ct_next = 0;
										end
								end
							reg_mem: // Envio de registros de la memoria de datos
								begin
									if(cr == 0 && ct < 8) // Envio de cabecera reg_mem:
										begin
											reg_uart_out = reg_aux; // Envio de a 8 bits del PC
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = cte4 >> b_shift;
											b_shift_next = b_shift + 8;
											ct_next = ct + 1;
										end

									else if(cr == 0 && ct == 8) // Envio de salto de linea
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											reg_aux_next = in_rddmem;
											cr_next = cr + 1;
											ct_next = 0;
											penv_next = 1'b1; // se habilita envio de registros
											est_next = 0;
										end

									else if(penv && out_duc2 && (cr > 0) && (cr <= 10) && (ct < 4)) // Envio de registro data mem
										begin // si se estabilizo se�al
											reg_uart_out = reg_aux[31:24] + 48; // Envio de a 8 bits de rgs
											wr_uart = 1'b1; // realizar transmision tx uart
											penv_next = 1'b0; // se cancela proximo envio hasta finalizacion de actual
										end
									else if(penv && out_duc2 && (cr > 0) && (cr < 10) && (ct == 4)) //
									begin // si se estabilizo se�al
										reg_uart_out = 10; // envio de salto de linea (10 binario)
										wr_uart = 1'b1; // realizar transmision tx uart
										penv_next = 1'b0; // se cancela proximo envio hasta finalizacion de actual
									end

									else if(!penv && (est < CTE_EST) && (ct<=5)) // esperando realizacion de envio previo
										begin
											if(in_tick)
												est_next = est +1; // se�al estabilizada
										end

									else if(!penv && (est==CTE_EST) && (ct<4)) // luego de envios previos
										begin // en ese momento cambiamos de valores y desplazamiento
											reg_aux_next = reg_aux << 8;
											penv_next = 1'b1; // levanto bandera nuevamente para proximo envio de reg
											ct_next = ct + 1;
											est_next = 0;
										end

									else if((est==CTE_EST) && !penv && (ct==4)) // luego de envios previos, para cambio de addr
										begin // en ese momento cambiamos de valores y desplazamiento y nueva addr
											//out_du_amem_next = {25'b0000000000000000000000000,cr}; // se selecciona siguiente registro data mem
											out_du_amem_next = 0 + cr; // se selecciona siguiente registro data mem
											ct_next = ct + 1;
											est_next = 0;
										end

									else if((est==CTE_EST) && !penv && (ct==5)) // espermos el cambio de addr reg para 
										begin // en ese momento si cargar el valor a enviar
											reg_aux_next = in_rddmem;
											ct_next = 0;
											cr_next = cr + 1;
											est_next = 0;
											penv_next = 1'b1; // levanto bandera nuevamente para proximo envio de reg
										end

									else if(cr == 10 && ct == 4)
										begin
											reg_uart_out = 10; // envio de salto de linea (10 binario)
											wr_uart = 1'b1; // realizar transmision tx uart
											i_reg_next = send_end; // finalizacion de envio por tx
											reg_aux_next = cte1; // se prepara cabecera 1
											//out_du_areg_next = 0; // se selecciona primer registro de modulo Registro
											//out_du_amem_next = 0; // se selecciona primer registro de mem datos
											//out_duc2_next = 1'b0; // se vuelve a utilizar addr mem por defecto en mips
											b_shift_next = 8;
											cr_next = 0;
											ct_next = 0;
										end
								end
							send_end: // send_end - Fin de envio de registros
								begin
									if(flag_PP) 
										begin // si clk se controla por Debug unit
											if(~tx_full) // mientras trasmisor no este lleno
											begin
												reg_uart_out = 32; // envio de salto de linea (10 binario)
												wr_uart = 1'b1; // realizar transmision tx uart
												state_next = idle_HALT_PP;// estado sig -> se vuelve estado de teccion de HALT por modo Paso a paso
												i_reg_next = reg_pc;
												out_duc1_next = 1'b0; // se vuelve a utilizar addr reg1 por defecto en mips
												out_duc2_next = 1'b0; // se vuelve a utilizar addr mem por defecto en mips
												est_next = 0;
												ct_next = 0;
											end
										end
									else 
										begin
											if(~tx_full) // mientras trasmisor no este lleno
											begin
												reg_uart_out = 10; // envio de salto de linea (10 binario)
												wr_uart = 1'b1; // realizar transmision tx uart
												state_next = start_MIPS;// estado sig -> se vuelve a start_MIPS
											end
										end
									end
							default: // por inconsistencias
								begin
									reg_uart_out = 88; // envio de X
									wr_uart = 1'b1; // realizar transmision tx uart
									ct_next = 0;
									state_next = start_MIPS;// estado sig -> se vuelve a start_MIPS
									i_reg_next = reg_pc;
								end
						endcase // fin de case dentro de estado send_reg
					end // fin del ultimo estado
				end
		endcase // fin de case de estados
   end // fin del always

	// Logica de Salida
	assign uart_out = reg_uart_out; // Se suma 48 ya uart transmite en ASCII
	assign reset_outw = reset_out;
	assign wr_secure = out_duc1 | out_duc2; // rwr_secure;

	endmodule

