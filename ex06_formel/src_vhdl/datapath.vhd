--------------------------------------------------------------------------------
--
-- file:   datapath.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: Processing unit for the 1s counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port(
        clk     : in  std_logic;
        InPort  : in  std_logic_vector(63 downto 0);
        OutPort : out std_logic_vector(6 downto 0);
        Ctrl    : in  std_logic_vector(7 downto 0);
        Sel     : in  std_logic_vector(3 downto 0);
        Wen     : in  std_logic;
        WA      : in  std_logic_vector(3 downto 0);
        RAA     : in  std_logic_vector(3 downto 0);
        RAB     : in  std_logic_vector(3 downto 0);
        Op      : in  std_logic_vector(2 downto 0);
        Flag    : out std_logic
    );
end datapath;

architecture struct of datapath is
    -- ALU component
    component alu
    port(
        Op : in  std_logic_vector(2 downto 0);
        A  : in  std_logic_vector(7 downto 0);
        B  : in  std_logic_vector(7 downto 0);
        Y  : out std_logic_vector(7 downto 0);
        F  : out std_logic
    );
    end component;

    -- Register bank component
    component regfile
    port(
        clk : in  std_logic;
        W   : in  std_logic_vector(7 downto 0);
        A   : out std_logic_vector(7 downto 0);
        B   : out std_logic_vector(7 downto 0);
        Wen : in  std_logic;
        WA  : in  std_logic_vector(3 downto 0);
        RAA : in  std_logic_vector(3 downto 0);
        RAB : in  std_logic_vector(3 downto 0)
    );
    end component;

    -- Input signal of the register bank
    signal InReg: std_logic_vector(7 downto 0);
    -- Output singals of the register bank
    signal A, B: std_logic_vector(7 downto 0);
    -- ALU result
    signal AluOut: std_logic_vector(7 downto 0);
    -- Flag for the ALU compare result
    signal AluFlag: std_logic;

begin

    -- Connect output with the 7 LSB of the ALU
    OutPort <= AluOut(6 downto 0);

    -- ALU instance
    thealu: alu
    port map(
        Op => Op,
        A  => A,
        B  => B,
        Y  => AluOut,
        F  => AluFlag
    );

    -- Register bank instance
    reg: regfile
    port map(
        clk => clk,
        W   => InReg,
        A   => A,
        B   => B,
        Wen => Wen,
        WA  => WA,
        RAA => RAA,
        RAB => RAB
    );

    -- Mux to select the data transmitted to register bank
    insel: process(InPort, Sel, AluOut, Ctrl)
    begin
        case to_integer(unsigned(Sel)) is
            when 0 => InReg <= Ctrl;
            when 1 => InReg <= InPort(7 downto 0);
            when 2 => InReg <= InPort(15 downto 8);
            when 3 => InReg <= InPort(23 downto 16);
            when 4 => InReg <= InPort(31 downto 24);
            when 5 => InReg <= InPort(39 downto 32);
            when 6 => InReg <= InPort(47 downto 40);
            when 7 => InReg <= InPort(55 downto 48);
            when 8 => InReg <= InPort(63 downto 56);
            when 9 => InReg <= AluOut;
            when others => InReg <= AluOut;
        end case;
    end process;

    -- Compare flag management
    theflag: process(clk)
    begin
        if rising_edge(clk) then
            Flag <= AluFlag;
        end if;
    end process;

end struct;
