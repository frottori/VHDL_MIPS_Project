library ieee;
use ieee.std_logic_1164.all;

entity MainController is 
	port (
		OpCode : in std_logic_vector(5 downto 0); -- Instruction 31-26
		RegDst : out std_logic;
		Branch : out std_logic;
		MemRead : out std_logic;
		MemtoReg : out std_logic;
		ALUOp : out std_logic_vector (1 downto 0);
		MemWrite : out std_logic;
		ALUSrc : out std_logic;
		RegWrite : out std_logic
	);
end MainController;

architecture behavioral of MainController is

begin
	process(OpCode)
	begin
	
		RegWrite <= '0'; --Deassert for next command
		
		case OpCode is 
		when "000000" => 	-- R Type (opcode = 0x00) add,sub
			RegDst   <= '1';
			Branch   <= '0';
			MemRead  <= '0';
			MemtoReg <= '0';
			ALUOp    <= "10";
			MemWrite <= '0';
			ALUSrc   <= '0';
			RegWrite <= '1';
		when "001000" =>    -- addi
			RegDst   <= '0';
			Branch   <= '0';
			MemRead  <= '0';
			MemtoReg <= '0';
			ALUOp    <= "00";  
			MemWrite <= '0';
			ALUSrc   <= '1';
			RegWrite <= '1';
		when "100011" => 	-- Load Word (opcode = 0x23)
			RegDst   <= '0';
			Branch   <= '0';
			MemRead  <= '1';
			MemtoReg <= '1';
			ALUOp    <= "00";
			MemWrite <= '0';
			ALUSrc   <= '1';
			RegWrite <= '1';
		when "101011" => 	-- Store Word (opcode = 0x2b)
			RegDst   <= 'X';   
			Branch   <= '0';
			MemRead  <= '0';
			MemtoReg <= 'X';
			ALUOp    <= "00";
			MemWrite <= '1';
			ALUSrc   <= '1';
			RegWrite <= '0';
		when "000101" => 	-- Bne (opcode = 0x05)
			RegDst   <= 'X';
			Branch   <= '1';
			MemRead  <= '0';
			MemtoReg <= 'X';
			ALUOp    <= "11";
			MemWrite <= '0';
			ALUSrc   <= '0';
			RegWrite <= '0';
		when others => null;
			RegDst   <= '0';
			Branch   <= '0';
			MemRead  <= '0';
			MemtoReg <= '0';
			ALUOp    <= "00";
			MemWrite <= '0';
			ALUSrc   <= '0';
			RegWrite <= '0';
		end case;
	end process;
	
end behavioral;
