/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    20-APRIL-2022                                                                       //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    top.sv                                                                              //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//             Top module is responsible to run tx_Test. We pass tx_test as a UVM_TESTNAME on          //
// 			   		 the commmand line. run_test() gets the name of the test from the commandline            //
//             and execute uvm_phases.		                                                             //
// Revision Date:  20-May-2022                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

module hdl_top;

	import uvm_pkg::*;        	 //Import uvm base classes
	import base_class_pkg ::*;	 //Import component classes
  `include "uvm_macros.svh"    //Includes uvm macros utility

	pwm_interface pwm_if();

//////////////////////////////////////////INTERFACE clk_gen METHODS//////////////////////////

always #1ns pwm_if.clk_i=~pwm_if.clk_i;

//////////////////////////////////////////Connecting DUT//////////////////////////////////////////////////

	pwm dut(
					.clk_i  (pwm_if.clk_i  ),
					.rst_ni (pwm_if.rst_ni ),
					.we_i   (pwm_if.we_i   ),
					.be_i   (pwm_if.be_i   ),
					.re_i   (pwm_if.re_i   ),
					.addr_i (pwm_if.addr_i ),
					.wdata_i({16'h0,pwm_if.wdata_i}),
					.rdata_o(pwm_if.rdata_o),
					.o_pwm  (pwm_if.o_pwm  ),
					.o_pwm_2(pwm_if.o_pwm_2),
					.oe_pwm1(pwm_if.oe_pwm1),
					.oe_pwm2(pwm_if.oe_pwm2)
		    );

//////////////////////////////////////////uvm_config_db set()/////////////////////////////////////////////

		/*
		To pass a virtual interface handle from the static module based part of the testbench (hdl_top), 
		to a UVM component,use the uvm_config_db as follows:
		Step 1: In the HDL part of the testbench assign the static interface to a virtual interface entry in 
		the uvm_config_db:
		Note the following:
		a-The uvm_config_db is parameterised with the type virtual pwm_if
		b-The first argument of the set() method is context, intended to be assigned a UVM component object 
			handle; in this case since we are in the HDL part of the testbench, a null object handle is assigned.
		c-The second argument of the set() method is a string used to identify the UVM component instance name(s)
			within the UVM testbench component hierarchy that may access the data object. This is "uvm_test_top"
			here to restrict access to the top level UVM test object. It could have been assigned a wildcard such 
			as "*",which means that all components in the UVM testbench could access it, but this may not be helpful, 
			and carrys a potential lookup overhead in the get() process.
		d-The third argument of the set() method is a string, intended as the lookup name, i.e. a string that can 
			be used to uniquely identify the virtual interface from within the uvm_config_db.
		e-The final argument of the set() is the static interface assigned to the virtual interface handle entry 
			that is created within the uvm_config_db.
		Step 2: In a UVM test component assign the virtual interface handle from the uvm_config_db entry to the 
		virtual interface handle inside a configuration object:
		Format to set the configuration settings into the config_db:
		uvm_config_db # (data type) :: set (scope{context(handle to the actual component that is calling the DB),
																				instance}, name of the entry,value of the entry)    
		The data type of get() and set() call must match.		
		*/ 
  
//////////////////////////////////////////uvm_config_db set()/////////////////////////////////////////////

	initial begin   
		uvm_config_db # (virtual pwm_interface) :: set(null,"uvm_test_top","pwm_if",pwm_if); 
		run_test();    				     //run_test start execution of uvm phases                                        
	end 
	
endmodule 