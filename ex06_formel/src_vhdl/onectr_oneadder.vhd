--------------------------------------------------------------------------------
--
-- file:   onectr_oneaddr.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: 1s Counter oneaddr architecture
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity OneCtr is
    generic(INPUTSIZE : integer := 64);
    port(
        clk:     in  std_logic;
        rst:     in std_logic;
        start_i: in  std_logic;
        InPort:  in  std_logic_vector(INPUTSIZE-1 downto 0);
        OutPort: out std_logic_vector(integer(ceil(log2(real(INPUTSIZE+1))))-1 downto 0)
    );
end OneCtr;

architecture oneadder of OneCtr is
begin
    process(InPort)
        variable res:    unsigned(6 downto 0);
        variable to_add: std_logic_vector(6 downto 0);
    begin
        res := (others => '0');

        for i in 0 to 63 loop
            to_add := "000000" & InPort(i);
            res := res + unsigned(to_add);
        end loop;

        OutPort <= std_logic_vector(res);
    end process;
end oneadder;
