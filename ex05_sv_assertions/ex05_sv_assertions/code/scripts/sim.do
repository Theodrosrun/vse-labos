# !/usr/bin/tclsh

# Main proc at the end #

# Call do ../scripts/sim.do to run avalon mode 0
# Call do ../scripts/sim.do 1 to run avalon mode 1
# Call do ../scripts/sim.do 2 to run avalon mode 2
# Call do ../scripts/sim.do 3 to run avalon mode 3
# Call do ../scripts/sim.do 4 to run avalon mode 4

#------------------------------------------------------------------------------
proc compile_duv { } {
  global Path_DUV
  puts "\nVHDL DUV compilation :"

  vlog $Path_DUV/avalon_generator.sv
}


#------------------------------------------------------------------------------
proc compile_tb { AVALONMODE } {
  global Path_TB
  global Path_DUV
  puts "\nVHDL TB compilation :"

  vlog $Path_TB/avalon_assertions_$AVALONMODE.sv
  vlog $Path_TB/avalon_assertions_wrapper.sv
}


#------------------------------------------------------------------------------
proc sim_start {AVALONMODE TESTCASE} {
  # Do not forget the '-voptargs=+acc=a', which enables assertion visibility
  # (otherwise '-assertdebug' will be ignored, and the whole simulation will hang)
  vsim -voptargs=+acc=a -assertdebug -GAVALONMODE=$AVALONMODE -GTESTCASE=$TESTCASE work.avalon_assertions_wrapper
  view assertions
  # atv = Assertion Thead Viewer: graphically shows activation of an assertion
  atv log -enable /avalon_assertions_wrapper/duv/binded
  add wave -r *

  switch $AVALONMODE {
    0 {
        # Add corresponding assertions
        add wave /avalon_assertions_wrapper/duv/binded/assert_waitreq1
    }
    1 {
        # Add corresponding assertions

    }
    2 {
        # Add corresponding assertions

    }
    3 {
        # Add corresponding assertions

    }
    4 {
        # Add corresponding assertions

    }
  }
  run -all
}


#------------------------------------------------------------------------------
proc do_all {AVALONMODE TESTCASE} {
  compile_duv
  compile_tb $AVALONMODE
  sim_start $AVALONMODE $TESTCASE
}


## MAIN #######################################################################
# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_DUV    "../src"
set Path_TB     "../src_tb"

global Path_DUV
global Path_TB

# start of sequence -------------------------------------------------
if {$argc>0} {
  if {$argc>1} {
    do_all $1 $2
  } else {
    do_all $1 0
  }
} else {
  do_all 0 0
}
