-------------------------------------------------------------------------------
-- Projet UART
--
-- Fichier : uart_sender_tb.vhd
-- Description: Banc de test pour un émetteur UART simple.
--
-- Auteur : Yann Thoma
-- Team   : Institut REDS
-- Date   : 19.03.13
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who  Description
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity uart_tb is
    generic(
        ERRNO : integer := 0;
        TESTCASE : integer := 0;
        FIFOSIZE : integer := 8;
        LOGFILENAME : string
    );
end uart_tb;

architecture testbench of uart_tb is

    component uart
        generic (
            ERRNO : integer := 0;
            FIFOSIZE : integer := 8
        );
        port (
            clk_i          : in  std_logic;
            rst_i          : in  std_logic;
            clk_per_bit_i  : in  std_logic_vector(31 downto 0);
            parity_i       : in  std_logic;
            stops_i        : in  std_logic;
            send_i         : in  std_logic;
            data_in_i      : in  std_logic_vector(7 downto 0);
            sender_ready_o : out std_logic;
            data_error_o   : out std_logic;
            data_valid_o   : out std_logic;
            data_out_o     : out std_logic_vector(7 downto 0);
            rx_i           : in std_logic;
            tx_o           : out std_logic
        );
    end component;

    signal sim_end_s       : boolean := false;

    signal clk_sti          : std_logic;
    signal rst_sti          : std_logic;
    signal parity_sti       : std_logic;
    signal stops_sti        : std_logic;
    signal send_sti         : std_logic;
    signal clk_per_bit_sti  : std_logic_vector(31 downto 0);
    signal data_sti         : std_logic_vector(7 downto 0);
    signal sender_ready_obs : std_logic;
    signal tx_obs           : std_logic;
    signal data_error_obs   : std_logic;
    signal data_valid_obs   : std_logic;
    signal data_out_obs     : std_logic_vector(7 downto 0);
    signal rx_sti           : std_logic;



    signal clk_per_bit_s   : integer := 0;

    constant CLK_PERIOD: time := 10 ns;

    FILE log_file : TEXT open WRITE_MODE is LOGFILENAME;

begin

    clk_per_bit_sti <= std_logic_vector(to_unsigned(clk_per_bit_s,32));

    send_process: process
        variable l: line;
        variable i: integer;
    begin
        if TESTCASE = 0 then
            sim_end_s <= true;
            wait;
        end if;
        if TESTCASE = 1 then
            report "Error in the DUV" severity error;
                sim_end_s <= true;
            wait;
        end if;
        stops_sti<='1';
        parity_sti <= '1';
        send_sti<='0';
        data_sti <= (others=>'0');
        clk_per_bit_s <= 8;

        write(l,string'("Starting simulation"));
        writeline(log_file,l);
        write(l,string'("ERRNO = "),left,10);
        write(l,ERRNO,Left,10);
        writeline(log_file,l);

        wait for 4*CLK_PERIOD;


        while (sender_ready_obs='0') loop
            wait for CLK_PERIOD;
        end loop;
        send_sti<='1';
        data_sti<="00001111";
        wait for CLK_PERIOD;
        send_sti<='0';
        wait for CLK_PERIOD;

        while (sender_ready_obs='0') loop
            wait for CLK_PERIOD;
        end loop;
        send_sti<='1';
        data_sti<="01101111";
        wait for CLK_PERIOD;
        send_sti<='0';
        wait for CLK_PERIOD;

        while (sender_ready_obs='0') loop
            wait for CLK_PERIOD;
        end loop;
        send_sti<='1';
        data_sti<="10001111";
        wait for CLK_PERIOD;
        send_sti<='0';
        wait for CLK_PERIOD;

        wait for 100*CLK_PERIOD;
        sim_end_s <= true;
        wait;
    end process;

    clk_process: process
    begin
        if (sim_end_s) then
            wait;
        end if;
        clk_sti<='0';
        wait for CLK_PERIOD/2;
        clk_sti<='1';
        wait for CLK_PERIOD/2;
    end process;

    rst_process: process
    begin
        rst_sti<='1';
        wait for CLK_PERIOD;
        rst_sti<='0';
        wait;
    end process;

    duv: uart
    generic map(
        ERRNO         => ERRNO,
        FIFOSIZE      => FIFOSIZE
    )
    port map(
        clk_i          => clk_sti,
        rst_i          => rst_sti,
        clk_per_bit_i  => clk_per_bit_sti,
        parity_i       => parity_sti,
        stops_i        => stops_sti,
        send_i         => send_sti,
        data_in_i      => data_sti,
        sender_ready_o => sender_ready_obs,
        data_error_o   => data_error_obs,
        data_valid_o   => data_valid_obs,
        data_out_o     => data_out_obs,
        rx_i           => rx_sti,
        tx_o           => tx_obs
    );

end testbench;
