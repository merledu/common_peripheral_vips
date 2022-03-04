///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    08-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    base_test_pkg.sv                                                                       //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//     - The uvm test is made of many classes a good way to organize these classes is to put each    //
//       class in a seperate file with a class name and extension of .svh. Then create system        //
//       verilog packages that include related classes                                               //
//     - For example package with AXI protocol components and an other package with USB protocol     //
//       components                                                                                  //
//     - Now if we want to add USB protocol to the testbench we just import the package with usb     //
//       componets in the top module.                                                                //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////


package base_test_pkg;
  // timeunit 1ns; timeprecision 1ns;

	import uvm_pkg::*;         // To bring uvm base library, from which we extend all the testbench components
	`include "uvm_macros.svh"  // To make use of macros that are found in uvm libraries
  
  ///////////////////////////////////////////////////////
  // Include UVM objects that are involved in the test //
  ///////////////////////////////////////////////////////
  
  // Sequence Items
  `include "./seq_items/tx_item.sv"
  `include "./seq_items/config_xactn_timer.sv"
  
  // Agent configuration
  `include "./config/tx_agent_config.sv"
  
  // Environment configuration
  `include "./config/env_config.sv"
  
  // Sequences
  `include "./sequences/tx_sequence.sv"
  `include "./sequences/config_timer_sequence.sv"
  `include "./sequences/read_timer_sequence.sv"
  `include "./sequences/reset_timer_sequence.sv"
  
  // Sequencers
  `include "./sequencers/tx_sequencer.sv"
  
  // Virtual Sequences
  `include "./sequences/tx_v_seq.sv"
  
  // Monitors
  `include "./monitors/tx_monitor.sv"
  
  // Drivers
  `include "./drivers/tx_driver.sv"
  //`include "./drivers/tx_driver_overriding_driver.sv"
  
  // Scoreboards
  `include "./scoreboard/timer_scoreboard.sv"
  //`include "./scoreboard/timer_predictor.sv"
  
  // Agents
  `include "./agents/tx_agent.sv"
  
  // Environments
  `include "./env/tx_env.sv"
  
  // Tests
  `include "./tests/tx_test.sv"
  
  // Any further test
  
endpackage // base_test_pkg