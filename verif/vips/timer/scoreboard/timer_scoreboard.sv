///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    20-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    timer_scoreboard.sv                                                               //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//         The scoreboard will check the correctness of the DUT by comparing the DUT output with the //
// expected values.                                                                                  //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class timer_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(timer_scoreboard)

	function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

  uvm_analysis_imp#(config_xactn_timer, timer_scoreboard) ap_imp;

  function void build_phase(uvm_phase phase);
    ap_imp = new("ap_imp", this);
  endfunction : build_phase

  virtual function void write(config_xactn_timer tx);
  	string msg ="";
    tx = config_xactn_timer::type_id::create("tx");
  	msg = "";
    $sformat(msg, {2{"%s============================"}}, msg                             );
    $sformat(msg, "%s\nRESRT__________________:: %0h"  , msg, tx.rst_ni                  );
    $sformat(msg, "%s\nADDRESS________________:: %0h"  , msg, tx.reg_addr                );
    $sformat(msg, "%s\nWRITE_EN_______________:: %0b"  , msg, tx.reg_we                  );
    $sformat(msg, "%s\nBYTE_EN________________:: %0b"  , msg, tx.reg_be                  );
    $sformat(msg, "%s\nW_DATA_________________:: %0d"  , msg, tx.reg_wdata               );
    $sformat(msg, "%s\nREAD_EN________________:: %0b"  , msg, tx.reg_re                  );
    $sformat(msg, "%s\nR_DATA_________________:: %0d"  , msg, tx.reg_rdata               );
    $sformat(msg, "%s\nERROR__________________:: %0d"  , msg, tx.reg_error               );
    $sformat(msg, "%s\nTIMER EXPIRED__________:: %0d\n", msg, tx.intr_timer_expired_0_0_o);
    $sformat(msg, "%s\nASSIGNED PRE-SCALE_____:: %0d"  , msg, tx.reg_wdata[11:0]         );
    $sformat(msg, "%s\nASSIGNED STEP__________:: %0d\n", msg, tx.reg_wdata[23:16]        );
    $sformat(msg, {2{"%s============================"}}, msg                             );
    `uvm_info("TIMER_SCORE-BOARD::",$sformatf("\n\nRECEIVED SIGNALS IN SCOREBOARD", msg), UVM_LOW)

  endfunction : write

  virtual task run_phase(uvm_phase phase);
  endtask // run_phase

endclass