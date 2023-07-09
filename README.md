# MIPS Processor in VHDL
A VHDL implementation of the MIPS Processor with 32-bit and 16 space memory and regfile, simple operations in ALU (Addtition,Subtraction, Branch etc.) that supports Type R and I operations. 
## Program for Execution:
addi $2, $2, 0 #\n
addi $2, $4, 0
addi $3, $0, 1
addi $5, $0, 3
L1: add $6, $3, $0
sw $6, 0($4)
addi $3, $3, 1
addi $4, $4, 1
addi $5, $5, -1
bne $5,$0,L1
