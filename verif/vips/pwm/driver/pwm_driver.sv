/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    20-APRIL-2022                                                                       //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_driver.sv                                                                       //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//          	 pwm_driver drives the configurations to the DUT via virtual interface.                  //
// Revision Date:  20-MAY-2022                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class pwm_driver extends uvm_driver #(pwm_item);

// Driver parameterized with the same sequence_item (pwm_item) for request & response
// response defaults to request

	//Factory Registration
	`uvm_component_utils(pwm_driver)

	//constructor
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

//////////////////////////////////////////VIRTUAL INTERFACE//////////////////////////////////////////////

	virtual pwm_interface vif;

//////////////////////////////////////////DATA MEMBERS///////////////////////////////////////////////////

	pwm_config pwm_cfg;

//////////////////////////////////////////METHODS///////////////////////////////////////////////////////

	// Standard UVM Methods:	
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

	//Print method for printing transaction items
	extern virtual task print_transaction(pwm_item tr);

	//Print method for printing transaction items from interface
	extern virtual task print_interface_signals_from_driver();

	//Print method for printing clock signal by using clk_gen() task from the interface
	//extern virtual task print_interface_task_clkgen_from_driver();

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Driver build phase------------------------------------------//

	function void pwm_driver :: build_phase (uvm_phase phase);
		`uvm_info($sformatf("BUILD PHASE : %s",get_type_name()),
							$sformatf("BUILD PHASE OF %s HAS STARTED !!!",get_type_name()),UVM_LOW);
	/*	if (!uvm_config_db # (virtual pwm_interface) :: get (this,"","pwm_if",vif))
			`uvm_fatal(get_type_name(),"NO PWM VIF IN DB");*/

		//get configuration object set by the environment through the DB. 
		if (!uvm_config_db #(pwm_config) :: get(this," ","pwm_cfg",pwm_cfg))
			`uvm_fatal(get_type_name(),"NO AGENT CONFIGURATION OBJECT FOUND !!")
		else 
			`uvm_info($sformatf("AGENT CONFIG OBJECT FOUND : %s",get_type_name()),
							  $sformatf("%s SUCCESSFULLY GOT THE CONFIG OBJECT !!!",get_type_name()),UVM_LOW);		
		
		vif = pwm_cfg.vif; 
	endfunction //function void pwm_driver :: build_phase (uvm_phase phase); 

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Driver build phase------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Driver run_phase--------------------------------------------//

	task pwm_driver :: run_phase(uvm_phase phase);

		// 1- Declare the sequence item handle
		pwm_item tx;
		`uvm_info($sformatf("RUN PHASE : %s",get_type_name()),
							$sformatf("RUN PHASE : %s HAS STARTED !!!",get_type_name()),UVM_LOW);
		forever begin
			// 2- Request a new transaction
			seq_item_port.get_next_item(tx);  /*Driver call get_next_item which blocks the driver until sequence send 
																					transaction handle to the driver by calling finish item. This action 
																					unblocks the sequence.seq_item_port is a blocking tlm port declare and
																					constructed inside the driver.*/
			
			//Print the interface signals before sending the pwm_items out to the interface
			//print_interface_signals_from_driver();
			
			//Check if the vif.clk_i is generating properly or not
			//vif.clk_gen();
			//print_interface_task_clkgen_from_driver();
		
			// 3- Send transaction to the DUT
			@(posedge vif.clk_i)
			//	if(tx.addr_i == 8'h0 && tx.wdata_i == 32'h0) begin
			//		tx.rst_ni  = 1'h1;
			//		tx.we_i    = 1'h0;
			//		tx.be_i    = 4'b0000;
			//		tx.re_i    = 1'h0;
			//		tx.addr_i  = 8'h0;
			//		tx.wdata_i = 32'h0;
			//		print_transaction(tx); 
			//		vif.record_data(tx);
			//		vif.dc_data(tx);
			//		vif.transaction(tx); 						  //transfer the item to the dut via virtual interface
			//		vif.print_interface_transaction(tx);
			//	end //if(tx.addr_i == 8'h0 && tx.wdata_i == 32'h0)

				//else begin //!(tx.addr_i == 8'h0 && tx.wdata_i == 32'h0)
					print_transaction(tx); 
					vif.record_data(tx);
					vif.dc_data(tx);
					vif.transaction(tx); 						  //transfer the item to the dut via virtual interface
					vif.print_interface_transaction(tx);
					//vif.clk_gen();
					//vif.wdata_i_q.push_front(vif.record_data(tx));
				//end
			
				//@(posedge vif.clk_i)
				//	vif.rst_ni  = tx.rst_ni  ;
				//	vif.we_i    = tx.we_i	   ;
				//	vif.be_i    = tx.be_i	   ;
				//	vif.re_i    = tx.re_i	   ;
				//	vif.addr_i  = tx.addr_i  ;
				//	vif.wdata_i = tx.wdata_i ;
    		//	vif.rdata_o = tx.rdata_o ;
    		//	vif.o_pwm   = tx.o_pwm   ;
    		//	vif.o_pwm_2 = tx.o_pwm_2 ;
    		//	vif.oe_pwm1 = tx.oe_pwm1 ;
    		//	vif.oe_pwm2 = tx.oe_pwm2 ;

			// 4- Driver is done with the transaction
			seq_item_port.item_done(); 			 	/*When the transaction completes, the driver calls item_done() to tell the 
			 																		seq it is done with the item. This call unblocks the sequence. */
			// 5 - Send response
		end // forever

	endtask //task pwm_driver :: run_phase(uvm_phase phase);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Driver run_phase--------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------print_transaction Method-----------------------------------------//

	/*task pwm_driver :: print_transaction(pwm_item tr);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.rst_ni  = 0x%0h",tr.rst_ni ),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.we_i    = 0x%0h",tr.we_i   ),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.be_i    = 0x%0h",tr.be_i   ),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.re_i    = 0x%0h",tr.re_i   ),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.addr_i  = 0x%0h",tr.addr_i ),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.wdata_i = 0x%0h",tr.wdata_i),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.rdata_o = 0x%0h",tr.rdata_o),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.o_pwm   = 0x%0h",tr.o_pwm  ),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.o_pwm_2 = 0x%0h",tr.o_pwm_2),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.oe_pwm1 = 0x%0h",tr.oe_pwm1),UVM_LOW);
		`uvm_info("PWM SEQUENCE ITEMS",$sformatf("tr.oe_pwm2 = 0x%0h",tr.oe_pwm2),UVM_LOW);
	endtask //task pwm_driver :: transfer(pwm_item tr);*/

	task pwm_driver :: print_transaction(pwm_item tr);
		`uvm_info(get_type_name(),
							"\n//////////////////////////////////////////DRIVER print_transaction METHOD//////////////////////",
							UVM_LOW);
		`uvm_info(get_type_name(),tr.convert2string,UVM_LOW);
		//vif.print_interface_transaction(tr)
		`uvm_info(get_type_name(),
							"\n//////////////////////////////////////////DRIVER print_transaction METHOD//////////////////////",
							UVM_LOW);
	endtask // task pwm_driver :: print_transaction(pwm_item tr);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------print_transaction Method-----------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------print_interface_signal_from_driver Method------------------------//

	task pwm_driver :: print_interface_signals_from_driver();
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.clk_i   =  0x%0h",vif.clk_i  ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.rst_ni  =  0x%0h",vif.rst_ni ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.we_i    =  0x%0h",vif.we_i   ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.be_i    =  0x%0h",vif.be_i   ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.re_i    =  0x%0h",vif.re_i   ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.addr_i  =  0x%0h",vif.addr_i ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.wdata_i =  0x%0h",vif.wdata_i),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.rdata_o =  0x%0h",vif.rdata_o),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.o_pwm   =  0x%0h",vif.o_pwm  ),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.o_pwm_2 =  0x%0h",vif.o_pwm_2),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.oe_pwm1 =  0x%0h",vif.oe_pwm1),UVM_LOW);
		`uvm_info($sformatf("PRINTING INTERFACE SIGNALS FROM : %s",get_type_name()),$sformatf("vif.oe_pwm2 =  0x%0h",vif.oe_pwm2),UVM_LOW);
	endtask //task pwm_driver :: print_interface_signal_from_driver();

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------print_interface_signal_from_driver Method------------------------//

/*
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------print_interface_task_clkgen_from_driver() Method-----------------//

	task pwm_driver :: print_interface_task_clkgen_from_driver();
		vif.clk_gen();
	endtask

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------print_interface_task_clkgen_from_driver() Method-----------------//
*/