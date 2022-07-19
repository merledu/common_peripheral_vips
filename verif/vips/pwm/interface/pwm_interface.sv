/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    20th-APRIL-2022                                                                     //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_interface.sv                                                                    //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//             PWM interface has methods and signals to drive pwm_items to DUT.                        //
// Revision Date:  9-MAY-2022                                                                          //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

interface pwm_interface;

	import uvm_pkg::*;        	 //Import uvm base classes
	import base_class_pkg ::*;	 //Import component classes
  `include "uvm_macros.svh"    //Includes uvm macros utility

  bit							clk_i		;									
	logic						rst_ni	;											
  logic    				re_i 		;
  logic    				we_i 	  ;
  logic  [3:0]		be_i    ;
	logic  [7:0]    addr_i	;										
	logic  [31:0]   wdata_i	;										
	logic  [31:0]   rdata_o	;																							
  logic           o_pwm   ;
	logic           o_pwm_2 ;
	logic     	    oe_pwm1 ;
	logic     	    oe_pwm2 ;

	//Declaring a queue to store wdata_i values for each configuration
	logic [15:0] wdata_i_q[$]; //unbounded-queue

  modport dut (input  clk_i,
                      rst_ni,	
                      we_i,
											be_i,	
											re_i,	
                      addr_i,	
                      wdata_i,
               output rdata_o,
                      o_pwm,
                      o_pwm_2,
                      oe_pwm1,
                      oe_pwm2 );
	
  modport tb  (output clk_i,
                      rst_ni,
                      we_i,
											be_i,	
											re_i,
											addr_i,	
                      wdata_i,
               input  rdata_o,
                      o_pwm,
                      o_pwm_2,
                      oe_pwm1,
                      oe_pwm2 );
    
  task automatic transaction (pwm_item tx);
    rst_ni  = tx.rst_ni;
    we_i    = tx.we_i;
    be_i    = tx.be_i;
    re_i    = tx.re_i;
    addr_i  = tx.addr_i;
    //wdata_i = tx.wdata_i;
    $display("//////////////////////////////////////////INTERFACE transaction METHODS//////////////////////");
    $display(" rst_ni  = 0x%0h",rst_ni );    
    $display(" we_i    = 0x%0h",we_i  );
    $display(" be_i    = 0x%0h",be_i  );
    $display(" re_i    = 0x%0h",re_i  );
    $display(" addr_i  = 0x%0h",addr_i );
    //$display(" wdata_i = 0x%0h",wdata_i);
    $display(" rdata_o = 0x%0h",tx.rdata_o);
    $display(" o_pwm   = 0x%0h",tx.o_pwm  );
    $display(" o_pwm_2 = 0x%0h",tx.o_pwm_2);
    $display(" oe_pwm1 = 0x%0h",tx.oe_pwm1);
    $display(" oe_pwm2 = 0x%0h",tx.oe_pwm2);    
    //$display("rst_ni = 0x%0h \nwrite = %0d \naddr_i = %0d \nwdata_i = %0h \nrdata_o = %0d \no_pwm = %0d \no_pwm_2 = %0d \noe_pwm1 = %0d \noe_pwm2 = %0d" , rst_ni, write, addr_i, wdata_i, rdata_o, o_pwm, o_pwm_2, oe_pwm1, oe_pwm2);
    $display("//////////////////////////////////////////INTERFACE transaction METHODS//////////////////////");
  endtask // task automatic transaction (pwm_item tx);

  task automatic clk_gen ();
		clk_i = 1'b0;
    //repeat(100) #1ns clk_i = ~clk_i;
    $display("//////////////////////////////////////////INTERFACE clk_gen METHODS//////////////////////////");
    //$monitor(" clk_i = 0x%0h",clk_i ); 
		for (int i = 0;i<20'hf0000;i++) begin
			#1ns clk_i = ~clk_i;
    	//$display(" clk_i = 0x%0h at time = %0tns",clk_i,$realtime); 
		end
		//forever #1ns clk_i=~clk_i;
    $display("//////////////////////////////////////////INTERFACE clk_gen METHODS//////////////////////////");   
  endtask // task automatic clk_gen (input bit clk);

	task automatic get_an_input (pwm_item tx);
    tx.rst_ni  = rst_ni  ;
    tx.we_i    = we_i		 ;
    tx.be_i    = be_i		 ;
    tx.re_i    = re_i		 ;    
		tx.addr_i  = addr_i  ;
    tx.wdata_i = wdata_i ;
	endtask // task automatic get_an_input (pwm_item tx);

	task automatic get_an_output (pwm_item tx);
    tx.rdata_o = rdata_o ;
    tx.o_pwm   = o_pwm   ;
    tx.o_pwm_2 = o_pwm_2 ;
    tx.oe_pwm1 = oe_pwm1 ;
    tx.oe_pwm2 = oe_pwm2 ;
	endtask // task automatic get_an_output (pwm_item tx);

  task automatic print_interface_transaction (pwm_item tx);
    get_an_input  (tx);
		get_an_output (tx);
    $display("//////////////////////////////////////////INTERFACE print_interface_transaction METHOD//////////////////////");
    $display(" clk_i      = 0x%0h",clk_i )    ;    
    $display(" tx.rst_ni  = 0x%0h",tx.rst_ni );    
    $display(" tx.we_i 		= 0x%0h",tx.we_i   );
    $display(" tx.be_i 		= 0x%0h",tx.be_i   );
    $display(" tx.re_i 		= 0x%0h",tx.re_i   );
		$display(" tx.addr_i  = 0x%0h",tx.addr_i );
    $display(" tx.wdata_i = 0x%0h",tx.wdata_i);
    $display(" tx.rdata_o = 0x%0h",tx.rdata_o);
    $display(" tx.o_pwm   = 0x%0h",tx.o_pwm  );
    $display(" tx.o_pwm_2 = 0x%0h",tx.o_pwm_2);
    $display(" tx.oe_pwm1 = 0x%0h",tx.oe_pwm1);
    $display(" tx.oe_pwm2 = 0x%0h",tx.oe_pwm2);
    //$display("tx.rst_ni = %0d \ntx.write = %0d \ntx.addr_i = %0d \ntx.wdata_i = %0h \ntx.rdata_o = %0d \ntx.o_pwm = %0d \ntx.o_pwm_2 = %0d \ntx.oe_pwm1 = %0d \ntx.oe_pwm2 = %0d" , tx.rst_ni, tx.write, tx.addr_i, tx.wdata_i, tx.rdata_o, tx.o_pwm, tx.o_pwm_2, tx.oe_pwm1, tx.oe_pwm2);
    $display("//////////////////////////////////////////INTERFACE print_interface_transaction METHOD//////////////////////");
	endtask // task automatic print_interface_transaction (pwm_item tx);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------record_data Method------------------------------------------//

	 function record_data (pwm_item tx);

    //Declare index to store value on a particular location
      int index;

		//Declaring a variable to store recent value of queue
		bit [31:0] data;

		//pushes the data items into the queue
		wdata_i_q.insert(index,tx.wdata_i[15:0]);

		//assign the front value to the variable
		//data = wdata_i_q[index];

		//Display the contents of the queue
		$display("Queue contents : %p",wdata_i_q);

    index++;

		//return data;

	endfunction // function record_data (pwm_item tx);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------record_data Method------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------dc_data Method----------------------------------------------//

	 task dc_data (pwm_item tx);

    if(tx.dc_seq_en) begin
      $display("Condition1 true");
      $display("tx.dc_seq_en = %0b",tx.dc_seq_en);
      if ((wdata_i_q[2] < wdata_i_q[3]) || wdata_i_q[2] ==0) begin
        $display("Condition2 true");
        if(wdata_i_q[2] == 0) begin // Period is configured as zero
          wdata_i = 0;
					wdata_i_q[3] = 0;
          $display("Condition3 true");
        end //(wdata_i_q[2] == 0)
        else begin //(wdata_i_q[2] != 0)
           $display("Condition4 true");
           if(wdata_i_q[2] < wdata_i_q[3]) begin
             wdata_i = $urandom_range(0,wdata_i_q[2]-1);
             $display("Condition5 true");
             $display("wdata_i = 0x%0h",wdata_i);
             wdata_i_q[3] = wdata_i;
           end //(wdata_i_q[2] < wdata_i_q[3])
				end //(wdata_i_q[2] != 0)
			end //((wdata_i_q[2] < wdata_i_q[3]) || wdata_i_q[2] ==0)
			else //!((wdata_i_q[2] < wdata_i_q[3]) || wdata_i_q[2] ==0)
				wdata_i = wdata_i_q[3];
				//wdata_i = tx.wdata_i;	
		end	//(tx.dc_seq_en)
    else begin //!(tx.dc_seq_en)
      $display("Condition1 false");
      wdata_i = tx.wdata_i;
      $display("tx.dc_seq_en = %0b",tx.dc_seq_en);
    end //!(tx.dc_seq_en)

    $display("wdata_i_q[2] = 0x%0h and wdata_i_q[3] = 0x%0h",wdata_i_q[2],wdata_i_q[3]);

	endtask //	 task dc_data (pwm_item tx);
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------dc_data Method----------------------------------------------//
endinterface