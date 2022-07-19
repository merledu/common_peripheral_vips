/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    23rd-MAY-2022                                                                       //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_vseq.sv                                                                         //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//          	 pwm_vseq is a sequence that creates and start other sequences.         								 //
// Revision Date:  25th-MAY-2022                                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class pwm_vseq extends uvm_sequence;

  //Factory Registration
	`uvm_object_utils(pwm_vseq)

	//Constructor
	function new(string name="pwm_vseq");
		super.new(name);
	endfunction
	
	//declare the sequence handle
	uvm_sequencer #(pwm_item) pwm_sqr;
	reset_sequence reset_seq;
	div_sequence div_seq;
	period_sequence period_seq;
	dc_sequence dc_seq;
	ctrl_sequence ctrl_seq;
	rand_sequence rand_seq;

//////////////////////////////////////////METHODS///////////////////////////////////////////////////////

	extern virtual task init_start_seq (output uvm_status_e txn_status,
															 				input uvm_sequencer #(pwm_item) pwm_sqr_i
															 				//other sequencer handles
															 				);

	extern virtual task body();

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------body Method------------------------------------------------------//

	task pwm_vseq :: body();

		div_seq = div_sequence::type_id::create("div_seq");
		period_seq = period_sequence::type_id::create("period_seq");
		dc_seq = dc_sequence::type_id::create("dc_seq");
		ctrl_seq = ctrl_sequence::type_id::create("ctrl_seq");
		reset_seq = reset_sequence::type_id::create("reset_seq");	
		rand_seq = rand_sequence::type_id::create("rand_seq");	
		
		begin
			`uvm_info(get_type_name(),
					  		$sformatf("Reseting the DUT through virtual sequence : %s",get_type_name()),
					  		UVM_LOW);
			reset_seq.start(pwm_sqr,this);

			`uvm_info(get_type_name(),
					  	  $sformatf("Setting the divisor through virtual sequence : %s",get_type_name()),
					  	  UVM_LOW);
			div_seq.start(pwm_sqr,this);

			`uvm_info(get_type_name(),
					  	  $sformatf("Setting the period through virtual sequence : %s",get_type_name()),
					  	  UVM_LOW);
			period_seq.start(pwm_sqr,this);

			`uvm_info(get_type_name(),
					  	  $sformatf("Setting the duty cycle through virtual sequence : %s",get_type_name()),
					  	  UVM_LOW);
			dc_seq.start(pwm_sqr,this);
			
			`uvm_info(get_type_name(),
					  	  $sformatf("Setting the control register through virtual sequence : %s",get_type_name()),
					  	  UVM_LOW);
			ctrl_seq.start(pwm_sqr,this);
			//ctrl_seq.kill(pwm_sqr,this);
			//pwm_sqr.stop_sequences();

			rand_seq.start(pwm_sqr,this);		

		end

	endtask

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------body Method------------------------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------init_start_seq Method--------------------------------------------//

	task pwm_vseq :: init_start_seq (output uvm_status_e txn_status,
																	 input uvm_sequencer #(pwm_item) pwm_sqr_i
																	 //other sequencer handles
																	);
		pwm_sqr = pwm_sqr_i;
		this.start(null);
		//this.stop_sequences();

	endtask

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------init_start_seq Method--------------------------------------------//