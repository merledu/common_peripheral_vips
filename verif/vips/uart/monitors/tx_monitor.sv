///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    10-MARCH-2022                                                                     //
// Design Name:    UART                                                                              //
// Module Name:    tx_monitor.sv                                                                     //
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

class tx_monitor extends uvm_monitor;
	// For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
	// Pass the class name to it
  `uvm_component_utils(tx_monitor)

  /*
	Then declare tx_monitor class constructor
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
  virtual test_ifc vif_tx;
  tx_agent_config tx_agent_config_h; // Declaration of agent configuraton object
  // TLM analysis port
  uvm_analysis_port #(transaction_item) dut_tx_port;
  
  function void build_phase(uvm_phase phase);
    `uvm_info("UART_MONITOR::",$sformatf("______BUILD_PHASE______"), UVM_LOW)
    // Creating analysis port TLM analysis ports are not created with factory
    dut_tx_port = new ("dut_tx_port",this);
    if(!uvm_config_db#(tx_agent_config)::get(this/*Handle to this component*/, ""/*an empty instance name*/, "tx_agent_config_h"/*Name of the object in db*/, tx_agent_config_h/*Handle that the db writes to*/))
      `uvm_fatal("TX_MONITOR::NO vif_tx",$sformatf("No virtual interface in db"))
    // Note now you can read the values from config object
    vif_tx = tx_agent_config_h.vif_tx;
    // Display the base address from config object
    `uvm_info(get_type_name(), $sformatf("config base adddress = %0x", tx_agent_config_h.base_address), UVM_LOW)
  endfunction : build_phase
  
  virtual task run_phase(uvm_phase phase);
    // Function to get transaction from virtual interface
    get_transaction();
  endtask
  
  // Declaration
  string msg ="";
  bit [76:0] cycle_num = 0     ; // NOTE: Change the width w.r.t. uart max cycle
  bit [15:0] baud_rate         ;
  bit [ 3:0] tx_level          ;
  bit [ 3:0] temp_var          ;
  bit [ 7:0] wdata_in_d[]      ;
  bit [ 7:0] tx_data_in_d[]    ;
  bit [ 7:0] tx_o_data_d[]     ;
  bit [31:0] tx_o_data         ;
  int        frequency         ;
  int        clock_per_bit     ;
  int        clock_per_bit_half;
  bit [31:0] rdata             ;
  bit        transfer_en       ;
  int index=0;
  int sig_bit=0;
  int counter=0;
  int counter_cpb =0;
  
  virtual task get_transaction();
    // Transaction Handle declaration
    transaction_item tx;
    forever begin
      //`uvm_info(get_type_name(), $sformatf("I am printing frequency = %0d", s_mbox_m.get(freq)), UVM_LOW)
      @(posedge vif_tx.clk_i)
        tx = transaction_item::type_id::create("tx");
      tx.rst_ni          = vif_tx.rst_ni         ;
      tx.reg_wdata       = vif_tx.reg_wdata      ;
      tx.reg_addr        = vif_tx.reg_addr       ;
      tx.reg_we          = vif_tx.reg_we         ;
      tx.reg_re          = vif_tx.reg_re         ;
      tx.rx_i            = vif_tx.rx_i           ;
      tx.reg_rdata       = vif_tx.reg_rdata      ;
      tx.tx_o            = vif_tx.tx_o           ;
      tx.intr_tx         = vif_tx.intr_tx        ;
      tx.intr_rx         = vif_tx.intr_rx        ;
      tx.intr_tx_level   = vif_tx.intr_tx_level  ;
      tx.intr_rx_timeout = vif_tx.intr_rx_timeout;
      tx.intr_tx_full    = vif_tx.intr_tx_full   ;
      tx.intr_tx_empty   = vif_tx.intr_tx_empty  ;
      tx.intr_rx_full    = vif_tx.intr_rx_full   ;
      tx.intr_rx_empty   = vif_tx.intr_rx_empty  ;

      // Print the transactions

      print_transaction(tx);
      
      // Setting baud rate
      if (tx.rst_ni == 1'b1 && tx.reg_re == 1'b0 && tx.reg_we == 1'b1 && tx.reg_addr == 'h0) begin
        //baud_rate = tx.reg_wdata;
        clock_per_bit = tx.reg_wdata;
      end
      // Setting tx_level
      else if (tx.rst_ni == 1'b1 && tx.reg_re == 1'b0 && tx.reg_we == 1'b1 && tx.reg_addr == 'h18) begin
        tx_level = tx.reg_wdata;
        wdata_in_d = new[tx_level+1];
        tx_data_in_d = new[tx_level+1];
        tx_o_data_d = new[tx_level+1];
      end
      // Storing input data to be transferred in the dynamic array
      else if (tx.rst_ni == 1'b1 /*&& tx.reg_re == 1'b0*/ && tx.reg_we == 1'b1 && tx.reg_addr == 'h04) begin
        wdata_in_d[temp_var] = tx.reg_wdata[7:0];
        temp_var++;
        if(temp_var == tx_level+1) begin
          print_input_array(wdata_in_d);
          temp_var = 0;
        end
      end

      else if (tx.tx_o == 1'b0) begin
        counter_cpb = counter_cpb +1;
        if (counter_cpb == clock_per_bit) begin
          `uvm_info(get_type_name(), $sformatf("Counter_cpb == clock_per_bit"), UVM_LOW)
          transfer_en = 1;
        end
      end

      if (transfer_en == 1'b1) begin
        bit tx_out = tx.tx_o;
        `uvm_info(get_type_name(), $sformatf("printing tx_o %0d", tx_out), UVM_LOW)
      end

      if (transfer_en == 1'b1) begin
        // Populating tx out fifo (To be compared afterwards)
        tx_data_in_d[index][sig_bit] = tx.tx_o;
        counter = counter+1;
        if (counter == clock_per_bit) begin
          sig_bit = sig_bit+1;
          counter = 0;
          if (sig_bit == 8) begin
            sig_bit = 0;
            index = index+1;
            counter_cpb = 0;
            transfer_en = 0;
            if ((index == tx_level+1))
               print_tx_out_data_array(tx_data_in_d);
          end
        end

      end // else if (tx.tx_o == 1'b0)
      dut_tx_port.write(tx);
    end // forever
  endtask

  function void print_input_array(bit [7:0] wdata_in_d[]);
    `uvm_info("TX_MONITOR::",$sformatf("\nInput array size = %0d\nContent of array are = %p",
                                                     wdata_in_d.size(), wdata_in_d), UVM_LOW)    
  endfunction : print_input_array

  function void print_tx_out_data_array(bit [7:0] tx_data_in_d[]);
    `uvm_info("TX_MONITOR::",$sformatf("\nTX OUT array size = %0d\nContent of TX out data array are = %p",
                                                     tx_data_in_d.size(), tx_data_in_d), UVM_LOW)    
  endfunction : print_tx_out_data_array

  function void print_read_array(bit [7:0] rdata_in_d[]);
    `uvm_info("TX_MONITOR::",$sformatf("\nRead array size = %0d\nContent of array are = %p", 
                                                    rdata_in_d.size(), rdata_in_d), UVM_LOW)    
  endfunction : print_read_array

  function void print_tx_o_data_array(bit [7:0] tx_o_data_d[]);
    `uvm_info("TX_MONITOR::",$sformatf("\nTX Out data array size = %0d\nContent of array are = %p", 
                                                    tx_o_data_d.size(), tx_o_data_d), UVM_LOW)    
  endfunction : print_tx_o_data_array

  function void print_transaction(transaction_item tx);
    msg = "";
    cycle_num = ++cycle_num;
    $sformat(msg, {2{"%s============================"}} , msg                    );
    $sformat(msg, "%s\nCYCLE_NUMBER___________:d: %0d"  , msg, cycle_num         );
    $sformat(msg, "%s\nRESRT__________________:h: %0h"  , msg, tx.rst_ni         );
    $sformat(msg, "%s\nR_EN___________________:h: %0h"  , msg, tx.reg_re         );
    $sformat(msg, "%s\nWRITE_EN_______________:h: %0h"  , msg, tx.reg_we         );
    $sformat(msg, "%s\nW_DATA_________________:h: %0h"  , msg, tx.reg_wdata      );
    $sformat(msg, "%s\nR_DATA_________________:h: %0h"  , msg, tx.reg_rdata      );
    $sformat(msg, "%s\nADDRESS________________:h: %0h"  , msg, tx.reg_addr       );
    $sformat(msg, "%s\nTX_O___________________:h: %0d"  , msg, tx.tx_o           );
    $sformat(msg, "%s\nRX_I___________________:h: %0h"  , msg, tx.rx_i           );
    $sformat(msg, "%s\nINTR_TX________________:h: %0h"  , msg, tx.intr_tx        );
    $sformat(msg, "%s\nINTR_RX________________:h: %0h"  , msg, tx.intr_rx        );
    $sformat(msg, "%s\nINTR_TX_LEVEL__________:h: %0h"  , msg, tx.intr_tx_level  );
    $sformat(msg, "%s\nINTR_RX_TIMEOUT________:h: %0h"  , msg, tx.intr_rx_timeout);
    $sformat(msg, "%s\nINTR_TX_FULL___________:h: %0h"  , msg, tx.intr_tx_full   );
    $sformat(msg, "%s\nINTR_TX_EMPTY__________:h: %0h"  , msg, tx.intr_tx_empty  );
    $sformat(msg, "%s\nINTR_TX_FULL___________:h: %0h"  , msg, tx.intr_rx_full   );
    $sformat(msg, "%s\nINTR_RX_EMPTY__________:h: %0h\n", msg, tx.intr_rx_empty  );
    $sformat(msg, {2{"%s============================"}} , msg                    );
    `uvm_info("UART_MONITOR::",$sformatf("\n\nCapturing the signals from the interface\n", msg), UVM_LOW)
  endfunction : print_transaction
  
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
  //function void tp();
  //  msg = "";
  //  $sformat(msg, "%s\n\n████████╗███████╗███████╗████████╗    ██████╗  █████╗ ███████╗███████╗███████╗██████╗  ", msg);
  //  $sformat(msg, "%s\n╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗ ", msg);
  //  $sformat(msg, "%s\n   ██║   █████╗  ███████╗   ██║       ██████╔╝███████║███████╗███████╗█████╗  ██║  ██║ ", msg);
  //  $sformat(msg, "%s\n   ██║   ██╔══╝  ╚════██║   ██║       ██╔═══╝ ██╔══██║╚════██║╚════██║██╔══╝  ██║  ██║ ", msg);
  //  $sformat(msg, "%s\n   ██║   ███████╗███████║   ██║       ██║     ██║  ██║███████║███████║███████╗██████╔╝ ", msg);
  //  $sformat(msg, "%s\n   ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═════╝  \n", msg);
  //  `uvm_info("TEST STATUS::",$sformatf("\n", msg), UVM_LOW)
  //endfunction : tp
  //
  //function void tf();
  //  msg = "";
  //  $sformat(msg, "%s\n\n ████████╗███████╗███████╗████████╗    ███████╗ █████╗ ██╗██╗     ███████╗██████╗ ", msg);
  //  $sformat(msg, "%s\n ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔════╝██╔══██╗██║██║     ██╔════╝██╔══██╗", msg);
  //  $sformat(msg, "%s\n    ██║   █████╗  ███████╗   ██║       █████╗  ███████║██║██║     █████╗  ██║  ██║", msg);
  //  $sformat(msg, "%s\n    ██║   ██╔══╝  ╚════██║   ██║       ██╔══╝  ██╔══██║██║██║     ██╔══╝  ██║  ██║", msg);
  //  $sformat(msg, "%s\n    ██║   ███████╗███████║   ██║       ██║     ██║  ██║██║███████╗███████╗██████╔╝", msg);
  //  $sformat(msg, "%s\n    ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝ \n", msg);
  //   `uvm_info("TEST STATUS::",$sformatf("\n", msg), UVM_LOW)                     
  //endfunction : tf

endclass

