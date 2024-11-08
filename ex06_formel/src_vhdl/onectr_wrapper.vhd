library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity OneCtrWrapper is
    port(
        clk: in std_logic;
        start: in std_logic;
        InPort: in std_logic_vector(63 downto 0);
        OutPort: out std_logic_vector(6 downto 0)
    );
end OneCtrWrapper;

architecture struct of OneCtrWrapper is

    component OneCtr
        port(
            clk: in std_logic;
            start: in std_logic;
            InPort: in std_logic_vector(63 downto 0);
            OutPort: out std_logic_vector(6 downto 0)
        );
    end component;
    for all: OneCtr use entity work.OneCtr(mux);

    signal InReg: std_logic_vector(63 downto 0);
    signal OutCtr: std_logic_vector(6 downto 0);

    constant withreg: boolean := true;

begin

    ctr: OneCtr
        port map(
            clk => clk,
            start => start,
            InPort => InReg,
            OutPort => OutCtr
        );

    wif: if withreg generate
        process(clk)
        begin
            if rising_edge(clk) then
                InReg <= InPort;
                OutPort <= OutCtr;
            end if;
        end process;
    end generate;

    wif1: if not withreg generate
        InReg <= InPort;
        OutPort <= OutCtr;
    end generate;
end struct;
