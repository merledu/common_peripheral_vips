///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    03-MARCH-2022                                                                     //
// Design Name:    UART                                                                              //
// Module Name:    test_ifc.sv                                                                       //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//            Interface can be consider a bundle of wires which is used to connect different modules //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

interface test_ifc  #(
		parameter int DATA_WIDTH = 32,
		parameter int ADDR_WIDTH =  12
	)(
		input logic clk_i
	);

  import uvm_pkg::*;      		 // For using uvm libraries
	import base_test_pkg::*;
	`include "uvm_macros.svh"    // To make use of macros that are found in uvm libraries

	// Declaration
	logic                  rst_ni   			;
	logic [DATA_WIDTH-1:0] reg_wdata			;
	logic [ADDR_WIDTH-1:0] reg_addr 			;
	logic        					 reg_we   			;
	logic        					 reg_re   			;
	logic        					 rx_i     			;
	logic [DATA_WIDTH-1:0] reg_rdata			;
	logic 								 tx_o           ;
	logic 								 intr_tx        ;
	logic 								 intr_rx        ;
	logic 								 intr_tx_level  ;
	logic 								 intr_rx_timeout;
	logic 								 intr_tx_full   ;
	logic 								 intr_tx_empty  ;
	logic 								 intr_rx_full   ;
	logic 								 intr_rx_empty  ;

	//// Modport for testbench
	//modport timer_mp_tb (
	//	output reg_we                  ,
	//	output reg_re                  ,
	//	output reg_addr                ,
	//	output reg_wdata               ,
	//	output reg_be                  ,
	//	input	 reg_rdata               ,
	//	input	 reg_error               ,
	//	input	 intr_timer_expired_0_0_o
	//);

	// Modport for testbench
	//modport timer_mp_tb (
	// 	output rst_ni ,
	// 	output ren    ,
	// 	output we     ,
	// 	output wdata  ,
	// 	input  rdata  ,
	// 	output addr   ,
	// 	input  tx_o   ,
	// 	output rx_i   ,
	// 	input  intr_tx,
	// 	input  intr_rx
	//);

  string msg;
	task automatic transfer(transaction_item tx);
	endtask // transfer

	task automatic wait_clks(input int num);
    repeat (num) @(posedge clk_i);
  endtask

  task automatic wait_neg_clks(input int num);
    repeat (num) @(negedge clk_i);
  endtask

endinterface : test_ifc