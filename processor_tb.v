`timescale 1ns / 1ps
module processor_tb;

	// Inputs
	reg clk; 
	reg reset;
	wire [31:0] pc;
	wire [31:0] instr;
	wire [31:0] ALU_Out;
	// input channel
    reg inp_valid;
    wire inp_ready;
    // output channel
    wire out_valid;
    reg out_ready;
	// Instantiate the Unit Under Test (UUT)
	processor uut (
		.clk(clk),
		.instr(instr),
		.pc(pc),
		.ALU_Out(ALU_Out),
		.reset(reset),
      .inp_valid_i(inp_valid),
      .inp_ready_o(inp_ready),
      .out_valid_o(out_valid),
      .out_ready_i(out_ready)
	);
	initial #2000 $finish;

	initial begin
		// Initialize Inputs
		#100;
		clk = 0;
		reset=0;
		out_ready=1;
		inp_valid=1;
	end 
	
	always begin
	#5 clk=~clk;
	end
       
	// -- Receiver Side -- //
always @(negedge clk) begin: ff_ready_in
    if (reset) begin
       out_ready <= 0;
    end else begin
        out_ready <= 1; // some randomness on the receiver, otherwise, we won't see if our DUT behaves correctly in case of ready=0
  end
end
  
always@(*) begin
inp_valid = (pc < 32'd88) ? 1'b1 : 1'b0;  
end
endmodule

