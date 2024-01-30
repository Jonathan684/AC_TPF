## Clock signal


set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
#	create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports i_clock]

##USB-RS232 Interface

#Recibir 
set_property PACKAGE_PIN B18 [get_ports rx]						
	set_property IOSTANDARD LVCMOS33 [get_ports rx]

#Enviar
set_property PACKAGE_PIN A18 [get_ports tx]						
  set_property IOSTANDARD LVCMOS33 [get_ports tx]
	
##1
set_property PACKAGE_PIN U16 [get_ports {auxiliar3[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[0]}]
#2
set_property PACKAGE_PIN E19 [get_ports {auxiliar3[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[1]}]
#3
set_property PACKAGE_PIN U19 [get_ports {auxiliar3[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[2]}]
#4
set_property PACKAGE_PIN V19 [get_ports {auxiliar3[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[3]}]
#5
set_property PACKAGE_PIN W18 [get_ports {auxiliar3[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[4]}]
#6
set_property PACKAGE_PIN U15 [get_ports {auxiliar3[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[5]}]
#7
set_property PACKAGE_PIN U14 [get_ports {auxiliar3[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[6]}]
#8
set_property PACKAGE_PIN V14 [get_ports {auxiliar3[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar3[7]}]

#set_property PACKAGE_PIN V13 [get_ports {auxiliar}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar}]
#set_property PACKAGE_PIN V3 [get_ports {auxiliar4}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {auxiliar4}]

###########################################################################
###1
#set_property PACKAGE_PIN V13 [get_ports {r_data[0]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[0]}]
##2
#set_property PACKAGE_PIN V3 [get_ports {r_data[1]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[1]}]
##3
#set_property PACKAGE_PIN W3 [get_ports {r_data[2]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[2]}]
##4
#set_property PACKAGE_PIN U3 [get_ports {r_data[3]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[3]}]
##5
#set_property PACKAGE_PIN P3 [get_ports {r_data[4]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[4]}]
##6
#set_property PACKAGE_PIN N3 [get_ports {r_data[5]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[5]}]
##7
#set_property PACKAGE_PIN P1 [get_ports {r_data[6]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[6]}]
##8
#set_property PACKAGE_PIN L1 [get_ports {r_data[7]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_data[7]}]

set_property PACKAGE_PIN T18 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]
    
set_property PACKAGE_PIN L1 [get_ports tx_full]
  set_property IOSTANDARD LVCMOS33 [get_ports tx_full]

set_property PACKAGE_PIN P1 [get_ports rx_empty]
  set_property IOSTANDARD LVCMOS33 [get_ports rx_empty]
    