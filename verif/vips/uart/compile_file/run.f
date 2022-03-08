# UVM base library
-uvmhome $UVMHOME

# Include directory of design and verification
-incdir ../uart
#-incdir ../../../../common_peripheral_ips/Timer_ip/rtl/ip

# Package and top module to compile and simulate
#./test_pkg/hello_pkg.sv
./test_pkg/base_test_pkg.sv

# Interfaces
./interface/test_ifc.sv

# Design
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/rv_timer_reg_pkg.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/prim_subreg_arb.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/prim_subreg.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/prim_subreg_ext.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/rv_timer_reg_top.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/prim_intr_hw.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/timer_core.sv
#../../../../common_peripheral_ips/Timer_ip/rtl/ip/rv_timer.sv

# Add top modules
./tb_top/top.sv