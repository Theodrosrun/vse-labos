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
    time pulse    = 0ns;
    logic synchro = 0;
   
    always #(sim_step/2) synchro = ~synchro;
   
    // Interfaces
    min_max_in_itf input_itf();
    min_max_out_itf output_itf();

    // Erros values
    logic error_signal = 0;
    int nb_errors     = 0;

    // Typedef
    typedef logic[VALSIZE-1:0] input_t;
    typedef logic[2**VALSIZE-1:0] output_t;

    // DUV instantiation
    min_max_top#(VALSIZE, ERRNO) duv(.com_i(input_itf.com),
                                     .max_i(input_itf.max),
                                     .min_i(input_itf.min),
                                     .osc_i(input_itf.osci),
                                     .val_i(input_itf.value),
                                     .leds_o(output_itf.leds));

    // ***********************************************
    // ******************** Param ********************
    // ***********************************************

    int MAX_ITERATION = 100;

    // ***********************************************
    // ******************** Class ********************
    // ***********************************************

    class RBase;
        rand input_t min;
        rand input_t max;
        rand input_t value;
        rand logic[1:0] com;
        rand logic osci;

        constraint max_bigger_than_min {
            max > min;
        }

        constraint s1 {
            solve min before max;
        }

        task process_iteration();
            input_itf.min = this.min;
            input_itf.max = this.max;
            input_itf.value = this.value;
            input_itf.com = this.com;
            input_itf.osci = this.osci;

            @(posedge(synchro));
            input_itf.osci = ~this.osci;

            @(posedge(synchro));
            input_itf.osci = ~this.osci;

            @(posedge(synchro));
        endtask
    endclass

    class RCoverage extends RBase;
        covergroup cg;
            coverpoint min {
                bins min    = {0};
                bins middle = {(2**(VALSIZE-1))};
                bins max    = {2**VALSIZE-1};
                bins values[VALSIZE] = {[1:2**VALSIZE-2]};
            }

            coverpoint max { 
                bins min    = {0};
                bins middle = {(2**(VALSIZE-1))};
                bins max    = {2**VALSIZE-1};
                bins values[VALSIZE] = {[1:2**VALSIZE-2]};
            }

            coverpoint value {
                bins min    = {0};
                bins middle = {(2**(VALSIZE-1))};
                bins max    = {2**VALSIZE-1};
                bins values[VALSIZE] = {[1:2**VALSIZE-2]};
            }

            coverpoint com { 
                bins values[] = {0, 1, 2, 3};
            }

            coverpoint osci { 
                bins values = {0,1};
            }
        endgroup

        function new();
            cg = new();
        endfunction

        task start();
            automatic int generation_count = 0;
            $display("\nstarting coverage");
            while ((cg.get_coverage() < 100) && (generation_count < MAX_ITERATION)) begin
                generation_count++;
                if (!randomize()) begin
                    $display("%m: randomization failed");
                end else begin
                    process_iteration();
                    cg.sample();
                end
            end
            $display("nb iterations: %d", generation_count);
            $display("coverage rate: %0.2f%%", cg.get_coverage());
            $display("coveraged finished\n");
        endtask
    endclass

    class RTest extends RBase;
        task start();
            automatic int generation_count = 0;
            $display("\nstarting randomization");
            for(integer i = 0; i < MAX_ITERATION; i++) begin
                generation_count++;
                if (!randomize()) begin
                    $display("%m: randomization failed");
                end else begin
                    process_iteration();
                end
            end
            $display("nb iterations: %d", generation_count);
            $display("randomization finished\n");
        endtask
    endclass

    class RTestOutOfRangeMin extends RTest;
        constraint value_smaller_than_min {
            value < min;
        }
    endclass

    class RTestOutOfRangeMax extends RTest;
        constraint value_bigger_than_max {
            value > max;
        }
    endclass
    
    class RTestBoundariesMin extends RTest;
        constraint boundaries {
            value == min;
        }
    endclass

    class RTestBoundariesMax extends RTest;
        constraint boundaries {
            value == max;
        }
    endclass

    // ***********************************************
    // ******************** Task *********************
    // ***********************************************

    task test_mode(logic[1:0] com);
        automatic RBase rb = new();
        automatic int generation_count = 0;
        $display("\nStarting randomization for mode %b", com);
        for (integer i = 0; i < MAX_ITERATION; i++) begin
            generation_count++;
            if (!rb.randomize()) begin
                $display("%m: randomization failed");
            end else begin
                input_itf.com = com;
                rb.process_iteration();
            end
        end
        $display("nb iterations: %d", generation_count);
        $display("Randomization finished for mode %b\n", com);
    endtask

    task test_value_equals_maximal_number();
        input_itf.min = 0;
        input_itf.max = 2**VALSIZE - 1;
        input_itf.value = 2**VALSIZE - 1;
        input_itf.com = 2'b00;
        input_itf.osci = 0;
        @(posedge(synchro));
    endtask

    task test_randomized_out_of_range_min();
        automatic RTestOutOfRangeMin rt = new();
        rt.start();
    endtask

    task test_randomized_out_of_range_max();
        automatic RTestOutOfRangeMax rt = new();
        rt.start();
    endtask

    task test_randomized_boundaries_min();
        automatic RTestBoundariesMin rt = new();
        rt.start();
    endtask

    task test_randomized_boundaries_max();
        automatic RTestBoundariesMax rt = new();
        rt.start();
    endtask

    task test_coverage();
        automatic RCoverage rt = new();
        rt.start();
    endtask

    // ***********************************************
    // ******************* Program *******************
    // ***********************************************

    task test(int TESTCASE);
        case(TESTCASE)
            0: test_coverage();
            1: test_randomized_out_of_range_min();
            2: test_randomized_out_of_range_max();
            3: test_randomized_boundaries_min();
            4: test_randomized_boundaries_max();
            5: test_mode(2'b00);
            6: test_mode(2'b01);
            7: test_mode(2'b10);
            8: test_mode(2'b11);
            9: test_value_equals_maximal_number();
            default: begin
                $display("Invalid TESTCASE: %d", TESTCASE);
                $finish;
            end
        endcase
    endtask

    task tests(int TESTCASE);
        if (TESTCASE == 0) begin
            for(integer i = 0; i < 10; i++) begin
               test(i); 
            end
        end
        else begin
            test(TESTCASE);
        end
    endtask

    task compute_reference(logic[1:0] com, input_t min, input_t max, input_t value, logic osci, output output_t leds);
        leds = {2**VALSIZE{1'b0}};
        
        case (com)
            2'b00: // Normal mode
            begin 
                if (value >= min && value <= max) begin
                    for (integer i = min; i <= value; i++) begin
                        leds[i] = 1;
                    end
                    for (integer i = value + 1; i <= max; i++) begin
                        leds[i] = osci;
                    end
                end
            end
            
            2'b01: // Linear mode
            begin
                for (integer i = 0; i <= value; i++) begin
                    leds[i] = 1;
                end
            end

            2'b10: // Test all OFF 
            begin
                // Set to 0 by default
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
                $error("%m: Error for com = %b, min = %d, max = %d, value = %d \nExpected: %b \nObserved: %b", 
                       input_itf.com, input_itf.min, input_itf.max, input_itf.value, leds_ref, output_itf.leds);
                error_signal = 1;
                #pulse;
                error_signal = 0;
            end
            @(negedge(synchro));
        end
    endtask

    initial begin
        $display("\nStarting simulation");
        fork
            tests(TESTCASE);
            compute_reference_task;
            verification;
        join_any

        if (nb_errors > 0)
            $display("Number of errors : %d", nb_errors);
        else
            $display("No errors");

        $display("Simulation finished\n");
        $finish;
    end

endmodule
