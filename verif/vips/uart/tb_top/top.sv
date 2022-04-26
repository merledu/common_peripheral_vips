///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    02-MARCH-2022                                                                     //
// Design Name:    UART                                                                              //
// Module Name:    top.sv                                                                            //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//            - The creation of class hierarchy in a system verilog testbench has to be initiated    //
//              from a top module.                                                                   //
//            - Since a module is static object that is present at beginning of simulation.          //
//            - Top module connects the testbench and DUT via interface                              //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

module top;
  // timeunit 1ns; timeprecision 1ns;

	// Import uvm_package and package for specific protocol that you want to add to the testbench like usb protocol that contain USB uvm objects
	import uvm_pkg::*;      		 // For using uvm libraries
	import base_test_pkg::*;
	
	`include "uvm_macros.svh"    // To make use of macros that are found in uvm libraries
	
  // Signal declaration
	bit clk;
	// Clock generation
	always #(`CLOCK_PERIOD/2) clk <= ~clk;
	int frequency = 1/(`CLOCK_PERIOD * 0.000000001);

	// Interface instance
	// TX
	test_ifc test_ifc_tx (
		.clk_i(clk)
	);
  
  // RX
	test_ifc test_ifc_rx (
		.clk_i(clk)
	);
    
  // UART TX instance
	uart_core uart_inst_tx (
		.clk_i          (clk                        ),
		.rst_ni         (test_ifc_tx.rst_ni         ),
		.reg_wdata      (test_ifc_tx.reg_wdata      ),
		.reg_addr       (test_ifc_tx.reg_addr       ),
		.reg_we         (test_ifc_tx.reg_we         ),
		.reg_re         (test_ifc_tx.reg_re         ),
		.rx_i           (test_ifc_tx.rx_i           ),
		.reg_rdata      (test_ifc_tx.reg_rdata      ),
		.tx_o           (test_ifc_tx.tx_o           ),
		.intr_tx        (test_ifc_tx.intr_tx        ),
		.intr_rx        (test_ifc_tx.intr_rx        ),
		.intr_tx_level  (test_ifc_tx.intr_tx_level  ),
		.intr_rx_timeout(test_ifc_tx.intr_rx_timeout),
		.intr_tx_full   (test_ifc_tx.intr_tx_full   ),
		.intr_tx_empty  (test_ifc_tx.intr_tx_empty  ),
		.intr_rx_full   (test_ifc_tx.intr_rx_full   ),
		.intr_rx_empty  (test_ifc_tx.intr_rx_empty  )
	);

	  // UART TX instance
	uart_core uart_inst_rx (
		.clk_i          (clk                        ),
		.rst_ni         (test_ifc_rx.rst_ni         ),
		.reg_wdata      (test_ifc_rx.reg_wdata      ),
		.reg_addr       (test_ifc_rx.reg_addr       ),
		.reg_we         (test_ifc_rx.reg_we         ),
		.reg_re         (test_ifc_rx.reg_re         ),
		.rx_i           (test_ifc_tx.tx_o           ),
		.reg_rdata      (test_ifc_rx.reg_rdata      ),
		.tx_o           (test_ifc_rx.tx_o           ),
		.intr_tx        (test_ifc_rx.intr_tx        ),
		.intr_rx        (test_ifc_rx.intr_rx        ),
		.intr_tx_level  (test_ifc_rx.intr_tx_level  ),
		.intr_rx_timeout(test_ifc_rx.intr_rx_timeout),
		.intr_tx_full   (test_ifc_rx.intr_tx_full   ),
		.intr_tx_empty  (test_ifc_rx.intr_tx_empty  ),
		.intr_rx_full   (test_ifc_rx.intr_rx_full   ),
		.intr_rx_empty  (test_ifc_rx.intr_rx_empty  )
	);

	// Also a top level module contains an initial block which contain a call to the uvm run_test method
	// At time 0, the run_test creates the uvm_root object
	//   - This fetches the test class name from the command line
	//   - Creates the test object
	//   - And then start the phases to run the test 
	// In general run_test method starts the execution of the uvm phases which controls the order in which the components are build
	// Test is run and simulation report are generated
  // run_test instantiates the test components(tx_test components) and starts execution of phases which will cause the test to run and print 
  // the informational message
	
	initial begin
		// Pass virtual interface test_ifc_tx in uvm_test_top
	  uvm_config_db#(virtual test_ifc/*data_type*/)::set(null/*Handle to the uvm_componemt that is calling the uvm_db*/, "uvm_test_top"/*relative path where you are writting or get this*/, "test_ifc_tx"/*interface name*/, test_ifc_tx/*Interface handle*/);
	  uvm_config_db#(virtual test_ifc)::set(null, "uvm_test_top", "test_ifc_rx", test_ifc_rx);
    $display("Value of clock_period = %0d, Value of frequency = %0d", `CLOCK_PERIOD, frequency);
		run_test();
	end
endmodule // top