/******************************************************************************
 * (C) Copyright 2020 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * MODULE:      BLOG
 * PROJECT:     Non-blocking socket communication in SV using DPI-C
 * Description: This is a code snippet from the Blog article mentioned on PROJECT
 * Link:
 *******************************************************************************/
import amiq_sv_c_python_pkg::*;

module amiq_top #(
    int ERRNO = 0
);

  typedef enum logic {
    ACQUISITION_IDLE,
    ACQUISITION_ACTIVE
  } acquisition_state_t;

  logic avl_clk_i = 0;
  logic avl_reset_i;
  logic [13:0] avl_address_i;
  logic [3:0] avl_byteenable_i;
  logic avl_write_i;
  logic [15:0] avl_writedata_i;
  logic avl_read_i;
  logic avl_readdatavalid_o;
  logic [15:0] avl_readdata_o;
  logic avl_waitrequest_o;
  logic avl_irq_o;

  string input_file_name;
  logic [15:0] sample_i;
  logic sample_valid_i;
  acquisition_state_t acq_state;

  event start_record;
  event input_file_setted;

  default clocking cb @(posedge avl_clk_i);
  endclocking

  always #5 avl_clk_i = ~avl_clk_i;

  spike_detection_avalon #(ERRNO) duv (.*);

  task avalon_write(int address, int data);
    $display("%t Starting a write command", $time);
    avl_address_i = address;
    avl_writedata_i = data;
    avl_write_i = 1;
    avl_read_i = 0;

    @(negedge avl_clk_i);
    while (avl_waitrequest_o) begin
      @(negedge avl_clk_i);
    end

    if (address == 1) begin
      if (data == 0) begin
        $display("%t Stopping acquisition", $time);
        acq_state = ACQUISITION_IDLE;
      end else if (data == 1) begin
        $display("%t Starting acquisition", $time);
        acq_state = ACQUISITION_ACTIVE;
        ->start_record;
      end
    end

    @(posedge avl_clk_i);
    avl_write_i = 0;
    @(posedge avl_clk_i);
  endtask

  task avalon_read(int address, output int data);
    $display("%t Starting a read command", $time);
    avl_address_i = address;
    avl_read_i = 1;
    avl_write_i = 0;
    avl_writedata_i = 0;
    @(posedge avl_clk_i);

    avl_read_i = 0;
    @(negedge avl_clk_i);
    if (!avl_readdatavalid_o) begin
      $display("%t [AVL Driver] Read datavalid is down", $time);
    end

    data = avl_readdata_o;
    @(posedge avl_clk_i);
  endtask

  task init_signals();
    avl_write_i = 0;
    avl_read_i = 0;
    avl_address_i = 0;
    avl_byteenable_i = 'hf;
    avl_writedata_i = 0;

    sample_i = 0;
    sample_valid_i = 0;
    acq_state = ACQUISITION_IDLE;
    @(negedge avl_clk_i);
  endtask

  task apply_reset();
    avl_reset_i = 1;
    #20;
    avl_reset_i = 0;
  endtask


  initial begin
    fork
      init_signals();
      apply_reset();
    join

    @(negedge avl_clk_i);
    @(negedge avl_clk_i);
  end

  amiq_server_connector #(
      .hostname("127.0.0.1"),
      .port(8888),
      .delim("\n")
  ) client = new();

  initial begin
    // Format to print time (%t) in nanosecond, with " ns" suffix.
    // This allows to click on log in QuestaSim to go to see it in the wave
    $timeformat(-9, 0, " ns", 15);

    @(posedge avl_clk_i);
    if (avl_reset_i == 1) @(negedge avl_reset_i);

    @(posedge avl_clk_i);

    fork
      // Connect to server and start communication threads
      begin
        client.start();
      end


      // Recv thread:
      //      Collecting received items through the connector's recv mailbox
      begin
        string recv_msg;
        int ret;

        forever begin
          client.recv_mbox.get(recv_msg);
          $display("%t Received item: %s", $time, recv_msg);

          // End of test mechanism:
          // recognizing the end of test item as a received item
          if (recv_msg == "end_test") begin
            $display("End of test");
            set_run_finish();
            $finish();
          end

          begin
            automatic string command = "";

            if (recv_msg.len() < 2) begin
              continue;
            end

            ret = $sscanf(recv_msg, "%s", command);

            if (command == "wr") begin
              automatic int addr;
              automatic int val;

              ret = $sscanf(recv_msg, "wr %d %d", addr, val);
              avalon_write(addr, val);
            end else if (command == "rd") begin
              automatic int addr;
              automatic int result;

              ret = $sscanf(recv_msg, "rd %d", addr);
              avalon_read(addr, result);

              client.send_mbox.put($sformatf("rd %0d", result));
              $display("%t Read result: %0d", $time, result);
            end else if (command == "file_set") begin
              automatic string file_name;
              ret = $sscanf(recv_msg, "file_set %s", file_name);
              input_file_name = file_name;
              ->input_file_setted;
            end else begin
              $error("%t Command unknown: %s", $time, recv_msg);
            end
          end
        end
      end

      begin
        forever begin
          // Wait for an IRQ, and then notify the software
          @(posedge avl_irq_o);

          client.send_mbox.put("irq");
        end
      end

      begin
        int fd;
        int val;
        int ret;

        @(input_file_setted);
        fd = $fopen(input_file_name, "r");
        if (!fd) $fatal("Input file not opened successfully");

        // Wait until the acquisition has started
        @(start_record);

        while (!$feof(
            fd
        )) begin
          ret = $fscanf(fd, "%d", val);
          if (acq_state == ACQUISITION_IDLE) begin
            $display("%t Acquisition Stopped. Waiting...", $time);
            wait (start_record.triggered);
            $display("%t Acquisition Restarted", $time);
          end
          @(posedge avl_clk_i);
          sample_i = val;
          sample_valid_i = 1;
          @(posedge avl_clk_i);
          sample_valid_i = 0;
          @(posedge avl_clk_i);
        end

        $fclose(fd);
      end
    join
  end

endmodule
