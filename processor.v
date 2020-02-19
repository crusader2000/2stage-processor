module processor(
  input clk,
  output reg [31:0] instr,
  output reg [31:0] pc
  );
//////////////////FETCH UNIT////////////////////////// 
   reg [31:0] instr_memory [255:0];
   initial begin
   $readmemb("instr_memory.mem",instr_memory);
   end
   reg [13:0] sign_extension;
   reg [29:0] sgn_extnd_signal;
   reg [29:0] mux_0;
   reg [29:0] mux_1;
   reg [29:0] branch_mux;
   reg [29:0] mux2_1;
   reg [5:0] next_pc;
   reg [31:0] prev_instr;
   reg jump,branch,zero;
   ////////////DECODE UNIT AND EXECUTE/////////////////////////////////
	reg [31:0] main_memory [63:0];
	initial begin
	  $readmemb("main_memory.mem",main_memory);
	end
	reg reg_dst;
	reg reg_wr;
	reg ext_op;
	reg [3:0] alu_ctr;
	reg alu_src;
	reg mem_wr;
	reg memto_reg;
	reg [4:0] rs,rt,rd;
	reg [15:0] imm16;
	reg alu_op_2,alu_op_1,alu_op_0;
	reg alu_out;

	//Register Write and Register Destination
	reg [5:0] rw;

	//EXTENDER
	reg [15:0] ext;

	reg [31:0] ip1,ip2,imm;
	reg [31:0] ALU_Out;
   initial begin
		jump=0;
		branch=0;
		zero=0;
		prev_instr=0;
		next_pc=0;
		instr=0;
   end 
   	  
  always@(negedge clk) begin
		 $display("fetch %t %b",$time,instr);
	    pc=next_pc;
		 instr=prev_instr;
       sign_extension = 14'b11111111111111 & prev_instr[15] + 14'b0000000000000000 & !prev_instr[15];
       sgn_extnd_signal = {sign_extension,prev_instr[15:0]};
       mux_0=pc[31:2] + 30'b000000000000000000000000000001;
       mux_1= mux_0 + sgn_extnd_signal;
       branch_mux=((~(branch && zero ))& mux_0) | ((branch && zero )& mux_1);
       mux2_1={pc[31:28],prev_instr[25:0]};
   	 pc={branch_mux,2'b00};
		 instr = {instr_memory[pc]};
		 prev_instr=instr;
		 next_pc=pc;
	end
	
	always@(negedge clk) begin	 
		$display("decode %t %b",$time,instr);
		
		reg_dst=(~instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (~instr[27]) & (~instr[26]));
		 reg_wr=(~instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (~instr[27]) & (~instr[26]))|
				  (~instr[31] & (~instr[30]) & (instr[29]) & (instr[28]) & (~instr[27]) & (instr[26]))|
				  (instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (instr[27]) & (instr[26]));
		 ext_op=(instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (instr[27]) & (instr[26]))|
				  (instr[31] & (~instr[30]) & (instr[29]) & (~instr[28]) & (instr[27]) & (instr[26]));
		 alu_op_2=(~instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (~instr[27]) & (~instr[26]));
		 alu_op_1=(~instr[31] & (~instr[30]) & (instr[29]) & (instr[28]) & (~instr[27]) & (instr[26]));
		 alu_op_0=(~instr[31] & (~instr[30]) & (~instr[29]) & (instr[28]) & (~instr[27]) & (~instr[26]));
		 branch=(~instr[31] & (~instr[30]) & (~instr[29]) & (instr[28]) & (~instr[27]) & (~instr[26]));
		 jump=(~instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (instr[27]) & (~instr[26]));
		 alu_ctr[0]=(instr[5] & ~instr[4] & ~instr[3] & ~instr[2] & instr[1] & ~instr[0]) |
						(~instr[5] & ~instr[4] & ~instr[3] & ~instr[2] & ~instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & ~instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & instr[3] & ~instr[2] & instr[1] & ~instr[0]) |
						(~alu_op_2 & ~alu_op_1 &alu_op_0);
		 alu_ctr[1]=(~instr[5] & ~instr[4] & ~instr[3] & ~instr[2] & ~instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & ~instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & instr[1] & instr[0]) ;
		 alu_ctr[2]=(~instr[5] & ~instr[4] & ~instr[3] & ~instr[2] & instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & ~instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & instr[3] & ~instr[2] & instr[1] & ~instr[0]) ;
		 alu_ctr[3]=(instr[5] & ~instr[4] & ~instr[3] & instr[2] & ~instr[1] & instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & instr[3] & ~instr[2] & instr[1] & ~instr[0]) |
						(instr[5] & ~instr[4] & ~instr[3] & instr[2] & instr[1] & instr[0]) |
						(~alu_op_2 & alu_op_1 & ~alu_op_0);
		 alu_src= (~instr[31] & (~instr[30]) & (instr[29]) & (instr[28]) & (~instr[27]) & (instr[26])) |
					 (instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (instr[27]) & (instr[26])) |
					 (instr[31] & (~instr[30]) & (instr[29]) & (~instr[28]) & (instr[27]) & (instr[26]));
		 mem_wr=instr[31] & (~instr[30]) & (instr[29]) & (~instr[28]) & (instr[27]) & (instr[26]);
		 memto_reg=instr[31] & (~instr[30]) & (~instr[29]) & (~instr[28]) & (instr[27]) & (instr[26]);
		 rt=instr[25:21];
		 rs=instr[20:16];
		 rd=instr[15:11];
		 imm16=instr[15:0];
		//////////////////////
		 rw=reg_wr&((reg_dst&(rd))|(~reg_dst&(rt)));
		 ext=(ext_op)&(16'b1111111111111111) | (~ext_op)&(16'b0000000000000000);
		 imm={ext,imm16};
		 ip2=((alu_src)&(imm)) | ((~alu_src)&(main_memory[rt]));
		 ip1=main_memory[rs];
		 case(alu_ctr)
			  4'b0000: // Addition
				  ALU_Out = ip1 + ip2 ;
			  4'b0001: // Subtraction
				  ALU_Out = ip1 - ip2 ;
			  4'b0010: //Multiplication
					ALU_Out=ip1[15:0]*ip2[15:0];
				4'b0011: //Logical shift left
					ALU_Out = ip1<<1;
				4'b0100: // Logical shift right
				  ALU_Out = ip1>>1;
				4'b0101: // Rotate left
				  ALU_Out = {ip1[30:0],ip1[31]};
				4'b0110: // Rotate right
				  ALU_Out = {ip1[0],ip1[31:1]};
				 4'b0111: //  Logical and
				  ALU_Out = ip1 & ip2;
				 4'b1000: //  Logical or
				  ALU_Out = ip1 | ip2;
				 4'b1001: //  Logical xor
				  ALU_Out = ip1 ^ ip2;
				 4'b1010: //  Logical nor
				  ALU_Out = ~(ip1 | ip2);
				 4'b1011: // Logical nand
				  ALU_Out = ~(ip1 & ip2);
				 4'b1100: // Logical xnor
				  ALU_Out = ~(ip1 ^ ip2);
				 4'b1101: // Less than comparison
				  ALU_Out = (ip1<ip2)?32'd1:32'd0 ;
				 4'b1110: // Equal comparison
					ALU_Out = (ip1==ip2)?32'd1:32'd0 ;
				 default: begin
				 end
			  endcase
			  
			main_memory[rw]=ALU_Out;
			zero=ALU_Out[31]|ALU_Out[30]|ALU_Out[29]|ALU_Out[28]|ALU_Out[27]|ALU_Out[26]|ALU_Out[25]|ALU_Out[24]|ALU_Out[23]|ALU_Out[22]|ALU_Out[21]|ALU_Out[20]|
			ALU_Out[19]|ALU_Out[18]|ALU_Out[17]|ALU_Out[16]|ALU_Out[15]|ALU_Out[14]|ALU_Out[13]|ALU_Out[12]|ALU_Out[11]|ALU_Out[10]|ALU_Out[9]|ALU_Out[8]|ALU_Out[7]|
			ALU_Out[6]|ALU_Out[5]|ALU_Out[4]|ALU_Out[3]|ALU_Out[2]|ALU_Out[1]|ALU_Out[0];
		
 //Need to make changes for Load and Store Word
end
always@(negedge clk) begin
		 $display("fetch %t %b",$time,prev_instr);
	    pc=next_pc;
		 instr=prev_instr;
       sign_extension = 14'b11111111111111 & prev_instr[15] + 14'b0000000000000000 & !prev_instr[15];
       sgn_extnd_signal = {sign_extension,prev_instr[15:0]};
       mux_0=pc[31:2] + 30'b000000000000000000000000000001;
       mux_1= mux_0 + sgn_extnd_signal;
       branch_mux=((~(branch && zero ))& mux_0) | ((branch && zero )& mux_1);
       mux2_1={pc[31:28],prev_instr[25:0]};
   	 pc={branch_mux,2'b00};
		 instr = {instr_memory[pc]};
		 prev_instr=instr;
		 next_pc=pc;
	end
	
endmodule
