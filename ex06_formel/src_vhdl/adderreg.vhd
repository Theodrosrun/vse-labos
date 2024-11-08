--------------------------------------------------------------------------------
--
-- file:   adderreg.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: N bits adder with N+1 bits in output.
--              Output is sync on the clock
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adderreg is
    generic(SIZE : integer := 2);
    port(
        clk    : in std_logic;
        rst    : in std_logic;
        input1 : in  std_logic_vector(SIZE-1 downto 0);
        input2 : in  std_logic_vector(SIZE-1 downto 0);
        output : out std_logic_vector(SIZE downto 0)
    );
end adderreg;

architecture comp of adderreg is
begin
    process(clk,rst)
    begin
        if rst='1' then
            output <= (others => '0');
        elsif rising_edge(clk) then
            output <= std_logic_vector(unsigned('0' & input1) + unsigned('0' & input2));
        end if;
    end process;
end comp;
