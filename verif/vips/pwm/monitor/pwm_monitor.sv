/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    8-MAY-2022                                                                          //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_monitor.sv                                                                      //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//            pwm_monitor broadcast the input and output transactions from DUT through the analysis    //
//						port.                                                                                    //
// Revision Date:   25-May-2022                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class pwm_monitor extends uvm_monitor;
	
	//Factory Registration
	`uvm_component_utils(pwm_monitor)

	//constructor
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

//////////////////////////////////////////VIRTUAL INTERFACE//////////////////////////////////////////////

	virtual pwm_interface vif;    									/*like driver, monitor too use virtual interface to 
																										call interface methods.*/

//////////////////////////////////////////DATA MEMBERS///////////////////////////////////////////////////

	pwm_config pwm_cfg; 												    //handle to configuration object

//////////////////////////////////////////COMPONENTS MEMBERS//////////////////////////////////////////////

	uvm_analysis_port #(pwm_item) dut_in_tx_port;   //for sending input transactions
	uvm_analysis_port #(pwm_item) dut_out_tx_port;  //for sending output transactions

//////////////////////////////////////////METHODS///////////////////////////////////////////////////////

	//Standard UVM methods
	extern virtual function void build_phase(uvm_phase phase); 
	extern virtual task run_phase(uvm_phase phase);
	
	//Method for getting inputs and outputs from the DUT through the interface
	extern virtual task get_inputs();
	extern virtual task get_outputs();

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Monitor build phase-----------------------------------------//

	function void pwm_monitor :: build_phase(uvm_phase phase); 
		`uvm_info($sformatf("BUILD PHASE : %s",get_type_name()),
							$sformatf("BUILD PHASE OF %s HAS STARTED !!!",get_type_name()),UVM_LOW);
		//Unlike driver single TLM port, monitor's analysis port has not declared in the base class.
		//These TLM classes are never extended, so no need to call factory to create an object.
		//Constructor has 2 arguments: 
		//i) Instance name 
		//ii) handle to the parent
		dut_in_tx_port  = new("dut_in_tx_port",this);
		dut_out_tx_port = new("dut_out_tx_port",this);

		//get configuration object set by the environment through the DB. 
		if (!uvm_config_db #(pwm_config) :: get(this," ","pwm_cfg",pwm_cfg))
			`uvm_fatal(get_type_name(),"NO AGENT CONFIGURATION OBJECT FOUND !!")
		else 
			`uvm_info($sformatf("AGENT CONFIG OBJECT FOUND : %s",get_type_name()),
							  $sformatf("%s SUCCESSFULLY GOT THE CONFIG OBJECT !!!",get_type_name()),UVM_LOW);		
		
		vif = pwm_cfg.vif;

	endfunction //	function void pwm_monitor :: build_phase(uvm_phase phase); 

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Monitor build_phase-----------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Monitor run_phase-----------------------------------------//

	task pwm_monitor :: run_phase(uvm_phase phase);
		`uvm_info($sformatf("RUN PHASE : %s",get_type_name()),
							$sformatf("RUN PHASE : %s HAS STARTED !!!",get_type_name()),UVM_LOW);		
		//input and output transaction are process separately, so spawn off separate thread to the receiver
		fork
			get_inputs();
			get_outputs();
		join

	endtask //	task pwm_monitor :: get_inputs();

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Monitor run_phase-------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------get_inputs method-------------------------------------------//

	task pwm_monitor :: get_inputs();
		pwm_item pwm_tx_in;
		forever begin
			@(posedge vif.clk_i) begin
				pwm_tx_in=pwm_item::type_id::create("pwm_tx_in");
				vif.get_an_input(pwm_tx_in); 
				/*
				call interface method get_an_input by passing handle to the argument. 
				The method waits for the DUT input transaction to fills in the properties of input transaction. 
				*/
				dut_in_tx_port.write(pwm_tx_in); //broadcast the transaction to the port
			end
//		`uvm_info("PWM_TX_IN",pwm_tx_in.convert2string(),UVM_LOW);
		end
	endtask //	task pwm_monitor :: get_inputs();

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------get_inputs method-------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------get_outputs method------------------------------------------//

	task pwm_monitor :: get_outputs();
		pwm_item pwm_tx_out;
		forever begin
			@(posedge vif.clk_i) begin
				pwm_tx_out=pwm_item::type_id::create("pwm_tx_out");
				vif.get_an_output(pwm_tx_out); 
				/*
				call interface method get_an_output by passing handle to the argument. 
				The method waits for the DUT output transaction to fills in the properties of output transaction. \
				*/
				dut_out_tx_port.write(pwm_tx_out); //send the transaction for analysis to the TLM connection
			end
//		`uvm_info("PWM_TX_OUT",pwm_tx_out.convert2string(),UVM_LOW);
		end
	endtask //	task pwm_monitor :: get_outputs();

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------get_outputs method------------------------------------------//