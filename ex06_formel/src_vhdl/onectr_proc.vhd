--------------------------------------------------------------------------------
--
-- file:   onectr_proc.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: 1s Counter proc architecture
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

architecture proc of OneCtr is
    component control
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
    end component;

    component datapath
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
    end component;

    -- Signal to connect the control and processing units
    signal Ctrl : std_logic_vector(7 downto 0);
    signal Sel  : std_logic_vector(3 downto 0);
    signal Wen  : std_logic;
    signal WA   : std_logic_vector(3 downto 0);
    signal RAA  : std_logic_vector(3 downto 0);
    signal RAB  : std_logic_vector(3 downto 0);
    signal Op   : std_logic_vector(2 downto 0);
    signal Flag : std_logic;
begin

    -- Control unit instance
    ctr: control
    port map(
        clk   => clk,
        start => start_i,
        Ctrl  => Ctrl,
        Sel   => Sel,
        Wen   => Wen,
        WA    => WA,
        RAA   => RAA,
        RAB   => RAB,
        Op    => Op,
        Flag  => Flag
    );

    -- Processing unit instance
    data: datapath
    port map(
        clk     => clk,
        InPort  => InPort,
        OutPort => OutPort,
        Ctrl    => Ctrl,
        Sel     => Sel,
        Wen     => Wen,
        WA      => WA,
        RAA     => RAA,
        RAB     => RAB,
        Op      => Op,
        Flag    => Flag
    );
end proc;
