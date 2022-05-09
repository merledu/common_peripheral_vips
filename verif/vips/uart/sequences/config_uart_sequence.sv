///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    10-MARCH-2022                                                                     //
// Design Name:    UART                                                                              //
// Module Name:    config_uart_sequence.sv                                                           //
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
//        This sequuence is used to configure the uart by passing constraint random values to DUT    //
//        via driver and interface                                                                   //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class config_uart_sequence extends uvm_sequence #(transaction_item);
	// For sequence we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(config_uart_sequence)

  /*
	Then declare config_uart_sequence class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
  function new (string name="config_uart_sequence");
    super.new(name);
    // In constructor this object can be randomize to set the block size, typicaly we don't randomize in constructor
    if(!this.randomize())
    	`uvm_fatal("FATAL_ID",$sformatf("Number of transaction is not randomized"))
  endfunction // new

  tx_agent_config tx_agent_config_h;  // Declaration of agent configuraton object, for configuring sequence

  // Every sequence has a method called pre start which is called before body
  task pre_start();
  	if(!uvm_config_db#(tx_agent_config)::get(null/*instead to "this" reletive path use absolute path*/ /*this*/ /*You will get error if your write "this" because "this" means config_uart_sequence which is transaction not a uvm_component and we need uvm component to pass*/, get_full_name() /*usually for get these commas are empty, but here we will define absolute path by get_full_name()*/, "tx_agent_config_h", tx_agent_config_h))
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

    // config_uart_sequence is going to generate 4 transactions of type transaction_item
    // TODO: for data to be send randomly (number of data send to the fifo to be transmit should be randomize depending on fifo depth)
    
    int tx_levl;
    int frequency = 1/(`CLOCK_PERIOD * 0.000000001);
    int clock_per_bit;

    //repeat (1) begin
    tx = transaction_item::type_id::create("tx");              // Factory creation (body task create transactions using factory creation)
    if(!tx.randomize())                                        // It randomize the transaction
      `uvm_fatal("ID","transaction is not randomize")          // If it not randomize it will through fatal error        
    tx_levl = tx.tx_level;
    `uvm_info("CONFIG_UART_SEQUENCE",$sformatf("Value of tx_level is set as %0d", tx_levl), UVM_LOW)
    
    ////////////////////////
    // CONFIGURE THE UART //
    ////////////////////////
    /*
    Note:
    2 cycles for setting baud rate and tx level
    tx level times, data will be written in tx fifo at address 'h04   
    */

    repeat(2+2+4+9+3+(tx_levl+1)) begin
      cycle = cycle + 1;
      tx = transaction_item::type_id::create("tx");              // Factory creation (body task create transactions using factory creation)
      start_item(tx);                                            // Waits for a driver to be ready
      if(!tx.randomize())                                        // It randomize the transaction
        `uvm_fatal("ID","transaction is not randomize")          // If it not randomize it will through fatal error
      // tx.addr=tx_agent_config_h.base_address;                 // For fetching base address from agent configuration "It can be a run time value"
      
      // Declaration and initialization
      tx.rst_ni = 1'b1;
      
      // Configuring the Baud rate
      if (cycle == 'b01) begin
        tx.reg_re    = 1'b0;
        tx.reg_we    = 1'b1;
        tx.reg_addr  =  'h0;
        //tx.reg_wdata = tx.baud_rate;        
        if (frequency%tx.baud_rate == 0)
          clock_per_bit = frequency/tx.baud_rate;
        else
          clock_per_bit = (frequency/tx.baud_rate)+1;
        tx.reg_wdata = clock_per_bit;
        `uvm_info("CONFIG_UART_SEQUENCE",$sformatf("\nFrequency = %0d,\nBaud rate = %0d,\nCPB = %0d",frequency, tx.baud_rate, tx.reg_wdata), UVM_LOW)
        print_transaction(tx, "Configuring the Baud rate", cycle);
      end
      // Configuring tx level
      else if (cycle == 'b10) begin
        tx.reg_re    = 1'b0;
        tx.reg_we    = 1'b1;
        tx.reg_addr  = 'h18;
        tx.reg_wdata = tx_levl;
        print_transaction(tx, "Configuring the tx level rate", cycle);
      end
      // Data to be transferred
      else if ( cycle >= 'd3 && cycle <= 'd2 +tx_levl+1) begin
        tx.reg_re    = 1'b0;
        tx.reg_we    = 1'b1;
        tx.reg_addr  = 'h04;
        //tx.reg_wdata = {24'h000000 , tx.reg_wdata[7:0]};
        print_transaction(tx, "Configuring data to be transfered", cycle);
      end
      /////////////////////////
      // READ THE CONFIGURED //
      /////////////////////////
      // Read register at address 'h0
      else if (cycle == tx_levl+'d4) begin
        tx.reg_re   = 1'h1;
        tx.reg_we   = 1'h0;  
        tx.reg_addr = 'h0;
        print_transaction(tx, "Reading configured baud rate", cycle);
      end
      // Read register at address 'h18
      else if (cycle == tx_levl+'d5) begin
        tx.reg_re   = 1'h1;
        tx.reg_we   = 1'h0;
        tx.reg_addr = 'h18;
        print_transaction(tx, "Reading configured tx level", cycle);
      end
      // Read register at address 'hc
      else if (cycle == tx_levl+'d6) begin
        tx.rst_ni    = 1'b1;  
        tx.reg_re    = 1'h0;
        tx.reg_we    = 1'h1;  
        tx.reg_addr  =  'hc;
        tx.reg_wdata =  'h1;
        print_transaction(tx, "Enabling uart to receive the data", cycle);
      end
      else if (cycle == tx_levl+'d7) begin
        tx.rst_ni    = 1'b1;  
        tx.reg_re    = 1'h0;
        tx.reg_we    = 1'h1;  
        tx.reg_addr  = 'h1c;
        tx.reg_wdata =  'h1;
        print_transaction(tx, "Enabling tx transfer", cycle);
      end
      else if (cycle == tx_levl+'d8) begin
        tx.rst_ni    = 1'b1;  
        tx.reg_re    = 1'h0;
        tx.reg_we    = 1'h1;  
        tx.reg_addr  = 'h1c;
        tx.reg_wdata =  'h0;
        print_transaction(tx, "Disabling tx transfer", cycle);
      end
      else if (cycle >= tx_levl+'d9 && cycle <= tx_levl+'d18) begin
        tx.rst_ni    = 1'b1;  
        tx.reg_re    = 1'h1;
        tx.reg_we    = 1'h0;  
        tx.reg_addr  = 'h8;
        tx.reg_wdata = 'h0;
        print_transaction(tx, "Reading RX data stored", cycle);
      end

      finish_item(tx);  // After randommize send it to the driver and waits for the response from driver to know when the driver is ready again to generate and send the new transaction and so on.
    end
    //end
  endtask // body
  
  // Function to print baud rate
  function void print_transaction (transaction_item tx, input string msg, int clk_cycle);
    $sformat(msg, {1{"\n%s\n========================================="}}, msg                    );
    $sformat(msg, "%s\ncycle_____________:d: %0d"                        , msg, clk_cycle        );
    $sformat(msg, "%s\nREAD_EN___________:h: %0h"                        , msg, tx.reg_re        );
    $sformat(msg, "%s\nWRITE_EN__________:h: %0h"                        , msg, tx.reg_we        );
    $sformat(msg, "%s\nW_DATA____________:h: %0h"                        , msg, tx.reg_wdata     );
    $sformat(msg, "%s\nR_DATA____________:h: %0h"                        , msg, tx.reg_rdata[7:0]);
    $sformat(msg, "%s\nADDR______________:h: %0h"                        , msg, tx.reg_addr      );    
    $sformat(msg, {1{"%s\n=========================================\n"}} , msg                   );
    `uvm_info("CONFIG_UART_SEQUENCE::",$sformatf("\n", msg), UVM_LOW)  
    msg = "";
  endfunction : print_transaction

endclass // config_uart_sequence
