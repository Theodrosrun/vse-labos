#!/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc duv_compile { } {
  global Path_DUV
  puts "\nDUV compilation :"

  vcom $Path_DUV/adder.vhd
}

proc tb_compile {} {
  global Path_TB

  vlog -sv $Path_TB/adder_tb.sv
}

#------------------------------------------------------------------------------
proc sim_start {DATASIZE TESTCASE} {
  puts "\nStart simulation :"
  vsim -t 1ns -GDATASIZE=$DATASIZE -GTESTCASE=$TESTCASE work.adder_tb
  #add wave -r *
  #wave refresh
  run -all
}

#------------------------------------------------------------------------------
proc do_all {DATASIZE TESTCASE} {
  duv_compile
  tb_compile
  sim_start $DATASIZE $TESTCASE
}

#------------------------------------------------------------------------------
proc help { } {
    puts "Call this script with one of the following options:"
    puts "    all         : compiles and run, with 2 arguments (see below)"
    puts "    comp_duv    : compiles all the DUV files"
    puts "    comp_tb     : compiles all the testbench files"
    puts "    sim         : starts a simulation, with 5 arguments (see below)"
    puts "    help        : prints this help"
    puts "    no argument : compiles and run with DATASIZE=8 TESTCASE=0"
    puts ""
    puts "When 2 arguments are required, the order is:"
    puts "    1: DATASIZE, the size of data"
    puts "    2: The test to run, 0 -> run all the tests"
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  mkdir work
  vlib work
  vmap work work
}

quietly set Path_DUV     "../src_vhdl"
quietly set Path_TB      "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all $2 $3
  } elseif {[string compare $1 "comp_duv"] == 0} {
    duv_compile
  } elseif {[string compare $1 "comp_tb"] == 0} {
    tb_compile
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start $2 $3
  } elseif {[string compare $1 "help"] == 0} {
    help
  }
} else {
  do_all 8 0
}
