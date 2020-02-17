module processor(
  input clk,
  output reg [31:0] instr,
  output reg [31:0] pc
  );

  reg [31:0] instr_memory [63:0];
  initial begin
  $readmemb("instr_memory.mem",instr_memory);
  end
  //reg [5:0] pc;
  reg [13:0] sign_extension;
  reg [29:0] sgn_extnd_signal;
  reg [29:0] mux_0;
  reg [29:0] mux_1;
  reg [29:0] branch_mux;
  reg [29:0] mux2_1;
  reg [5:0] next_pc;
  reg [31:0] prev_instr;
  //,instr
  reg jump,branch,zero;
  //decode_n_execute ux111(.instr(instr),.instr_memory(instr_memory));

  initial begin
		jump=0;
		branch=0;
		zero=0;
		prev_instr=0;
		next_pc=0;
  end 
  always@(negedge clk) begin
		pc=next_pc;
      sign_extension = 14'b11111111111111 & prev_instr[15] + 14'b0000000000000000 & !prev_instr[15];
      sgn_extnd_signal = {sign_extension,prev_instr[15:0]};
      mux_0=pc[31:2] + 30'b000000000000000000000000000001;
      mux_1= mux_0 + sgn_extnd_signal;
      branch_mux=((~(branch && zero ))& mux_0) | ((branch && zero )& mux_1);
      mux2_1={pc[31:28],prev_instr[25:0]};
   	pc={branch_mux,2'b00};
		instr = instr_memory[pc[5:0]];
		prev_instr=instr;
		next_pc=pc;
  end

endmodule
