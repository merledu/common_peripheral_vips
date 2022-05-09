///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    11-MARCH-2022                                                                     //
// Design Name:    UART                                                                              //
// Module Name:    read_uart_sequence.sv                                                             //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//       - Sequence can be one or many seqeunce items and the sequence is not the part of            //
//         component heirarchy                                                                       //
//       - Note that tx_sequnce is extended from uvm_sequnce base class                              //
//       - uvm_sequnce is define in uvm_pkg                                                          //
//       - UVM components are permanent because they are never destroyed, they are created at the    //
//         start of simulation and exist for the entire simulation                                   //
//       - Whereas stimulus are temporary because thousands of transactions are created and          //
//         destroyed during simulation                                                               //
//       - Components are hierarical i.e. they have fixed location in topology.                      //
//       - Transactions do not have fixed location because transaction move throught the components. //
//       - sequnce is parameterize class, as shown here the config_uart_sequence only send           // 
//         transaction_item transaction                                                              //
//                                                                                                   //
// This sequence will read the values from UART's register to observe either the                     // 
// config_uart_sequence has succussfully configured the UART or not                                  //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class read_uart_sequence extends uvm_sequence #(transaction_item);
	// For sequence we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(read_uart_sequence)

  /*
	Then declare read_uart_sequence class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
  function new (string name="read_uart_sequence");
    super.new(name);
    // In constructor this object can be randomize to set the block size, typicaly we don't randomize in constructor
    if(!this.randomize())
    	`uvm_fatal("FATAL_ID",$sformatf("Number of transaction is not randomized"))
  endfunction // new

  tx_agent_config tx_agent_config_h;  // Declaration of agent configuraton object, for configuring sequence

  // Every sequence has a method called pre start which is called before body
  task pre_start();
  	if(!uvm_config_db#(tx_agent_config)::get(null/*instead to "this" reletive path use absolute path*/ /*this*/ /*You will get error if your write "this" because "this" means read_uart_sequence which is transaction not a uvm_component and we need uvm component to pass*/, get_full_name() /*usually for get these commas are empty, but here we will define absolute path by get_full_name()*/, "tx_agent_config_h", tx_agent_config_h))
  		`uvm_fatal("NO AGENT CONFIG",$sformatf("No Agent configuration found in db"))
  endtask : pre_start
  
  // For generating random number of transactions. Just as single transaction can be randomize entire sequences can be randomize. This way you sequences act differently everytime it is run. 
  rand bit [15:0] num_of_xactn;
  constraint size {soft num_of_xactn inside {5,15};}
  
  // A sequence is a block of procedural code that have been wrapped in a method called body
  // Task can have delays
  // Note: Driver limits how fast the stimulus can be applied to the driver by sequence, since the sequence is connected to driver it can send a new transaction when driver is ready
  virtual task body();
    // transaction of type transaction_item
    transaction_item tx                 ;
    int                cycle            ;
    bit [ 63:0]        data             ;
    bit                lower_data_en    ;
    bit [ 31:0]        upper_data       ;
    bit [ 31:0]        lower_data       ;
    bit [ 11:0]        prescale      = 0;
    bit [23:16]        step          = 0;
    string msg="";

    // read_uart_sequence is going to generate 6 transactions of type transaction_item
    repeat(3) begin
      cycle = cycle + 1;
      `uvm_info("READ_UART_SEQUENCE::",$sformatf("READ_UART_SEQUENCE"), UVM_LOW)
      tx = transaction_item::type_id::create("tx");              // Factory creation (body task create transactions using factory creation)
      start_item(tx);                                            // Waits for a driver to be ready
      if(!tx.randomize())                                        // It randomize the transaction
        `uvm_fatal("ID","transaction is not randomize")          // If it not randomize it will through fatal error
      // tx.addr=tx_agent_config_h.base_address;                 // For fetching base address from agent configuration "It can be a run time value"
    
      // Declaration and Initializatin
      tx.rst_ni = 1'b1;  
      tx.ren    = 1'h1;
      tx.we     = 1'h0;  
      // Read register at address 'h0
      if (cycle == 'b01)
        tx.addr = 'h0;
      // Read register at address 'h18
      else if (cycle == 'b10)
        tx.addr = 'h18;
      // Read register at address 'h04
      else if (cycle == 'b11)
        tx.addr = 'h04;
      // Enable the FIFO write to transmit the data
      else if (cycle == 'b100) begin
        tx.rst_ni = 1'b1;  
        tx.ren    = 1'h0;
        tx.we     = 1'h1;  
        tx.addr   = 'h14;
        tx.wdata  =  'h1;
      end
      else begin
        tx.rst_ni = 1'b1;  
        tx.ren    = 1'h0;
        tx.we     = 1'h1;  
        tx.addr   = 'h1c;
        tx.wdata  =  'h1;
      end
      finish_item(tx);                                          // After randommize send it to the driver and waits for the response from driver to know when the driver is ready again to generate and send the new transaction and so on.
    end
  endtask // body

endclass // read_uart_sequence
