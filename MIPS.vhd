library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

-- Entity 1 (ALU)

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
	zero <= '0' when res=x"00000000" else '1';  --για το bne
	
end behavioral;

-- Entity 2 (Register File)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity RegFile is
generic (   
      w : natural := 5;     -- number of address bits
	  b : natural := 32;    --number of bits 
	  size : natural := 16  -- number of registers (to the register file)
	  );
port ( ReadReg1 : in std_logic_vector(w-1 downto 0);
	   ReadReg2 : in std_logic_vector(w-1 downto 0);
	   WriteReg : in std_logic_vector(w-1 downto 0);
       WriteData : in std_logic_vector(b-1 downto 0);
       RegWrite : in std_logic;
	   ReadData1 : out std_logic_vector(b-1 downto 0);
       ReadData2 : out std_logic_vector(b-1 downto 0);
	   clk,rst : in std_logic
	   );
end RegFile;

architecture behavioral of RegFile is

type regArray is array(0 to size-1) of std_logic_vector
(b-1 downto 0);
signal reg_file : regArray; -- 0 to 16 registers

begin
	process(clk,rst,RegWrite)
	begin
	
	if(rst='1') then
		for i in 0 to (size-1) loop   --μηδενίζει καταχωρητές
			reg_file(i) <=(others => '0');
		end loop;
 	elsif (rising_edge(clk)) then 
 		if RegWrite='1' then
			reg_file(to_integer(unsigned(WriteReg))) <= WriteData; 
 		end if;
 	end if;
	end process;
	ReadData1 <= reg_file(to_integer(unsigned(ReadReg1)));
	ReadData2 <= reg_file(to_integer(unsigned(ReadReg2)));
	
end behavioral;

-- Entity 3 (Data Memory)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity DataMemory is
	port(
		Address : in std_logic_vector(31 downto 0);
		WriteData : in std_logic_vector(31 downto 0);
		MemRead, MemWrite : in std_logic;
		ReadData : out std_logic_vector(31 downto 0);
		clk : in std_logic
	);
end DataMemory;


architecture behavioral of DataMemory is

type ROM_16_x_32 is array (0 to 15) of std_logic_vector(31 downto 0);
	signal DM : ROM_16_x_32 := (x"00000000", 
								x"00000000", 
								x"00000000", 
								x"00000000", 
								x"00000000", 
								x"00000000",
								x"00000000", 
								x"00000000", 
								x"00000000", 
								x"00000000", 
								x"00000000", 
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000"
								);

begin

	process (MemWrite, MemRead, clk)
	begin
		if (rising_edge(clk)) then 
		if (MemWrite = '1') then
			DM ((to_integer(unsigned(Address)))) <= WriteData;
		end if;
		end if;
		
		if (MemRead = '1') then 
			ReadData <= DM ((to_integer(unsigned(Address))));
		else 
			ReadData <= x"00000000";
		end if;
	end process;
end behavioral;

-- Entity 4 (Instruction Memory)
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
								x"14A0FFFA", --bne $5,$0,L1 
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000",
								x"00000000"
								);
begin

Instruction <= IM(to_integer(unsigned(ReadAddress)));
				
end behavioral;

-- Entity 5 (Main Controller)
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

-- Entity 6 (ALU Controller)
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

-- Entity 7 (PC)
library ieee ;
use ieee.std_logic_1164.all;

entity PC is 
	port ( 
		pc_current :out std_logic_vector (31 downto 0); 
		pc_next : in std_logic_vector (31 downto 0);
		clk : in std_logic;
		reset : in std_logic
	);
end PC;

architecture dataflow of PC is
begin
	process(clk,reset)       --!!! Change PC when clock rises
	begin 
		if (reset='1') then                  
			pc_current <= x"00000000";
		elsif (rising_edge(clk)) then
			pc_current <= pc_next;
		end if;
	end process;
end dataflow;

-- Entity 8,10,11,12 (Mux2to1 with N bits (default 32))
library ieee;
use ieee.std_logic_1164.all;

entity Mux2to1 is
generic(
	n : integer := 32 );
port(
	a, b: in std_logic_vector(n-1 downto 0);
    s: in std_logic;
    d: out std_logic_vector(n-1 downto 0));
end Mux2to1;
    
architecture behavioral of Mux2to1 is
 begin
    d <= a when s='0' else b;
  end behavioral;
  
-- Entity 9 (Sign Extender)
  
library ieee;
use ieee.std_logic_1164.all;

entity SignExtender is
port (
	se_in : in std_logic_vector (15 downto 0);
	se_out : out std_logic_vector (31 downto 0)
);
end SignExtender;

architecture behavioral of SignExtender is
begin
	se_out <= x"0000" & se_in when se_in(15) = '0' 
	else x"FFFF" & se_in;
	
end behavioral; 

-- Entity 14,15 (Adder)

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Adder is 
	port ( 
		a, b : in std_logic_vector(31 downto 0);
		s : out std_logic_vector(31 downto 0)
	);
end Adder;

architecture dataflow of adder is
begin
	s <= a + b;
end dataflow;

-- Entity MIPS 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity MIPS is port(
clk : in std_logic;
reset : in std_logic);
end MIPS;

architecture behavioral of MIPS is
component ALU 
	port (
		 ALUin1: in std_logic_vector(31 downto 0); 
		 ALUin2: in std_logic_vector(31 downto 0); 
		 ALUctrl: in std_logic_vector(3 downto 0); 
		 ALUout1: out std_logic_vector(31 downto 0); 
		 zero: out std_logic);
 end component;
 
component RegFile
	generic(
	 w : natural := 5;     -- number of address bits
	 b : natural := 32;    --number of bits 
	 size : natural := 16  -- number of registers (to the register file)
	);
	port (
		   ReadReg1 : in std_logic_vector(w-1 downto 0);
		   ReadReg2 : in std_logic_vector(w-1 downto 0);
		   WriteReg : in std_logic_vector(w-1 downto 0);
		   WriteData : in std_logic_vector(b-1 downto 0);
		   RegWrite : in std_logic;
		   ReadData1 : out std_logic_vector(b-1 downto 0);
		   ReadData2 : out std_logic_vector(b-1 downto 0);
		   clk,rst : in std_logic
	);
end component; 

component DataMemory
	port(
			Address : in std_logic_vector(31 downto 0);
			WriteData : in std_logic_vector(31 downto 0);
			MemRead, MemWrite : in std_logic;
			ReadData : out std_logic_vector(31 downto 0);
			clk : in std_logic
		);
end component; 

component InstructionMemory
	port (
			ReadAddress : std_logic_vector(31 downto 0);
			Instruction : out std_logic_vector(31 downto 0)	
		);
end component;

component MainController
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
end component;

component ALUController
	port (
			funct : in std_logic_vector(5 downto 0);
			ALUOp : in std_logic_vector(1 downto 0);
			Operation : out std_logic_vector(3 downto 0)
		);
end component;

component PC
	port ( 
			pc_current :out std_logic_vector (31 downto 0); 
			pc_next : in std_logic_vector (31 downto 0);
			clk : in std_logic;
			reset : in std_logic
		);
end component;

component Mux2to1
	generic(
		n : integer := 32 );
	port(
	a, b: in std_logic_vector(n-1 downto 0);
    s: in std_logic;
    d: out std_logic_vector(n-1 downto 0)
	);
end component;

component SignExtender
	port (
		se_in : in std_logic_vector (15 downto 0);
		se_out : out std_logic_vector (31 downto 0)
	);
end component;

component Adder
	port ( 
			a, b : in std_logic_vector(31 downto 0);
			s : out std_logic_vector(31 downto 0)
		);
end component;
 
constant N1 : natural := 5;
constant N2 : natural := 32;
signal pc_current : std_logic_vector (31 downto 0); 
signal pc_next : std_logic_vector (31 downto 0);
signal instruct : std_logic_vector (31 downto 0); --Instruction bits
signal	RegDst :  std_logic;
signal	Branch :  std_logic;
signal	MemRead :  std_logic;
signal  MemtoReg :  std_logic;
signal  ALUOp :  std_logic_vector (1 downto 0);
signal  MemWrite : std_logic;
signal  ALUSrc :  std_logic;
signal  RegWrite :  std_logic;
signal  Write_Reg : std_logic_vector(4 downto 0); --εξοδος 5-Mux
signal se_out : std_logic_vector (31 downto 0);
signal Write_Data : std_logic_vector(31 downto 0);
signal reg1,reg2 : std_logic_vector (31 downto 0);
signal ALUIN_2 : std_logic_vector (31 downto 0);
signal ALU_Control : std_logic_vector(3 downto 0); --output of alu controller
signal ALU_out : std_logic_vector(31 downto 0); --adress of data memory
signal zero : std_logic;
signal readData :std_logic_vector(31 downto 0);
signal y,z : std_logic_vector(31 downto 0);
signal and_out : std_logic;

begin
	-- PC (Entity 7)
	E7 : PC
	port map( pc_current => pc_current, 
			  pc_next => pc_next, 
			  clk => clk,
			  reset => reset	
			  );
	
	-- Instruction Memory (Entity 4)
	E4 : InstructionMemory
	port map( ReadAddress => pc_current, 
			  Instruction => instruct );
			  
	-- Main Controller (Entity 5)
	E5 : MainController
	port map ( OpCode => instruct(31 downto 26),
			   RegDst => RegDst, 
			   Branch => Branch,
			   MemRead => MemRead,
			   MemtoReg => MemtoReg,
			   ALUOp => ALUOp,
			   MemWrite => MemWrite,
			   ALUSrc => ALUSrc,
			   RegWrite => RegWrite );
			   
	-- 5-bit Multiplexer (Entity 8)		   
	E8 : Mux2to1 
	generic map ( n => N1)
	port map ( a => instruct(20 downto 16), --0
			   b => instruct (15 downto 11), --1
			   s => RegDst, 
			   d => Write_Reg );
			   
	-- Sign Extender (Entity 9)		   
	E9 : SignExtender 
	port map( se_in => instruct (15 downto 0),	
			  se_out => se_out );
			  
	-- Register File (Entity 2)
	E2 : RegFile
	port map( ReadReg1 => instruct(25 downto 21),
			  ReadReg2 => instruct(20 downto 16),
			  WriteReg => Write_Reg,
			  WriteData => Write_Data,
			  RegWrite => RegWrite,
			  ReadData1 => reg1,
			  ReadData2 => reg2,
			  clk => clk,
			  rst => reset	  
	);
	
	--32-bit Multiplexer (Entity 10)
	E10 : Mux2to1 
	generic map ( n => N2)
	port map ( a => reg2, --0 
			   b => se_out, --1
			   s => ALUSrc, 
			   d => ALUIN_2 );
			   
	-- ALU Controller (Entity 6)
	E6 : ALUController
	port map( funct => instruct( 5 downto 0),
			  ALUOp => ALUOp,
			  Operation => ALU_Control);
			  
	-- ALU (Entity 1)
	E1 : ALU
	port map( ALUin1 => reg1 , 
			  ALUin2 => ALUIN_2, 
	          ALUctrl => ALU_Control, 
			  ALUout1 => ALU_out, 
			  zero => zero); 
			  
	-- Data Memory (Entity 3)
	E3 : DataMemory
	port map(  Address => ALU_out,
			   WriteData => reg2,
			   MemRead => MemRead,
			   MemWrite => MemWrite,
			   ReadData => readData,
			   clk => clk);
			  
	-- 32-bit Multiplexer (Entity 11)
	E11 : Mux2to1
	generic map ( n => N2)
	port map ( a => ALU_out, --0
			   b => readData,  --1
			   s => MemtoReg, 
			   d => Write_Data);
			   
	-- 32-bit Adder (Entity 14)		   
	E14 : Adder 
	port map (a => pc_current, 
			  b => x"00000001", 
			  s => y);	
			  
	-- 32-bit Adder (Entity 15)		   
	E15 : Adder 
	port map (a => y, 
			  b => se_out, 
			  s => z);	
			  
	--AND Gate 2 Inputs			  
	and_out <= zero and Branch; 
	
	--32-bit Multiplexer (Entity 12)
	E12 : Mux2to1
	generic map ( n => N2)
	port map ( a => y, --0
			   b => z, --1
			   s => and_out, 
			   d => pc_next );
	
end behavioral;