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
		for i in 0 to (size-1) loop   
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
