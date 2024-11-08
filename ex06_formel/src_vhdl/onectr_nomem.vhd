--------------------------------------------------------------------------------
--
-- file:   onectr.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   November 2024
--
-- description: 1s Counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity OneCtr_Nomem is
    generic(INPUTSIZE : integer := 64;
            PCSIZE : integer := 8);
    port(
        clk:         in  std_logic;
        rst:         in  std_logic;
        start_i:     in  std_logic;
        InPort:      in  std_logic_vector(INPUTSIZE-1 downto 0);
        OutPort:     out std_logic_vector(integer(ceil(log2(real(INPUTSIZE+1))))-1 downto 0);
        Ctrl:        in std_logic_vector(7 downto 0);
        Sel:         in std_logic_vector(3 downto 0);
        Wen:         in std_logic;
        WA:          in std_logic_vector(3 downto 0);
        RAA:         in std_logic_vector(3 downto 0);
        RAB:         in std_logic_vector(3 downto 0);
        Op:          in std_logic_vector(2 downto 0);
        JP:          in std_logic;
        JF:          in std_logic;
        JumpAddress: in std_logic_vector(PCSIZE-1 downto 0);
        PCAddress:   out std_logic_vector(PCSIZE-1 downto 0)
    );
end OneCtr_Nomem;

architecture struct of OneCtr_Nomem is

     component ProgramCounter
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

     -- Internal signals
     signal Flag : std_logic;
 begin

    ctr: ProgramCounter
    generic map(N => PCSIZE)
    port map(
        clk   => clk,
        start => start_i,
        JP => JP,
        JF => JF,
        addr => JumpAddress,
        Flag  => Flag,
        PC => PCAddress
     );

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

 end struct;
