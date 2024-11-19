/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avl_uart_env.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the environment that instantiates the input
              and output agent, as well as the scoreboard

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef UART_TRANSCEIVER_ENV_SV
`define UART_TRANSCEIVER_ENV_SV

class avl_uart_env#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    avalon_agent#(DATASIZE, FIFOSIZE) local_agent;
    uart_agent#(DATASIZE, FIFOSIZE) remote_agent;

    avl_uart_scoreboard_rx#(DATASIZE, FIFOSIZE) scoreboard_rx;
    avl_uart_scoreboard_tx#(DATASIZE, FIFOSIZE) scoreboard_tx;

    virtual avalon_itf local_itf;
    virtual uart_itf remote_itf;

    avalon_fifo_t avalon_to_scoreboard_rx_fifo;
    avalon_fifo_t avalon_to_scoreboard_tx_fifo;
    uart_fifo_t uart_to_scoreboard_rx_fifo;
    uart_fifo_t uart_to_scoreboard_tx_fifo;

    task build;
        avalon_to_scoreboard_rx_fifo = new(10);
        avalon_to_scoreboard_tx_fifo = new(10);
        uart_to_scoreboard_rx_fifo = new(10);
        uart_to_scoreboard_tx_fifo = new(10);

        local_agent = new;
        remote_agent = new;
        scoreboard_rx = new;
        scoreboard_tx = new;

        local_agent.testcase = testcase;
        remote_agent.testcase = testcase;
        scoreboard_rx.testcase = testcase;
        scoreboard_tx.testcase = testcase;

        local_agent.vif = local_itf;
        remote_agent.vif = remote_itf;

        local_agent.build();
        remote_agent.build();
    endtask : build

    task connect;
        local_agent.avalon_to_scoreboard_rx_fifo = avalon_to_scoreboard_rx_fifo;
        local_agent.avalon_to_scoreboard_tx_fifo = avalon_to_scoreboard_tx_fifo;
        scoreboard_rx.avalon_to_scoreboard_rx_fifo = avalon_to_scoreboard_rx_fifo;
        scoreboard_tx.avalon_to_scoreboard_tx_fifo = avalon_to_scoreboard_tx_fifo;

        remote_agent.uart_to_scoreboard_rx_fifo = uart_to_scoreboard_rx_fifo;
        remote_agent.uart_to_scoreboard_tx_fifo = uart_to_scoreboard_tx_fifo;
        scoreboard_rx.uart_to_scoreboard_rx_fifo = uart_to_scoreboard_rx_fifo;
        scoreboard_tx.uart_to_scoreboard_tx_fifo = uart_to_scoreboard_tx_fifo;

        local_agent.connect();
        remote_agent.connect();
    endtask : connect

    task end_display;

        $display("************************** End of Simulation **************************\n");

        scoreboard_rx.end_display();
        scoreboard_tx.end_display();

        $display("\n***********************************************************************");
    endtask : end_display

    task run;
        fork
            local_agent.run();
            remote_agent.run();
            scoreboard_rx.run();
            scoreboard_tx.run();
        join;
    endtask : run

endclass : avl_uart_env

`endif // UART_TRANSCEIVER_ENV_SV
