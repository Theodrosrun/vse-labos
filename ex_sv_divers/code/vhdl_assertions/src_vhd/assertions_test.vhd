library ieee;
context ieee.ieee_std_context;

entity assertions_test is
end assertions_test;


architecture testbench of assertions_test is

    signal clk  : std_logic;
    signal a1    : std_logic;
    signal b1    : std_logic;
    signal a2    : std_logic := '0';
    signal b2    : std_logic := '0';
    signal a3    : std_logic;
    signal b3    : std_logic;
    signal wr   : std_logic;
    signal data : std_logic;

    constant CLK_PERIOD : time := 10 ns;
    constant ta : time := 50 ns;
    constant tf : time := 20 ns;

    signal stop : boolean := false;
begin


    clk_gen: process is
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
        if (stop) then
            wait;
        end if;
    end process clk_gen;

    -- assertion 1

    -- assertion 2

    -- assertion 3

    -- assertion 4



    process is


        procedure testcase_assertion1_true is
        begin
            a1 <= '0';
            b1 <= '0';
            wait for 200 ns;
            a1 <= '1';
            wait for 101 ns;
            b1 <= '1';
            wait for 200 ns;
        end testcase_assertion1_true;

        procedure testcase_assertion1_false is
        begin
            a1 <= '0';
            b1 <= '0';
            wait for 200 ns;
            a1 <= '1';
            wait for 50 ns;
            b1 <= '1';
            wait for 200 ns;
        end testcase_assertion1_false;


        procedure testcase_assertion2_true is
        begin
            wait for 10 ns;
            a2 <= '1';
            b2 <= '1';
            wait for 10 ns;
            a2 <= '0';
            b2 <= '0';
            wait for 10 ns;
        end testcase_assertion2_true;

        procedure testcase_assertion2_false is
        begin
            a2 <= '1';
            b2 <= '1';
            wait for 10 ns;
            a2 <= '0';
            b2 <= '1';
            wait for 10 ns;
        end testcase_assertion2_false;

        procedure testcase_assertion3_true is
        begin
            a3 <= '0';
            b3 <= '0';
            wait until rising_edge(clk);
            a3 <= '1';
            b3 <= '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end testcase_assertion3_true;

        procedure testcase_assertion3_false is
        begin
            a3 <= '0';
            b3 <= '0';
            wait until rising_edge(clk);
            a3 <= '1';
            b3 <= '1';
            wait until rising_edge(clk);
            b3 <= '0';
            wait until rising_edge(clk);
            b3 <= '0';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end testcase_assertion3_false;

        procedure testcase_assertion4_true is
        begin
            data <= '0', '1' after 100 ns, '0' after 100 ns + ta - tf + 10 ns;
            wr <= '1', '0' after 101 ns + ta;
        end testcase_assertion4_true;

        procedure testcase_assertion4_false is
        begin
            data <= '0', '1' after 100 ns, '0' after 100 ns + ta - tf;
            wr <= '1', '0' after 110 ns + ta;
        end testcase_assertion4_false;

    begin
        testcase_assertion1_true;
        --testcase_assertion2_true;
        testcase_assertion3_true;
        testcase_assertion4_true;
        wait for 10000 ns;
        testcase_assertion1_false;
        testcase_assertion2_false;
        testcase_assertion3_false;
        testcase_assertion4_false;
        stop <= true;
        wait;
    end process;

end architecture testbench;
