/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    13TH-MAY-2022                                                                       //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_config.sv                                                                       //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//          	pwm_config has configuration settings that will be store in config db.                   //
// Revision Date:                                                                                      //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class pwm_config extends uvm_object;

	//Factory registration
	`uvm_object_utils(pwm_config)

	//constructor
	function new(string name="pwm_config");
		super.new(name);	
	endfunction

	//virtual interface
	virtual pwm_interface vif;

	//Sequencer handle
    uvm_sequencer #(pwm_item) sqr; 	
	
	//configure whether the agent is active or passive;
	uvm_active_passive_enum active = UVM_ACTIVE;

endclass