/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    05-JULY-2022                                                                        //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    pwm_scb.sv                                                                          //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//            pwm_scb is a flat scoreboard that has predictor and evaluator for the comparison         //
//						of expected results versus actual results.												  										 //
// Revision Date:   						                                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/*imp_decl macro is used when we have multiple write function in a same class. SystemVerilog does not 
	function overloading. */

`uvm_analysis_imp_decl(_predictor)
`uvm_analysis_imp_decl(_evaluator)

class pwm_scb extends uvm_scoreboard;

	//Factory Registration
	`uvm_component_utils(pwm_scb)

	//constructor
	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction
   //////////////////////////////////COMPONENTS MEMBERS//////////////////////////////////////////////

	//create analysis imp export handles
	uvm_analysis_imp_predictor #(pwm_item , pwm_scb) dut_in_imp_export;
	uvm_analysis_imp_evaluator #(pwm_item , pwm_scb) dut_out_imp_export;

//////////////////////////////////////////VIRTUAL INTERFACE//////////////////////////////////////////////

	virtual pwm_interface vif;    									

//////////////////////////////////////////DATA MEMBERS///////////////////////////////////////////////////

	pwm_config pwm_cfg; 												    //handle to configuration object
	//pwm_tx_out expect_aa[bit[23:0]];						  //expected output associative array
	int match, mismatch;
	logic [31:0] DIV,PER,DC;
	logic [31:0] total_output_per, off_time, on_time;
	logic expected_fifo[$:999];
	logic actual_fifo[$:999];
	int counter0 ;
	int counter1 ;
	int counter2 ;

//////////////////////////////////////////METHODS////////////////////////////////////////////////////////

	extern virtual function void build_phase(uvm_phase phase); 				//Standard UVM methods
	extern virtual function void report_phase(uvm_phase phase);
	extern virtual function void write_predictor(pwm_item pwm_tx_in);
	extern virtual function void write_evaluator(pwm_item pwm_tx_out);

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------scoreboard build phase--------------------------------------//

	function void pwm_scb :: build_phase(uvm_phase phase); 
		`uvm_info($sformatf("BUILD PHASE : %s",get_type_name()),
							$sformatf("BUILD PHASE OF %s HAS STARTED !!!",get_type_name()),UVM_LOW);

		//create the components below agent.
		pwm_cfg = pwm_config::type_id::create("pwm_cfg",this);	
		dut_in_imp_export = new("dut_in_imp_export",this);
		dut_out_imp_export = new("dut_out_imp_export",this);

		//get configuration object set by the environment through the DB. 
		if (!uvm_config_db #(pwm_config) :: get(this," ","pwm_cfg",pwm_cfg))
			`uvm_fatal(get_type_name(),"NO AGENT CONFIGURATION OBJECT FOUND !!")
		else 
			`uvm_info($sformatf("AGENT CONFIG OBJECT FOUND : %s",get_type_name()),
							  $sformatf("%s SUCCESSFULLY GOT THE CONFIG OBJECT !!!",get_type_name()),UVM_LOW);		
		
		vif = pwm_cfg.vif;

	endfunction //	function void pwm_scb :: build_phase(uvm_phase phase); 

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------scoreboard build phase--------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------predictor write method--------------------------------------//

	function void pwm_scb :: write_predictor (pwm_item pwm_tx_in);
				
		if (pwm_tx_in.addr_i == 8'h4)
			DIV = pwm_tx_in.wdata_i[15:0];
		
		else if (pwm_tx_in.addr_i == 8'h8)
			PER = pwm_tx_in.wdata_i[15:0];
		
		else if (pwm_tx_in.addr_i == 8'hc)
			DC = pwm_tx_in.wdata_i[15:0];
		
		//else if (pwm_tx_in.addr_i == 8'h0 && pwm_tx_in.wdata_i == 32'h0)
		//	`uvm_info(get_type_name(),"Resetting",UVM_LOW);
		//
		//else if (pwm_tx_in.addr_i == 8'h0 && pwm_tx_in.wdata_i == 32'h7)
		//	`uvm_info(get_type_name(),"Control has transferred",UVM_LOW);
		
		//else
		//	`uvm_info(get_type_name(),"Illegal address",UVM_LOW);

		//Checker logic when control has configured
		//if (pwm_tx_in.addr_i == 8'h0 && counter1 < on_time)	begin
		if (pwm_tx_in.addr_i == 8'h0 && pwm_tx_in.wdata_i == 32'h7)	begin
		//if (pwm_tx_in.dc_seq_en == 1) begin
			total_output_per = (DIV*2)*(PER+1);				// total period of PWM pulse (on_time+off_time)
			off_time = total_output_per - (DC*DIV*2);	//	The time when pulse is low
			on_time = total_output_per - off_time;		// Time when pulse is high
			`uvm_info(get_type_name(),
								$sformatf("DIV: %0h, PER: %0h, DC=%0h, total_output_per=%0h, off_time=%0h, on_time=%0h",DIV,PER,DC,total_output_per,off_time,on_time),
								UVM_LOW);

			counter1 = 0;
			counter2 = 0;

			for (int i = 0; i<total_output_per; i++) begin
				if(counter1 < on_time) begin
					//`uvm_info(get_type_name(),"counter 1 if loop",UVM_LOW);
					expected_fifo.push_back(1);
					counter1 ++;
				end //(counter1 < on_time)

				else begin //!((counter1 < on_time))
				//	`uvm_info(get_type_name(),"counter1 elseloop",UVM_LOW);
					//`uvm_info(get_type_name(),"On time configured",UVM_LOW);
					counter1 = 32'hffffffff;
				end // else

				if(counter2 < off_time) begin
					if(counter1 == 32'hffffffff) begin
					//	`uvm_info(get_type_name(),"counter 2 if loop",UVM_LOW);
						expected_fifo.push_back(0);
						counter2 ++;
					end //(counter1 == 32'hffffffff)

					//else //!(counter1 == 32'hffffffff)
					//	`uvm_info(get_type_name(),"counter 2 else loop",UVM_LOW);
					//	`uvm_info(get_type_name(),"On time has not finished yet",UVM_LOW);
				end	//if(counter2 < off_time)
				
			end	//for (int i = 0; i<total_output_per; i++)
		
			`uvm_info(get_type_name(),$sformatf("expected_fifo contents : %p",expected_fifo),UVM_LOW);

		end	//(pwm_tx_in.addr_i == 8'h0 && pwm_tx_in.wdata_i == 32'h7)
		//end //(pwm_tx_in.dc_seq_en)
		//end //(pwm_tx_in.addr_i == 8'h0 && counter0 != total_output_per)

	endfunction // function void pwm_scb :: write_predictor (pwm_item pwm_tx_in);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------predictor write method--------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------evaluator write method--------------------------------------//

	function void pwm_scb :: write_evaluator (pwm_item pwm_tx_out);

			if (vif.clk_i) begin
				if (pwm_tx_out.oe_pwm1) begin
					if(counter0 < total_output_per) begin
						actual_fifo.push_back(pwm_tx_out.o_pwm);
						counter0 ++;
					end //(counter0 < total_output_per)

					else begin //!(pwm_tx_out.oe_pwm1)
						vif.oe_pwm1 = 0;
						foreach(expected_fifo[i]) begin
							if(expected_fifo[i] == actual_fifo[i]) begin
								match ++;
								//`uvm_info(get_type_name(),$sformatf("No of matches : %0d",match),UVM_LOW);
							end // (expected_fifo[i] == actual_fifo[i])

							else begin //!(expected_fifo[i] == actual_fifo[i])
								mismatch ++;
								//`uvm_info(get_type_name(),$sformatf("No of mis-matches : %0d",mismatch),UVM_LOW);
							end //!(expected_fifo[i] == actual_fifo[i])
						
						end //foreach(expected_fifo[i]) begin
					
					end //!(pwm_tx_out.oe_pwm1)

				end //(pwm_tx_out.oe_pwm1)
			
			end //(vif.clk_i)

	endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------evaluator write method--------------------------------------//

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Scoreboard report_phase-------------------------------------//

	function void pwm_scb :: report_phase(uvm_phase phase);
		`uvm_info($sformatf("REPORT PHASE : %s",get_type_name()),
							$sformatf("REPORT PHASE OF %s HAS STARTED !!!",get_type_name()),UVM_LOW);

		`uvm_info($sformatf("ScoreCard : %s",get_type_name()),
							$sformatf("Matches = %0d and Mis-matches = %0d !!!",match,mismatch),UVM_LOW);

	endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------Scoreboard report_phase-------------------------------------//