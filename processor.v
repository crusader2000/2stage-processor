module processor(
    input clk,
    output reg [31:0] instr,
    output reg [31:0] pc,
    output reg [31:0] ALU_Out
  );
  //////////////////FETCH UNIT////////////////////////// 
  reg [7:0] instr_memory [11:0];
  initial begin
    $readmemb("instr_memory.mem",instr_memory);
  end
  reg [13:0] sign_extension;
  reg [29:0] sgn_extnd_signal;
  reg [29:0] mux_0;
  reg [29:0] mux_1;
  reg [31:0] a,b,c;
  reg [29:0] branch_mux;
  reg [29:0] mux2_1;
  //   reg [5:0] next_pc;
  reg [31:0] prev_instr,decode_instr;
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
  reg [4:0] rw;

  //EXTENDER
  reg [15:0] ext;

  reg [31:0] ip1,ip2,imm;
  initial begin
  jump=0;
  branch=0;
  zero=0;
  decode_instr=0;
  pc=0;
  instr=0;
  end 

  always@(negedge clk) begin
    //	   pc=next_pc;
    decode_instr=instr;
    a=pc+31'd1;
    b=pc+31'd2;
    c=pc+31'd3;
    instr = {instr_memory[pc],instr_memory[a],instr_memory[b],instr_memory[c]};
    $display("fetch %t %b %b %b %b",$time,instr_memory[pc],instr_memory[a],instr_memory[b],instr_memory[c]);
	 $display("fetch %t %b",$time,instr);
    // instr=prev_instr;
    sign_extension = 14'b11111111111111 & instr[15] + 14'b00000000000000 & !instr[15];
    sgn_extnd_signal = {sign_extension,instr[15:0]};
    mux_0=pc[31:2] + 30'b000000000000000000000000000001;
    mux_1= mux_0 + sgn_extnd_signal;
    branch_mux=((~(branch && zero ))& mux_0) | ((branch && zero )& mux_1);
    mux2_1={pc[31:28],instr[25:0]};
    pc={branch_mux,2'b00};
    //prev_instr=instr;
    //next_pc=pc;
  end

  always @(negedge clk) begin   
    $display("decode %t %b",$time,decode_instr);
    reg_dst=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));
    reg_wr=((~decode_instr[31]) & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))
    |(~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|(decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));
    ext_op=(decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          (decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));
    alu_op_2=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));
    alu_op_1=(~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]));
    alu_op_0=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));
    branch=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));
    jump=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]));
    alu_ctr[0]=(decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0]) |
      (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & ~decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0]) |
      (~alu_op_2 & ~alu_op_1 &alu_op_0);
    alu_ctr[1]=(~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & ~decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0]) ;
    alu_ctr[2]=(~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0]) ;
    alu_ctr[3]=(decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0]) |
      (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0]) |
      (~alu_op_2 & alu_op_1 & ~alu_op_0);
    alu_src= (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26])) |
      (decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26])) |
      (decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));
    mem_wr=decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]);
    memto_reg=decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]);
    rs=decode_instr[25:21];
    rt=decode_instr[20:16];
    rd=decode_instr[15:11];
    imm16=decode_instr[15:0];
    //////////////////////
    if (reg_wr) begin
		if (reg_dst)
			rw=rd;
		else 
			rw=rt;
	 end
	 else 
		rw=5'bxxxxxx;
	   
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
    if (reg_wr)
      main_memory[rw] = ALU_Out;
    else 
     main_memory[rw]= 32'd0;

    zero=ALU_Out[31]|ALU_Out[30]|ALU_Out[29]|ALU_Out[28]|ALU_Out[27]|ALU_Out[26]|ALU_Out[25]|ALU_Out[24]|ALU_Out[23]|ALU_Out[22]|ALU_Out[21]|ALU_Out[20]|ALU_Out[19]|ALU_Out[18]|ALU_Out[17]|ALU_Out[16]|ALU_Out[15]|ALU_Out[14]|ALU_Out[13]|ALU_Out[12]|ALU_Out[11]|ALU_Out[10]|ALU_Out[9]|ALU_Out[8]|ALU_Out[7]|ALU_Out[6]|ALU_Out[5]|ALU_Out[4]|ALU_Out[3]|ALU_Out[2]|ALU_Out[1]|ALU_Out[0];
    $display("decode rs %b",rs);
    $display("decode rt %b",rt);
    $display("decode rd %b",rd);
    $display("decode rw %b",rw);
    $display("decode main_memory[rw] %b",main_memory[rw]);
    //Need to make changes for Load and Store Word
  end

endmodule
