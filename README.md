# MIPS Processor in VHDL
A VHDL implementation of the MIPS Processor with 32-bit and 16 space Data Memory and Register File, simple operations in ALU (Addtition, Subtraction, Branch etc.) that supports Type R and I operations. <br>
![Mips Processor](MIPS.png) <br>
## Program for Execution:
addi $2, $2, 0 <br>
addi $2, $4, 0 <br>
addi $3, $0, 1 <br>
addi $5, $0, 3 <br>
L1: add $6, $3, $0 <br>
sw $6, 0($4) <br>
addi $3, $3, 1 <br>
addi $4, $4, 1 <br>
addi $5, $5, -1 <br>
bne $5,$0,L1 <br>
##Wave of Execution in Modelsim
![Mips Wave](MIPS_WAVE.jpg) <br>
