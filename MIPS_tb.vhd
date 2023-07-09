library ieee;
use ieee.std_logic_1164.all;

entity test_MIPS is
end test_MIPS;

architecture test of test_MIPS is
signal clk_t,reset_t : std_logic := '0';
constant clk_period : time := 20 ns;
component MIPS 
port (
clk : in std_logic;
reset : in std_logic); 
end component;
begin
 M1 : MIPS port map ( clk => clk_t, reset => reset_t );
 
 --Clock process
 clk_process: process
 begin
	clk_t <= '0';
	wait for clk_period/2;
	
	clk_t <= '1';
	wait for clk_period/2;
 end process;
 
 --Stimulus Process
stim_proc: process
   begin  
      reset_t <= '1'; wait for clk_period/2;
	  reset_t <= '0'; wait for clk_period*23;
 end process;
end test;
