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
    get_transaction();
  endtask
  
  // Declaration
  string msg ="";
  bit [ 76:0] cycle_num = 0;
  int         set          ;
  int         clct_mosi    ;
  int         count        ;
  int         data         ;
  bit         next_data    ;

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

        if(count == 32) begin
          data = clct_mosi; 
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing the collected mosi = %0b",data), UVM_LOW)
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing the slave select output signal = %0b", vif.ss_o), UVM_LOW)
        end

        if(!vif.ss_o[0] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Printing the collected data = %0b",data), UVM_LOW)
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 1"), UVM_LOW)
          if(data[1:0] == 2'b11) begin
            `uvm_info("SPI_MONITIOR::", $sformatf("Next will be tx data"), UVM_LOW)
          end
        end
        if(!vif.ss_o[1] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 2"), UVM_LOW)
        end
        if(!vif.ss_o[2] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 3"), UVM_LOW)
        end
        if(!vif.ss_o[3] && count == 32) begin
          `uvm_info("SPI_MONITIOR::", $sformatf("Enabled Device 4"), UVM_LOW)
        end

    //  tx.rst_ni                   = vif.rst_ni                  ;
    //  tx.reg_we                   = vif.reg_we                  ;
    //  tx.reg_re                   = vif.reg_re                  ;
    //  tx.reg_addr                 = vif.reg_addr                ;
    //  tx.reg_wdata                = vif.reg_wdata               ;
    //  tx.reg_be                   = vif.reg_be                  ;
    //  tx.reg_rdata                = vif.reg_rdata               ;
    //  tx.reg_error                = vif.reg_error               ;
    //  tx.intr_timer_expired_0_0_o = vif.intr_timer_expired_0_0_o;
    //  // Print the transactions
    //  print_transaction(tx);
    //  // The monitor reads the transaction from the DUT and passed the handle to TLM analysis port write function
    //  dut_tx_port.write(tx);
    //  // Following is the logic to get data to which counter will count, when the data is less than 64'h00000001FFFFFFFF
    //  if (tx.reg_wdata <= 64'h00000000FFFFFFFF && tx.reg_addr == 'h10c && tx.reg_we == 1'b1) begin
    //    data = tx.reg_wdata;
    //    `uvm_info("TIMER_DRIVER::",$sformatf("DATA::____ %0d", data), UVM_LOW)
    //  end
    //  // Following is the logic to get data to which counter will count, when data is greater than 64'h00000000FFFFFFFF
    //  if (tx.reg_wdata > 64'h00000000FFFFFFFF && tx.reg_addr == 'h110 && tx.reg_we == 1'b1) begin
    //    data = tx.reg_wdata;
    //    `uvm_info("TIMER_DRIVER::",$sformatf("DATA::____ %0d", data), UVM_LOW)
    //  end
    //  // Following logic is used to find the number of clock cycles required to complete the count depening on prescale and step
    //  // set during the configuratiuon period
    //  else if (tx.reg_addr == 'h100 && tx.reg_we == 1'b1) begin
    //    prescale = tx.reg_wdata[11:0] ;
    //    step     = tx.reg_wdata[23:16];
    //    div_q    = data/step;
    //    div_r    = data%step;
    //    // Logic to predict number of cycles required to complete the count.
    //    if(div_r == 0)
    //      cycle_to_get_result = ( (div_q) * (prescale + 1) ) + 2;
    //    else
    //      cycle_to_get_result = ( (div_q + 1) * (prescale + 1) ) + 2;
    //    // Printing the number of cycles required to complete the count and its related fields
    //    print_num_of_cycles_req(prescale, data, step, div_q, div_r, cycle_to_get_result);
    //  end
    //  // When intr_timer_expired_0_0_o is enabled from the DUT, that indicates timer has compeletd the count.
    //  // Following logic will check if the timer enabled the intr_timer_expired_0_0_o after correct number of cycle
    //  else if (tx.intr_timer_expired_0_0_o == 1) begin
    //    `uvm_info("UART_MONITOR::",$sformatf("TIMER EXPIRED SIGNAL IS SET = %0d", tx.intr_timer_expired_0_0_o), UVM_LOW)
    //    if((cycle_to_get_result == (cycle_num-12-1)) && set==0) begin // Note initial 12 cycles are for reseting and configuring the timer (3 cycle to reset amd 8 to configure the timer)
    //      print_test_passed(cycle_to_get_result, cycle_num);
    //      set=1;
    //    end  // if((cycle_to_get_result == (cycle_num-12-1)) && set==0)
    //    else if (set==0) begin
    //      print_test_failed(cycle_to_get_result, cycle_num);
    //      set=1;
    //    end // if (set==0)
    //  end // if (tx.intr_timer_expired_0_0_o == 1)
    end // forever
  endtask

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

