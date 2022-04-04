# UVM base library
-uvmhome $UVMHOME

# Include directory of design and verification
-incdir ../uart
-incdir ../../../../common_peripheral_ips/Uart_ip/rtl

# Package and top module to compile and simulate
#./test_pkg/hello_pkg.sv
./test_pkg/base_test_pkg.sv

# Interfaces
./interface/test_ifc.sv

# Design
../../../../common_peripheral_ips/Uart_ip/rtl/uart_tx.sv
../../../../common_peripheral_ips/Uart_ip/rtl/uart_rx.sv
../../../../common_peripheral_ips/Uart_ip/rtl/uart_fifo_tx.sv
../../../../common_peripheral_ips/Uart_ip/rtl/uart_fifo_rx.sv
../../../../common_peripheral_ips/Uart_ip/rtl/timer_rx.sv
../../../../common_peripheral_ips/Uart_ip/rtl/uart_core.sv

# Add top modules
./tb_top/top.sv


