library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
    generic(N : integer := 8);
    port(
        clk :  in std_logic;
        start: in  std_logic;
        addr:  in std_logic_vector(N-1 downto 0);
        JP:    in std_logic;
        JF:    in std_logic;
        Flag:  in  std_logic;
        PC:    out std_logic_vector(N-1 downto 0)
    );
end ProgramCounter;

architecture struct of ProgramCounter is
    -- Programm counter register
    signal PC_reg: std_logic_vector(N-1 downto 0);
begin
    PC <= PC_reg;

    -- Program counter management
    process(clk)
    begin
        if rising_edge(clk) then
            if start='1' then
                PC_reg <= (others => '0');
            else
                if (JP='1') or (Flag='1' and JF='1') then
                    PC_reg <= addr;
                else
                    PC_reg <= std_logic_vector(unsigned(PC_reg) + 1);
                end if;
            end if;
        end if;
    end process;
end struct;
