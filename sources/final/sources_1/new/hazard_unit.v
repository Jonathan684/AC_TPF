`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2023 13:50:14
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit
(   
    // Entradas al modulo
    input [4:0] IDRegRs,
    input [4:0] IDRegRt,
    input [4:0] EXRegRt,
    input EXMemRead,
    
    // Salidas del modulo
    output PCWrite, 
    output IFIDWrite,
    output HazMuxCon
);
 
 
 
 
 // Variables internas
 reg PCWrite, IFIDWrite, HazMuxCon;

 always@(IDRegRs,IDRegRt,EXRegRt,EXMemRead)
 if(EXMemRead &&((EXRegRt == IDRegRs)||(EXRegRt == IDRegRt)))
 begin//stall
	 PCWrite = 1'b0;
	 IFIDWrite = 1'b0;
	 HazMuxCon = 1'b1;
    $display("HAY RIESGO");
 end
 else
 begin//no stall
	 PCWrite = 1'b1;
	 IFIDWrite = 1'b1;
	 HazMuxCon = 1'b0;
	 $display("NO HAY RIESGO");
 end 

endmodule
