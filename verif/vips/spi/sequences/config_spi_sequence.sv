///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    24-MAY-2022                                                                       //
// Design Name:    SPI                                                                               //
// Module Name:    config_spi_sequence.sv                                                            //
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
//       - sequnce is parameterize class, as shown here the config_spi_sequence only send            // 
//         transaction_item transaction                                                              //
//                                                                                                   //
//        This sequuence is used to configure the timer by passing constraint random values to DUT   //
//        via driver and interface                                                                   //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class config_spi_sequence extends uvm_sequence #(transaction_item);
	// For sequence we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(config_spi_sequence)

  /*
	Then declare config_spi_sequence class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
  function new (string name="config_spi_sequence");
    super.new(name);
    // In constructor this object can be randomize to set the block size, typicaly we don't randomize in constructor
    if(!this.randomize())
    	`uvm_fatal("FATAL_ID",$sformatf("Number of transaction is not randomized"))
  endfunction // new

  tx_agent_config tx_agent_config_h;  // Declaration of agent configuraton object, for configuring sequence

  // Every sequence has a method called pre start which is called before body
  task pre_start();
  	if(!uvm_config_db#(tx_agent_config)::get(null/*instead to "this" reletive path use absolute path*/ /*this*/ /*You will get error if your write "this" because "this" means config_spi_sequence which is transaction not a uvm_component and we need uvm component to pass*/, get_full_name() /*usually for get these commas are empty, but here we will define absolute path by get_full_name()*/, "tx_agent_config_h", tx_agent_config_h))
  		`uvm_fatal("NO AGENT CONFIG",$sformatf("No Agent configuration found in db"))
  endtask : pre_start
  
  // For generating random number of transactions. Just as single transaction can be randomize entire sequences can be randomize. This way you sequences act differently everytime it is run. 
  rand bit [15:0] num_of_xactn;
  constraint size {soft num_of_xactn inside {5,15};}
  
  // A sequence is a block of procedural code that have been wrapped in a method called body
  // Task can have delays
  // Note: Driver limits how fast the stimulus can be applied to the driver by sequence, since the sequence is connected to driver it can send a new transaction when driver is ready
  virtual task body();
    
    // dvider address 0x14
    // control addr   0x10
    // tx_reg         0x0
    // ss             0x18
    // rx_reg         0x20

    // transaction of type transaction_item
    transaction_item tx        ;
    int              cycle     ;
    bit      [31:16] reserved_2;
    bit              rx_en     ;
    bit              tx_en     ;
    bit              ass       ;
    bit              ie        ;
    bit              lsb       ;
    bit              tx_neg    ;
    bit              rx_neg    ;
    bit              go_bsy    ;
    bit              reserved_1;
    bit      [  6:0] char_len  ;
    bit      [ 31:0] ctrl_reg  ;
    string msg="";

    // config_spi_sequence is going to generate 4 transactions of type transaction_item
    repeat(4) begin
      cycle = cycle + 1;
      tx = transaction_item::type_id::create("tx");              // Factory creation (body task create transactions using factory creation)
      start_item(tx);                                            // Waits for a driver to be ready
      if(!tx.randomize())                                        // It randomize the transaction
        `uvm_fatal("ID","transaction is not randomize")          // If it not randomize it will through fatal error
      //tx.addr=tx_agent_config_h.base_address;                  // For fetching base address from agent configuration "It can be a run time value"
      
      // De-asserting
      tx.rst_ni = 1'b1;        

      //Configuring Control and status register
      // Assigning values TODO: Add fields for tx and rx enables
      if (cycle == 'd1) begin
        reserved_2 = 18'd0;
        rx_en      = 1'b0;
        tx_en      = 1'b0;
        ass        = 1'b0;
        ie         = 1'b1;
        lsb        = 1'b1;
        tx_neg     = 1'b0;
        rx_neg     = 1'b0;
        go_bsy     = 1'b0;
        reserved_1 = 1'b0;
        char_len   = 32'd32;
        // concatenating ctrl register fields
        ctrl_reg = {reserved_2,rx_en,tx_en,ass,ie,lsb,tx_neg,rx_neg,go_bsy,reserved_1,char_len};
        `uvm_info ("CONFIG_SPI_SEQUENCES::", $sformatf("ctrl_reg = %0b", ctrl_reg), UVM_LOW)
        // transaction
        tx.addr_i  = 'h10;            
        tx.wdata_i = ctrl_reg;              
        tx.be_i    = 0;           
        tx.we_i    = 1;       
        tx.re_i    = 0;        
        //tx.sd_i    = ;    // miso
      end 
      // Configuring TX register
      else if (cycle == 'd2) begin
        //tx.addr_i  = ;            
        //tx.wdata_i = ;              
        //tx.be_i    = ;           
        tx.we_i    = 1;       
        tx.re_i    = 0;        
        //tx.sd_i    = ;
      end
      // Configuring Divider
      else if (cycle == 'd3) begin
        tx.addr_i  = 'h14;            
        tx.wdata_i = 'h0;              
        //tx.be_i    = ;           
        tx.we_i    = 1;       
        tx.re_i    = 0;        
        //tx.sd_i    = ;
      end

      //// Declaration and initialization
      //tx.rst_ni = 1'b1;
      //tx.reg_we = 1'h1;
      //tx.reg_be = 4'b1111;
      //tx.reg_re = 1'h0;
      //
      //if (cycle == 'b01 || cycle =='b10) begin
      //  //tx.reg_wdata = 64'h000000F0FFFFFFFF;
      //  `uvm_info("\nconfig_spi_sequence::",$sformatf(" [CHECK DATA___________:: %0b", tx.reg_wdata), UVM_LOW)
      //  // If the data is less than or equal to 64'h00000000FFFFFFFF then put the lower 32bit of data in register at address 'h10c 
      //  if(tx.reg_wdata <= 64'h00000000FFFFFFFF && cycle == 'b1) begin
      //    tx.reg_addr = 'h10c;
      //    data = tx.reg_wdata;
      //    print_transaction(tx, "Value to be counted is less than 32 bit");
      //  end
      //  // If the data is less than or equal to 64'h00000000FFFFFFFF then set 32bit register at address 'h110 to zero 
      //  else if (cycle == 'b10 && data <= 64'h00000000FFFFFFFF && lower_data_en == 1'b0) begin
      //    tx.reg_addr = 'h110;
      //    tx.reg_wdata = 64'h00000000;
      //    print_transaction(tx, "Setting all bit of upper compare register to zero");
      //  end
      //  // If the data is greater than 64'h00000000FFFFFFFF then put the lower 32bit of data in register at address 'h10c 
      //  else if (lower_data_en == 1) begin
      //    tx.reg_addr = 'h10c;
      //    tx.reg_wdata = {32'h00000000 , lower_data};
      //    lower_data_en = 1'b0;
      //    print_transaction(tx, "Setting up the lower compare registere as lower_data(lower 32 bit) of input data");
      //  end
      //  // If the data is greater than 64'h00000000FFFFFFFF then put the upper 32bit of data in register at address 'h110 
      //  else begin
      //    upper_data = tx.reg_wdata[63:32];
      //    lower_data = tx.reg_wdata[31:0 ];
      //    tx.reg_addr = 'h110;
      //    tx.reg_wdata = {32'h00000000 , upper_data};
      //    lower_data_en = 1'b1; // Enable bit to assign lower bit to respective register i.e. to tx.reg_wdata[31:0 ] at address 0x110
      //    print_transctn_data(tx, "Value to be counted is greater than 32 bit", upper_data, lower_data);
      //  end
      //end
      //// Configure the timer by writing random values in register at address 'h100 for setting prescale and step value of timer
      //else if (cycle == 'b11) begin
      //  tx.reg_addr = 'h100;
      //  prescale =  /*4*/$urandom();
      //  step     =  /*6*/$urandom();
      //  tx.reg_wdata = {8'b11111111, step, 4'b1111, prescale};
      //  if(step == 0)
      //    `uvm_fatal("config_spi_sequence::FATAL ERROR",$sformatf("Step value is set to zero, please re-run the test"))
      //  //msg = "";
      //  //$sformat(msg, {2{"%s============================"}}    , msg                     );
      //  //$sformat(msg, "%s\nPRE-SCALE RANDOM___________:: %0b"  , msg, prescale           );
      //  //$sformat(msg, "%s\nASSIGNED PRE-SCALE_________:: %0b"  , msg, tx.reg_wdata[11:0] );
      //  //$sformat(msg, "%s\nSTEP RANDOM________________:: %0b"  , msg, step               );
      //  //$sformat(msg, "%s\nASSIGNED STEP______________:: %0b"  , msg, tx.reg_wdata[23:16]);
      //  //$sformat(msg, "%s\nWDATA______________________:: %0b\n", msg, tx.reg_wdata       );
      //  //$sformat(msg, {2{"%s============================"}}    , msg                     );
      //  //`uvm_info("config_spi_sequence::",$sformatf("\n\nSetting prescale and step for the counter\n", msg), UVM_LOW)
      //  print_step_scale(tx, "Setting prescale and step for the counter", prescale, step);
      //end
      //// Enable the interupt pin by writing 1 in register at address 'h114
      //else if (cycle == 'b100) begin
      //  tx.reg_we    = 1'h1;
      //  tx.reg_be    = 4'b1111;
      //  tx.reg_addr  = 'h114;
      //  tx.reg_wdata = 32'h00000001;
      //  print_transaction(tx, "Enabling the interupt");
      //end

      finish_item(tx);  // After randommize send it to the driver and waits for the response from driver to know when the driver is ready again to generate and send the new transaction and so on.
    end
  endtask // body

  //function void print_transaction(transaction_item tx, input string msg);
  //  $sformat(msg, {1{"\n%s\n========================================="}}, msg              );
  //  $sformat(msg, "%s\nADDRESS__________:: %0h"                         , msg, tx.reg_addr );
  //  $sformat(msg, "%s\nWRITE_EN_________:: %0b"                         , msg, tx.reg_we   );
  //  $sformat(msg, "%s\nBYTE_EN__________:: %0b"                         , msg, tx.reg_be   );
  //  $sformat(msg, "%s\nDATA_____________:: %0b\n"                       , msg, tx.reg_wdata);
  //  $sformat(msg, {1{"%s=========================================\n"}}  , msg              );
  //  `uvm_info("config_spi_sequence::",$sformatf("\n", msg), UVM_LOW)  
  //  msg = "";
  //endfunction : print_transaction
  //
  //function void print_transctn_data(transaction_item tx, input string msg, input bit [31:0] upper_data, input bit [31:0] lower_data);
  //  $sformat(msg, {1{"\n%s\n========================================="}}, msg              );
  //  $sformat(msg, "%s\nUPPER-DATA_______:: %0b"                         , msg, upper_data  );
  //  $sformat(msg, "%s\nLOWER-DATA_______:: %0b"                         , msg, lower_data  );
  //  $sformat(msg, "%s\nADDRESS__________:: %0h"                         , msg, tx.reg_addr );
  //  $sformat(msg, "%s\nWRITE_EN_________:: %0b"                         , msg, tx.reg_we   );
  //  $sformat(msg, "%s\nBYTE_EN__________:: %0b"                         , msg, tx.reg_be   );
  //  $sformat(msg, "%s\nDATA_____________:: %0b\n"                       , msg, tx.reg_wdata);
  //  $sformat(msg, {1{"%s========================================="}}    , msg              );
  //  `uvm_info("config_spi_sequence::",$sformatf("\n", msg), UVM_LOW)  
  //  msg = "";
  //endfunction : print_transctn_data
  //
  //function void print_step_scale(transaction_item tx, input string msg, input bit [11:0] prescale, input bit [23:16] step);
  //  $sformat(msg, {1{"\n%s\n========================================="}}, msg                     );
  //  $sformat(msg, "%s\nPRE-SCALE RANDOM___________:: %0d"               , msg, prescale           );
  //  $sformat(msg, "%s\nASSIGNED PRE-SCALE_________:: %0d"               , msg, tx.reg_wdata[11:0] );
  //  $sformat(msg, "%s\nSTEP RANDOM________________:: %0d"               , msg, step               );
  //  $sformat(msg, "%s\nASSIGNED STEP______________:: %0d"               , msg, tx.reg_wdata[23:16]);
  //  $sformat(msg, "%s\nWDATA______________________:: %0b\n"             , msg, tx.reg_wdata       );
  //  $sformat(msg, {1{"%s========================================="}}    , msg                     );
  //  `uvm_info("config_spi_sequence::",$sformatf("\n", msg), UVM_LOW)
  //  msg = "";
  //endfunction : print_step_scale

endclass // config_spi_sequence
