--------------------------------------------------------------------------------
--
-- file:   control.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: Control unit of the 1s counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
    port(
        clk   : in  std_logic;
        start : in  std_logic;
        Ctrl  : out std_logic_vector(7 downto 0);
        Sel   : out std_logic_vector(3 downto 0);
        Wen   : out std_logic;
        WA    : out std_logic_vector(3 downto 0);
        RAA   : out std_logic_vector(3 downto 0);
        RAB   : out std_logic_vector(3 downto 0);
        Op    : out std_logic_vector(2 downto 0);
        Flag  : in  std_logic
    );
end control;

architecture struct of control is
    constant N: integer := 8;

    component rom
        port(
            addr: in  std_logic_vector(N-1 downto 0);
            data: out std_logic_vector(30+N-1 downto 0)
        );
    end component;

    component ProgrammCounter
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
    end component;
    -- Programm counter register
    signal PC: std_logic_vector(N-1 downto 0);
    -- Unconditionnal jump
    signal JP: std_logic;
    -- Conditionnal jump
    signal JF: std_logic;
    -- Address for accessing the program ROM memory
    signal addr: std_logic_vector(N-1 downto 0);
    -- Program ROM memory output
    signal rom_out: std_logic_vector(30+N-1 downto 0);

begin
    -- Program ROM instanciation
    mem: rom
        port map(
            addr => PC,
            data => rom_out
        );

    pcinst: ProgrammCounter
        generic map(N => N)
        port map(
            clk => clk,
            start => start,
            addr => addr,
            JP => JP,
            JF => JF,
            Flag => Flag,
            PC => PC
        );

    -- Define signal based on ROM output
    addr <= rom_out(30+N-1 downto 30);
    JP   <= rom_out(29);
    JF   <= rom_out(28);
    CTRL <= rom_out(27 downto 20);
    Sel  <= rom_out(19 downto 16);
    Wen  <= rom_out(15);
    Wa   <= rom_out(14 downto 11);
    RAA  <= rom_out(10 downto 7);
    RAB  <= rom_out(6 downto 3);
    Op   <= rom_out(2 downto 0);

end struct;
