///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    12-MARCH-2022                                                                     //
// Design Name:    SPI                                                                               //
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
		parameter int DATA_WIDTH    = 32,
		parameter int SLAVE_SEL     =  4,
		parameter int ADDRESS_WIDTH =  8
	)(
		input logic clk_i
	);

  import uvm_pkg::*;      		 // For using uvm libraries
	import base_test_pkg::*;
	`include "uvm_macros.svh"    // To make use of macros that are found in uvm libraries

	// tlul signals
  logic                     rst_ni 	 ;        
  logic [ADDRESS_WIDTH-1:0] addr_i   ;            
  logic [	  DATA_WIDTH-1:0] wdata_i  ;              
  logic [	  DATA_WIDTH-1:0] rdata_o  ;             
  logic [	   SLAVE_SEL-1:0] be_i     ;           
  logic                     we_i     ;       
  logic                     re_i     ;        
  logic    		              error_o  ;       
  logic    		              intr_rx_o;
  logic    		              intr_tx_o;                                 
  // signals                          
  logic [    SLAVE_SEL-1:0] ss_o     ;       // slave select
  logic                     sclk_o	 ;       // serial clock
  logic                     sd_o  	 ;
  logic                     sd_oe 	 ;       // master out slave in
  logic                     sd_i  	 ;       // master in slave out

	//// Modport for DUT i.e. UART
	//modport uart_mp_dut (
	//	input  rst_ni ,
	//	input  ren    ,
	//	input  we     ,
	//	input  wdata  ,
	//	output rdata  ,
	//	input  addr   ,
	//	output tx_o   ,
	//	input  rx_i   ,
	//	output intr_tx,
	//	output intr_rx
	//);
  //
	//// Modport for testbench
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