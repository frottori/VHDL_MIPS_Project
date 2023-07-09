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
