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