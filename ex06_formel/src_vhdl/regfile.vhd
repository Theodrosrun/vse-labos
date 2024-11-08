--------------------------------------------------------------------------------
--
-- file:   regfile.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: Register bank for the 1s counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    port(
        clk : in  std_logic;                    -- System clock
        W   : in  std_logic_vector(7 downto 0); -- Write data
        A   : out std_logic_vector(7 downto 0); -- Read data A
        B   : out std_logic_vector(7 downto 0); -- Read data B
        Wen : in  std_logic;                    -- Enable write
        WA  : in  std_logic_vector(3 downto 0); -- Write address
        RAA : in  std_logic_vector(3 downto 0); -- Read address A
        RAB : in  std_logic_vector(3 downto 0)  -- Read address B
    );
end regfile;

architecture comp of regfile is

    -- Type to store 16 register of 8 bits
    type mem_type is array(0 to 15) of std_logic_vector(7 downto 0);
    -- Register bank
    signal reg: mem_type;

begin

    -- Write management
    wr:process(clk)
    begin
        if rising_edge(clk) then
            if Wen = '1' then
                reg(to_integer(unsigned((WA)))) <= W;
            end if;
        end if;
    end process;

    -- Read data A
    A <= reg(to_integer(unsigned((RAA))));
    -- Read data B
    B <= reg(to_integer(unsigned((RAB))));

end comp;
