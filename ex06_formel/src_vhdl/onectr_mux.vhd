--------------------------------------------------------------------------------
--
-- file:   onectr_mux.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: 1s Counter mux architecture
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

architecture Mux of OneCtr is
    signal counter : unsigned(integer(ceil(log2(real(INPUTSIZE+1))))-1 downto 0);
    signal output  : std_logic_vector(integer(ceil(log2(real(INPUTSIZE+1))))-1 downto 0);

        constant counter_zero : std_logic_vector(integer(ceil(log2(real(INPUTSIZE+1))))-2 downto 0) := (others => '0');
begin

    process(clk,rst)
        variable to_add : std_logic_vector(integer(ceil(log2(real(INPUTSIZE+1))))-1 downto 0);
    begin
        if (rst= '1') then
            counter <= (others => '0');
            output  <= (others => '0');
        elsif rising_edge(clk) then
            if start_i='1' then
                counter <= (others => '0');
                output  <= (others => '0');
            else
                counter <= counter + 1;
                to_add  := counter_zero & InPort(to_integer(counter));
                output  <= std_logic_vector(unsigned(output) + unsigned(to_add));
            end if;
        end if;
    end process;

    OutPort <= output;

end Mux;
