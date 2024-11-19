proc check_sva { } {

  vlog -sv ../src_tb/avl_uart_interface_assertions.sv ../src_tb/avl_uart_interface_wrapper.sv

  vcom -2008 -mixedsvvh ../src_vhd/fifo.vhd
  vcom -2008 -mixedsvvh ../src_vhd/uart.vhd
  vcom -2008 -mixedsvvh ../src_vhd/avl_uart_interface.vhd

  formal compile -d avl_uart_interface_wrapper -G DATASIZE=20 -G FIFOSIZE=2 -work work

  formal verify
}


check_sva