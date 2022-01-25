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
// - Test instantiate the environment and create the stimulus                                        //
// - Note that tx_test is extended from uvm_test base class                                          //
// - uvm_test is define in uvm_pkg                                                                   //
//                                                                                                   //
// - UVM components are permanent because they are never destroyed, they are created at              //
//   the start of simulation and exist for the entire simulation                                     //
// - Whereas stimulus are temporary because thousands of transactions are created and                //
//   destroyed during simulation                                                                     //
// - Componets are hierarical i.e. they have fixed location in topology.                             //
// - Transactions do not have fixed location because transaction move throught the components.       //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class tx_test extends uvm_test;
  // For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
	// Pass the class name to it
  `uvm_component_utils(tx_test)

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

  tx_env          tx_env_h         ; // Declare the handle to the environment component
  env_config      env_config_h     ; // Declaration of environment configuraton object
  tx_agent_config tx_agent_config_h; // Declaration of agent configuraton object
  
  // Note that virtual interface is directly store in agent config object so no need to declare it here.
  // virtual test_ifc        vif;                // Declare the local variable in test to hold virtual interface
  
  // tx_driver_overriding_driver tx_driver_overriding_driver_h;  // this driver will override the tx_driver in present in tx_agent    
  
  // Build phase
	// Similar to agent and environment, the test is also hierarchical and create components like the env during the build phase
	// There are no other components apart from environment so no connect phase is required
	// Build phase (In build phase we have function because components are build at zero time and function are executed at zero time)
	virtual function void build_phase(uvm_phase phase); 
    `uvm_info("TIMER_TX_TEST::",$sformatf("______BUILD_PHASE______"), UVM_LOW)

    // Create the environment and related configuration objects
    tx_env_h = tx_env::type_id::create("tx_env_h",this);
    env_config_h = env_config::type_id::create("env_config_h",this);
    tx_agent_config_h = tx_agent_config::type_id::create("tx_agent_config_h",this);
    
    // Link the agent config object present in config environemnt with agent config in this test class
    env_config_h.tx_agent_config_h = tx_agent_config_h;
  
    // Each test can set configuration values depending upon its needs
    env_config_h.enable_scoreboard =    0;        // Test overides the default values
    env_config_h.enable_coverage   =    0;        // Test overides the default values
    tx_agent_config_h.base_address = 'hAA;        // Test overides the default values

   /* Imagine you have a test class that does what you want, but you want to run it several time with a small change for each run, for example you may
   try a different base address for the agent. Do you have to make a copy of test class for each address? NO! . Because uvm lets you write individual 
   values to config_db from the command line that the test can read*/ 
   // USE command line switch " +uvm_set_config_int = uvm_test_top,base_address,'hB " // This create an entry in uvm_config_db, this command line switch is optional
   
   // Get the configuration value from command line
   void'(uvm_config_db #(uvm_bitstream_t)::get(this,"","base_address",tx_agent_config_h.base_address));                  // void means you are calling get and not checking either succeeded or failed
   `uvm_info(get_type_name(), $sformatf("TX_TEST::config base adddress = %0x", tx_agent_config_h.base_address), UVM_LOW)
   
    // Call uvm_config_db to get the virtual interface from top
    if(!uvm_config_db#(virtual test_ifc)::get(this,""/*this field is mostly empty in get phase*/, "test_ifc_h",tx_agent_config_h.vif))
      `uvm_fatal("NO VIF",$sformatf("No virtual interface in db"))
    // Now set the environment config object in the config database (uvm_config_db)
    uvm_config_db#(env_config)::set(this, "tx_env_h", "env_config_h", env_config_h);

    // Pass virtual interface vif to agent. You need to pass virtual interface to agent, monitor and driver, * in below lines is setting vif in mentioned agent and their respective driver and monitor
    // This is a good approach (* approach) if a database is of 100 or a 1000 entries but if testbench is large then this is not a good approach.(if large testbench puts every configuration variable in db creating 1000 entries more then it is a series performance problem)
    // TODO, uvm_config_db#(virtual test_ifc)::set(this, "env_h.tx_agent_h*", "vif",vif);*/ // DB scope + name is "uvm_test_top.env_h.tx_agent_h.vif"
    
    // Using the following command, one component will override the other respective component, here tx_driver_overriding_driver driver overrides the tx_driver present in tx_agent
    // tx_driver_overriding_driver is extended from tx_driver
    // Now when the agent create its respective component intead of creating tx_driver in tx_agent, it will build tx_driver_overriding_driver and override tx_driver
    // And you do not need to make any changes in agent and below classes
    // This means exiting tests will behave the same way, you made added the extra code by extending the present driver i.e. tx_driver.
    // Only code that is needed to be changed is in the test class
    // tx_driver::type_id::set_type_override(tx_driver_overriding_driver::get_type());
    // set_type_override_by_type(tx_driver::get_type(),tx_driver_overriding_driver::get_type());

    // Can also over_rides the transaction class
    // TODO tx_item::type_id::set_type_override(tx_item_overriding_item::get_type());
    
    // You can also override the component in the specific instances, like if you multiple instances of tx_agent and you only need to change the driver in sub_instance 2, following is the code for that.
    // TODO tx_driver::type::set_inst_override(tx_driver_overriding_driver::get_type(), "uvm_test_top.tx_env_h.tx_agent_h");
  endfunction

  // Phases other than build phase are task based phases
  
  // Run phase
  virtual task run_phase(uvm_phase phase);
    tx_sequence tx_sequence_h;                                                       // Sequence of type tx_sequence, this eventually calls new block size is randomize
    tx_v_seq    tx_v_seq_h   ;                                                       // Handle to the virtual sequences which run multiple sequences
    tx_sequence_h = tx_sequence::type_id::create("tx_sequence_h");                   // Factory creation (create sequence using factory creation method)
    tx_v_seq_h    = tx_v_seq   ::type_id::create("tx_v_seq_h   ");                   // Factory creation (create virtual sequence using factory creation method)
    
    // Then test starts the sequences on the sequencer down in the enveronment by using seq.start
    // How do we keep run_phase running until all stimulus is applied? This is done with UVM objections
    // Wrap it in objections to keep run_phase from completing
    // As long as there is one objection raise UVM cannot move to the next phase

    phase.raise_objection(this, "Start tx_sequence");                                // To start objection we use phase.raise_objection    
    if (!tx_sequence_h.randomize() with {num_of_xactn inside {4,7};})                // Normally sequence will be started immediately after sequence is created however sequence behaviour can be changed using randomize to set the number of transaction to 4 or 7   
      `uvm_fatal("FATAL_ID",$sformatf("Number of transaction is not randomized"))    // You took and existing sequence and injected a new functionality by leveraging its randomness 
    // NOTE the hierarchical path to the sequencer is a poor OOP code in line below i.e tx_env_h.tx_agent_h.tx_sequencer_h. What if we have multiple agent we have to change below mentioned line that is not reuseable. So sequncer can be set by configuration classes
    // WARNING tx_sequence_h.start(tx_env_h.tx_agent_h.tx_sequencer_h);              // Then test starts the sequences on the sequencer down in the enveronment by using seq.start. Also identify which sequencer is used with its hierarchical path.
    // WARNING avoid using above line due poor OOP code that is not reuseable. Instead use the following
    
    // NOTE tx_sequence_h.start(tx_agent_config_h.tx_sequencer_h);                   // Then test starts the sequences on the sequencer down in the enveronment by using seq.start. Also identify which sequencer is used with its hierarchical path. (This is not usable).
    tx_v_seq_h.start(tx_agent_config_h.tx_sequencer_h);                              // Execution of virtual sequence having multiple sequences

    // NOTE there is a problem with the above code, it drop the objection when above sequence ends(when last transaction is send) which is to early because last few transactions does not have time to propogate to the design so you need to wait a little longer
    // So you need a drain time (Time so that transaction propogate through RTL and respective signals propogate on the output) this way scoreboard can read the last transaction.
    #10ns // Drain time could be set like this but NOTE this is not reusable, then you have to put it at every call to drop objection 
    // Instead in run_phase call set_drain_time as shown below, this automatically delays after last objection is dropped 
    phase.phase_done.set_drain_time(this, 100/*time in ns*/); // Delay objection drop for 100ns
    phase.drop_objection(this, "End tx_sequence");                                   // After all the sequences are sent to sequencer we use phase.drop_objection
    // NOTE In above line End tx_sequence is a message definining what is happening, you can use +UVM_OBJECTION_TRACE switch to print these message in the log
    // You can use these message helps ypu find out the active objection that you forgot to drop
    // Best practive is raise and drop objections in test and avoid in other components and sequences 
  endtask

  /*
  - Afer building your testbench, it is very useful to see the final topology that is build.
  - In case you are using the factory to build the components and override them, with whatever variation needed for testing, you need to check either the topology is build with desired objects or not
  - UVM provides a print topology method that can be used to print the testbench structure
  - A good place to call a print topology is in the end_of_elaboration phase (here you are sure that that all objetcs are build and connected) in the test class
  - topology can be print anytime after building and connecting of components
  */
	function void /*tx_test::*/end_of_elaboration_phase(uvm_phase phase);
		// top class is uvm_root, uvm_top is the instance name of uvm_root
		uvm_top.print_topology();
		
    /*
		UVM testbenches required clear messages to let you know the status of different components that build up the testbench
		Clear message and right number of messages are keys to accurate and efficient debugging.
		Note : - Number of message are inverely proportional to the speed of simulation. In too many messages you are like to miss important information.
		- Avoid $display because message cannot be tracked or controlled by UVM.
		- Format strings with $sformatf as a macros won't do it for you
		*/
		
    // Fatal messages are of such severity that the simulation should terminated
		// `uvm_fatal("FATAL_ID",$sformatf("[FATAL MESSAGE] Test message"))
		
    // Error message indicates a real error but simulation is allowed to proceed for the purpose of gathering more information about the cause of the problem
		// `uvm_error("ERROR_ID",$sformatf("[ERROR MESSAGE] Test message"))
		
    // Warning message are displayed to warn you about a potential problem that are likely to happen and need further investigation
	  // `uvm_warning("WARNING_ID",$sformatf("[WARNING MESSAGE] Test message"))
		
    // Informative messages that are used to display status information or to report results. UVM_LOW is verbosity control, by verbosity we can turn off or on printing this message. It can be set as UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH, UVM_FULL or UVM_DEBUG
		// Instead of message ID you can also get_type_name() for displaying a name of a current class in which uvm_info is calling.
		// `uvm_info(get_type_name(),$sformatf("[INFO MESSAGE] Test message with verbosity DEBUG" ), UVM_DEBUG )
		// `uvm_info(get_type_name(),$sformatf("[INFO MESSAGE] Test message with verbosity FULL"  ), UVM_FULL  )
		// `uvm_info(get_type_name(),$sformatf("[INFO MESSAGE] Test message with verbosity HIGH"  ), UVM_HIGH  )
		// `uvm_info(get_type_name(),$sformatf("[INFO MESSAGE] Test message with verbosity MEDIUM"), UVM_MEDIUM)
		// `uvm_info(get_type_name(),$sformatf("[INFO MESSAGE] Test message with verbosity LOW"   ), UVM_LOW   )
		// `uvm_info(get_type_name(),$sformatf("[INFO MESSAGE] Test message with verbosity NONE"  ), UVM_NONE  )
	endfunction : end_of_elaboration_phase

endclass
