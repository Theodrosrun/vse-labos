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
    // ******************** Params *******************
    // ***********************************************

    int TARGET_COVERAGE_PERCENT = 93;

    // ***********************************************
    // ******************** class ********************
    // ***********************************************
    class RTest;
        rand logic[1:0] com;
        rand input_t max;
        rand input_t min;
        rand logic osci;
        rand input_t value;

        constraint max_bigger_than_min {
            max > min;
        }

        covergroup cg;
            coverpoint com { 
                bins values[] = {0, 1, 2, 3}; 
            }

            coverpoint max { 
                bins values[VALSIZE] = {[0:2**VALSIZE-1]};
            }

            coverpoint min { 
                bins values[VALSIZE] = {[0:2**VALSIZE-1]};
            }

            coverpoint osci { 
                bins values = {0,1};
            }

            coverpoint value { 
                bins values[VALSIZE] = {[0:2**VALSIZE-1]};
            }
            
            cross com, max, min, osci, value;
        endgroup

        function new();
            cg = new();
        endfunction

        function void sample_coverage();
            cg.sample();
        endfunction

        virtual function void validate_constraints();
            assert (com inside {0, 1, 2, 3}) else $error("%m: com out of bounds");
            assert (max > min) else $error("%m: max should be greater than min");
            assert (osci inside {0, 1}) else $error("%m: osci out of bounds");
            return;
        endfunction

        task test_scenario_generic();
            automatic int generation_count = 0;

            while (this.cg.get_coverage() < TARGET_COVERAGE_PERCENT) begin
                generation_count++;
                if (!this.randomize()) begin
                    $error("%m: Randomization failed");
                end else begin
                    this.validate_constraints();
                    input_itf.com = this.com;
                    input_itf.max = this.max;
                    input_itf.min = this.min;
                    input_itf.osci = this.osci;
                    input_itf.value = this.value;
                    @(posedge(synchro));

                    this.sample_coverage();
                    $display("Coverage rate: %0.2f%%", this.cg.get_coverage());
                end
            end

        endtask
    endclass

    class RTestOutOfRangeMin extends RTest;
        constraint value_smaller_than_min {
            value < min;
        }

        virtual function void validate_constraints();
            super.validate_constraints();
            assert (value < min) else $error("%m: value should be smaller than min");
        endfunction
    endclass

    class RTestOutOfRangeMax extends RTest;
        constraint value_bigger_than_max {
            value > max;
        }

        virtual function void validate_constraints();
            super.validate_constraints();
            assert (value > max) else $error("%m: value should be bigger than max");
        endfunction
    endclass
    
    class RTestBoundariesMin extends RTest;
        constraint boundaries {
            value == min;
        }

        virtual function void validate_constraints();
            super.validate_constraints();
            assert (value == min) else $error("%m: value should be equal to min");
        endfunction
    endclass

    class RTestBoundariesMax extends RTest;
        constraint boundaries {
            value == max;
        }

        virtual function void validate_constraints();
            super.validate_constraints();
            assert (value == max) else $error("%m: value should be equal to max");
        endfunction
    endclass

    task test_scenario_randomized();
        automatic RTest rt = new();
        rt.test_scenario_generic();
    endtask

    task test_scenario_randomized_out_of_range_min();
        automatic RTestOutOfRangeMin rt = new();
        rt.test_scenario_generic();
    endtask

    task test_scenario_randomized_out_of_range_max();
        automatic RTestOutOfRangeMax rt = new();
        rt.test_scenario_generic();
    endtask

    task test_scenario_randomized_boundaries_min();
        automatic RTestBoundariesMin rt = new();
        rt.test_scenario_generic();
    endtask

    task test_scenario_randomized_boundaries_max();
        automatic RTestBoundariesMax rt = new();
        rt.test_scenario_generic();
    endtask

    // ***********************************************
    // ***************** Normal mode *****************
    // ***********************************************

    // Value equals max
    task test_scenario3;
        input_itf.min = 0;
        input_itf.max = 2**VALSIZE - 1;
        input_itf.value = 2**VALSIZE - 1;
        input_itf.com = 2'b00;
        input_itf.osci = 0;
        @(posedge(synchro));
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

        assert (output_itf.leds[10:8] == 3'b000) else $error("%m: LEDs should be off");
        input_itf.osci = 1'b1;  
        @(posedge(synchro));

        assert (output_itf.leds[10:8] == 3'b111) else $error("%m: LEDs should be on with low intensity");
        input_itf.osci = 1'b0;
        @(posedge(synchro));

        assert (output_itf.leds[10:8] == 3'b000) else $error("%m: LEDs should be off again");
    endtask

    // ***********************************************
    // ******************* Program *******************
    // ***********************************************

    task test_scenarios(int TESTCASE);
        if (TESTCASE == 0) begin
            $display("Running all test scenarios...");
            test_scenario_randomized();
            test_scenario_randomized_out_of_range_min();
            test_scenario_randomized_out_of_range_max();
            test_scenario_randomized_boundaries_min();
            test_scenario_randomized_boundaries_max();
            test_scenario3();
            test_scenario5();
        end
        else begin
            case(TESTCASE)
                1: test_scenario_randomized();
                2: test_scenario_randomized_out_of_range_min();
                3: test_scenario_randomized_out_of_range_max();
                4: test_scenario_randomized_boundaries_min();
                5: test_scenario_randomized_boundaries_max();
                6: test_scenario3();
                7: test_scenario5();
                default: begin
                    $error("Invalid TESTCASE: %d", TESTCASE);
                    $finish;
                end
            endcase
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
                // Set to by default
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
            test_scenarios(TESTCASE);
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
