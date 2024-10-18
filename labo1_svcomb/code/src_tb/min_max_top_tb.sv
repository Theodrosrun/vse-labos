/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Engineering and Management Vaud
********************************************************************************
REDS Institute
Reconfigurable and Embedded Digital Systems
********************************************************************************

File     : min_max_top_tb.sv
Author   : Yann Thoma
Date     : 07.10.2024

Context  : min max component testbench

********************************************************************************
Description : This testbench is decomposed into stimuli
              generation and verification, with the use of interfaces.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   07.10.2024  YTA        Initial version

*******************************************************************************/


interface min_max_in_itf#(int VALSIZE);
    logic[1:0] com;
    logic[VALSIZE-1:0] max;
    logic[VALSIZE-1:0] min;
    logic osci;
    logic[VALSIZE-1:0] value;
endinterface

interface min_max_out_itf#(int VALSIZE);
    logic[2**VALSIZE-1:0] leds;
endinterface

module min_max_top_tb#(int VALSIZE, int TESTCASE, int ERRNO);

    timeunit 1ns;         // Definition of the time unit
    timeprecision 1ns;    // Definition of the time precision
   
    // Reference
    logic[2**VALSIZE-1:0] leds_ref;
   
    // Timings definitions
    time sim_step = 10ns;
    time pulse = 0ns;
   
    logic error_signal = 0;
   
    logic synchro = 0;
   
    always #(sim_step/2) synchro = ~synchro;
   
    min_max_in_itf input_itf();
    min_max_out_itf output_itf();

    typedef logic[VALSIZE-1:0] input_t;
    typedef logic[2**VALSIZE-1:0] output_t;
   
    // DUV instantiation
    min_max_top#(VALSIZE, ERRNO) duv(.com_i(input_itf.com),
                                     .max_i(input_itf.max),
                                     .min_i(input_itf.min),
                                     .osc_i(input_itf.osci),
                                     .val_i(input_itf.value),
                                     .leds_o(output_itf.leds));


    task test_scenario_something;
        // Déclarations locales
        logic[VALSIZE-1:0] test_min, test_max, test_value;
        logic[1:0] test_com;
        logic test_osci;

        // Scénario de test simple
        $display("Test scenario: Value within range of min and max, com = 00");
        test_com = 2'b00;           // Commande
        test_min = 'd3;             // Valeur minimum
        test_max = 'd8;             // Valeur maximum
        test_value = 'd5;           // Valeur courante
        test_osci = 1'b0;           // Oscillateur

        // Appliquer les stimuli sur l'interface
        input_itf.com = test_com;
        input_itf.min = test_min;
        input_itf.max = test_max;
        input_itf.value = test_value;
        input_itf.osci = test_osci;

        // Attendre un cycle pour synchronisation
        @(posedge(synchro));
        #1;

        // Affichage des résultats
        $display("Input: min=%d, max=%d, value=%d, com=%b, osci=%b", test_min, test_max, test_value, test_com, test_osci);
        $display("Output leds: %b", output_itf.leds);
    endtask


    task compute_reference(logic[1:0] com, input_t min, input_t max, input_t value, logic osci, output output_t leds);
        integer i;
        leds = 0;

        case (com)
            2'b00: 
            begin 
                if (value >= min && value <= max) begin
                    for (i = min; i <= value; i++) begin
                        leds[i] = 1;
                    end
                    for (i = value + 1; i <= max; i++) begin
                        leds[i] = osci;
                    end
                end
            end
            2'b01: 
            begin
                for (i = 0; i <= value; i++) begin
                    leds[i] = 1;
                end
            end
            2'b10: leds = 0;
            2'b11: leds = {2**VALSIZE{1'b1}};
        endcase
    endtask

    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;
            compute_reference(input_itf.com, input_itf.min, input_itf.max, input_itf.value, input_itf.osci, leds_ref);
        end
    endtask

    task verification;
        @(negedge(synchro));
        forever begin
            @(negedge(synchro));
        end
    endtask

    initial begin

        $display("Starting simulation");
        fork
            test_scenario_something;
            compute_reference_task;
            verification;
        join_any

        $display("Ending simulation");
    
        $finish;
    end

endmodule

