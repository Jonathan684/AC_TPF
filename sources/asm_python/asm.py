import logging as log
import re
import argparse

class Assembler:
    def find_tokens(self, assembler_file):
        lines = assembler_file.readlines()
        tokens = []
        gramatical_rules = (r'(?m)(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*$'         
                            + r'|(?m)(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*\(\s*(-{0,1}\w+)\)\s*$'
                            + r'|(?m)(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*$'
                            + r'|(?m)(\w+)\s+(-{0,1}\w+)\s*$')                                          

        for line in lines:
            line = line.upper()
            formated_line = line.replace('\n', '')
            if not formated_line == 'HALT':
                tokens.append(
                    list(filter(None, re.split(string=formated_line, pattern=gramatical_rules))))
            else:
                tokens.append(['HALT'])
        return tokens

    def str_to_bin_str(self, str, n_bits):
        bin_str = ''

        matches = re.search('R{0,1}(-{0,1}\d+)', str)
        if matches == None:
            log.fatal(f'No se pudo matchear ningún valor para el str = {str}')

        num = int(matches[1])

        if num < 0:
            bin_str = format(num & 0xffffffff, '32b')
        else:
            bin_str = '{:032b}'.format(num)

        return bin_str[32-n_bits:]

    def instruction_generator(self, token):
        binary_instruction = "00000000000000000000000000000000"
        i_name = token[0]
        if i_name == "SLL":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_shamt(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "000000")
        elif i_name == "SRL":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_shamt(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "000010")
        elif i_name == "SRA":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_shamt(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "000011")
        elif i_name == "SLLV":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "000100")
        elif i_name == "SRLV":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "000110")
        elif i_name == "SRAV":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "000111")
        elif i_name == "ADDU":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
            binary_instruction = self.set_func(binary_instruction, "100001")
        elif i_name == "SUBU":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
            binary_instruction = self.set_func(binary_instruction, "100011")
        elif i_name == "AND":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "100100")
        elif i_name == "OR":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
            binary_instruction = self.set_func(binary_instruction, "100101")
        elif i_name == "XOR":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
            binary_instruction = self.set_func(binary_instruction, "100110")
        elif i_name == "NOR":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
            binary_instruction = self.set_func(binary_instruction, "100111")
        elif i_name == "SLT":
            binary_instruction = self.set_rd(binary_instruction, token[1])
            binary_instruction = self.set_rt(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
            binary_instruction = self.set_func(binary_instruction, "101010")
        elif i_name == "LB":
            binary_instruction = self.set_op_code(binary_instruction, "100000")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "LH":
            binary_instruction = self.set_op_code(binary_instruction, "100001")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "LW":
            binary_instruction = self.set_op_code(binary_instruction, "100011")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "LWU":
            binary_instruction = self.set_op_code(binary_instruction, "100111")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "LHU":
            binary_instruction = self.set_op_code(binary_instruction, "100101")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "LBU":
            binary_instruction = self.set_op_code(binary_instruction, "100100")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "SB":
            binary_instruction = self.set_op_code(binary_instruction, "101000")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "SH":
            binary_instruction = self.set_op_code(binary_instruction, "101001")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])
        elif i_name == "SW":
            binary_instruction = self.set_op_code(binary_instruction, "101011")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
            binary_instruction = self.set_rs(binary_instruction, token[3])

        elif i_name == "ADDI":
            binary_instruction = self.set_op_code(binary_instruction, "001000")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "ANDI":
            binary_instruction = self.set_op_code(binary_instruction, "001100")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "ORI":
            binary_instruction = self.set_op_code(binary_instruction, "001101")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "XORI":
            binary_instruction = self.set_op_code(binary_instruction, "001110")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "LUI":
            binary_instruction = self.set_op_code(binary_instruction, "001111")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[2])
        elif i_name == "SLTI":
            binary_instruction = self.set_op_code(binary_instruction, "001010")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "BEQ":
            binary_instruction = self.set_op_code(binary_instruction, "000100")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "BNE":
            binary_instruction = self.set_op_code(binary_instruction, "000101")
            binary_instruction = self.set_rt(binary_instruction, token[1])
            binary_instruction = self.set_offset_immed(binary_instruction, token[3])
            binary_instruction = self.set_rs(binary_instruction, token[2])
        elif i_name == "J":
            binary_instruction = self.set_op_code(binary_instruction, "000010")
            binary_instruction = self.set_target(binary_instruction, token[1])
        elif i_name == "JAL":
            binary_instruction = self.set_op_code(binary_instruction, "000011")
            binary_instruction = self.set_target(binary_instruction, token[1])
        elif i_name == "JR":
            binary_instruction = self.set_func(binary_instruction, "001000")
            binary_instruction = self.set_rs(binary_instruction, token[1])
        elif i_name == "JALR":
            binary_instruction = self.set_func(binary_instruction, "001001")
            if len(token) > 1:
                binary_instruction = self.set_rs(binary_instruction, token[2])
                binary_instruction = self.set_rd(binary_instruction, token[1])
            else:
                binary_instruction = self.set_rs(binary_instruction, token[1])
                binary_instruction = self.set_rd(binary_instruction, "31")

        elif i_name == "HALT":
            binary_instruction = "11111100000000000000000000000000"
        elif i_name == "NOP":
            binary_instruction = binary_instruction
        else:
            print(i_name)
            log.FATAL(f'UNRECOGNIZED {i_name}')

        return binary_instruction

    def set_op_code(self, insttruction, op_code):
        return op_code + insttruction[6:]

    def set_rs(self, instruction, rs):
        rs = self.str_to_bin_str(rs, 5)
        return instruction[0:6] + rs + instruction[11:]

    def set_rt(self, instruction, rt):
        rt = self.str_to_bin_str(rt, 5)
        return instruction[0:11] + rt + instruction[16:]

    def set_rd(self, instruction, rd):
        rd = self.str_to_bin_str(rd, 5)
        return instruction[0:16] + rd + instruction[21:]

    def set_shamt(self, instruction, shamt):
        shamt = self.str_to_bin_str(shamt, 5)
        return instruction[0:21] + shamt + instruction[26:]

    def set_func(self, instruction, aluFunc):
        return instruction[0:26] + aluFunc

    def set_offset_immed(self, instruction, offset):
        offset = self.str_to_bin_str(offset, 16)
        return instruction[0:16] + offset

    def set_target(self, instruction, target):
        target = self.str_to_bin_str(target, 26)
        return instruction[0:6] + target
    
binary = ""
assembler = Assembler()

parser = argparse.ArgumentParser(description='Ensamblador')
parser.add_argument('arg1', type=str, help='input file')
parser.add_argument('arg2', type=str, help='output file')
args = parser.parse_args()

assembler_file = open(args.arg1)
assembler_tokens = assembler.find_tokens(assembler_file)
assembler_file.close()

for instruction in assembler_tokens:
    binary += (assembler.instruction_generator(instruction))
    binary += "\n"

print(binary)

numeros_binarios = binary.split()

hexas = []

for numero_binario in numeros_binarios:
    decimal = int(numero_binario, 2)
    hexa = format(decimal, '02X')
    hexas.append(hexa)

print(hexas)

out_file = open(args.arg2, "w")
out_file.write(binary)
