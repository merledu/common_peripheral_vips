/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    05-MAY-2022                                                                         //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_agent.sv                                                                        //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//            pwm_agent builds and connects driver and sequencer.                                      //
// Revision Date:  21-MAY-2022                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class pwm_agent extends uvm_agent;

	//Factory registration
	`uvm_component_utils(pwm_agent)

	//constructor
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

//////////////////////////////////////////DATA MEMBERS///////////////////////////////////////////////////

	pwm_config pwm_cfg; 												    //handle to configuration object

//////////////////////////////////////////COMPONENTS MEMBERS//////////////////////////////////////////////

	pwm_driver drv;
	pwm_monitor mon;
	uvm_sequencer #(pwm_item) sqr; 								   //Never extended
	uvm_analysis_port #(pwm_item) dut_in_tx_port; 	 //Port for sending input transactions
	uvm_analysis_port #(pwm_item) dut_out_tx_port;	 //Port for sending output transactions

//////////////////////////////////////////METHODS////////////////////////////////////////////////////////

	//Standard UVM methods:
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);	

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Agent build_phase-------------------------------------------//

	//building the components inside the hierarchy of agent class
	function void pwm_agent :: build_phase(uvm_phase phase);
		`uvm_info($sformatf("BUILD PHASE : %s",get_type_name()),
							$sformatf("BUILD PHASE : %s HAS STARTED !!!",get_type_name()),UVM_LOW);

		//create the components below agent.
		pwm_cfg = pwm_config::type_id::create("pwm_cfg",this);	
		dut_in_tx_port  = new("dut_in_tx_port",this);
		dut_out_tx_port = new("dut_out_tx_port",this);

		//always create the monitor
		mon = pwm_monitor::type_id::create("mon",this);
		
		//get configuration information set by the environment through the DB. 
		if (!uvm_config_db # (pwm_config) :: get (this,"","pwm_cfg",pwm_cfg))
			`uvm_fatal(get_type_name(),"NO AGENT CONFIGURATION OBJECT FOUND !!")
		else 
			`uvm_info($sformatf("AGENT CONFIG OBJECT FOUND : %s",get_type_name()),
							  $sformatf("%s SUCCESSFULLY GOT THE CONFIG OBJECT !!!",get_type_name()),UVM_LOW);			 

		//if the agent is active, create driver and sequencer
		if (pwm_cfg.active == UVM_ACTIVE) begin
			`uvm_info($sformatf("ACTIVE AGENT : %s",get_type_name()),
							  $sformatf("CREATING DRIVER AND SEQUENCER !!!"),UVM_LOW);
			drv = pwm_driver::type_id::create("drv",this);
			sqr = new("sqr",this);
			pwm_cfg.sqr = sqr;
		end

	endfunction //	function void pwm_agent :: build_phase(uvm_phase phase);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Agent build_phase-------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Agent connect_phase-----------------------------------------//

	//connecting the components inside the hierarchy of agent class
	/*The TLM connection between the components would follow the pattern as:
		intiator.port.connect(target.port)
	*/
	function void pwm_agent :: connect_phase(uvm_phase phase);
		//connect monitor input and output analysis port to the agent's port.
		//Note that /*this*/ handle is optional.	
		`uvm_info($sformatf("CONNECT PHASE : %s",get_type_name()),
							$sformatf("CONNECT PHASE : %s HAS STARTED !!!",get_type_name()),UVM_LOW);
		mon.dut_in_tx_port.connect(this.dut_in_tx_port);
		mon.dut_out_tx_port.connect(this.dut_out_tx_port);
		
		// Only connect the driver and the sequencer if active
		if (pwm_cfg.active == UVM_ACTIVE) begin
			// The agent is actively driving stimulus
			// Driver-Sequencer TLM connection
			drv.seq_item_port.connect(sqr.seq_item_export); //Can't connect in build phase
			`uvm_info($sformatf("CONNECTING DRIVER-SEQUENCER : %s",get_type_name()),
								"Driver-Sequencer successfully connected",UVM_LOW);
			// Virtual interface assignment
					//...
		end

	endfunction //	function void pwm_agent :: connect_phase(uvm_phase phase);	

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Agent connect_phase-----------------------------------------//