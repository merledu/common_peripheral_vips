///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    26-MAY-2022                                                                       //
// Design Name:    SPI                                                                               //
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
	always #50 clk <= ~clk;
	
	// Inetrface instance
	test_ifc test_ifc_h (
		.clk_i(clk)
	);

  // DUT ports
  spi_core spi_core_inst(
  .clk_i    (clk                 ),     
  .rst_ni   (test_ifc_h.rst_ni   ),     
  .addr_i   (test_ifc_h.addr_i   ),         
  .wdata_i  (test_ifc_h.wdata_i  ),            
  .rdata_o  (test_ifc_h.rdata_o  ),           
  .be_i     (test_ifc_h.be_i     ),      
  .we_i     (test_ifc_h.we_i     ),  
  .re_i     (test_ifc_h.re_i     ),   
  .error_o  (test_ifc_h.error_o  ),     
  .intr_rx_o(test_ifc_h.intr_rx_o),
  .intr_tx_o(test_ifc_h.intr_tx_o),                                              
  .ss_o     (test_ifc_h.ss_o     ),
  .sclk_o   (test_ifc_h.sclk_o   ),
  .sd_o     (test_ifc_h.sd_o     ),
  .sd_oe    (test_ifc_h.sd_oe    ),
  .sd_i     (test_ifc_h.sd_i     )
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