`timescale 1ns / 1ps
module processor_tb;

	// Inputs
	reg clk; 
	wire [31:0] pc;
	wire [31:0] instr;
	wire [31:0] ALU_Out;

	// Instantiate the Unit Under Test (UUT)
	processor uut (
		.clk(clk),
		.instr(instr),
		.pc(pc),
		.ALU_Out(ALU_Out)
	);
	initial #140 $finish;
	initial begin
		// Initialize Inputs
		#100;
		clk = 1;
	end 
	
	always begin
	#5 clk=~clk;
	end
      
endmodule

