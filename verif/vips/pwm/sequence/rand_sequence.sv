/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      Kinza Qamar Zaman - Verification                                                    //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    13-JULY-2022                                                                        //
// Design Name:    PWM Verification IP                                                                 //
// Module Name:    rand_sequence.sv                                                                    //
// Project Name:   PWM Verification IP.                                                                //
// Language:       SystemVerilog - UVM                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//            rand_sequence generates transactions after the control has configured.  	  						 //
// Revision Date:                                                                                      //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class rand_sequence extends uvm_sequence # (pwm_item);

  //Factory Registration
	`uvm_object_utils(rand_sequence)

	//Constructor
	function new(string name="rand_sequence");
		super.new(name);
	endfunction

//////////////////////////////////////////METHODS///////////////////////////////////////////////////////

	// Standard UVM Methods:	
	extern virtual task body();

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
	The two most important properties of a sequence are the body method and the sequencer handle. 
	
	The body Method:
	An uvm_sequence contains a task method called body. It is the content of the body method that determines 
	what the sequence does.
	
	The sequencer Handle:
	When a sequence is started it is associated with a sequencer. The sequencer handle contains the 
	reference to the sequencer on which the sequence is running. The sequencer handle can be used to access 
	configuration information and other resources in the UVM component hierarchy.
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////Running a sequence/////////////////////////////////////////////
//Step 1 - Sequence creation
//Step 2 - Sequence configuration
//Step 3 - Starting the sequence:	
//				 A sequence is started using a call to its start() method, passing as an argument a pointer to 
//				 the sequencer through which it will be sending sequence_items to a driver. The start() method
//				 assigns the sequencer pointer to a sequencer handle called m_sequencer within the sequence 
//				 and then calls the body task within the sequence. When the sequence body task completes, the 
//				 start method returns. Since it requires the body task to finish and this requires interaction
//				 with a driver, start() is a blocking method.

//////////////////////////////////Sending a sequence_item to a driver///////////////////////////////////
//Step 1 - Creation
//Step 2 - Ready - start_item()
//Step 3 - Set
//Step 4 - Go - finish_item():
//				 The finish_item() call is made, which blocks until the driver has completed its side of the 
//				 transfer protocol for the item. No simulation time should be consumed between start_item() 
//				 and finish_item().
//Step 5 - Response - get_response():
//				 This step is optional, and is only used if the driver sends a response to indicate that it has
//				 completed transaction associated with the sequence_item. The get_response() call blocks until
//			   a response item is available from the sequencers response FIFO.

  task rand_sequence :: body();
		pwm_item tx;
		repeat(5) begin 			        								//generate transactions for n times
			//Step 1 - Creation
			tx = pwm_item::type_id::create("tx"); 			//Body task creates transaction using factory creation
			
			//Step 2 - Ready - start_item()
			start_item(tx);		                  				/*start item. sequence body() blocks waiting for driver 
																										to be ready.Driver ask about sending transaction in 
																										its run phase.*/				
																									//Wait for driver to be ready
			//Step 3 - Set
			if (!tx.randomize())		           					//Randomize transaction
				`uvm_fatal("Fatal","Randomization Failed")
			//tx.dc_data(tx);
			tx.addr_i  	 = 8'h8;												//Address to set Duty cycle for channel 1
			tx.rst_ni    = 1'h1;
			tx.we_i    	 = 1'h0;
			tx.be_i    	 = 4'b0000;
			tx.re_i    	 = 1'h0;
			tx.wdata_i   = 32'h00000007;
			//tx.dc_seq_en = 1'h1;		
				
			//Step 4 - Go - finish_item()
			finish_item(tx);		          					    /*Sends transaction and waits for response from driver 
																										to know when it is ready again to generate and send 
																										transactions again.*/
			//Step 5 - Response - get_response()

		end
		
	endtask //  task rand_sequence :: body();

//////////////////////////////////Sending a sequence_item to a driver///////////////////////////////////
//////////////////////////////////////////Running a sequence///////////////////////////////////////////

//After the body() methods returns , it passes the control back to the test.