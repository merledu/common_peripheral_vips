/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    7-MAY-2022                                                                          //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_env.sv                                                                          //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//            pwm_env instantiate the agent in the build phase.                                        //
// Revision Date:  05-JULY-22                                                                          //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class pwm_env extends uvm_env;

	//Factory registration
	`uvm_component_utils(pwm_env)

	//constructor
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction 

//////////////////////////////////////////DATA MEMBERS///////////////////////////////////////////////////

	pwm_config pwm_cfg;				  //handle to configuration object
	env_config env_cfg;				  //handle to configuration object


//////////////////////////////////////////COMPONENTS MEMBERS//////////////////////////////////////////////

	pwm_agent agt;
	pwm_scb scb;

//////////////////////////////////////////METHODS///////////////////////////////////////////////////////

	// Standard UVM Methods:	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Env build phase---------------------------------------------//

	//building the components inside the hierarchy of environment class
	function void pwm_env :: build_phase(uvm_phase phase);
		`uvm_info($sformatf("BUILD PHASE : %s",get_type_name()),
							$sformatf("BUILD PHASE OF %s HAS STARTED !!!",get_type_name()),UVM_LOW);

		//create the config objects and low level components						
		agt = pwm_agent::type_id::create("agt",this);
		pwm_cfg = pwm_config::type_id::create("pwm_cfg",this);
		env_cfg = env_config::type_id::create("env_cfg",this);

		//get the environment configuration object from the DB
		if (!uvm_config_db # (env_config) :: get (this,"","env_cfg",env_cfg))
			`uvm_fatal(get_type_name(),"NO ENVIRONMENT CONFIGURATION OBJECT FOUND !!")
		else 
			`uvm_info($sformatf("ENV CONFIG OBJECT FOUND : %s",get_type_name()),
							  $sformatf("%s SUCCESSFULLY GOT THE CONFIG OBJECT !!!",get_type_name()),UVM_LOW);	

		//set the PWM configuration object into the DB.
		uvm_config_db # (pwm_config) :: set (this,"agt*","pwm_cfg",env_cfg.pwm_cfg); 	

		if (env_cfg.enable_coverage) begin
			`uvm_info($sformatf("COVERAGE ENABLED AT : %s",get_type_name()),
								"CREATING COVERAGE COLLECTOR !!!",UVM_LOW);		
			//cov = cov_collector::typeid::create("cov",this);
		end

		if (env_cfg.enable_scoreboard) begin
			`uvm_info($sformatf("SCOREBOARD ENABLED AT : %s",get_type_name()),
								"CREATING SCOREBOARD !!!",UVM_LOW);			
		  scb = pwm_scb::type_id::create("scb",this);

			//set the PWM configuration object into the DB.
			uvm_config_db # (pwm_config) :: set (this,"scb*","pwm_cfg",env_cfg.pwm_cfg);
		end
		
		endfunction // 	function void pwm_env :: build_phase(uvm_phase phase);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Env build phase---------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Env build phase---------------------------------------------//

	function void pwm_env :: connect_phase(uvm_phase phase);

		`uvm_info($sformatf("CONNECT PHASE : %s",get_type_name()),
							$sformatf("CONNECT PHASE : %s HAS STARTED !!!",get_type_name()),UVM_LOW);

		//connect agents analysis port to scb analysis imp export
		agt.dut_in_tx_port.connect(scb.dut_in_imp_export);
		agt.dut_out_tx_port.connect(scb.dut_out_imp_export);
	
	endfunction //	function void pwm_env :: connect_phase(uvm_phase phase);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Env build phase---------------------------------------------//