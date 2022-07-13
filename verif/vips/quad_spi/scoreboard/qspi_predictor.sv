class qspi_predictor extends uvm_subscriber #(config_xactn_timer);
  // For transactions we have to register this object with uvm factory using macro uvm_object
  // Pass the class name to it
  `uvm_component_utils(qspi_predictor)

	// Define a constructor function
	// It has singal argument name which must have a default value that is typically a class name.
	// All components and transactions call super.new to pass values in uvm base classes
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

	uvm_analysis_port #(config_xactn_timer) expected_port;

	virtual function void build_phase(uvm_phase phase);
	  expected_port = new("expected_port",this);
  endfunction

	virtual function void write(input config_xactn_timer tx);
	  config_xactn_timer expected_txn;
	  if(!$cast(expected_txn, tx.do_copy(tx)))
	    `uvm_fatal(get_type_name(),"Illegal expected_txn arguments")
	endfunction : write


endclass