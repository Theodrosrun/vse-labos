/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Engineering and Management Vaud
********************************************************************************
REDS Institute
Reconfigurable and Embedded Digital Systems
********************************************************************************

File     : adder_tb.sv
Author   : Yann Thoma
Date     : 20.09.2024

Context  : Code example for an adder testbench

********************************************************************************
Description : This testbench illustrates the decomposition into stimuli
              generation and verification, with the use of interfaces.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.09.2024  YTA        Initial version

*******************************************************************************/

interface adder_in_itf #(int DATASIZE = 8);
    logic[DATASIZE-1:0] a;
    logic[DATASIZE-1:0] b;
    logic               carry;
endinterface

interface adder_out_itf #(int DATASIZE = 8);
    logic[DATASIZE-1:0] result;
    logic               carry;
endinterface

module adder_tb #(int DATASIZE = 8, int TESTCASE = 0);

    timeunit 1ns;         
    timeprecision 1ns;    

    logic[DATASIZE-1:0] result_ref;  

    time sim_step = 10ns;
    time pulse = 0ns;

    logic error_signal = 0;
    logic synchro = 0;

    always #(sim_step/2) synchro = ~synchro;

    int nb_errors = 0;

    adder_in_itf #(DATASIZE) input_itf();
    adder_out_itf #(DATASIZE) output_itf();
   
    // DUV instantiation
    adder #(.SIZE(DATASIZE))  // Mapping the SIZE parameter with DATASIZE
    duv (
        .a_i(input_itf.a),
        .b_i(input_itf.b),
        .carryin_i(input_itf.carry),
        .result_o(output_itf.result),
        .carryout_o(output_itf.carry)
    );

    // Test Scenario 0: Test Min and Max
    task test_scenario0;
        // Min
        input_itf.a = 0;
        input_itf.b = 0;
        compute_reference(input_itf.a, input_itf.b, result_ref);
        @(posedge(synchro));

        // Max
        input_itf.a = 2**DATASIZE - 1;
        input_itf.b = 2**DATASIZE - 1;
        compute_reference(input_itf.a, input_itf.b, result_ref);
        @(posedge(synchro));
    endtask

    // Test Scenario 1: Test 5000 random values
    task test_scenario1;
        for (int i = 0; i < 5000; i++) begin
            input_itf.a = $urandom_range(0, 2**DATASIZE - 1);
            input_itf.b = $urandom_range(0, 2**DATASIZE - 1);
            compute_reference(input_itf.a, input_itf.b, result_ref);
            @(posedge(synchro));
        end
    endtask

    // Test Scenario 2: Test values around half the data range
    task test_scenario2;
        input_itf.a = 2**(DATASIZE-1) - 1; // Half of the range minus 1
        input_itf.b = 2**(DATASIZE-1);     // Exactly half of the range
        compute_reference(input_itf.a, input_itf.b, result_ref);
        @(posedge(synchro));

        input_itf.a = 2**(DATASIZE-1);     // Exactly half of the range
        input_itf.b = 2**(DATASIZE-1) + 1; // Half of the range plus 1
        compute_reference(input_itf.a, input_itf.b, result_ref);
        @(posedge(synchro));
    endtask

    // Test Scenario 3: Test powers of two
    task test_scenario3;
        for (int i = 0; i < DATASIZE; i++) begin
            input_itf.a = 2**i; // Power of two for a
            input_itf.b = 2**i; // Power of two for b
            compute_reference(input_itf.a, input_itf.b, result_ref);
            @(posedge(synchro));
        end

        // Additional test with a power of two and a random value
        for (int i = 0; i < 5; i++) begin
            input_itf.a = 2**$urandom_range(0, DATASIZE-1); // Random power of two for a
            input_itf.b = $urandom_range(0, 2**DATASIZE - 1); // Random value for b
            compute_reference(input_itf.a, input_itf.b, result_ref);
            @(posedge(synchro));
        end
    endtask

    task compute_reference(logic[DATASIZE-1:0] a, logic[DATASIZE-1:0] b, output logic[DATASIZE:0] result);
        result = a + b;  // Calculate the reference result
    endtask

    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;  // Minimal delay for synchronization
        end
    endtask

    task verification;
        @(negedge(synchro));
        forever begin
            if (output_itf.result != result_ref) begin
                nb_errors++;
                $display("Error for a = %d and b = %d. Expected: %d, Observed: %d", input_itf.a, input_itf.b, result_ref, output_itf.result);
                error_signal = 1;
                #pulse;
                error_signal = 0;
            end
            @(negedge(synchro));
        end
    endtask

    initial begin
        $display("Starting simulation with DATASIZE = %d and TESTCASE = %d", DATASIZE, TESTCASE);
        fork
            case(TESTCASE)
                0: test_scenario0();  // Run the min and max test
                1: test_scenario1();  // Run the random value test
                2: test_scenario2();  // Run the half-range test
                3: test_scenario3();  // Run the powers of two test
                default: begin
                    $display("Invalid TESTCASE: %d", TESTCASE);
                    $finish;
                end
            endcase

            compute_reference_task;  // Continuously compute the reference result
            verification;  // Run the verification task
        join_any

        $display("Ending simulation");
        if (nb_errors > 0)
            $display("Number of errors : %d", nb_errors);
        else
            $display("No errors");

        $finish(0);
    end

endmodule
