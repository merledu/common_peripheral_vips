///////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
//                                                                                                   //
// Engineers:      Auringzaib Sabir - Verification                                                   //
//                                                                                                   //
// Additional contributions by:                                                                      //
//                                                                                                   //
// Create Date:    03-JAN-2022                                                                       //
// Design Name:    TIMER                                                                             //
// Module Name:    config_xactn_timer.sv                                                             //
// Project Name:   VIPs for different peripherals                                                    //
// Language:       SystemVerilog - UVM                                                               //
//                                                                                                   //
// Description:                                                                                      //
//          Transaction classes are always drivered/extended from uvm_sequence_item base class.      //
//          Sequence items class are transaction class                                               //
//          So config_xactn_timer is a single transaction.                                           //
//          Sequence item describes your transaction                                                 //
//                                                                                                   //
// Revision Date:                                                                                    //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////

class config_xactn_timer extends uvm_sequence_item;
  // For transactions we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_object_utils(config_xactn_timer)

	// Define a constructor function
	// It has singal argument name which must have a default value that is typically a class name.
	// All components and transactions call super.new to pass values in uvm base classes
	function new(string name="config_xactn_timer");
		super.new(name);
	endfunction // new

	rand bit          rst_ni                  ;
	rand bit          reg_we                  ;
	rand bit          reg_re                  ;
	rand bit [9-1 :0] reg_addr                ;
	rand bit [64-1:0] reg_wdata               ;
	rand bit [4-1 :0] reg_be                  ;
	rand bit [32-1:0] reg_rdata               ;
	rand bit          reg_error               ;
	rand bit          intr_timer_expired_0_0_o;

	constraint reg_addr_c { reg_addr inside {'h118, 'h11c, 'h114, 'h110, 'h10c, 'h108, 'h104, 'h100, 'h000};}
	constraint reg_wdata_c { reg_wdata inside {[1:500]};}

	// Declare any transaction specific property or field such as data, address and error connection. here the transaction is random 8 bit number
	// Class properties hold the values that are send into the DUT and read from the DUT
	// All inputs should be randomize for maximum controlability. You don't have to use a random values but it you don't declare inputs as rand then you can't randomize them later
	// Since randomize only creates 1's and 0's, so declare the variable as bit(2 state type).
	// Outputs do not need to be randomize but they do need to be declare as 4 state values as logic, so do not miss any unknown values
	rand bit        [ 7:0] data  ;
	rand bit        [31:0] src   ;
	rand bit        [31:0] dst   ;
	rand bit        [31:0] addr  ;
	     logic      [31:0] result;   // The result is also store here
	//rand command_t         cmd   ;
	//rand tx_payload        pay_h ;   // tx_payload is also extended from uvm_sequence_item
  
  // In sequence item we have properties that are
  // Send to the DUT (inputs or stimulus)
  // Read from the DUT (outputs)
  // - DUT outputs & predicted outputr values. Comes in the monitor and send to the Scoreboard

  //====================================================================================================================================================

  // Most of the following methods are declared in uvm_object base class. But all of them are declared as virtual 
	// virtual function bit  	 do_compare    ();   // Deep compare two transactions
	// virtual function void 	 do_copy       ();   // Deep compy of transactions
	// virtual function bit  	 do_print      ();   // Creates a new object and return a handle
	// virtual function bit  	 do_pack       ();
	// virtual function bit  	 do_unpack     ();
	// virtual function bit    do_record     ();
	// virtual function string convert2string();   // Print an object as a string
	// print()                                     // Method print display the transaction properties
  // sprint()                                    // Method sprint like print() except that it returns the resulting string
  // records()                                   // This method records the transaction for further analysis by simulator

  //====================================================================================================================================================

  ///////////////////////////////
  //  DEEP COPY A TRANSACTION  //
  ///////////////////////////////
  // Deep copy a transaction object including the property shown above, System verilog dos not have a deep copy operator so must have followinf for deep copying
  // There are three method to most do methods

  // void function do_copy has one argument rhs for right hand side, because of the rules of system verilog OOP the type of this argument must match the type in the base class where it was declare as a uvm object handle
	virtual function void do_copy(uvm_object rhs);
		// The problem is the config_xactn_timer properties are not visible with uvm object handle
		// STEP 1: Declare a new handle tx_rhs and cast the arguments to this type
		config_xactn_timer tx_rhs;
		if (!$cast (tx_rhs, rhs))
			`uvm_fatal(get_type_name(),"Illegal rhs arguments")
		// STEP 2: This step involves the base class, there may be properties in uvm_sequences_item that need to copied so super.copy and pass the rhs handle
		super.do_copy(rhs);     // Copy the base class properties
		// STEP 3a: This step is used to copy the objects properties. You are copying from another object into this one (this one means where this function is called)
	  //          "this" is this not nessasary in following lines		          
    this.rst_ni                   = tx_rhs.rst_ni                  ;
    this.reg_we                   = tx_rhs.reg_we                  ;
    this.reg_re                   = tx_rhs.reg_re                  ;
    this.reg_addr                 = tx_rhs.reg_addr                ;
    this.reg_wdata                = tx_rhs.reg_wdata               ;
    this.reg_be                   = tx_rhs.reg_be                  ;
    this.reg_rdata                = tx_rhs.reg_rdata               ;
    this.reg_error                = tx_rhs.reg_error               ;
    this.intr_timer_expired_0_0_o = tx_rhs.intr_timer_expired_0_0_o;
    // STEP 3b: Now for the deep copy, uptil this line you copy properties in this object which is just a shallow copy 
    // if ((pay_h != null) && (tx_rhs.pay_h != null))
    // 	pay_h.do_copy(tx_rhs.pay_h);
	endfunction : do_copy

	//====================================================================================================================================================

  ////////////////////////////////////////////
  // DEEP COMPARE TWO SEQUENCE ITEM OBJECTS //
  ////////////////////////////////////////////
  // Deep compare two transactions objects. A virtual do_compare method is called by the scoreboard and returns a bit true or false
  // There are three method to most do methods

  // bit function do_compare has two argument rhs for right hand side and comparer, because of the rules of system verilog OOP the type of this argument must match the type in the base class where it was declare as a uvm object handle
	// uvm_comparer is for advanced comparison
	virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		// The problem is the config_xactn_timer properties are not visible with uvm object handle
		// STEP 1: Declare a new handle tx_rhs and cast the arguments to this type. So you can access the rhs properties
		config_xactn_timer tx_rhs;
		if (!$cast (tx_rhs, rhs))
			`uvm_fatal(get_type_name(),"Illegal rhs arguments")
		// STEP 2: This step involves the base class, there may be properties in uvm_sequences_item that need to compare so super.do_compare and pass the rhs and comparer handle
		//         Since a function returns a value you need to return save it
		return (super.do_compare(rhs, comparer)) &&    // Compare the base class properties
		// STEP 3a: This step is used to compare the objects properties. You are comparing from another object into this one(this means where this functions is called)
	  //          "this" is this not nessasary in following lines
	  //          You should use 4 state case equality operator		          
		       (this.src    === tx_rhs.src   ) &&
		       (this.dst    === tx_rhs.dst 	 ) &&
		       (this.result === tx_rhs.result);
    // STEP 3b: Now for the deep compare, uptil this line you compared properties in this object which is just a shallow compared 
    // ((pay_h == null) ? 1 : (pay_h.do_compare(tx_rhs.pay_h, comparer)));
	endfunction : do_compare

	//====================================================================================================================================================

  //////////////////////
  // CONVERT 2 STRING //
  //////////////////////

  // In your log file you often need to print values in the transaction object. The best way to accomplish this in uvm is with convert2string method
  // Following virtual method returns the string with the content of this object
  virtual function string convert2string();
    // STEP 1: Print he base object
    string s = super.convert2string();
    // STEP 2: ADD more value with $sformat()
    $sformat(s, "%s\n config_xactn_timer values are:", s);
  	//$sformat(s, "%s\n cmd     = %s (0x%0x)", s, cmd.name(), cmd);
  	$sformat(s, "%s\n src,dst = 0x%0x, 0x%0x", s, src, dst);
  	$sformat(s, "%s\n result  = 0x%0x", s, result);
  	// $sformat(s, "%s\n payload = %s", s, (pay_h==null) ? "null" : pay_h.convert2string());
  	return s;
  endfunction : convert2string

  //====================================================================================================================================================

  //////////////////////////////////////////////////
  // PRINT CONVERTED STRING FROM CONVERT 2 STRING //
  //////////////////////////////////////////////////

  
  // Upper covert2string can be printed using following calls
  
  //`uvm_info ("DBG", tx.convert2string(),UVM_DEBUG)
  //`uvm_error("DRV", $sformatf("Bad XACT:", tx.convert2string()))
  //`uvm_fatal("cast", ("$cast failed", tx.convert2string))
  
  // Avoid sprint() & print() as both ignore UVM_VERBOSITY
endclass