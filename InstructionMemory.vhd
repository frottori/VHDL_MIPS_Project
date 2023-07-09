library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity InstructionMemory is 
	port (
		ReadAddress : std_logic_vector(31 downto 0);
		Instruction : out std_logic_vector(31 downto 0)	
	);
end InstructionMemory;

architecture behavioral of InstructionMemory is

	type ROM_16_x_32 is array (0 to 15) of std_logic_vector(31 downto 0);
	signal IM : ROM_16_x_32 := (x"20000000", --addi $0, $0, 0 
								x"20420000", --addi $2, $2, 0
								x"20820000", --addi $2, $4, 0
								x"20030001", --addi $3, $0, 1
								x"20050003", --addi $5, $0, 3
								x"00603020", --L1: add $6, $3, $0
								x"AC860000", --sw $6, 0($4)
								x"20630001", --addi $3, $3, 1
								x"20840001", --addi $4, $4, 1
								x"20A5FFFF", --addi $5, $5, -1
								x"14A0FFFA", --*bne $5,$0,L1 !!
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000"
								);
begin

Instruction <= IM(to_integer(unsigned(ReadAddress)));
				
end behavioral;