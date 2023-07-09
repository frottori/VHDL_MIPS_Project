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

