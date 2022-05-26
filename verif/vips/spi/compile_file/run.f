# UVM base library
-uvmhome $UVMHOME

# Include directory of design and verification
-incdir ../uart
#-incdir ../../../../common_peripheral_ips/spi_ip

# Package and top module to compile and simulate
#./test_pkg/hello_pkg.sv
./test_pkg/base_test_pkg.sv

# Interfaces
./interface/test_ifc.sv

# Design
../../../../common_peripheral_ips/spi_ip/rtl/spi_defines.v
../../../../common_peripheral_ips/spi_ip/rtl/spi_shift.v
../../../../common_peripheral_ips/spi_ip/rtl/spi_clgen.v
../../../../common_peripheral_ips/spi_ip/rtl/spi_core.sv

# Add top modules
./tb_top/top.sv