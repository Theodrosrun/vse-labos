--------------------------------------------------------------------------------
--
-- file:   onectr_piso.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: 1s Counter PISO architecture
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

architecture PISO of OneCtr is
    signal input  : std_logic_vector(63 downto 0);
    signal output : std_logic_vector(6 downto 0);
begin
    process(clk,start_i)
        variable to_add : std_logic_vector(6 downto 0);
    begin
        if rising_edge(clk) then
            if start_i='1' then
                input  <= InPort;
                output <= (others => '0');
            else
                input  <= '0' & input(63 downto 1);
                to_add := "000000" & input(0);
                output <= std_logic_vector(unsigned(output) + unsigned(to_add));
            end if;
        end if;
    end process;

    OutPort <= output;
end PISO;
