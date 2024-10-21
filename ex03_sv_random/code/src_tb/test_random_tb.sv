/****************************************************************************** 
Project Math_computer

File : test_random_tb.sv 
Description : This module is meant to test some random constructs. 
              Improved for better coverage and efficiency.

Author : Y. Thoma 
Team   : REDS institute 

Date   : 07.11.2022

| Modifications |-------------------------------------------------------------- 
Ver    Date         Who    Description 
1.0    07.11.2022   YTA    First version 
1.1    16.10.2024   GPT    Improved coverage and constraints handling

******************************************************************************/ 

module test_random_tb;

    logic clk = 0;
    logic [15:0] a, b, c;
    logic [1:0]  m;

    // Clock generation 
    always #5 clk = ~clk;

    // Clocking block 
    default clocking cb @(posedge clk);
    endclocking

class RTest;
    rand bit [15:0] a;
    rand bit [15:0] b;
    rand bit [15:0] c;
    rand bit [1:0]  m;

    covergroup cg;
        coverpoint a {
            bins low_a = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
            bins mid_a = {[10:255]};
            bins high_a = {[256:65535]};
            option.at_least = 3;
        }

        coverpoint b {
            bins low_b = {[0:11]};
            bins mid_b = {[12:16]};
            bins high_b = {[17:65535]};
            option.at_least = 3;
        }

        coverpoint c {
            bins low_c = {[0:32767]};
            bins high_c = {[32768:65535]};
            bins greater_than_ab = {[0:65535]};
            option.at_least = 3;
        }

        coverpoint m {
            bins m_values[] = {0, 1, 2};
            option.at_least = 3;
        }

        cross a, b, m;
    endgroup

    function new();
        cg = new();
    endfunction

    function void sample_coverage();
        cg.sample();
    endfunction

    constraint m_constraint {
        m inside {[0:2]};
    }

    constraint a_constraint {
        if (m == 0)
            a < 10;
    }

    constraint b_constraint {
        if (m == 1)
            b inside {[12:16]};
    }

    constraint c_constraint {
        c > a + b;
    }

endclass

    task validate_constraints(RTest rt);
        assert (rt.m inside {0, 1, 2}) else $error("m out of bounds");
        if (rt.m == 0) assert (rt.a < 10) else $error("a constraint violated when m == 0");
        if (rt.m == 1) assert (rt.b inside {[12:16]}) else $error("b constraint violated when m == 1");
        assert (rt.c > rt.a + rt.b) else $error("c constraint violated");
    endtask

    task test_case0();
        automatic RTest rt = new();
        int generation_count = 0;

        while (rt.cg.get_coverage() < 100) begin
            generation_count++;

            if (!rt.randomize()) begin
                $error("Randomization failed");
            end else begin
                validate_constraints(rt); 
                rt.sample_coverage();
                $display("Taux de couverture : %0.2f%%", rt.cg.get_coverage());
            end

            a = rt.a;
            b = rt.b;
            c = rt.c;
            m = rt.m;

            ##1;
        end

        $display("Nombre de générations pour atteindre 98%% : %d", generation_count);
        $display("Couverture atteinte à 98%% : %0.2f%%", rt.cg.get_coverage());
    endtask

    program TestSuite;
        initial begin
            test_case0();
            $stop;
        end
    endprogram

endmodule
