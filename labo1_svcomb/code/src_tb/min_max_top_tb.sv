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
    logic synchro = 0;
   
    always #(sim_step/2) synchro = ~synchro;
   
    // Interfaces
    min_max_in_itf input_itf();
    min_max_out_itf output_itf();

    // Erros values
    logic error_signal = 0;
    int nb_errors = 0;

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
    // ************** Randomized class ***************
    // ***********************************************
    class RTest;
        rand logic[1:0] com;
        rand input_t max;
        rand input_t min;
        rand logic osci;
        rand input_t value;

        constraint c_min_max {
            max > min;
        }

        covergroup cg;
            coverpoint com { 
                bins values[] = {0, 1, 2, 3}; 
            }
            coverpoint max { 
                bins low = {[0:5]};
                bins high = {[6:2**VALSIZE-1]}; 
            }
            coverpoint min { 
                bins low = {[0:5]}; 
                bins high = {[6:2**VALSIZE-1]}; 
            }
            coverpoint osci { 
                bins values[] = {0, 1}; 
            }
            coverpoint value { 
                bins low = {[0:5]};
                bins mid = {[6:10]};
                bins high = {[11:2**VALSIZE-1]}; 
            }
            cross com, max, min, osci, value;
        endgroup

        function new();
            cg = new();
        endfunction

        function void sample_coverage();
            cg.sample();
        endfunction

        task validate_constraints();
            assert (com inside {0, 1, 2, 3}) else $error("com out of bounds");
            assert (osci inside {0, 1}) else $error("osci out of bounds");
            assert (max > min) else $error("max should be greater than min");
            if (value < min || value > max) $error("value out of range: %0d is not between %0d and %0d", value, min, max);
        endtask
    endclass

    task test_scenario_randomized();
        automatic RTest rt = new();
        int generation_count = 0;

        while (rt.cg.get_coverage() < 100) begin
            generation_count++;

            if (!rt.randomize()) begin
                $error("Randomization failed");
            end else begin
                rt.validate_constraints();
                input_itf.com = rt.com;
                input_itf.max = rt.max;
                input_itf.min = rt.min;
                input_itf.osci = rt.osci;
                input_itf.value = rt.value;
                @(posedge(synchro));

                rt.sample_coverage();
                $display("Coverage rate: %0.2f%%", rt.cg.get_coverage());
            end
        end

        $display("Number of generations to reach 100%% : %d", generation_count);
    endtask

    // ***********************************************
    // ***************** Normal mode *****************
    // ***********************************************

    // Basic value
    task test_scenario0;
        input_itf.min = 3;
        input_itf.max = 12;
        input_itf.value = 8;
        input_itf.com = 2'b00;
        input_itf.osci = 1;
        @(posedge(synchro));
    endtask

    // Random values
    task test_scenario1;
        input_itf.min = $urandom_range(0, 2**VALSIZE - 2);
        input_itf.max = $urandom_range(input_itf.min + 1, 2**VALSIZE - 1);
        input_itf.value = $urandom_range(input_itf.min, input_itf.max);
        input_itf.com = 2'b00;
        input_itf.osci = $urandom_range(0, 1);
        @(posedge(synchro));
    endtask

    // Large values
    task test_scenario2;
        input_itf.min = 100;
        input_itf.max = 1000;
        input_itf.value = 500;
        input_itf.com = 2'b00;
        input_itf.osci = 1;
        @(posedge(synchro));
    endtask

    // Boundaries
    task test_scenario3;
        input_itf.min = 0;
        input_itf.max = 2**VALSIZE - 1;
        input_itf.value = 2**VALSIZE - 1;
        input_itf.com = 2'b00;
        input_itf.osci = 0;
        @(posedge(synchro));
    endtask

    // Value smaller than min and bigger than max
    task test_scenario4;
        input_itf.min = 5;
        input_itf.max = 10;
        input_itf.value = 4;
        input_itf.com = 2'b00;
        input_itf.osci = 0;
        @(posedge(synchro));

        assert (output_itf.leds == 0) else $error("All LEDs should be off, value is smaller than min");
        input_itf.value = 11; 
        @(posedge(synchro));

        assert (output_itf.leds == 0) else $error("All LEDs should be off, value is bigger than max");
    endtask

    // ***********************************************
    // ******************** Mode *********************
    // ***********************************************

    // ***********************************************
    // ******************** Osci *********************
    // ***********************************************

    task test_scenario5;
        input_itf.min = 5;
        input_itf.max = 10;
        input_itf.value = 7;
        input_itf.com = 2'b00;
        input_itf.osci = 1'b0;
        @(posedge(synchro));

        assert (output_itf.leds[10:8] == 3'b000) else $error("LEDs should be off");
        input_itf.osci = 1'b1;  
        @(posedge(synchro));

        assert (output_itf.leds[10:8] == 3'b111) else $error("LEDs should be on with low intensity");
        input_itf.osci = 1'b0;
        @(posedge(synchro));

        assert (output_itf.leds[10:8] == 3'b000) else $error("LEDs should be off again");
    endtask

    // ***********************************************
    // ******************** ERRNO ********************
    // ***********************************************

    // Utiliser une validation des contraites pour la randomisation comme lexo2

    // ***********************************************
    // ******************* Program *******************
    // ***********************************************

    task test_scenarios(int TESTCASE);
        if (TESTCASE == 0) begin
            $display("Running all test scenarios...");
            test_scenario0();
            test_scenario1();
            test_scenario2();
            test_scenario3();
            test_scenario4();
            test_scenario5();
        end
        else begin
            case(TESTCASE)
                1: test_scenario1();
                2: test_scenario2();
                3: test_scenario3();
                4: test_scenario4();
                5: test_scenario5();
                default: begin
                    $display("Invalid TESTCASE: %d", TESTCASE);
                    $finish;
                end
            endcase
        end
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
                else if (value < min || value > max) begin
                    leds = 0;
                end
                else begin
                    // Do nothing
                end
            end
            
            2'b01: // Linear mode
            begin
                for (i = 0; i <= value; i++) begin // TODO - Set the rest to 0?
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