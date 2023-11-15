# MIPS Processor in VHDL (Single Cycle)
A VHDL implementation of the MIPS Processor : <br>
* 16 Registers of 32-bit (Register File) <br>
* 16 Memory Slots of 32-bit (Data Memory) <br>
* Simple operations in ALU (Addition, Subtraction, Branch etc.) <br>
* Type R and Type I operations <br>
* PC typically increases by 1 <br>
*  Initial Address is 0x00000000 <br> <br>
![Mips Processor](MIPS.png) <br>
## Program for Execution (Instruction Memory):
```vhdl
addi $2, $2, 0 
addi $2, $4, 0 
addi $3, $0, 1 
addi $5, $0, 3 
L1: add $6, $3, $0 
sw $6, 0($4) 
addi $3, $3, 1 
addi $4, $4, 1 
addi $5, $5, -1 
bne $5,$0,L1 
```
## Wave in Modelsim
![Mips Wave](MIPS_WAVE.jpg) <br>
