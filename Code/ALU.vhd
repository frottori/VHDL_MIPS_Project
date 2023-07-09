library ieee;
use ieee.std_logic_1164.all;
-- arithmetic function with signed or unsigned values
use ieee.numeric_std.all; 

entity ALU is port ( 
 ALUin1: in std_logic_vector(31 downto 0); 
 ALUin2: in std_logic_vector(31 downto 0); 
 ALUctrl: in std_logic_vector(3 downto 0); 
 ALUout1: out std_logic_vector(31 downto 0); 
 zero: out std_logic); 
end ALU;

architecture behavioral of ALU is
signal res : std_logic_vector (31 downto 0);
begin 
	process(ALUctrl,ALUin1,ALUin2)
	begin
	case ALUctrl is
	when "0000" => --Bitwise AND
		res <= ALUin1 and ALUin2; 
	when "0001" => --Bitwise OR
		res <= ALUin1 or ALUin2;  
	when "0010" => --Addition
		res <= std_logic_vector(unsigned(ALUin1) + unsigned(ALUin2));
	when "0110" =>  --Subtraction
		res <= std_logic_vector(unsigned(ALUin1) - unsigned(ALUin2));
	when others => null; --No Option
		res <= std_logic_vector(unsigned(ALUin1) + unsigned(ALUin2));
	end case;
	end process;
	
	ALUout1 <= res;
	zero <= '0' when res=x"00000000" else '1';
	
end behavioral;


