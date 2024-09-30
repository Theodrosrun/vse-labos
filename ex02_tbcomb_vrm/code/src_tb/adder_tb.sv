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

interface adder_in_itf;
    logic[7:0] a;
    logic[7:0] b;
    logic      carry;
endinterface

interface adder_out_itf;
    logic[7:0] result;
    logic      carry;
endinterface

module adder_tb;

    timeunit 1ns;         // Definition of the time unit
    timeprecision 1ns;    // Definition of the time precision
   
    // Reference
    logic[7:0] result_ref;
   
    // Timings definitions
    time sim_step = 10ns;
    time pulse = 0ns;
   
    logic error_signal = 0;
   
    logic synchro = 0;
   
    always #(sim_step/2) synchro = ~synchro;
   
    // Integer to keep track of the number of errors
    int nb_errors = 0;
   
    adder_in_itf input_itf();
    adder_out_itf output_itf();
   
    // DUV instantiation
    adder duv(.a_i(input_itf.a),
              .b_i(input_itf.b),
              .carryin_i(input_itf.carry),
              .result_o(output_itf.result),
              .carryout_o(output_itf.carry));


    task test_scenario0;
        for(int a = 0; a < 256; a++) begin
            for(int b = 0; b < 256; b++) begin
                input_itf.a = a;
                input_itf.b = b;
                compute_reference(input_itf.a, input_itf.b, result_ref);
                @(posedge(synchro));
            end
        end
    endtask

    task compute_reference(logic[7:0] a, logic[7:0] b, output logic[8:0] result);
        result = a + b;
    endtask

    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;
            compute_reference(input_itf.a, input_itf.b, result_ref);
        end
    endtask

    task verification;
        @(negedge(synchro));
        forever begin
            if (output_itf.result != result_ref) begin
                nb_errors ++;
                $display("Error for a_i = %d and b_i = %d. Expected: %d, Observed: %d", input_itf.a, input_itf.b, result_ref, output_itf.result);
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
            test_scenario0;
            compute_reference_task;
            verification;
        join_any

        $display("Ending simulation");
        if (nb_errors > 0)
            $display("Number of errors : %d", nb_errors);
        else
            $display("No errors");

        $finish(0);
    end

endmodule
