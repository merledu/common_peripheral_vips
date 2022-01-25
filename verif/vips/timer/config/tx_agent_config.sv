///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    03-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    tx_agent_config.sv                                                                //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//             The agent level configuration object is use to pass information to the agent          //
//             This effects what it does and how it is build and connected                           //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class tx_agent_config extends uvm_object;
  // For configuration classes we have to register this with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(tx_agent_config)

  // Define a constructor function
  function new(string name="tx_agent_config");
  	super.new(name);
  endfunction // new
  
  /* You can add specific setting for the agents and its sub components */
  // Like the active bit which can be used to select weather the agent is active or passive
  // Passive means driver and sequencer are not required
  // Active means driver, monitor and sequencer all are required
  
  // When agent needs virtual interface or any configuaration variable it just read from this object instead of config db get. It is a huge performance boost rather the * appraoch mentioned in the test class which set more than 1000 entries in config db.
  // Each agent should also constain a reference to a virtual interface which the driver and monitor use to connect to the system verilog interface and so to the device under test (DUT)
  virtual test_ifc vif;
  // Agent is active or passive
  rand uvm_active_passive_enum active = UVM_ACTIVE;
  // The base address for the master or slave when sending transaction from the driver
  rand bit [31:0]              base_address='hA;
  // It may also contain some other fields which control weather other sub components classes such as the coverage collector or scoreboards get build at the agent level or not 
  rand bit                     enable_coverage;
  // NOTE the hierarchical path to the sequencer(tx_sequence_h.start(tx_env_h.tx_agent_h.tx_sequencer_h);) in test class is a poor OOP code i.e tx_env_h.tx_agent_h.tx_sequencer_h. What if we have multiple agent we have to change this path, that is not reuseable. So sequencer can be set by configuration classes as follows
  uvm_sequencer #(config_xactn_timer) tx_sequencer_h;    // Handle to sequencer   (Never extended) tx_sequencer is parameterize and is specialize with config_xactn_timer transaction

endclass

// Definition of factory registration
/*
- How can you add new functionality to your testbench? 
- In UVM it is recommened to write your testbench only once
- So you start by wrting a basic functionality like creating good transactions with no error injection or delay for example.
- Then when you need to test additional functionalities you can extend your original class to create new ones that would apply the new functionalities.
- Then have the testbench to use these new ones with Polymorphism
- Using this technique existing test will continue to work beacause they rely on the base code

- In order to do so UVM provides a build in factory to create the testbencg components and transactions.
- This allow test to "override" the original object with one that has new functionality
- Other overriding class must be derived from he original class
- Factory overridees make it possible to write many complex tests that run on the same testbeanch
- Each test can customize the testbench at run time for the specific needs of that test, without duplicating complex test code, or requiring the top to be recompiled 
- There is no risk of breakinf due to the addition of new tests
- For example, we have usb_agent_3.0 having driver_3.0 to check USB_3.0 protocol. Using factory registration we can check USB_3.1 protocol with driver_3.1 with the same agent usb_agent_3.0 without changing anthing in the usb_agent_3.0 or in lower level
*/