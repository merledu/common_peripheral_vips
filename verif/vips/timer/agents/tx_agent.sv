///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    01-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    tx_agent.sv                                                                       //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//        The agents encapsulates the components such as the driver, the monitor and the sequencer   //
//        that communinated with DUT through an interface(that is following a specific protocol) So  //
//        once we make an agent for a particular protocol we can re_use this in future testbenches   //
//        Based on the design complexity we may have more than one agent each for specific protocol. //
//                                                                                                   //
//        Note that tx_agent is extended from uvm_agent base class                                   //
//        uvm_agent is define in uvm_pkg                                                             //
//        UVM components are permanent because they are never destroyed, they are created at the     //
//        start of simulation and exist for the entire simulation, Whereas stimulus are temporary    //
//        because thousands of transactions are created and destroyed during simulation              //
//        Componets are hierarical i.e. they have fixed location in topology.                        //
//        Transactions do not have fixed location because transaction move throught the components.  //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class tx_agent extends uvm_agent;
	// For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
	// Pass the class name to it
  `uvm_component_utils(tx_agent)

  /*
	Then declare tx_agent class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module(top module) is static object that is present at beginning of simulation 
	*/
	// Component Constructor have two arguments to specify the name and handle of the parent of this component in testbench topology
	function new(string name, uvm_component parent);
    super.new(name, parent);
	endfunction // new

	// Declare the handle
  tx_driver       tx_driver_h      ;                    // Handle to driver
  tx_monitor      tx_monitor_h     ;                    // Handle to monitor
  tx_agent_config tx_agent_config_h;                    // Declaration of agent configuraton object
  uvm_sequencer#(config_xactn_timer) tx_sequencer_h;    // Handle to sequencer   (Never extended) tx_sequencer is parameterize and is specialize with config_xactn_timer transaction

  // Analysis port to connect with the analysis port of monitor
  uvm_analysis_port #(config_xactn_timer) dut_txn_port;
  
  // Build phase
	// The agent is hierarchical and create component like the driver, monitor and sequencer during the Build phase
	// Build phase (In build phase we have function because components are build at zero time and function are executed at zero time)
	virtual function void build_phase(uvm_phase phase);
    `uvm_info("TIMER_AGENT::",$sformatf("______BUILD_PHASE______"), UVM_LOW)

    // TLM analysis ports are NOT created with factory
    dut_txn_port = new ("dut_txn_port",this);
    
    // The agent gets its configuration from uvm_config_db
    if(!uvm_config_db#(tx_agent_config)::get(this/*Handle to this component*/, ""/*an empty instance name*/, "tx_agent_config_h"/*Name of the object in db*/, tx_agent_config_h/*Handle that the db writes to*/))
    	`uvm_fatal("TX_AGENT::NO VIF",$sformatf("No virtual interface in db"))
    // Now the object has it config object after getting it from uvm_config_db
    
    // If agent config object says it is active agent create driver and sequecer
    if(tx_agent_config_h.active == UVM_ACTIVE) begin
	    tx_driver_h    = tx_driver::type_id::create ("tx_driver_h", this);
      tx_sequencer_h = new("tx_sequencer_h",this); // No factory
    end
    // Copy the sequencer handle into the config object tx_agent_config
    tx_agent_config_h.tx_sequencer_h = tx_sequencer_h;
    // Always create the monitor 
	  tx_monitor_h = tx_monitor::type_id::create ("tx_monitor_h"  , this);
  endfunction
  
  // Connect phase
  // Where components are connected with each other
  // Like driver is connected with sequencer (Connected with TLM ports)
  virtual function void connect_phase(uvm_phase phase);
    `uvm_info("TIMER_AGENT::",$sformatf("______CONNECT_PHASE______"), UVM_LOW)
  if(tx_agent_config_h.active == UVM_ACTIVE)
    tx_driver_h.seq_item_port.connect(tx_sequencer_h.seq_item_export);
    tx_monitor_h.dut_tx_port.connect(this.dut_txn_port);
  endfunction

endclass: tx_agent