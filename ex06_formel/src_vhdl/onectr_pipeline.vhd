--------------------------------------------------------------------------------
--
-- file:   onectr_pipeline.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: 1s Counter pipeline architecture
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

architecture pipeline of OneCtr is

    type inter1_type is array(0 to 63) of std_logic_vector(0 downto 0);
    signal inter1:  inter1_type;
    type inter2_type is array(0 to 31) of std_logic_vector(1 downto 0);
    signal inter2:  inter2_type;
    type inter3_type is array(0 to 15) of std_logic_vector(2 downto 0);
    signal inter3:  inter3_type;
    type inter4_type is array(0 to 7) of std_logic_vector(3 downto 0);
    signal inter4:  inter4_type;
    type inter5_type is array(0 to 3) of std_logic_vector(4 downto 0);
    signal inter5:  inter5_type;
    type inter6_type is array(0 to 1) of std_logic_vector(5 downto 0);
    signal inter6:  inter6_type;

    component adderreg
        generic(SIZE: integer:=2);
        port(
            clk, rst: in std_logic;
            input1,input2: in std_logic_vector(SIZE-1 downto 0);
            output: out std_logic_vector(SIZE downto 0)
        );
    end component;
begin
    gen1: for i in 0 to 31 generate
        inter1(2*i)(0)   <= InPort(2*i);
        inter1(2*i+1)(0) <= InPort(2*i+1);

        add: adderreg
            generic map(SIZE=>1)
            port map(
                clk => clk,
                rst => start,
                input1 => inter1(2*i),
                input2 => inter1(2*i+1),
                output => inter2(i)
            );
    end generate;

    gen2: for i in 0 to 15 generate
         add: adderreg
            generic map(SIZE=>2)
            port map(
                clk => clk,
                rst => start,
                input1 => inter2(2*i),
                input2 => inter2(2*i+1),
                output => inter3(i)
            );
    end generate;

    gen3: for i in 0 to 7 generate
         add: adderreg
            generic map(SIZE=>3)
            port map(
                clk => clk,
                rst => start,
                input1 => inter3(2*i),
                input2 => inter3(2*i+1),
                output => inter4(i)
            );
    end generate;

    gen4: for i in 0 to 3 generate
         add: adderreg
            generic map(SIZE=>4)
            port map(
                clk => clk,
                rst => start,
                input1 => inter4(2*i),
                input2 => inter4(2*i+1),
                output => inter5(i)
            );
    end generate;

    gen5: for i in 0 to 1 generate
         add: adderreg
            generic map(SIZE=>5)
            port map(
                clk => clk,
                rst => start,
                input1 => inter5(2*i),
                input2 => inter5(2*i+1),
                output => inter6(i)
            );
    end generate;

    gen6: for i in 0 to 0 generate
         add: adderreg
            generic map(SIZE=>6)
            port map(
                clk => clk,
                rst => start,
                input1 => inter6(2*i),
                input2 => inter6(2*i+1),
                output => OutPort
            );
    end generate;

end pipeline;
