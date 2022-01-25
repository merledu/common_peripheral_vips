///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    02-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    env_config.sv                                                                     //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
// - One of the most important goals of UVM is build a configurable verification environment that    //
//   can be used with different projects                                                             //
// - To achieve this goal we need a mechanism that can be used to store and retrive specific         //
//   configuration information that would effect your testbench                                      //
// - The UVM class library provide various utilitize to support storing and retriving of this        //
//   configuration information                                                                       //
// - Configuation classes are containers of this such information                                    //
// - In a typical testbench there can be several configuration classes each tied to a component class//
// - One object of the conguration class will be created for every object of its related component   //
//   class                                                                                           //
// - All these configuration class objects have to be created at the test level before the creation  //
//   of related sub components                                                                       //
// - You can decide weather to randomize these configuarion values or decide to use specific per     //
//   test values                                                                                     //
// - Using configration data base these configuration values are passed down to the lower levels     //
// - In most cases we usually have two types of configuration classes one for configuring the        //
//   environment and another for configuring agents                                                  //
// - Each agent class will have its own configuration class and two instances or objects of the same //
//   agent will each have there own configuration object                                             //
//                                                                                                   //
//   The environment configuration class controls which of the environment sub-component are built.  //
//   So for exmaple you can decide weather you want your envirenmnet to enable the creation of       //
//   coverage collector or scoreboard compoents                                                      //
//   Also you can specify how many agents your environment would built                               //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class env_config extends uvm_object;
  // For configuration classes we have to register this with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(env_config)

  // Define a constructor function
  function new(string name="env_config");
  	super.new(name);
  endfunction // new

	rand bit enable_scoreboard=1;            // Enable scoreboard
	rand bit enable_coverage  =0;            // Enable coverage collector 
	rand int n_tx_agent         ;            // Number of agent your environment should build
       tx_agent_config tx_agent_config_h;  // Environment config object should have handles to agent configs so can see configuration for the entire system
	// tx_agent_config tx_agent_config_h[4]; // If you have multiple agents like 4 usb agent then you have to have 4 seperate config objects in that case environment need array with 4 seperate handle 
	
endclass