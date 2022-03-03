///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    05-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
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
		parameter int AW = 9,
		parameter int DW = 32,
		localparam int DBW = DW/8
	)(
		input logic clk_i
	);

  import uvm_pkg::*;      		 // For using uvm libraries
	import base_test_pkg::*;
	`include "uvm_macros.svh"    // To make use of macros that are found in uvm libraries
  
  // Declaration
  logic           rst_ni                  ;
	logic           reg_we                  ;
	logic           reg_re                  ;
	logic [ AW-1:0] reg_addr                ;
	logic [ DW-1:0] reg_wdata               ;
	logic [DBW-1:0] reg_be                  ;
	logic [ DW-1:0] reg_rdata               ;
	logic           reg_error               ;
	logic           intr_timer_expired_0_0_o;

	 // Modport for DUT i.e. Timer
	 modport timer_mp_dut (
	 	input	  reg_we                  ,
	 	input	  reg_re                  ,
	 	input	  reg_addr                ,
	 	input	  reg_wdata               ,
	 	input	  reg_be                  ,
	 	output	reg_rdata               ,
	 	output	reg_error               ,
	 	output	intr_timer_expired_0_0_o
	 );
   
	 // Modport for testbench
	 modport timer_mp_tb (
	 	output reg_we                  ,
	 	output reg_re                  ,
	 	output reg_addr                ,
	 	output reg_wdata               ,
	 	output reg_be                  ,
	 	input	 reg_rdata               ,
	 	input	 reg_error               ,
	 	input	 intr_timer_expired_0_0_o
	 );   

  string msg;
	task automatic transfer(config_xactn_timer tx);
	endtask // transfer

	task automatic wait_clks(input int num);
    repeat (num) @(posedge clk_i);
  endtask

  task automatic wait_neg_clks(input int num);
    repeat (num) @(negedge clk_i);
  endtask

	//// Clocking for DUT i.e. Timer
	//clocking timer_mp_dut_clk @(posedge clk_i);
	//	input	  reg_we                  ;
	//	input	  reg_re                  ;
	//	input	  reg_addr                ;
	//	input	  reg_wdata               ;
	//	input	  reg_be                  ;
	//	output	reg_rdata               ;
	//	output	reg_error               ;
	//	output	intr_timer_expired_0_0_o;
	//endclocking
  //
	//// Clocking for testbench
	//clocking timer_mp_tb_clk @(posedge clk_i);
	//	output reg_we                  ;
	//	output reg_re                  ;
	//	output reg_addr                ;
	//	output reg_wdata               ;
	//	output reg_be                  ;
	//	input	 reg_rdata               ;
	//	input	 reg_error               ;
	//	input	 intr_timer_expired_0_0_o;
	//endclocking

endinterface : test_ifc