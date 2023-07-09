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
