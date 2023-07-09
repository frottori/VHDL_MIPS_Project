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
