///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    06-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
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
	import hello_pkg::*;
	import base_test_pkg::*;
	
	`include "uvm_macros.svh"    // To make use of macros that are found in uvm libraries
	
  // Signal declaration
	bit clk;
	// Clock generation
	always #50 clk <= ~clk;
	
	// Inetrface instance
	test_ifc test_ifc_h (
		.clk_i(clk)
	);
	
	// Dut instance
	rv_timer rv_timer_inst (
		.clk_i                   (clk                                ),
		.rst_ni                  (test_ifc_h.rst_ni                  ),
		.reg_we                  (test_ifc_h.reg_we                  ),
		.reg_re                  (test_ifc_h.reg_re                  ),
		.reg_addr                (test_ifc_h.reg_addr                ),
		.reg_wdata               (test_ifc_h.reg_wdata               ),
		.reg_be                  (test_ifc_h.reg_be                  ),
		.reg_rdata               (test_ifc_h.reg_rdata               ),
		.reg_error               (test_ifc_h.reg_error               ),
		.intr_timer_expired_0_0_o(test_ifc_h.intr_timer_expired_0_0_o)
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
		// Pass virtual interface test_ifc_h in uvm_test_top
	  uvm_config_db#(virtual test_ifc/*data_type*/)::set(null/*Handle to the uvm_componemt that is calling the uvm_db*/, "uvm_test_top"/*relative path where you are writting or get this*/, "test_ifc_h"/*interface name*/, test_ifc_h/*Interface handle*/);
		run_test();
	end
endmodule // top