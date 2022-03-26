/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Auringzaib Sabir - Verification                                                     //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    08-MARCH-2022                                                                       //
// Design Name:    UART                                                                                //
// Module Name:    tx_driver.sv                                                                        //
// Project Name:   VIPs for different peripherals                                                      //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//     - Driver recieves the transacions from the sequencers(through TLM connections- Transaction      //
//     - level modeling) then the driver sends a transactions to DUT via interfaces.                   //
//     - Note that tx_driver is extended from uvm_driver base class                                    //
//     - uvm_driver is define in uvm_pkg                                                               //
//     - UVM components are permanent because they are never destroyed, they are created at the start  // 
//       of simulation and exist for the entire simulation                                             //
//     - Whereas stimulus are temporary because thousands of transactions are created and destroyed    //
//       during simulation                                                                             //
//     - Componets are hierarical i.e. they have fixed location in topology.                           //
//     - Transactions do not have fixed location because transaction move throught the components.     //
//     - Driver is parameterize class, as shown here the tx_driver only send transaction_item          //
//       transaction (driver is a uvm component)                                                       //
//                                                                                                     //
// Revision Date:                                                                                      //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class tx_driver extends uvm_driver #(transaction_item);
  // For all uvm_component we have to register them with uvm factory using uvm macro (`uvm_component_utils)
  // Pass the class name to it
  `uvm_component_utils(tx_driver)

  /*
  Then declare tx_driver class constructor
  Since a class object has to be constructed before it exit in a memory
  The creation of class hierarchy in a system verilog testbench has to be initiated from a top module.
  Since a module(top module) is static object that is present at beginning of simulation 
  */
  // Component Constructor have two arguments to specify the name and handle of the parent of this component in testbench topology
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

  virtual test_ifc vif;                      // Declaring a virtual interface which connects DUT and testbench. Virtual interfaces. In system verilog virtual means something is a reference to something else
  tx_agent_config tx_agent_config_h;         // Declaration of agent configuraton object

  function void build_phase(uvm_phase phase);
    `uvm_info("UART_DRIVER::",$sformatf("______BUILD_PHASE______"), UVM_LOW)
    if(!uvm_config_db#(tx_agent_config)::get(this/*Handle to this component*/, ""/*an empty instance name*/, "tx_agent_config_h"/*Name of the object in db*/, tx_agent_config_h/*Handle that the db writes to*/))
      `uvm_fatal("TX_DRIVER::NO VIF",$sformatf("No virtual interface in db"))
    // Now you can read the values from config object

    // Assigning the virtual interface declared in this class with the one from agent config class
    vif = tx_agent_config_h.vif;
    // Display the base address from config object
    `uvm_info(get_type_name(), $sformatf("config base adddress = %0x", tx_agent_config_h.base_address), UVM_LOW)
  endfunction : build_phase

  // Typically the driver recieves and sends the transaction in the run_phase in a forever loop
  // Run phase fetch items and drives
  // Connected to sequncer through TLM ports, just for understand consider TLM similar to mail box
  // Note: In a testbench the DUT limits how fast the stimulus can be applied to DUT, since the driver is connected to DUT it can accept a new transaction when DUT is ready
  string msg="";
  virtual task run_phase(uvm_phase phase);
    transaction_item tx;
    int cycle;
    forever begin
      // Use to get the next item
      seq_item_port.get_next_item (tx);
      transfer(tx);   
      //Calling a transfer method to send and recieve data from the DUT
      //vif.transfer(tx);
      // indicates item done
      seq_item_port.item_done();
    end
  endtask 
  
  bit value;  
  bit [ 63 : 0] data;
  bit [ 76 : 0] cycle_to_get_result;
  // Function to transfer the transaction to DUT via interface that is recieved in run phase
  virtual task transfer(transaction_item tr);
    //uvm_event ev = uvm_event_pool::get_global("ev_ab");
    //
    //// Declaring variables
    //bit [ 31: 0] r_data      ;
    //bit [ 11: 0] prescale = 0;
    //bit [ 23:16] step     = 0;
    //bit [ 31:0 ] div_q    = 0;
    //bit [ 4:0 ]  div_r    = 0;  
    //
    //@(posedge vif.clk_i);
    //// For driving signals to DUT via interface
    //vif.rst_ni    = tr.rst_ni   ;
    //vif.reg_we    = tr.reg_we   ;
    //vif.reg_re    = tr.reg_re   ;
    //vif.reg_addr  = tr.reg_addr ;
    //vif.reg_wdata = tr.reg_wdata;
    //vif.reg_be    = tr.reg_be   ;
    //// For Reading signals from DUT via interface
    //r_data        = vif.reg_rdata;
    //
    //// Print the signals driven on the virtual interface
    //print_tx_fields(vif);
    //// Following is the logic to get data to which counter will count, when the data is less than 64'h00000001FFFFFFFF
    //if (tr.reg_wdata <= 64'h00000000FFFFFFFF && tr.reg_addr == 'h10c && tr.reg_we == 1'b1) begin
    //  data = tr.reg_wdata;
    //  `uvm_info("UART_DRIVER::",$sformatf("DATA::____ %0d", data), UVM_LOW)
    //end
    //// Following is the logic to get data to which counter will count, when data is greater than 64'h00000000FFFFFFFF
    //if (tr.reg_wdata > 64'h00000000FFFFFFFF && tr.reg_addr == 'h110 && tr.reg_we == 1'b1) begin
    //  data = tr.reg_wdata;
    //  `uvm_info("UART_DRIVER::",$sformatf("DATA::____ %0d", data), UVM_LOW)
    //end
    //// Following logic is used to find the number of clock cycles required to complete the count depening on prescale and step
    //// set during the configuratiuon period
    //else if (tr.reg_addr == 'h100 && tr.reg_we == 1'b1) begin
    //  prescale = tr.reg_wdata[11:0] ;
    //  step     = tr.reg_wdata[23:16];
    //  div_q    = data/step;
    //  div_r    = data%step;
    //  // Logic to predict number of cycles required to complete the count.
    //  if(div_r == 0)
    //    cycle_to_get_result = ( (div_q) * (prescale + 1) ) + 2;
    //  else
    //    cycle_to_get_result = ( (div_q + 1) * (prescale + 1) ) + 2;
    //  // Printing the number of cycles required to complete the count and its related fields
    //  print_num_of_cycles_req(prescale, data, step, div_q, div_r, cycle_to_get_result);
    //end
    //// When the timer is activated, following logic waits untils intr_timer_expired_0_0_o is enabled from the DUT, that indicates timer has compeletd the count
    //else if (vif.reg_addr == 'h000 && tr.reg_we == 1'b1) begin
    //  `uvm_info("UART_DRIVER::",$sformatf("Waiting for intr_timer_expired_0_0_o to be set"), UVM_LOW)
    //  wait (vif.intr_timer_expired_0_0_o == 1'b1);
    //  `uvm_info("UART_DRIVER::",$sformatf("intr_timer_expired_0_0_o is one"), UVM_LOW)
    //end

    // Declaring variables
    bit [ 31: 0] r_data;
    
    // Assigning signals drived to the DUT 
    @(posedge vif.clk_i);
    vif.rst_ni = tr.rst_ni ;
    vif.we     = tr.we     ;
    vif.wdata  = tr.wdata  ;
    vif.rdata  = tr.rdata  ;
    vif.addr   = tr.addr   ;
    vif.ren    = tr.ren    ;
    // For Reading signals from DUT via interface
    r_data = vif.rdata;

    // Print the signals driven on the virtual interface
    print_tx_fields(vif);

    // When the uart tx transfer is activated, following logic waits untils intr_tx is enabled from the DUT, that indicates tx uart has compeletd the count
    if ((tr.rst_ni == 1'b1) && (tr.we == 1'h1) && (tr.addr=='h1c) && (tr.wdata == 'h1)) begin
      `uvm_info("UART_DRIVER::",$sformatf("Waiting for intr_tx to be high"), UVM_LOW)
      //wait (vif.intr_tx == 1'b0);
      `uvm_info("UART_DRIVER::",$sformatf("intr_tx is high"), UVM_LOW)
    end

  endtask

  function void print_tx_fields(virtual test_ifc vif);
    msg = "";
    $sformat(msg, {2{"%s============================"}}, msg             );
    $sformat(msg, "%s\nRESRT__________________:h: %0h"  , msg, vif.rst_ni );
    $sformat(msg, "%s\nREAD_EN________________:h: %0h"  , msg, vif.ren    );
    $sformat(msg, "%s\nWRITE_EN_______________:h: %0h"  , msg, vif.we     );
    $sformat(msg, "%s\nADDRESS________________:h: %0h"  , msg, vif.addr   );
    $sformat(msg, "%s\nW_DATA_________________:h: %0h"  , msg, vif.wdata  );
    $sformat(msg, "%s\nR_DATA_________________:h: %0h"  , msg, vif.rdata  );
    $sformat(msg, "%s\nTX_OUT_________________:h: %0h"  , msg, vif.tx_o   );
    $sformat(msg, "%s\nRX_IN__________________:h: %0h"  , msg, vif.rx_i   );
    $sformat(msg, "%s\nINTR_TX________________:h: %0h"  , msg, vif.intr_tx);
    $sformat(msg, "%s\nINTR_RX________________:h: %0h\n", msg, vif.intr_rx);
    $sformat(msg, {2{"%s============================"}}, msg                      );
    `uvm_info("UART_DRIVER::",$sformatf("\n\nPrinting the values on the virtual interface\n", msg), UVM_LOW)
  endfunction : print_tx_fields

endclass