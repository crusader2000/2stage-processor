`timescale 1ns / 1ps

module processor_tb;

	// Inputs
	reg clk; 
	wire [31:0] pc;
	wire [31:0] instr;

	// Instantiate the Unit Under Test (UUT)
	processor uut (
		.clk(clk),
		.instr(instr),
		.pc(pc)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
	end
	
	always begin
	#5 clk=~clk;
	end
      
endmodule

