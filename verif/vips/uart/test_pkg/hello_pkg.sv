package hello_pkg;
	import uvm_pkg::*;         // To bring uvm base library, from which we extend all the testbench components
	`include "uvm_macros.svh"  // To make use of macros that are found in uvm libraries

  // Test class that prints the hello world message
  `include "./tests/hello_test.sv"

endpackage // hello_pkg