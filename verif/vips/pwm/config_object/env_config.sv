/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    13TH-MAY-2022                                                                       //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    env_config.sv                                                                       //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//             env_config has environment configuration settings that will be store in config db.      //
// Revision Date:                                                                                      //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class env_config extends uvm_object;

	//Factory registration
	`uvm_object_utils(env_config)

	//constructor
	function new(string name="env_config");
		super.new(name);
	endfunction

//////////////////////////////////////////DATA MEMBERS///////////////////////////////////////////////////

// Whether env analysis components are used:
  bit enable_scoreboard=1;
  bit enable_coverage=0;

// Configurations for the sub_components
  pwm_config pwm_cfg;

// Whether the various agents are used:
	//	...

endclass