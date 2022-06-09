///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    27-MAY-2022                                                                       //
// Design Name:    SPI                                                                               //
// Module Name:    spi_monitor.sv                                                                    //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
// Monitor is parameterize component class, as shown here the monitor get transactions from DUT      //
// and send transaction to other components like scoreboard and coverage collector                   //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class spi_monitor extends uvm_monitor;
	// For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
	// Pass the class name to it
  `uvm_component_utils(spi_monitor)

  /*
	Then declare spi_monitor class constructor
	Since a class object has to be constructed before it exit in a memory
	The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
	Since a module(top module) is static object that is present at beginning of simulation 
	*/
	// Component Constructor have two arguments to specify the name and handle of the parent of this component in testbench topology
	function new(string name, uvm_component parent);
    super.new(name, parent);
	endfunction // new
  
  // Declaring a virtual interface which connects DUT and testbench. Virtual interfaces in system verilog virtual means something is a reference to something else
  // Note tx_agent_config object with virtual interface is present(set) in uvm_config_db
  virtual test_ifc vif;
  tx_agent_config tx_agent_config_h; // Declaration of agent configuraton object
  
  // TLM analysis port
  uvm_analysis_port #(transaction_item) dut_tx_port;

  function void build_phase(uvm_phase phase);
    `uvm_info("UART_MONITOR::",$sformatf("______BUILD_PHASE______"), UVM_LOW)
    // Creating analysis port TLM analysis ports are not created with factory
    dut_tx_port = new ("dut_tx_port",this);
    if(!uvm_config_db#(tx_agent_config)::get(this/*Handle to this component*/, ""/*an empty instance name*/, "tx_agent_config_h"/*Name of the object in db*/, tx_agent_config_h/*Handle that the db writes to*/))
      `uvm_fatal("spi_monitor::NO AGENT CONFIG",$sformatf("No agent config in db"))
    // Note now you can read the values from config object
    vif = tx_agent_config_h.vif;
    // Display the base address from config object
    `uvm_info(get_type_name(), $sformatf("config base adddress = %0x", tx_agent_config_h.base_address), UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    // Function to get transaction from virtual interface
    fork
      capture_control_register();
      get_transaction();
      get_tranxaction();
      count_clk();
    join_none
    //`uvm_info(get_type_name(), $sformatf("count_clock_cycles = %0d", count_clock_cycles), UVM_LOW)
  endtask
  
  // Declaration
  string msg ="";
  bit [ 76:0] cycle_num = 0                           ;
  int         set                                     ;
  int         clct_mosi                               ;
  int         count                                   ;
  int         data                                    ;
  bit         next_data                               ;
  bit         reg1_slav1_enable                       ;
  bit         reg2_slav1_enable                       ;
  int         count_clock_cycles                      ;
  bit  [31:0] reg1_slav1_collection_q[$]              ;
  bit  [31:0] reg2_slav1_collection_q[$]              ;
  bit  [31:0] chker_reg1_slav1_collection_q[$]        ;
  bit  [31:0] chker_reg2_slav1_collection_q[$]        ;
  int         counter                                 ;
  bit  [31:0] contrl_reg                              ;
  bit  [31:0] mosi_data_collection_q[$]               ;
  bit  [31:0] tb_driven_tx_config_data_collection_q[$];
  bit         lock                                    ;
  bit  [31:0] control_register                        ;


  // Task for capturing control register @every posedge of clock
  virtual task capture_control_register();
    // Transaction Handle declaration
    transaction_item tx_ctrl_reg;
    forever begin
      @(posedge vif.clk_i)
        tx_ctrl_reg = transaction_item::type_id::create("tx_ctrl_reg");
        tx_ctrl_reg.rst_ni  = vif.rst_ni ;        
        tx_ctrl_reg.addr_i  = vif.addr_i ;            
        tx_ctrl_reg.wdata_i = vif.wdata_i;              
        tx_ctrl_reg.be_i    = vif.be_i   ;           
        tx_ctrl_reg.we_i    = vif.we_i   ;       
        tx_ctrl_reg.re_i    = vif.re_i   ;        
        tx_ctrl_reg.sd_i    = vif.sd_i   ;                       // master in slave out
        
        // Assigning counter the value char length that is present in 7 LSB of control register  
        if (tx_ctrl_reg.addr_i == 'h10) begin
            control_register = tx_ctrl_reg.wdata_i;
            `uvm_info("SPI_MONITIOR::", $sformatf("Control register = %0b",control_register), UVM_LOW)
        end
    end
  endtask 

  virtual task get_transaction();
    // Transaction Handle declaration
    transaction_item tx;
    forever begin
      @(posedge vif.sclk_o)
        tx = transaction_item::type_id::create("tx");
        tx.rst_ni  = vif.rst_ni ;        
        tx.addr_i  = vif.addr_i ;            
        tx.wdata_i = vif.wdata_i;              
        tx.be_i    = vif.be_i   ;           
        tx.we_i    = vif.we_i   ;       
        tx.re_i    = vif.re_i   ;        
        tx.sd_i    = vif.sd_i   ;                       // master in slave out

        clct_mosi[count] = vif.sd_o;
        count = count + 1;

        // Assigning counter the value char length that is present in 7 LSB of control register  
        //if (tx.addr_i == 'h10) begin
        if (lock == 0) begin
          lock = 1;
          contrl_reg = control_register;
          counter = 10/*contrl_reg[6:0]*/;                                                       // TODO always select the randomize data
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing Counter = %0d",counter), UVM_LOW)
        end
        //end

        // Data collection depending on the char length
        if(count == counter) begin
          data = clct_mosi;
          if(contrl_reg[14]==1) begin
            mosi_data_collection_q.push_front(clct_mosi);
          end
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing the collected mosi = %0b",data), UVM_LOW)
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing the slave select output signal = %0b", vif.ss_o), UVM_LOW)
          // Check if rx is enabled in conrol register and tx is disabled
          if(contrl_reg[8]==1 && contrl_reg[15]==1 && contrl_reg[14]==0) begin
            wait(vif.intr_rx_o == 1'b1);
            count = 0;
            reg1_slav1_enable = 1'b0;
            reg2_slav1_enable = 1'b0;
          end
        end

        // slave 1
        if(!vif.ss_o[0] && count == counter) begin
          if(contrl_reg[8]==1 && contrl_reg[15]==1 && contrl_reg[14]==1) begin
            wait(vif.intr_tx_o == 1'b1);
            count = 0;
            lock = 0;
          end
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing the collected data = %0b",data), UVM_LOW)
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 1"), UVM_LOW)
          // Check if data send by driver is a command or a data. And if it is command detect either read or write operation is performed
          if(data[1:0] == 2'b11 && data[2] == 1'b1) begin // data[2] == 1 and data[1:0] == 2'b11, that means command data is command and write is to be performed respectively. 
            `uvm_info("SPI_MONITIOR::", $sformatf("Next will be tx data"), UVM_LOW)
            reg1_slav1_enable = 1'b1;
            reg2_slav1_enable = 1'b0;
            `uvm_info("SPI_MONITIOR::", $sformatf("Printing write enable = %0d", reg1_slav1_enable), UVM_LOW)
            count = 0;
            wait(vif.intr_tx_o == 1'b1);
            lock = 0;
          end
          // Check if data send by driver is a command or a data. And if it is command detect either read or write operation is performed
          else if (data[1:0] == 2'b10 && data[2] == 1'b1) begin // data[2] == 1 and data[1:0] == 2'b11, that means command data is command and write is to be performed respectively.
            `uvm_info("SPI_MONITIOR::", $sformatf("Next will be rx data"), UVM_LOW)
            reg1_slav1_enable = 1'b0;
            reg2_slav1_enable = 1'b1;
            count = 0;
            wait(vif.intr_tx_o == 1'b1);
            lock = 0;
          end

          // Write operation is to be performed in reg1
          if (reg1_slav1_enable == 1'b1 && contrl_reg[8]==1 && contrl_reg[14]==1 && (data[2:0] != 3'b111)) begin
             `uvm_info("SPI_MONITIOR::", $sformatf("Coming data is tx"), UVM_LOW)
             `uvm_info("SPI_MONITIOR::", $sformatf("Printing output tx data to be pushed in queue = %0b",data), UVM_LOW)
             reg1_slav1_collection_q.push_front(data);
             count = 0;
             wait(vif.intr_tx_o == 1'b1);
             lock = 0;
          end
          // Write operation is to be performed in reg2
          else if (reg2_slav1_enable == 1'b1 && contrl_reg[8]==1 && contrl_reg[14]==1 && (data[2:0] != 3'b110)) begin
            `uvm_info("SPI_MONITIOR::", $sformatf("Coming data is tx"), UVM_LOW)
            `uvm_info("SPI_MONITIOR::", $sformatf("Printing output tx data to be pushed in queue = %0b",data), UVM_LOW)
            reg2_slav1_collection_q.push_front(data);
            count = 0;
            wait(vif.intr_tx_o == 1'b1);
            lock = 0;
          end
        end
        
        // slave 2
        if(!vif.ss_o[1] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 2"), UVM_LOW)
        end
        // slave 3
        if(!vif.ss_o[2] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 3"), UVM_LOW)
        end
        // slave 3
        if(!vif.ss_o[3] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 4"), UVM_LOW)
        end

    end // forever
  endtask

  bit  [31:0] length                       ;
  bit  [31:0] data_queued                  ;
  bit  [31:0] ctrl_reg                     ;
  bit  [31:0] drive_data                   ;
  int         num_of_runs                  ;
  bit         chkr_reg1_slav1_drive_data_en;
  bit         chkr_reg2_slav1_drive_data_en;
  bit         wr_en_driving_data           ;
  bit         lock_ctrl_reg                ;
  bit         first_config                 ;

  virtual task get_tranxaction();
    // Transaction Handle declaration
    transaction_item tx;
    forever begin
      @(posedge vif.clk_i)
        tx = transaction_item::type_id::create("tx");
        tx.rst_ni  = vif.rst_ni ;        
        tx.addr_i  = vif.addr_i ;            
        tx.wdata_i = vif.wdata_i;              
        tx.be_i    = vif.be_i   ;           
        tx.we_i    = vif.we_i   ;       
        tx.re_i    = vif.re_i   ;        
        tx.sd_i    = vif.sd_i   ;                       // master in slave out
        
        if (tx.addr_i == 'h0 && tx.be_i == 'b1111 && tx.we_i == 'h1 && tx.re_i == 'h0) begin
          drive_data = tx.wdata_i;
          if (first_config == 0) begin
            tb_driven_tx_config_data_collection_q.push_front(drive_data[9:0]);
            first_config = 1;
          end
          if (ctrl_reg[14] == 1'h1) begin
            tb_driven_tx_config_data_collection_q.push_front(drive_data[9:0]);
            `uvm_info("SPI_MONITIOR::", $sformatf("Printing drive_data %0b", drive_data), UVM_LOW)
          end
        end

        if(tx.addr_i == 'h10 && tx.be_i == 'b1111 && tx.we_i == 1 && tx.re_i == 0) begin
          length = 10/*tx.wdata_i[6:0]*/;
          if (lock_ctrl_reg == 0)
            ctrl_reg = vif.wdata_i;
          //`uvm_info("SPI_MONITIOR::", $sformatf("Printing length %d", length), UVM_LOW)
          //`uvm_info("SPI_MONITIOR::", $sformatf("Printing control register ctrl_Reg %b", ctrl_reg), UVM_LOW)
          
          if (ctrl_reg[14] == 1'h1) begin
            lock_ctrl_reg = 1;
            // Check if driving signal is tx cmd or tx data
            if (drive_data[1:0] == 2'b11 && drive_data[2] == 1'b1 && ctrl_reg[8] == 1'h1 && ctrl_reg[14] == 1'h1) begin
              chkr_reg1_slav1_drive_data_en = 1'b1;
              chkr_reg2_slav1_drive_data_en = 1'b0;
            end
            else if (drive_data[1:0] == 2'b10 && drive_data[2] == 1'b1 && ctrl_reg[8] == 1'h1 && ctrl_reg[14] == 1'h1) begin
              chkr_reg1_slav1_drive_data_en = 1'b0;
              chkr_reg2_slav1_drive_data_en = 1'b1;
            end
            if (ctrl_reg[8] == 1'h1 && ctrl_reg[14] == 1'h0) begin
              chkr_reg1_slav1_drive_data_en = 1'b0;
              chkr_reg2_slav1_drive_data_en = 1'b0;
            end          
            
            // Logic to push data in chker_reg1_slav1_collection_q
            if (chkr_reg1_slav1_drive_data_en == 1 && drive_data[2:0] != 3'b111) begin
              num_of_runs = num_of_runs + 1'b1;
              for(int index=0; index < length; index=index+1) begin
                data_queued[index] = drive_data[index];
              end
              if (num_of_runs==1) begin
                `uvm_info("SPI_MONITIOR::", $sformatf("Printing data queue %0h", data_queued), UVM_LOW)
                chker_reg1_slav1_collection_q.push_front(data_queued/*tx.wdata_i*/);
                wait(vif.intr_tx_o);
                lock_ctrl_reg = 0;
                `uvm_info("SPI_MONITIOR::", $sformatf("tx_adress %0h", tx.addr_i), UVM_LOW)
                `uvm_info("SPI_MONITIOR::", $sformatf("second run value %0d", num_of_runs), UVM_LOW)
              end 
              if (num_of_runs==2) begin
                num_of_runs=0;
              end
            end

            // Logic to push data in chker_reg2_slav1_collection_q
            if (chkr_reg2_slav1_drive_data_en == 1 && drive_data[2:0] != 3'b110) begin
              num_of_runs = num_of_runs + 1'b1;
              for(int index=0; index < length; index=index+1) begin
                data_queued[index] = drive_data[index];
              end
              if (num_of_runs==1) begin
                `uvm_info("SPI_MONITIOR::", $sformatf("Printing data queue %0h", data_queued), UVM_LOW)
                chker_reg2_slav1_collection_q.push_front(data_queued/*tx.wdata_i*/);
                wait(vif.intr_tx_o);
                lock_ctrl_reg = 0;
                `uvm_info("SPI_MONITIOR::", $sformatf("tx_adress %0h", tx.addr_i), UVM_LOW)
                `uvm_info("SPI_MONITIOR::", $sformatf("second run value %0d", num_of_runs), UVM_LOW)
              end 
              if (num_of_runs==2) begin
                num_of_runs=0;
              end
            end
          end
          if (ctrl_reg[14] == 0)
            tb_driven_tx_config_data_collection_q.delete(0); 
        end

        //if(vif.intr_tx_o || vif.intr_rx_o) begin
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print mosi_data_collection_q = %p", mosi_data_collection_q), UVM_LOW)
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print tb_driven_tx_config_data_collection_q = %p", tb_driven_tx_config_data_collection_q), UVM_LOW)
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print reg1_slav1_collection_q = %p", reg1_slav1_collection_q), UVM_LOW)
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print reg2_slav1_collection_q = %p", reg2_slav1_collection_q), UVM_LOW)
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print chker_reg1_slav1_collection_q = %p", chker_reg1_slav1_collection_q), UVM_LOW)
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print chker_reg2_slav1_collection_q = %p", chker_reg2_slav1_collection_q), UVM_LOW)
        //  `uvm_info("SPI_MONITIOR::", $sformatf("Print Number of clock = %d", count_clock_cycles), UVM_LOW)
        //  count_clock_cycles = 0;
        //end

    end // forever
  endtask

  virtual task count_clk();
    // Transaction Handle declaration
    transaction_item tx;
    forever begin
      @(posedge vif.sclk_o)
        count_clock_cycles = count_clock_cycles + 1;
    end // forever
  endtask

  virtual function void check_phase(uvm_phase phase);
    int mismatch = 0;

    `uvm_info("SPI_MONITIOR::", $sformatf("Print mosi_data_collection_q = %p", mosi_data_collection_q), UVM_LOW)
    `uvm_info("SPI_MONITIOR::", $sformatf("Print tb_driven_tx_config_data_collection_q = %p", tb_driven_tx_config_data_collection_q), UVM_LOW)
    `uvm_info("SPI_MONITIOR::", $sformatf("Print reg1_slav1_collection_q = %p", reg1_slav1_collection_q), UVM_LOW)
    `uvm_info("SPI_MONITIOR::", $sformatf("Print reg2_slav1_collection_q = %p", reg2_slav1_collection_q), UVM_LOW)
    `uvm_info("SPI_MONITIOR::", $sformatf("Print chker_reg1_slav1_collection_q = %p", chker_reg1_slav1_collection_q), UVM_LOW)
    `uvm_info("SPI_MONITIOR::", $sformatf("Print chker_reg2_slav1_collection_q = %p", chker_reg2_slav1_collection_q), UVM_LOW)
    `uvm_info("SPI_MONITIOR::", $sformatf("Print Number of clock = %d", count_clock_cycles), UVM_LOW)

    if (mosi_data_collection_q == tb_driven_tx_config_data_collection_q)
      `uvm_info(get_type_name(), $sformatf("[COMPARISON PASSED] Drived data & MOSI"), UVM_LOW)
    else begin
      `uvm_fatal("FATAL_ID",$sformatf("COMPARISON FAILED] Drived data and MOSI"))
      mismatch = mismatch + 1;
    end
    if (reg1_slav1_collection_q == chker_reg1_slav1_collection_q)
      `uvm_info(get_type_name(), $sformatf("[COMPARISON PASSED] slave 1's first storage element & checker of slave 1"), UVM_LOW)
    else begin
      `uvm_fatal("FATAL_ID",$sformatf("COMPARISON FAILED] slave 1's first storage element & checker of slave 1"))
      mismatch = mismatch + 1;
    end
    if (reg2_slav1_collection_q == chker_reg2_slav1_collection_q)
      `uvm_info(get_type_name(), $sformatf("[COMPARISON PASSED] slave 1's second storage element & checker of slave 1"), UVM_LOW)
    else begin
      `uvm_fatal("FATAL_ID",$sformatf("COMPARISON FAILED] slave 1's second storage element & checker of slave 1"))
    mismatch = mismatch + 1;
    end
    if (mismatch != 0)
      tf();
    else
      tp();
  endfunction

  //function void print_transaction(transaction_item tx);
  //  msg = "";
  //  cycle_num = ++cycle_num;
  //  $sformat(msg, {2{"%s============================"}}, msg                             );
  //  $sformat(msg, "%s\nCYCLE_NUMBER___________:: %0d"  , msg, cycle_num                  );
  //  $sformat(msg, "%s\nRESRT__________________:: %0h"  , msg, tx.rst_ni                  );
  //  $sformat(msg, "%s\nADDRESS________________:: %0h"  , msg, tx.reg_addr                );
  //  $sformat(msg, "%s\nWRITE_EN_______________:: %0b"  , msg, tx.reg_we                  );
  //  $sformat(msg, "%s\nBYTE_EN________________:: %0b"  , msg, tx.reg_be                  );
  //  $sformat(msg, "%s\nW_DATA_________________:: %0d"  , msg, tx.reg_wdata               );
  //  $sformat(msg, "%s\nREAD_EN________________:: %0b"  , msg, tx.reg_re                  );
  //  $sformat(msg, "%s\nR_DATA_________________:: %0d"  , msg, tx.reg_rdata               );
  //  $sformat(msg, "%s\nERROR__________________:: %0d"  , msg, tx.reg_error               );
  //  $sformat(msg, "%s\nTIMER EXPIRED__________:: %0d\n", msg, tx.intr_timer_expired_0_0_o);
  //  $sformat(msg, "%s\nASSIGNED PRE-SCALE_____:: %0d"  , msg, tx.reg_wdata[11:0]         );
  //  $sformat(msg, "%s\nASSIGNED STEP__________:: %0d\n", msg, tx.reg_wdata[23:16]        );
  //  $sformat(msg, {2{"%s============================"}}, msg                             );
  //  `uvm_info("UART_MONITOR::",$sformatf("\n\nCapturing the signals from the interface\n", msg), UVM_LOW)
  //endfunction : print_transaction
  //
  //function void print_num_of_cycles_req(input bit[11:0] prescale, input bit [63:0] data, input bit [23:16] step, input bit [31:0] div_q, input bit [4:0] div_r, input bit [76:0] cycle_to_get_result);
  //  msg = "";
  //  $sformat(msg, {2{"%s============================"}}   , msg                     );
  //  $sformat(msg, "%s\nPRE-SCALE_VALUE___________:: %0d"  , msg, prescale           );
  //  $sformat(msg, "%s\nDATA VALUE________________:: %0d"  , msg, data               );
  //  $sformat(msg, "%s\nSTEP VALUE________________:: %0d"  , msg, step               );
  //  $sformat(msg, "%s\nDIV QUOTIENT______________:: %0d"  , msg, div_q              );
  //  $sformat(msg, "%s\nDIV REMINDER______________:: %0d"  , msg, div_r              );
  //  $sformat(msg, "%s\nCYCLE TO GET RESULT_______:: %0d\n", msg, cycle_to_get_result);
  //  $sformat(msg, {2{"%s============================"}}   , msg                     );
  //  `uvm_info("TIMER_DRIVER::",$sformatf("\n\nPrinting the number of cycles to complete the count and related field in monitor\n", msg), UVM_LOW)
  //endfunction : print_num_of_cycles_req
  //
  //function void print_test_passed(input bit [76:0] cycle_to_get_result, input bit[76:0] cycle_num);
  //  msg = "";
  //  $sformat(msg, {2{"%s============================"}}   , msg                     );
  //  $sformat(msg, "%s\nCycle_to_get_result_______:: %0d"  , msg, cycle_to_get_result);
  //  $sformat(msg, "%s\nCycle_Num_________________:: %0d\n", msg, cycle_num          );
  //  $sformat(msg, {2{"%s============================"}}   , msg                     );
  //  `uvm_info("TEST PASSED",$sformatf("\n\nTimer succesfully counted the configured value\n", msg), UVM_LOW)
  //  tp();
  //endfunction : print_test_passed
  //
  //function void print_test_failed(input bit [76:0] cycle_to_get_result, input bit[76:0] cycle_num);
  //  msg = "";
  //  $sformat(msg, {2{"%s============================"}}   , msg                     );
  //  $sformat(msg, "%s\nCycle_to_get_result_______:: %0d"  , msg, cycle_to_get_result);
  //  $sformat(msg, "%s\nCycle_Num_________________:: %0d\n", msg, cycle_num          );
  //  $sformat(msg, {2{"%s============================"}}   , msg                     );
  //  `uvm_info("TEST FAILED::",$sformatf("\n\nTimer failed to count the configured value\n", msg), UVM_LOW)
  //  tf();
  //endfunction : print_test_failed
  //
  function void tp();
    msg = "";
    $sformat(msg, "%s\n\n████████╗███████╗███████╗████████╗    ██████╗  █████╗ ███████╗███████╗███████╗██████╗  ", msg);
    $sformat(msg, "%s\n╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗ ", msg);
    $sformat(msg, "%s\n   ██║   █████╗  ███████╗   ██║       ██████╔╝███████║███████╗███████╗█████╗  ██║  ██║ ", msg);
    $sformat(msg, "%s\n   ██║   ██╔══╝  ╚════██║   ██║       ██╔═══╝ ██╔══██║╚════██║╚════██║██╔══╝  ██║  ██║ ", msg);
    $sformat(msg, "%s\n   ██║   ███████╗███████║   ██║       ██║     ██║  ██║███████║███████║███████╗██████╔╝ ", msg);
    $sformat(msg, "%s\n   ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═════╝  \n", msg);
    `uvm_info("TEST STATUS::",$sformatf("\n", msg), UVM_LOW)
  endfunction : tp
  
  function void tf();
    msg = "";
    $sformat(msg, "%s\n\n ████████╗███████╗███████╗████████╗    ███████╗ █████╗ ██╗██╗     ███████╗██████╗ ", msg);
    $sformat(msg, "%s\n ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔════╝██╔══██╗██║██║     ██╔════╝██╔══██╗", msg);
    $sformat(msg, "%s\n    ██║   █████╗  ███████╗   ██║       █████╗  ███████║██║██║     █████╗  ██║  ██║", msg);
    $sformat(msg, "%s\n    ██║   ██╔══╝  ╚════██║   ██║       ██╔══╝  ██╔══██║██║██║     ██╔══╝  ██║  ██║", msg);
    $sformat(msg, "%s\n    ██║   ███████╗███████║   ██║       ██║     ██║  ██║██║███████╗███████╗██████╔╝", msg);
    $sformat(msg, "%s\n    ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝ \n", msg);
     `uvm_info("TEST STATUS::",$sformatf("\n", msg), UVM_LOW)                     
  endfunction : tf

endclass

