/*******************************************************************************
 HEIG-VD
 Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 School of Business and Engineering in Canton de Vaud
 ********************************************************************************
 REDS Institute
 Reconfigurable Embedded Digital Systems
 ********************************************************************************

 File     : avalon_generator.sv
 Author   : Yann Thoma
 Date     : 01.11.2024

 Context  : Generation of Avalon trsnafers

 ********************************************************************************
 Description : This module can generate various avalon transfers. It is purely
               simulated, and is meant to be used to test assertions.

 ********************************************************************************
 Dependencies : -

 ********************************************************************************
 Modifications :
 Ver   Date        Person     Comments
 1.0   03.05.2018  YTA        Initial version

 *******************************************************************************/

module avalon_generator #(
                          int AVALONMODE = 0,
                          int TESTCASE = 0,
                          int NBDATABYTES = 2,
                          int NBADDRBITS = 8,
                          int WRITEDELAY = 2,  // Delay for fixed delay write operation
                          int READDELAY = 1,   // Delay for fixed delay read operation
                          int FIXEDDELAY = 2)  // Delay for pipeline operation
(
    input logic                      clk,
    input logic                      rst,

    output logic [NBADDRBITS-1:0]    address,
    output logic [NBDATABYTES:0]     byteenable,
    output logic [2^NBDATABYTES-1:0] readdata,
    output logic [2^NBDATABYTES-1:0] writedata,
    output logic                     read,
    output logic                     write,
    output logic                     waitrequest,
    output logic                     readdatavalid,
    output logic [7:0]               burstcount,
    output logic                     beginbursttransfer
);


    enum {waitreq, fixed, pipeline_variable, pipeline_fixed, burst_read, burst_write} testcase_type;

    // clocking block
    default clocking cb @(posedge clk);
    endclocking

    task test_case_waitrequest();
        for(int i=0; i < 5; i++) begin
            testcase_type = waitreq;

            address = 0;
            byteenable = 0;
            read = 0;
            write = 0;
            waitrequest = 0;
            readdata = 0;
            writedata = 0;

            ##1;

            address = 1;
            byteenable = 1;
            read = 1;
            if (i > 0)
                waitrequest = 1;
            for (int j = 0; j < i; j++)
                ##1;

            waitrequest = 0;
            readdata = 2;

            ##1;

            address = 0;
            byteenable = 0;
            read = 0;

            ##1;

            address = 1;
            byteenable = 1;
            write = 1;
            waitrequest = 1;
            writedata = 3;

            ##2;

            waitrequest = 0;

            ##1;

            address = 0;
            byteenable = 0;
            write = 0;
            waitrequest = 0;
            writedata = 0;

            ##1;

            ##10;
        end
    endtask

    task test_case_waitrequest_wrong2();
        $display("********************************************");
        $display("Expecting the detection of an error");
        $display("********************************************");
        for(int i=0; i < 5; i++) begin
            testcase_type = waitreq;

            address = 0;
            byteenable = 0;
            read = 0;
            write = 0;
            waitrequest = 0;
            readdata = 0;
            writedata = 0;

            ##1;

            address = 1;
            byteenable = 1;
            read = 1;
            if (i > 1)
                waitrequest = 1;
            for (int j = 0; j < i; j++)
                ##1;

            waitrequest = 0;
            readdata = 2;

            ##1;

            address = 0;
            byteenable = 0;
            read = 0;

            ##1;

            address = 1;
            byteenable = 1;
            write = 1;
            waitrequest = 1;
            writedata = 3;

            ##2;

            waitrequest = 0;

            ##1;

            address = 0;
            byteenable = 0;
            write = 0;
            waitrequest = 0;
            writedata = 0;

            ##1;

            ##10;
        end
        $display("********************************************");
        $display("End of : Expecting the detection of an error");
        $display("********************************************");
    endtask


    task test_case_waitrequest_wrong();
        $display("********************************************");
        $display("Expecting the detection of an error");
        $display("********************************************");
        testcase_type = waitreq;

        address = 0;
        byteenable = 0;
        read = 0;
        write = 0;
        waitrequest = 0;
        readdata = 0;
        writedata = 0;

        ##1;

        address = 1;
        byteenable = 1;
        read = 1;
        waitrequest = 1;

        ##2;

        waitrequest = 0;
        readdata = 2;

        ##1;

        address = 0;
        byteenable = 0;
        read = 0;

        ##1;

        address = 1;
        byteenable = 1;
        write = 1;
        waitrequest = 1;
        writedata = 3;

        ##3;

        address = 0;
        byteenable = 0;
        write = 0;
        waitrequest = 0;
        writedata = 0;

        ##1;

        ##10;
        $display("********************************************");
        $display("End of : Expecting the detection of an error");
        $display("********************************************");
    endtask


    task test_case_fixed();
        testcase_type = fixed;

        address = 0;
        byteenable = 0;
        read = 0;
        write = 0;
        readdata = 0;
        writedata = 0;

        ##1;

        address = 1;
        byteenable = 1;
        read = 1;

        ##1;
        ##READDELAY;

        readdata = 2;

        ##1;

        address = 0;
        byteenable = 0;
        read = 0;
        readdata = 0;

        ##1;

        address = 1;
        byteenable = 1;
        write = 1;
        writedata = 3;

        ##1;
        ##WRITEDELAY;

        address = 0;
        byteenable = 0;
        write = 0;
        writedata = 0;

        ##10;
    endtask


    task test_case_pipeline_variable();
        testcase_type = pipeline_variable;

        address = 0;
        read = 0;
        waitrequest = 0;
        readdatavalid = 0;
        readdata = 0;

        ##1;

        address = 1;
        read = 1;
        waitrequest = 0;

        ##1;

        address = 2;
        readdata = 1;
        readdatavalid = 1;

        ##1;

        address = 3;
        readdata = 2;
        waitrequest = 1;

        ##1;

        readdata=0;
        readdatavalid = 0;

        ##1;

        waitrequest = 0;

        ##1;

        address = 4;
        readdata = 3;
        readdatavalid = 1;

        ##1;

        address = 5;
        readdata = 4;

        ##1;

        address = 0;
        read = 0;
        waitrequest = 1;
        readdata = 0;
        readdatavalid = 0;

        ##2;

        readdata = 5;
        readdatavalid = 1;

        ##1;

        readdata = 0;
        readdatavalid = 0;

        ##10;
    endtask


    task test_case_pipeline_fixed();
        testcase_type = pipeline_fixed;

        address = 0;
        read = 0;
        waitrequest = 0;
        readdata = 0;

        ##1;

        address = 1;
        read = 1;
        waitrequest = 1;

        ##1;

        waitrequest = 0;

        ##1;

        read = 0;
        address = 0;
        waitrequest = 1'bz;

        ##1;

        readdata = 1;

        ##1;

        address = 2;
        read = 1;
        waitrequest = 0;
        readdata = 0;

        ##1;

        address = 3;

        ##1;

        address = 0;
        read = 0;
        waitrequest = 1'bz;
        readdata = 2;

        ##1;

        readdata = 3;

        ##1;
        readdata = 0;

        ##10;
    endtask


    task test_case_burst_read();
        testcase_type = burst_read;

        address = 0;
        read = 0;
        beginbursttransfer = 0;
        waitrequest = 0;
        burstcount = 0;
        readdatavalid = 0;
        readdata = 0;

        ##1;

        address = 1;
        read = 1;
        beginbursttransfer = 1;
        waitrequest = 1;
        burstcount = 4;
        readdatavalid = 0;

        ##1;

        beginbursttransfer = 0;
        waitrequest = 0;

        ##1;

        address = 2;
        beginbursttransfer = 1;
        waitrequest = 1;
        burstcount = 2;

        ##1;

        beginbursttransfer = 0;
        waitrequest = 0;
        readdatavalid = 1;
        readdata = 1;

        ##1;

        address = 0;
        read = 0;
        waitrequest = 1'bz;
        burstcount = 0;
        readdata = 2;

        ##1;

        readdatavalid = 0;
        readdata = 0;

        ##1;

        readdatavalid = 1;
        readdata = 3;

        ##1;

        readdata = 4;

        ##1;

        readdata = 5;

        ##1;

        readdata = 6;

        ##1;

        readdatavalid = 0;
        readdata = 0;

        ##10;
    endtask


    task test_case_burst_write();
        testcase_type = burst_write;

        address = 0;
        beginbursttransfer = 0;
        burstcount = 0;
        write = 0;
        writedata = 0;
        waitrequest = 0;

        ##1;

        address = 1;
        beginbursttransfer = 1;
        burstcount = 4;
        write = 1;
        writedata = 1;
        waitrequest = 1;

        ##1;

        beginbursttransfer = 0;
        waitrequest = 0;

        ##1;

        address = 0;
        burstcount = 0;
        writedata = 2;

        ##1;

        write = 0;
        writedata = 0;

        ##3;

        write = 1;
        writedata = 3;

        ##1;

        writedata = 4;
        waitrequest = 1;

        ##1;

        waitrequest = 0;

        ##1;

        write = 0;
        writedata = 0;
        waitrequest = 1'bz;

        ##10;
    endtask


// Programme lancé au démarrage de la simulation
program TestSuite;
    initial begin

        case (AVALONMODE)
            0: begin
                test_case_waitrequest();
                test_case_waitrequest_wrong();
                test_case_waitrequest_wrong2();
            end
            1: test_case_fixed();
            2: test_case_pipeline_variable();
            3: test_case_pipeline_fixed();
            4: begin
                test_case_burst_read();
                test_case_burst_write();
            end
        endcase // case (AVALONMODE)

        $display("done!");

        $stop;

    end
endprogram

endmodule
