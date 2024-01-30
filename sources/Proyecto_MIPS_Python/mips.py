import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
from tkinter import *
import serial
import time
import module as md


def main():
    
    paso = 0
    clks_prog = 0
    ser = serial.Serial(port="COM17", baudrate=57600, bytesize=8, timeout=0.5)
    #md.enviar_programar(ser)
    
    print("======================== ENVIAR START ========================")
    ser.write(b'\x4E') # 78 N
    
    result = ser.read() # Leer un byte desde la conexión serial
    print(result)
    valor_ascii = ord(result)
    clks_prog = valor_ascii-48
    if (clks_prog < 1):
        clks_prog = 23
        clks = 65  # ascii A
    while True:
        print("Elige una opción:")
        print("0. Cargar programa.")
        print("1. MIPS modo continuo.")
        print("2. MIPS modo paso a paso.")
        print("3. Avanzar un paso.")
        print("4. Salir")
        eleccion = input("Ingresa el número de la opción que deseas: ")
        if eleccion == "0":
            md.enviar_programar(ser, clks_prog)
            time.sleep(1)
        elif eleccion == "1":
            md.modo_continuo(ser, clks_prog)
            time.sleep(1)
        elif eleccion == "2":
            md.modo_paso_a_paso(ser, clks_prog)
            time.sleep(1)
        elif eleccion == "3":
            print("Avanzando un ciclo reloj:")
            time.sleep(1)
            md.avanzar(ser, paso, clks_prog, 1)
            paso = 1 if paso == 0 else 0
            time.sleep(1)
        else:
            print("Saliendo del programa...")
            # print("Elección no válida. Por favor, elige una opción válida (1, 2 o 3).")
            break  # Salir del ciclo while
    ser.close()


if __name__ == '__main__':
    main()
