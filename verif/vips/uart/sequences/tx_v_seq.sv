///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    03-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    tx_v_seq.sv                                                                       //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//       - A virtual sequence is a sequence that creates and starts other sequences. Virtual         // 
//         sequences is used when you have to stimulate the DUT with multiple sequences.             //
//       - A virtual sequences does not directly generate item and does not need to be specialized   //
//       - This class wraps multiple sequences and this class is reuseable                           //
//       - This virtual sequence starts child sequences with sequencers handle from ""               //
//         tx_v_seq_h.start(tx_agent_config_h.config_timer_sequencer_h);"" present in tx_test class  //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class tx_v_seq extends uvm_sequence;

	// For sequence we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(tx_v_seq)

  /*
	Then declare tx_v_seq class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
  function new (string name="tx_v_seq");
    super.new(name);
  endfunction // new

  // Declaring a sequences
  
  // Sequence to reset the timer
  reset_timer_sequence  reset_timer_sequence_h ;
  // Sequence to configure the timer by writing random values to registers present at different addresses
  config_timer_sequence config_timer_sequence_h;                      
  // Sequence to read the timer's register present at different addresses to observe if register are properly configured or not
  read_timer_sequence   read_timer_sequence_h  ;

  task body();
    // Sequence to reset 
    reset_timer_sequence_h = reset_timer_sequence::type_id::create("reset_timer_sequence_h");                  // Creating a sequences
    reset_timer_sequence_h.start(get_sequencer(), this);
  	// Sequence to configuring the timer
  	config_timer_sequence_h = config_timer_sequence::type_id::create("config_timer_sequence_h");              // Creating a sequences
  	config_timer_sequence_h.start(get_sequencer(), this);
    // Sequence for reading the configuration registers to check either timer is configured properly or not
    read_timer_sequence_h = read_timer_sequence::type_id::create("read_timer_sequence_h");                    // Creating a sequences
    read_timer_sequence_h.start(get_sequencer(), this);
  endtask
  
endclass