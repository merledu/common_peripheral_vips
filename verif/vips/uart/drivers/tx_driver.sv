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

  virtual test_ifc vif_tx;                   // Declaring a virtual interface which connects DUT and testbench. Virtual interfaces. In system verilog virtual means something is a reference to something else
  virtual test_ifc vif_rx;                   // Declaring a virtual interface which connects DUT and testbench. Virtual interfaces. In system verilog virtual means something is a reference to something else
  tx_agent_config tx_agent_config_h;         // Declaration of agent configuraton object

  function void build_phase(uvm_phase phase);
    `uvm_info("UART_DRIVER::",$sformatf("______BUILD_PHASE______"), UVM_LOW)
    if(!uvm_config_db#(tx_agent_config)::get(this/*Handle to this component*/, ""/*an empty instance name*/, "tx_agent_config_h"/*Name of the object in db*/, tx_agent_config_h/*Handle that the db writes to*/))
      `uvm_fatal("TX_DRIVER::NO vif_tx",$sformatf("No virtual interface in db"))
    // Now you can read the values from config object

    // Assigning the virtual interface declared in this class with the one from agent config class
    vif_tx = tx_agent_config_h.vif_tx;
    vif_rx = tx_agent_config_h.vif_rx;
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
      //vif_tx.transfer(tx);
      // indicates item done
      seq_item_port.item_done();
    end
  endtask 
  
  bit value;  
  bit [ 63 : 0] data;
  bit [ 76 : 0] cycle_to_get_result;
  // Function to transfer the transaction to DUT via interface that is recieved in run phase
  virtual task transfer(transaction_item tr);

    // Declaring variables
    bit [ 31: 0] r_data;
    
    // Assigning signals drived to the DUT 
    @(posedge vif_tx.clk_i);
    // For tx
    vif_tx.rst_ni    = tr.rst_ni;
    vif_tx.reg_we    = tr.reg_we;
    vif_tx.reg_wdata = tr.reg_wdata;
    vif_tx.reg_rdata = tr.reg_rdata;
    vif_tx.reg_addr  = tr.reg_addr;
    vif_tx.reg_re    = tr.reg_re;
    vif_tx.rx_i      = tr.rx_i;
    // For Reading signals from DUT via interface
    r_data           = vif_tx.reg_rdata;
    // For rx
    vif_rx.rst_ni    = tr.rst_ni;
    vif_rx.reg_we    = tr.reg_we;
    vif_rx.reg_wdata = tr.reg_wdata;
    vif_rx.reg_rdata = tr.reg_rdata;
    vif_rx.reg_addr  = tr.reg_addr;
    vif_rx.reg_re    = tr.reg_re;
    vif_rx.rx_i      = tr.rx_i;
    // For Reading signals from DUT via interface
    r_data           = vif_rx.reg_rdata;

    // Print the signals driven on the virtual interface
    print_tx_fields(vif_tx, "Printing the values on the tx virtual interface");
    print_tx_fields(vif_rx, "Printing the values on the rx virtual interface");

    // When the uart tx transfer is activated, following logic waits untils intr_tx is enabled from the DUT, that indicates tx uart has compeletd the count
    if ((tr.rst_ni == 1'b1) && (tr.reg_we == 1'h1) && (tr.reg_addr=='h1c) && (tr.reg_wdata == 'h0)) begin
      `uvm_info("UART_DRIVER::",$sformatf("Waiting for intr_tx to be high"), UVM_LOW)
      wait (vif_tx.intr_tx == 1'b1 && vif_rx.intr_rx == 1'b1);
      `uvm_info("UART_DRIVER::",$sformatf("intr_tx is high"), UVM_LOW)
    end

  endtask

  function void print_tx_fields(virtual test_ifc vif_tx, input string msg);
    msg = "";
    $sformat(msg, {2{"%s============================"}}, msg                         );
    $sformat(msg, "%s\nRESRT__________________:h: %0h"  , msg, vif_tx.rst_ni         );
    $sformat(msg, "%s\nREAD_EN________________:h: %0h"  , msg, vif_tx.reg_re         );
    $sformat(msg, "%s\nWRITE_EN_______________:h: %0h"  , msg, vif_tx.reg_we         );
    $sformat(msg, "%s\nADDRESS________________:h: %0h"  , msg, vif_tx.reg_addr       );
    $sformat(msg, "%s\nW_DATA_________________:h: %0h"  , msg, vif_tx.reg_wdata      );
    $sformat(msg, "%s\nR_DATA_________________:h: %0h"  , msg, vif_tx.reg_rdata      );
    $sformat(msg, "%s\nTX_OUT_________________:h: %0h"  , msg, vif_tx.tx_o           );
    $sformat(msg, "%s\nRX_IN__________________:h: %0h"  , msg, vif_tx.rx_i           );
    $sformat(msg, "%s\nINTR_TX________________:h: %0h"  , msg, vif_tx.intr_tx        );
    $sformat(msg, "%s\nINTR_RX________________:h: %0h"  , msg, vif_tx.intr_rx        );
    $sformat(msg, "%s\nINTR_TX_LEVEL__________:h: %0h"  , msg, vif_tx.intr_tx_level  );
    $sformat(msg, "%s\nINTR_RX_TIMEOUT________:h: %0h"  , msg, vif_tx.intr_rx_timeout);
    $sformat(msg, "%s\nINTR_TX_FULL___________:h: %0h"  , msg, vif_tx.intr_tx_full   );
    $sformat(msg, "%s\nINTR_TX_EMPTY__________:h: %0h"  , msg, vif_tx.intr_tx_empty  );
    $sformat(msg, "%s\nINTR_TX_FULL___________:h: %0h"  , msg, vif_tx.intr_rx_full   );
    $sformat(msg, "%s\nINTR_RX_EMPTY__________:h: %0h\n", msg, vif_tx.intr_rx_empty  );
    $sformat(msg, {2{"%s============================"}} , msg                        );
    `uvm_info("CONFIG_UART_SEQUENCE::",$sformatf("\n"   , msg), UVM_LOW)  
    //`uvm_info("UART_DRIVER::",$sformatf("\n\nPrinting the values on the virtual interface\n", msg), UVM_LOW)
  endfunction : print_tx_fields

endclass