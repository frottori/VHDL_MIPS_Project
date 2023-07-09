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
	signal IM : ROM_16_x_32 := (x"20000000",
								x"20420000", 
								x"20820000",
								x"20030001", 
								x"20050003", 
								x"00603020", 
								x"AC860000", 
								x"20630001", 
								x"20840001", 
								x"20A5FFFF", 
								x"14A0FFFA", 
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000"
								);
begin

Instruction <= IM(to_integer(unsigned(ReadAddress)));
				
end behavioral;