--------------------------------------------------------------------------------
--
-- file:   alu.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: Arithmetic and logic unit for the 1s counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port(
        Op : in  std_logic_vector(2 downto 0); -- Operation to execute
        A  : in  std_logic_vector(7 downto 0); -- First operand
        B  : in  std_logic_vector(7 downto 0); -- Second operand
        Y  : out std_logic_vector(7 downto 0); -- Result
        F  : out std_logic                     -- Flag
    );
end alu;

architecture behave of alu is
begin
    -- Process to execute the correct operation
    process(A,B,Op)
    begin
        Y <= A;
        F <= '0';

        case Op is
            when "000" => Y <= std_logic_vector(unsigned(A) + unsigned(B));
            when "001" => Y <= '0' & A(7 downto 1);
            when "010" =>
                    if A = B then
                        F <= '1';
                    else
                        F <= '0';
                    end if;
            when "011" => Y <= A and B;
            when "100" => Y <= A;
            when others => null;
        end case;
    end process;
end behave;
