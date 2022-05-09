///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    03-MARCH-2022                                                                     //
// Design Name:    UART                                                                              //
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
  virtual test_ifc vif_tx;
  virtual test_ifc vif_rx;
  // Agent is active or passive
  rand uvm_active_passive_enum active = UVM_ACTIVE;
  // The base address for the master or slave when sending transaction from the driver
  rand bit [31:0]              base_address='hA;
  // It may also contain some other fields which control weather other sub components classes such as the coverage collector or scoreboards get build at the agent level or not 
  rand bit                     enable_coverage;
  // NOTE the hierarchical path to the sequencer(tx_sequence_h.start(tx_env_h.tx_agent_h.tx_sequencer_h);) in test class is a poor OOP code i.e tx_env_h.tx_agent_h.tx_sequencer_h. What if we have multiple agent we have to change this path, that is not reuseable. So sequencer can be set by configuration classes as follows
  uvm_sequencer #(transaction_item) tx_sequencer_h;    // Handle to sequencer   (Never extended) tx_sequencer is parameterize and is specialize with transaction_item transaction

endclass