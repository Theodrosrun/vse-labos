--------------------------------------------------------------------------------
--
-- file:   adder.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: N bits adder with N+1 bits in output
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    generic(SIZE: integer:=2);
    port(
        input1 : in  std_logic_vector(SIZE-1 downto 0);
        input2 : in  std_logic_vector(SIZE-1 downto 0);
        output : out std_logic_vector(SIZE downto 0)
    );
end adder;

architecture comp of adder is
begin
    output <= std_logic_vector(unsigned('0' & input1) + unsigned('0' & input2));
end comp;
