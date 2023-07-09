library ieee;
use ieee.std_logic_1164.all;

entity ALUController is 
	port (
		funct : in std_logic_vector(5 downto 0);
		ALUOp : in std_logic_vector(1 downto 0);
		Operation : out std_logic_vector(3 downto 0)
	);
end ALUController;

architecture behavioral of ALUController is

begin

	Operation(3) <= '0';
	Operation(2) <= ALUOp(0) or (ALUOp(1) and funct(1));
	Operation(1) <= not ALUOp(1) or not funct(2);
	Operation(0) <= (funct(3) or funct(0)) and ALUOp(1);
end behavioral;
