/******************************************************************************
Project Math_computer

File : test_random_tb.sv
Description : This module is meant to test some random constructs.
              Currently it is far from being efficient nor useful.

Author : Y. Thoma
Team   : REDS institute

Date   : 07.11.2022

| Modifications |--------------------------------------------------------------
Ver    Date         Who    Description
1.0    07.11.2022   YTA    First version

******************************************************************************/

module test_random_tb;

    logic clk = 0;

    logic[15:0] a;
    logic[15:0] b;
    logic[15:0] c;
    logic[1:0]  m;

    // clock generation
    always #5 clk = ~clk;

    // clocking block
    default clocking cb @(posedge clk);
    endclocking


    class RTest;

    endclass


    task test_case0();

        a = 0;
        b = 0;
        c = 0;
        m = 0;

        // Create the object


        ##1;

        repeat (10) begin
            // Randomize the object

            // Apply its values to the signals (for nice view in the chronogram)
            ##1;
        end
    endtask



    // Program launched at simulation start
    program TestSuite;
        initial begin
            test_case0();
            $stop;
        end

    endprogram

endmodule
