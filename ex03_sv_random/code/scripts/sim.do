#!/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc tb_compile { } {
  global Path_TB
  puts "\nSystemVerilog TB compilation :"

  vlog $Path_TB/test_random_tb.sv
}

#------------------------------------------------------------------------------
proc sim_start {} {

  vsim -t 1ns -voptargs=+acc work.test_random_tb
  add wave -r *
  wave refresh
  run -all
}

#------------------------------------------------------------------------------
proc do_all {} {
  tb_compile
  sim_start
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

set Path_TB       "../src_tb"

global Path_TB

# start of sequence -------------------------------------------------

do_all
