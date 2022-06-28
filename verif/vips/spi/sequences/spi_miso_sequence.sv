///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    02-June-2022                                                                      //
// Design Name:    SPI                                                                               //
// Module Name:    spi_miso_sequence.sv                                                              //
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
//       - sequnce is parameterize class, as shown here the spi_miso_sequence only send              // 
//         transaction_item transaction                                                              //
//                                                                                                   //
//        This sequuence is used to configure the timer by passing constraint random values to DUT   //
//        via driver and interface                                                                   //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class spi_miso_sequence extends uvm_sequence #(transaction_item);
	// For sequence we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(spi_miso_sequence)

  /*
	Then declare spi_miso_sequence class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module is static object that is present at beginning of simulation 
	*/
  function new (string name="spi_miso_sequence");
    super.new(name);
    // In constructor this object can be randomize to set the block size, typicaly we don't randomize in constructor
    if(!this.randomize())
    	`uvm_fatal("FATAL_ID",$sformatf("Number of transaction is not randomized"))
  endfunction // new

  tx_agent_config tx_agent_config_h;  // Declaration of agent configuraton object, for configuring sequence

  // Every sequence has a method called pre start which is called before body
  task pre_start();
  	if(!uvm_config_db#(tx_agent_config)::get(null/*instead to "this" reletive path use absolute path*/ /*this*/ /*You will get error if your write "this" because "this" means spi_miso_sequence which is transaction not a uvm_component and we need uvm component to pass*/, get_full_name() /*usually for get these commas are empty, but here we will define absolute path by get_full_name()*/, "tx_agent_config_h", tx_agent_config_h))
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
    transaction_item tx             ;
    int              cycle          ;
    bit      [31:16] reserved_2     ;
    bit              rx_en          ;
    bit              tx_en          ;
    bit              ass            ;
    bit              ie             ;
    bit              lsb            ;
    bit              tx_neg         ;
    bit              rx_neg         ;
    bit              go_bsy         ;
    bit              reserved_1     ;
    bit      [  6:0] char_len       ;
    bit      [31:0]  divider        ;
    bit      [ 31:0] ctrl_reg       ;
    bit              send_rx        ;
    bit      [ 31:0] count_length   ;
    bit              rd_miso_reg    ;
    bit previous_sd_i               ;
    int count_divider_clk           ;
    int divider_clk_cycle           ;
    int count_clk_cycles_b4_clk_o   ;
    int first_time                  ;
    int counter                     ;
    string msg="";

    // spi_miso_sequence is going to generate 4 transactions of type transaction_item
    repeat(223) begin                                             // It should be an even number
      tx = transaction_item::type_id::create("tx");              // Factory creation (body task create transactions using factory creation)
      start_item(tx);                                            // Waits for a driver to be ready
      if(!tx.randomize())                                        // It randomize the transaction
        `uvm_fatal("ID","transaction is not randomize")          // If it not randomize it will through fatal error
      //tx.addr=tx_agent_config_h.base_address;                  // For fetching base address from agent configuration "It can be a run time value"
      
      // De-asserting
      tx.rst_ni = 1'b1;
      char_len  = `CHAR_LENGTH_CTRL_REG/*30*/ /*tx.char_len*/;
      divider   = `DIVIDER_REG;
      reserved_2 = 18'd0;
      ass        = 1'b0;
      ie         = 1'b1;
      lsb        = 1'b1;
      tx_neg     = 1'b0;
      rx_neg     = 1'b0;
      reserved_1 = 1'b0;

      cycle = cycle + 1;
      
      // Enabling RX
      if (send_rx == 0) begin
        send_rx = 1;
        tx_en      = 1'b0;
        rx_en      = 1'b1;
        go_bsy     = 1'b1;
        ctrl_reg = {reserved_2,rx_en,tx_en,ass,ie,lsb,tx_neg,rx_neg,go_bsy,reserved_1,char_len};
        `uvm_info ("spi_miso_sequenceS::", $sformatf("ctrl_reg = %0b", ctrl_reg), UVM_LOW)
        // Transaction
        tx.addr_i  = 'h10;           
        tx.wdata_i = ctrl_reg;              
        tx.be_i    = 'b1111;           
        tx.we_i    = 1'h1;       
        tx.re_i    = 1'h0;     
        print_transaction(tx, "Enabing MISO");
      end

      // Following logic is responsible for settitng sd_i from negative to negative edge of clock 
      else if (send_rx == 1 && rd_miso_reg == 0) begin
        tx.addr_i  = 'h0;
        tx.be_i    = 'b1111;           
        tx.we_i    = 'h1;       
        tx.re_i    = 'h0;   
        
        // Generating the same value of sd_i at ne to poistive edge of sclk_o 
        /////////////////////////////////////////////////////
        /////////////// IMPORTANT CODE /////////////////////
        ////////////////////////////////////////////////////
        //if (count_divider_clk == 0) begin
        //  previous_sd_i = tx.sd_i;                                                         // Randomized sd_i
        //  `uvm_info("spi_miso_sequenceS::",$sformatf("Printing previous value = %0d", previous_sd_i), UVM_LOW)
        //end
        //// previous_sd_i = tx.sd_i;
        //divider_clk_cycle = (divider)*2 + 2;
        //count_divider_clk = count_divider_clk + 1;  
        //if (count_divider_clk <= divider_clk_cycle) begin
        //  tx.sd_i = previous_sd_i;
        //  `uvm_info("spi_miso_sequenceS::",$sformatf("Printing updated tx_sd_i = %0d", tx.sd_i), UVM_LOW)
        //  if (count_divider_clk == divider_clk_cycle)
        //    count_divider_clk = 0;
        //end
        ////////////////////////////////

        counter = counter + 1;
        if (counter <= 23) begin
          if (count_divider_clk == 0) begin
            previous_sd_i = tx.sd_i;                                                          // Randomized sd_i
            `uvm_info("spi_miso_sequenceS::",$sformatf("Printing previous value = %0d", previous_sd_i), UVM_LOW)
          end
          divider_clk_cycle = (divider)*2 + 2;
          count_divider_clk = count_divider_clk + 1;  
          if (count_divider_clk <= divider_clk_cycle) begin
            tx.sd_i = previous_sd_i;
            `uvm_info("spi_miso_sequenceS::",$sformatf("Printing updated tx_sd_i = %0d", tx.sd_i), UVM_LOW)
            if (count_divider_clk == divider_clk_cycle)
              count_divider_clk = 0;
          end
        end
        else begin
          if (count_divider_clk == 1 && first_time == 1) begin
            previous_sd_i = tx.sd_i;                                                          // Randomized sd_i
            `uvm_info("spi_miso_sequenceS::",$sformatf("Printing previous value = %0d", previous_sd_i), UVM_LOW)
          end
          first_time = 1;
          // previous_sd_i = tx.sd_i;
          divider_clk_cycle = (divider)*2 + 2;
          count_divider_clk = count_divider_clk + 1;  
          if (count_divider_clk <= divider_clk_cycle) begin
            tx.sd_i = previous_sd_i;
            `uvm_info("spi_miso_sequenceS::",$sformatf("Printing updated tx_sd_i = %0d", tx.sd_i), UVM_LOW)
            if (count_divider_clk == divider_clk_cycle)
              count_divider_clk = 0;
          end
        end
        print_transaction(tx, "Randomly applying MISO");
        count_length = count_length + 1;
        // If the serial data is reached its length
        if (count_length == (char_len * ((divider*2)+2)+3/*extra 3 cycles*/ ) ) begin
          `uvm_info("spi_miso_sequenceS::",$sformatf("Print (char_len * ((divider*2)+2)) = %0d", count_length), UVM_LOW)
          count_length = 0;
          rd_miso_reg = 1;
        end
      end

      // for reading the MISO register MISO
      else if (rd_miso_reg == 1) begin
        send_rx = 0;
        rd_miso_reg = 0;
        count_divider_clk = 0;
        count_clk_cycles_b4_clk_o = 0;
        tx.addr_i  = 'h20;           
        tx.be_i    = 'b1111;           
        tx.we_i    = 1'h0;       
        tx.re_i    = 1'h1;     
        print_transaction(tx, "Reading MISO");
      end

      finish_item(tx);  // After randommize send it to the driver and waits for the response from driver to know when the driver is ready again to generate and send the new transaction and so on.
    end
  endtask // body

  function void print_transaction(transaction_item tx, input string msg);
    $sformat(msg, {1{"\n%s\n========================================="}}, msg            );
    $sformat(msg, "%s\nRESET__________:: %0h"                           , msg, tx.rst_ni );
    $sformat(msg, "%s\nADDRESS________:: %0b"                           , msg, tx.addr_i );
    $sformat(msg, "%s\nDATA___________:: %0b"                           , msg, tx.wdata_i);
    $sformat(msg, "%s\nBYTE_EN________:: %0b"                           , msg, tx.be_i   );
    $sformat(msg, "%s\nWRITE_EN_______:: %0b"                           , msg, tx.we_i   );
    $sformat(msg, "%s\nREAD_EN________:: %0b"                           , msg, tx.re_i   );
    $sformat(msg, "%s\nMISO___________:: %0b\n"                         , msg, tx.sd_i   );
    $sformat(msg, {1{"%s======================================== \n"}}  , msg            );
    `uvm_info("spi_miso_sequenceS::",$sformatf("\n", msg), UVM_LOW)
    msg = "";
  endfunction : print_transaction        

endclass // spi_miso_sequence

  // control addr   0x10
  // tx_reg         0x0
  // dvider address 0x14
  // ss             0x18
  // rx_reg         0x20
