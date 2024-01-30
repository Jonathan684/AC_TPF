
import time
ingresos = 0  # se reinicia el numero de ingresos
modo = 0     # y se cambia al modo actual

def enviar_programar(ser):
    print("enviar programa")
    ser.write(b'\x52')  # 82 Envio una R en ascii
    # enviando la cantidad de instrucciones.
    #time.sleep(1)
    numero_entero = int(b'00100000', 2)
    numero_hexadecimal = hex(numero_entero)
    print(numero_hexadecimal)
    #ser.write(numero_hexadecimal) 
    
    numero_entero = int(b'00000011', 2)
    numero_hexadecimal = hex(numero_entero)
    print(numero_hexadecimal)
    
    numero_entero = int(b'00000000', 2)
    numero_hexadecimal = hex(numero_entero)
    print(numero_hexadecimal)
    
    numero_entero = int(b'00000011', 2)
    numero_hexadecimal = hex(numero_entero)
    print(numero_hexadecimal)
    recibir_datos(ser)

    
    
    #ser.write(b'\x52')  #  envio 8 bit de la primera instruccion
    #pass
def recibir_datos(ser):
    global ingresos, modo
    print("Datos recibidos")
    print("Ingresos [", ingresos, "]")
    acumulador = ""
    try:
        while True:
            data = ser.read()
            #print(data)
            acumulador = acumulador + str(data)
            if not data:
                break  # Exit the loop if there is no more data
    except KeyboardInterrupt:
        print("mal")
        pass  # Allow the user to exit the loop with Ctrl+C
    decoded_data = acumulador.replace('b', '')
    decoded_data = decoded_data.replace("'", '')
    print("===========================")
    nombre_archivo = "salida.txt"
    cadena = decoded_data.replace('\\n', '\n')
    nombre_archivo = "salida.txt"
    with open(nombre_archivo, 'w') as archivo:
        archivo.write(cadena)
    print("Se ha escrito la cadena en", nombre_archivo)


def modo_continuo(ser, clks_prog):
    print("Modo continuo")

    print("clks_prog :", clks_prog)
    print("El numero de ciclos del programa en ejecucion es: ", clks_prog)
    print("Modo continuo")
    ser.write(b'\x43')  # 67 C
    recibir_datos(ser)


def modo_paso_a_paso(ser, clks_prog):
    global ingresos, modo
    print("Modo paso a paso")
    ingresos = 0  # se reinicia el numero de ingresos
    modo = 1  # y se cambia al modo actual
    ser.write(b'\x50')  # 67
    recibir_datos(ser)


def avanzar(ser, paso, num_inst, pmodo):
    global ingresos, modo  # Declarar ingresos y modo como globales
    print("Avanzar un paso")
    # print(modo)
    if pmodo != modo:
        ingresos = 0  # ; //se reinicia el numero de ingresos
        modo = pmodo  # ; // y se cambia al modo actual
    else:
        if ((ingresos < num_inst) or pmodo == 1):
            time.sleep(1)
            recibir_datos(ser)
            ingresos = ingresos + 1

            # // se ignoran ingresos para modo paso a paso
            # /*Sobreescribir archivo recepcion.txt para cargar recepcion nueva */
            # // Write sobre driver
    if paso == 0:
        ser.write(b'\x30')  # 67
        # driver_write("0", pfd) #; // 0 ascci: decimal 48

    if (paso == 1):
        ser.write(b'\x31')  # 67
        # driver_write("1", pfd); // 1 ascii: decimal 49
    if (pmodo == 1):
        print("\n   --> Trasmision UART exitosa!!!\n")
    return

# 00100000000000110000000000000011

# 00100000
# 00000011
# 00000000
# 00000011
# 00100000
# 00000101
# 00000000
# 00000111
# 00000000
# 01100000
# 00010000
# 00100010
# 00000000
# 01000101
# 01100000
# 00100100
# 00000000
# 11000010
# 01101000
# 00100101
# 00000000
# 01000010
# 01110000
# 00100000
# 10101100
# 01001111
# 00000000
# 00000001
# 11111100
# 00000000
# 00000000
# 00000000



# 00100000
# 00000011
# 00000000
# 00000011

# 11111100
# 00000000
# 00000000
# 00000000