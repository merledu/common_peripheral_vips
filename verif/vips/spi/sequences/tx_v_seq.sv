///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    24-May-2022                                                                       //
// Design Name:    SPI                                                                               //
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
  
  // Sequence to reset the spi
  reset_spi_sequence reset_spi_sequence_h ;
  // Sequence to configure the timer by writing random values to registers present at different addresses
  config_spi_sequence config_spi_sequence_h;
  // Sequence for MOSI (tx) stimulus
  spi_mosi_sequence spi_mosi_sequence_h;
  // Sequence for MISO (rx) stimulus
  spi_miso_sequence spi_miso_sequence_h;
  // Sequence for MISO & MOSI stimulus simultenously                      
  spi_miso_mosi_simultaneous_sequence spi_miso_mosi_simultaneous_sequence_h;
  
  task body();
    // Sequence to reset 
    reset_spi_sequence_h = reset_spi_sequence::type_id::create("reset_spi_sequence_h");                                                                  // Creating a sequences
    reset_spi_sequence_h.start(get_sequencer(), this);
  	//// Sequence to configuring the timer
  	config_spi_sequence_h = config_spi_sequence::type_id::create("config_spi_sequence_h");                                                              // Creating a sequences
  	config_spi_sequence_h.start(get_sequencer(), this);
    // Sequence for MOSI (tx) stimulus
    spi_mosi_sequence_h = spi_mosi_sequence::type_id::create("spi_mosi_sequence_h");                                                                    // Creating a sequences
    spi_mosi_sequence_h.start(get_sequencer(), this);
    // Sequence for MISO (rx) stimulus
    spi_miso_sequence_h = spi_miso_sequence::type_id::create("spi_miso_sequence_h");                                                                    // Creating a sequences
    spi_miso_sequence_h.start(get_sequencer(), this);
    // Sequence for MISO & MOSI stimulus simultenously                      
    spi_miso_mosi_simultaneous_sequence_h = spi_miso_mosi_simultaneous_sequence::type_id::create("spi_miso_mosi_simultaneous_sequence_h");              // Creating a sequences
    spi_miso_mosi_simultaneous_sequence_h.start(get_sequencer(), this);
    
  endtask
  
endclass