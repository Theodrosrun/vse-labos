#!/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc vhdl_compile { } {
  global Path_VHDL
  global Path_TB
  puts "\nVHDL compilation :"

  vcom -2008 -mixedsvvh $Path_VHDL/fifo.vhd
  vcom -2008 -mixedsvvh $Path_VHDL/uart.vhd
  vcom -2008 -mixedsvvh $Path_VHDL/avl_uart_interface.vhd
  vlog +acc -sv -mixedsvvh $Path_TB/avl_uart_tb.sv
}

#------------------------------------------------------------------------------
proc sim_start { testcase datasize fifosize errno} {

  vsim -assertdebug -t 1ns -GTESTCASE=$testcase -GDATASIZE=$datasize -GFIFOSIZE=$fifosize -GERRNO=$errno work.avl_uart_tb
  add wave -r *
  wave refresh
  run -all
}

#------------------------------------------------------------------------------
proc do_all { testcase datasize fifosize errno } {
  vhdl_compile
  sim_start $testcase $datasize $fifosize $errno
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_VHDL     "../src_vhd"
set Path_TB       "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>=1} {
  if {[string compare $1 "all"] == 0} {
    do_all $2 $3 $4 $5
  } elseif {[string compare $1 "comp_vhdl"] == 0} {
    vhdl_compile
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start $2 $3 $4 $5
  }

} else {
  do_all 0 20 10 0
}
