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
1.0   07.10.2024  TMU        Initial version

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
    int nb_errors = 0;
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

    task test_scenario0;
        input_itf.min = 3;
        input_itf.max = 12;
        input_itf.value = 8;
        input_itf.com = 2'b00;
        input_itf.osci = 1;
        @(posedge(synchro));
    endtask

    task test_scenario1;
        @(posedge(synchro));
    endtask

    task test_scenario2;
        @(posedge(synchro));
    endtask

    task test_scenarios(int TESTCASE);
        case(TESTCASE)
            0: test_scenario0();
            1: test_scenario1();
            2: test_scenario2();
            default: begin
                $display("Invalid TESTCASE: %d", TESTCASE);
                $finish;
            end
        endcase
    endtask

    task compute_reference(logic[1:0] com, input_t min, input_t max, input_t value, logic osci, output output_t leds);
        integer i;
        leds = 0;

        case (com)
            2'b00: // Normal mode
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
            
            2'b01: // Linear mode
            begin
                for (i = 0; i <= value; i++) begin
                    leds[i] = 1;
                end
            end

            2'b10: // Test all OFF 
            begin
                leds = 0;
            end

            2'b11: // Test all ON
            begin
                leds = {2**VALSIZE{1'b1}}; 
            end
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
            if (output_itf.leds !== leds_ref) begin
                nb_errors++;
                $display("Error for com = %b, min = %d, max = %d, value = %d", input_itf.com, input_itf.min, input_itf.max, input_itf.value);
                $display("Expected: %b, Observed: %b", leds_ref, output_itf.leds);
                error_signal = 1;
                #pulse;
                error_signal = 0;
            end
            @(negedge(synchro));
        end
    endtask

    initial begin
        $display("Starting simulation");
        fork
            test_scenarios(TESTCASE);
            compute_reference_task;
            verification;
        join_any

        $display("Ending simulation");
        if (nb_errors > 0)
            $display("Number of errors : %d", nb_errors);
        else
            $display("No errors");
                
        $finish;
    end

endmodule