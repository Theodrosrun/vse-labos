/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : uart_agent.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the UART agent, that is the one monitoring
              and sending data to the UART output. Act like the remote host.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef UART_AGENT_SV
`define UART_AGENT_SV

class uart_agent#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    int ns_per_bit = 1_000_000_000 / 9600;

    uart_sequencer#(DATASIZE, FIFOSIZE) sequencer;
    uart_driver#(DATASIZE, FIFOSIZE) driver;
    uart_monitor#(DATASIZE, FIFOSIZE) monitor;

    virtual uart_itf vif;

    uart_fifo_t sequencer_to_driver_fifo;
    uart_fifo_t uart_to_scoreboard_rx_fifo;
    uart_fifo_t uart_to_scoreboard_tx_fifo;


    task build;
        sequencer_to_driver_fifo = new(10);

        sequencer = new;
        driver = new;
        monitor = new;

        sequencer.testcase = testcase;
        driver.testcase = testcase;
        monitor.testcase = testcase;

        driver.ns_per_bit = ns_per_bit;
        monitor.ns_per_bit = ns_per_bit;
    endtask : build

    task connect;
        sequencer.sequencer_to_driver_fifo = sequencer_to_driver_fifo;
        driver.sequencer_to_driver_fifo = sequencer_to_driver_fifo;
        driver.uart_to_scoreboard_rx_fifo = uart_to_scoreboard_rx_fifo;
        monitor.uart_to_scoreboard_tx_fifo = uart_to_scoreboard_tx_fifo;

        driver.vif = vif;
        monitor.vif = vif;
    endtask : connect

    task run;
        fork
            sequencer.run();
            driver.run();
            monitor.run();
        join;
    endtask : run

endclass : uart_agent

`endif // UART_AGENT_SV
