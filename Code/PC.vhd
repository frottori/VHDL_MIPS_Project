library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

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
	process(clk,reset)       --PC changes when clock rises
	begin 
		if (reset='1') then                  
			pc_current <= x"00000000";
		elsif (rising_edge(clk)) then
			pc_current <= pc_next;
		end if;
	end process;
end dataflow;