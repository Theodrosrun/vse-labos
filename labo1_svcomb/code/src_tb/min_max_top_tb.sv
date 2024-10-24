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

Context  : Testbench for min max component

********************************************************************************
Description : Testbench implementation using interface-based verification and 
             stimulus generation. The testbench includes various test scenarios
             and coverage analysis.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   07.10.2024  TMU       Initial version

*******************************************************************************/

// Interface for input signals with parameterizable size
interface min_max_in_itf#(int VALSIZE);
    logic[1:0] com;          // Command signal (operation mode)
    logic[VALSIZE-1:0] max;  // Maximum value
    logic[VALSIZE-1:0] min;  // Minimum value
    logic osci;              // Oscillation signal
    logic[VALSIZE-1:0] value;// Input value
endinterface

// Interface for output signals with parameterizable size
interface min_max_out_itf#(int VALSIZE);
    logic[2**VALSIZE-1:0] leds; // LED output array
endinterface

module min_max_top_tb#(int VALSIZE, int TESTCASE, int ERRNO);

    timeunit 1ns;         // Definition of the time unit
    timeprecision 1ns;    // Definition of the time precision
   
    // Reference output for comparison
    logic[2**VALSIZE-1:0] leds_ref;
   
    // Clock and timing definitions
    time sim_step = 10ns;
    time pulse    = 0ns;
    logic synchro = 0;
   
    // Generate clock signal
    always #(sim_step/2) synchro = ~synchro;
   
    // Instantiate interfaces
    min_max_in_itf input_itf();
    min_max_out_itf output_itf();

    // Error tracking variables
    logic error_signal = 0;
    int nb_errors     = 0;

    // Type definitions for easier handling
    typedef logic[VALSIZE-1:0] input_t;
    typedef logic[2**VALSIZE-1:0] output_t;

    // Device Under Verification (DUV) instantiation
    min_max_top#(VALSIZE, ERRNO) duv(
        .com_i(input_itf.com),
        .max_i(input_itf.max),
        .min_i(input_itf.min),
        .osc_i(input_itf.osci),
        .val_i(input_itf.value),
        .leds_o(output_itf.leds)
    );

    // Test configuration parameters
    int MAX_ITERATION = 100;  // Maximum number of iterations per test
    int NB_TESTCASE   = 10;   // Total number of test cases

    // Base class for test generation
    class Base;
        // Random variables for stimulus generation
        rand input_t min;
        rand input_t max;
        rand input_t value;
        rand logic[1:0] com;
        rand logic osci;

        // Constraint: max must be greater than min
        constraint max_bigger_than_min {
            max > min;
        }

        // Solve min before max to ensure constraints are met
        constraint s1 {
            solve min before max;
        }

        // Update interface signals with generated values
        task update_interface();
            input_itf.min   = this.min;
            input_itf.max   = this.max;
            input_itf.value = this.value;
            input_itf.com   = this.com;
            input_itf.osci  = this.osci;
        endtask

        // Process a single test iteration with clock synchronization
        task process_iteration();
            @(posedge(synchro));
            input_itf.osci = ~this.osci;

            @(posedge(synchro));
            input_itf.osci = ~this.osci;

            @(posedge(synchro));
        endtask
    endclass

    // Random test class for general test scenarios
    class RandomTest extends Base;
        // Execute random test sequence
        task execute();
            automatic int generation_count = 0;
            $display("\nstarting randomization");
            for(integer i = 0; i < MAX_ITERATION; i++) begin
                generation_count++;
                if (!randomize()) begin
                    $display("%m: randomization failed");
                end else begin
                    update_interface();
                    process_iteration();
                end
            end
            $display("nb iterations: %d", generation_count);
            $display("randomization finished\n");
        endtask

        // Execute test with fixed command mode
        task execute_with_fixed_mode(logic[1:0] com);
            this.com.rand_mode(0);  // Disable com randomization
            this.com = com;         // Set fixed com
            execute();
            this.com.rand_mode(1);  // Re-enable com randomization
        endtask
    endclass

    // Test class for values below minimum
    class OutOfRangeMin extends RandomTest;
        constraint value_smaller_than_min {
            value < min;
        }
    endclass

    // Test class for values above maximum
    class OutOfRangeMax extends RandomTest;
        constraint value_bigger_than_max {
            value > max;
        }
    endclass
    
    // Test class for boundary value at minimum
    class BoundariesMin extends RandomTest;
        constraint boundaries {
            value == min;
        }
    endclass

    // Test class for boundary value at maximum
    class BoundariesMax extends RandomTest;
        constraint boundaries {
            value == max;
        }
    endclass

    // Coverage test class for functional coverage analysis
    class CoverageTest extends Base;
        covergroup cg;
            // Coverage for minimum value
            coverpoint min {
                bins min    = {0};
                bins middle = {(2**(VALSIZE-1))};
                bins max    = {2**VALSIZE-1};
                bins values[VALSIZE] = {[1:2**VALSIZE-2]};
            }

            // Coverage for maximum value
            coverpoint max { 
                bins min    = {0};
                bins middle = {(2**(VALSIZE-1))};
                bins max    = {2**VALSIZE-1};
                bins values[VALSIZE] = {[1:2**VALSIZE-2]};
            }

            // Coverage for input value
            coverpoint value {
                bins min    = {0};
                bins middle = {(2**(VALSIZE-1))};
                bins max    = {2**VALSIZE-1};
                bins values[VALSIZE] = {[1:2**VALSIZE-2]};
            }

            // Coverage for command modes
            coverpoint com { 
                bins values[] = {0, 1, 2, 3};
            }

            // Coverage for oscillation signal
            coverpoint osci { 
                bins values = {0,1};
            }
        endgroup

        // Constructor
        function new();
            cg = new();
        endfunction

        // Execute coverage-driven test
        task execute();
            automatic int generation_count = 0;
            $display("\nstarting coverage");
            while ((cg.get_coverage() < 100) && (generation_count < MAX_ITERATION)) begin
                generation_count++;
                if (!randomize()) begin
                    $display("%m: randomization failed");
                end else begin
                    update_interface();
                    process_iteration();
                    cg.sample();
                end
            end
            $display("nb iterations: %d", generation_count);
            $display("coverage rate: %0.2f%%", cg.get_coverage());
            $display("coveraged finished\n");
        endtask
    endclass

    // Individual test tasks for different scenarios
    task test_mode_00();
        automatic RandomTest rt = new();
        rt.execute_with_fixed_mode(2'b00);
    endtask

    task test_mode_01();
        automatic RandomTest rt = new();
        rt.execute_with_fixed_mode(2'b01);
    endtask

    task test_mode_10();
        automatic RandomTest rt = new();
        rt.execute_with_fixed_mode(2'b10);
    endtask

    task test_mode_11();
        automatic RandomTest rt = new();
        rt.execute_with_fixed_mode(2'b11);
    endtask

    task test_out_of_range_min();
        automatic OutOfRangeMin rt = new();
        rt.execute();
    endtask

    task test_out_of_range_max();
        automatic OutOfRangeMax rt = new();
        rt.execute();
    endtask

    task test_boundaries_min();
        automatic BoundariesMin rt = new();
        rt.execute();
    endtask

    task test_boundaries_max();
        automatic BoundariesMax rt = new();
        rt.execute();
    endtask

    task test_coverage();
        automatic CoverageTest ct = new();
        ct.execute();
    endtask

    // Test maximum value scenario
    task test_value_equals_maximal_number();
        input_itf.min   = 0;
        input_itf.max   = 2**VALSIZE - 1;
        input_itf.value = 2**VALSIZE - 1;
        input_itf.com   = 2'b00;
        input_itf.osci  = 0;
        @(posedge(synchro));
    endtask

    // Test selection and execution
    task test(int TESTCASE);
        case(TESTCASE)
            0: test_mode_00();         // Test normal mode
            1: test_mode_01();         // Test linear mode
            2: test_mode_10();         // Test all OFF mode
            3: test_mode_11();         // Test all ON mode
            4: test_out_of_range_min();// Test values below min
            5: test_out_of_range_max();// Test values above max
            6: test_boundaries_min();   // Test minimum boundary
            7: test_boundaries_max();   // Test maximum boundary
            8: test_coverage();         // Test coverage
            9: test_value_equals_maximal_number(); // Test max value
            default: begin
                $display("Invalid TESTCASE: %d", TESTCASE);
                $finish;
            end
        endcase
    endtask

    // Execute single or all tests based on TESTCASE parameter
    task tests(int TESTCASE);
        if (TESTCASE == 0) begin
            for(integer i = 0; i < NB_TESTCASE; i++) begin
               test(i); 
            end
        end
        else begin
            test(TESTCASE);
        end
    endtask

    // Reference model computation
    task compute_reference(logic[1:0] com, input_t min, input_t max, input_t value, logic osci, output output_t leds);
        leds = {2**VALSIZE{1'b0}};
        
        case (com)
            2'b00: // Normal mode: Light LEDs up to value, oscillate between value and max
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
            
            2'b01: // Linear mode: Light all LEDs up to value
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

    // Continuous reference model computation
    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;
            compute_reference(input_itf.com, input_itf.min, input_itf.max, input_itf.value, input_itf.osci, leds_ref);
        end
    endtask

    // Output verification task
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

    // Main simulation execution
    initial begin
        $display("\nStarting simulation");
        fork
            tests(TESTCASE);                // Execute test scenarios
            compute_reference_task;         // Compute expected results
            verification;                   // Verify outputs
        join_any

        // Report results
        if (nb_errors > 0)
            $display("Number of errors : %d", nb_errors);
        else
            $display("No errors");

        $display("Simulation finished\n");
        $finish;
    end

endmodule