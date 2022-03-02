///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    05-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    tx_env.sv                                                                         //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//      - We can put all the agents in an uvm environment                                            //
//      - The uvm environment is a top of testbench that is shared by all tests                      //
//      - Note that tx_env is extended from uvm_env base class                                       //
//      - uvm_env is define in uvm_pkg                                                               //
//      - UVM components are permanent because they are never destroyed, they are created at the     // 
//        start of simulation and exist for the entire simulation                                    //
//      - Whereas stimulus are temporary because thousands of transactions are created and destroyed //
//        during simulation                                                                          //
//      - Componets are hierarical i.e. they have fixed location in topology.                        //
//      - Transactions do not have fixed location because transaction move throught the components.  //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class tx_env extends uvm_env;
  // For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
	// Pass the class name to it
  `uvm_component_utils(tx_env)

  /*
	Then declare tx_env constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module(top module) is static object that is present at beginning of simulation 
	*/
	// Component Constructor have two arguments to specify the name and handle of the parent of this component in testbench topology
	function new(string name, uvm_component parent);
    super.new(name, parent);
	endfunction // new
  
  // Declare handle to the objects agent, scoreboard, env config and agent config.
  tx_agent         tx_agent_h        ;
  timer_scoreboard timer_scoreboard_h;
  env_config       env_config_h      ;
  tx_agent_config  tx_agent_config_h ;
  // cov_collector   cov_collector_h;

  // Build phase
	// Similar to agent, environment is hierarchical and create components like the agent, scoreboards during the build phase
	// Build phase (In build phase we have function because components are build at zero time and function are executed at zero time)
	virtual function void build_phase(uvm_phase phase);
    `uvm_info("TIMER_ENV::",$sformatf("______BUILD_PHASE______"), UVM_LOW)
    // The environment fetches it config object from uvm_config db
    if (!uvm_config_db#(env_config)::get(this,"", "env_config_h", env_config_h))
      `uvm_fatal("TX_ENV::NO VIF",$sformatf("No virtual interface in db"))
    // Put agent tx_agent_config handle into uvm_config_db for agent and sub_components
    uvm_config_db#(tx_agent_config)::set(this, "tx_agent_h*", "tx_agent_config_h", env_config_h.tx_agent_config_h);
    // Buiding Objects
    tx_agent_h = tx_agent::type_id::create("tx_agent_h",this);
    // Now you can use the configuration values like if test enable coverage create coverage collector, there is also similar code for creating scoreboard and connect phase
    // if(env_config_h.enable_coverage) TODO
    // 	cov_collector_h    = cov_collector::type_id::create("cov_collector_h",this);
    if(env_config_h.enable_scoreboard)
      timer_scoreboard_h = timer_scoreboard::type_id::create("timer_scoreboard_h",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    `uvm_info("TIMER_ENV::",$sformatf("______CONNECT_PHASE______"), UVM_LOW)
    if(env_config_h.enable_scoreboard)
      tx_agent_h.dut_txn_port.connect(timer_scoreboard_h.ap_imp);
      //tx_agent_h.tx_monitor_h.dut_tx_port.connect(timer_scoreboard_h.ap_imp);
  endfunction // connect_phase

endclass // tx_env