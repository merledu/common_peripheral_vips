// Note that hello_test is extended from uvm_test base class
// uvm_test is define in uvm_pkg
// UVM components are permanent because they are never destroyed, they are created at the start of simulation and exist for the entire simulation
// Whereas stimulus are temporary because thousands of transactions are created and destroyed during simulation
// Componets are hierarical i.e. they have fixed location in topology.
// Transactions do not have fixed location because transaction move throught the components.
class hello_test extends uvm_test;
	// For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
	// Pass the class name to it
	`uvm_component_utils(hello_test)
	/*
	Then declare hello_test class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
	function new(string name, uvm_component parent);
    super.new(name, parent);
	endfunction // new 

	// Since there is only run_phase methods present here, so hello_test will only overrides this phase that print the hello world
	// In log reporter(a part of uvm infrastructure) tells which test is running
  virtual task run_phase(uvm_phase phase);
    `uvm_info("ID", "Hello World!", UVM_LOW)
  endtask // run_phase

endclass // test