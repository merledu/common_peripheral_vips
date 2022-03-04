///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    04-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    read_timer_sequence.sv                                                            //
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
//       - sequnce is parameterize class, as shown here the config_timer_sequence only send          // 
//         config_xactn_timer transaction                                                            //
//                                                                                                   //
// This sequence will read the values from timer's register to observe either the                    // 
// config_timer_sequence has succussfully configured the timer or not                                //                                                           //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class read_timer_sequence extends uvm_sequence #(config_xactn_timer);
	// For sequence we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(read_timer_sequence)

  /*
	Then declare read_timer_sequence class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
  function new (string name="read_timer_sequence");
    super.new(name);
    // In constructor this object can be randomize to set the block size, typicaly we don't randomize in constructor
    if(!this.randomize())
    	`uvm_fatal("FATAL_ID",$sformatf("Number of transaction is not randomized"))
  endfunction // new

  tx_agent_config tx_agent_config_h;  // Declaration of agent configuraton object, for configuring sequence

  // Every sequence has a method called pre start which is called before body
  task pre_start();
  	if(!uvm_config_db#(tx_agent_config)::get(null/*instead to "this" reletive path use absolute path*/ /*this*/ /*You will get error if your write "this" because "this" means read_timer_sequence which is transaction not a uvm_component and we need uvm component to pass*/, get_full_name() /*usually for get these commas are empty, but here we will define absolute path by get_full_name()*/, "tx_agent_config_h", tx_agent_config_h))
  		`uvm_fatal("NO AGENT CONFIG",$sformatf("No Agent configuration found in db"))
  endtask : pre_start
  
  // For generating random number of transactions. Just as single transaction can be randomize entire sequences can be randomize. This way you sequences act differently everytime it is run. 
  rand bit [15:0] num_of_xactn;
  constraint size {soft num_of_xactn inside {5,15};}
  
  // A sequence is a block of procedural code that have been wrapped in a method called body
  // Task can have delays
  // Note: Driver limits how fast the stimulus can be applied to the driver by sequence, since the sequence is connected to driver it can send a new transaction when driver is ready
  virtual task body();
    // transaction of type config_xactn_timer
    config_xactn_timer tx               ;
    int                cycle            ;
    bit [ 63:0]        data             ;
    bit                lower_data_en    ;
    bit [ 31:0]        upper_data       ;
    bit [ 31:0]        lower_data       ;
    bit [ 11:0]        prescale      = 0;
    bit [23:16]        step          = 0;
    string msg="";

    // read_timer_sequence is going to generate 6 transactions of type config_xactn_timer
    repeat(6) begin
      cycle = cycle + 1;
      `uvm_info("READ_TIMER_SEQUENCE::",$sformatf("READ_TIMER_SEQUENCE"), UVM_LOW)
      tx = config_xactn_timer::type_id::create("tx");            // Factory creation (body task create transactions using factory creation)
      start_item(tx);                                            // Waits for a driver to be ready
      if(!tx.randomize())                                        // It randomize the transaction
        `uvm_fatal("ID","transaction is not randomize")          // If it not randomize it will through fatal error
      // tx.addr=tx_agent_config_h.base_address;                 // For fetching base address from agent configuration "It can be a run time value"
      
      // Declaration and Initializatin
      tx.rst_ni = 1'b1   ;  
      tx.reg_we = 1'h0   ;
      tx.reg_be = 4'b0000;
      tx.reg_re = 1'h1   ;

      // Read register at address 'h10c
      if (cycle == 'b01)
        tx.reg_addr = 'h10c;
      
      // Read register at address 'h110
      else if (cycle == 'b10)
        tx.reg_addr = 'h110;
      
      // Read register at address 'h100
      else if (cycle == 'b11)
        tx.reg_addr = 'h100;
      
      // Read register at address 'h114
      else if (cycle == 'b100)
        tx.reg_addr = 'h114;
      
      // Active timer 
      else if(cycle == 'b101) begin
        // Active timer by writing 1 to control register at address 0x0)
        tx.reg_we    = 1'h1;
        tx.reg_be    = 4'b1111;
        tx.reg_re    = 1'h0;
        tx.reg_addr  = 'h000;
        tx.reg_wdata = 32'h00000001;
        print_transaction(tx, "Active the time");
      end
      
      // Check if the timer started counting by reading register at address 'h104 (This register will increament at everyclock cycle)
      else begin
        tx.reg_be    = 4'b0000;
        tx.reg_addr  = 'h104; 
        //tx.reg_re    = 1'b1;
        print_transaction(tx, "Checking if the timer started counting");
      end

      //tx.reg_addr='h110;
      finish_item(tx);                                           // After randommize send it to the driver and waits for the response from driver to know when the driver is ready again to generate and send the new transaction and so on.
    end
  endtask // body
  
  function void print_transaction(config_xactn_timer tx, input string msg);
    $sformat(msg, {1{"\n%s\n========================================="}}, msg );
    $sformat(msg, "%s\nADDRESS__________:: %0h"                         , msg, tx.reg_addr     );
    $sformat(msg, "%s\nWRITE_EN_________:: %0b"                         , msg, tx.reg_we       );
    $sformat(msg, "%s\nBYTE_EN__________:: %0b"                         , msg, tx.reg_be       );
    $sformat(msg, "%s\nREAD_EN__________:: %0b"                         , msg, tx.reg_re       );
    $sformat(msg, "%s\nDATA_____________:: %0b\n"                       , msg, tx.reg_wdata    );
    $sformat(msg, {1{"%s=========================================\n"}}  , msg );
    `uvm_info("READ REGISTER TO CHECK THE CONFIGURED TIMER & ACTIVATE TIMER::",$sformatf("\n", msg), UVM_LOW)
    msg = "";
  endfunction : print_transaction

endclass // read_timer_sequence
