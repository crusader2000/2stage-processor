module processor(
    input clk,
	 input reset,
    output reg [31:0] instr,
    output reg [31:0] pc,
    output reg [31:0] ALU_Out,
	 // input channel
    input   inp_valid_i,
    output  inp_ready_o,
    // output channel
    output  out_valid_o,
    input   out_ready_i
  );
  //////////////////FETCH UNIT////////////////////////// 
  reg [7:0] instr_memory [87:0];
  reg [13:0] sign_extension;
  reg [29:0] sgn_extnd_signal;
  reg [29:0] mux_0;
  reg [29:0] mux_1;
  reg [31:0] a,b,c;
  reg [29:0] branch_mux;
  reg [29:0] mux2_1;
  reg [31:0] prev_pc,jump_pc,jump_instr;
  reg [31:0] prev_instr,decode_instr,branch_instr;
  reg jump,branch,zero,fetch_zero;
  ////////////DECODE UNIT AND EXECUTE/////////////////////////////////
  reg [31:0] main_memory [31:0];
  reg [7:0] data_memory [63:0];
  reg reg_dst;
  reg reg_wr;
  reg ext_op;
  reg [4:0] alu_ctr;
  reg alu_src;
  reg mem_wr;
  reg memto_reg;
  reg [4:0] rs,rt,rd;
  reg [15:0] imm16;
  reg alu_op_2,alu_op_1,alu_op_0;
  reg alu_out;
  reg sltiu;
  reg bgtz_bne_blez;
  reg lb,sb,jal;
  //Register Write and Register Destination
  reg [4:0] rw,sa;
  //EXTENDER
  reg [15:0] ext;
  // INSTR
  reg sll_n_sra_srl,sllv_n_srav_srlv;
  reg [31:0] ip1,ip2,imm;
  
  //FPGA Part
  wire wr_en;
reg full_r;

assign wr_en = ~full_r | out_ready_i;
 
  initial begin
  full_r=0;
  jump=0;
  branch=0;
  zero=0;
  decode_instr=0;
  pc=0;
  instr=0;
  main_memory[0]=32'd0;
	
instr_memory[32'd0]=8'b00100000;
instr_memory[32'd1]=8'b00000001;
instr_memory[32'd2]=8'b00000000;
instr_memory[32'd3]=8'b00000101;

instr_memory[32'd4]=8'b00100000;
instr_memory[32'd5]=8'b00000010;
instr_memory[32'd6]=8'b00000000;
instr_memory[32'd7]=8'b00000110;

instr_memory[32'd8]=8'b00010000;
instr_memory[32'd9]=8'b00100000;
instr_memory[32'd10]=8'b00000000;
instr_memory[32'd11]=8'b00001101;

instr_memory[32'd12]=8'b00010000;
instr_memory[32'd13]=8'b01000000;
instr_memory[32'd14]=8'b00000000;
instr_memory[32'd15]=8'b00010000;

instr_memory[32'd16]=8'b00000000;
instr_memory[32'd17]=8'b00100010;
instr_memory[32'd18]=8'b00100000;
instr_memory[32'd19]=8'b00100010 ;
instr_memory[32'd20]=8'b00011100;
instr_memory[32'd21]=8'b10000000;
instr_memory[32'd22]=8'b00000000;
instr_memory[32'd23]=8'b00000011 ;
instr_memory[32'd24]=8'b00000000;
instr_memory[32'd25]=8'b00000000;
instr_memory[32'd26]=8'b00000000;
instr_memory[32'd27]=8'b00000000;
instr_memory[32'd28]=8'b00000000 ;
instr_memory[32'd29]=8'b00000000;
instr_memory[32'd30]=8'b00000000;
instr_memory[32'd31]=8'b00000000;
instr_memory[32'd32]=8'b00000000;
instr_memory[32'd33]=8'b01000001;
instr_memory[32'd34]=8'b00010000;
instr_memory[32'd35]=8'b00100010;
instr_memory[32'd36]=8'b00001000;
instr_memory[32'd37]=8'b00000000;
instr_memory[32'd38]=8'b00000000;
instr_memory[32'd39]=8'b00000010;
instr_memory[32'd40]=8'b00000000;
instr_memory[32'd41]=8'b00000000;
instr_memory[32'd42]=8'b00000000;
instr_memory[32'd43]=8'b00000000;
instr_memory[32'd44]=8'b00000000;
instr_memory[32'd45]=8'b00000000;
instr_memory[32'd46]=8'b00000000;
instr_memory[32'd47]=8'b00000000;
instr_memory[32'd48]=8'b00000000;
instr_memory[32'd49]=8'b00100010;
instr_memory[32'd50]=8'b00001000;
instr_memory[32'd51]=8'b00100010;
instr_memory[32'd52]=8'b00001000;
instr_memory[32'd53]=8'b00000000;
instr_memory[32'd54]=8'b00000000;
instr_memory[32'd55]=8'b00000010;
instr_memory[32'd56]=8'b00000000;
instr_memory[32'd57]=8'b00000000;
instr_memory[32'd58]=8'b00000000;
instr_memory[32'd59]=8'b00000000;
instr_memory[32'd60]=8'b00000000;
instr_memory[32'd61]=8'b00000000;
instr_memory[32'd62]=8'b00000000;
instr_memory[32'd63]=8'b00000000;
instr_memory[32'd64]=8'b00000000;
instr_memory[32'd65]=8'b01100000;
instr_memory[32'd66]=8'b00010000;
instr_memory[32'd67]=8'b00100000;
instr_memory[32'd68]=8'b00001000;
instr_memory[32'd69]=8'b00000000;
instr_memory[32'd70]=8'b00000000;
instr_memory[32'd71]=8'b00010110;
instr_memory[32'd72]=8'b00000000;
instr_memory[32'd73]=8'b00000000;
instr_memory[32'd74]=8'b00000000;
instr_memory[32'd75]=8'b00000000;
instr_memory[32'd76]=8'b00000000;
instr_memory[32'd77]=8'b00000000;
instr_memory[32'd78]=8'b00000000;
instr_memory[32'd79]=8'b00000000;
instr_memory[32'd80]=8'b00000000;
instr_memory[32'd81]=8'b01100000;
instr_memory[32'd82]=8'b00001000;
instr_memory[32'd83]=8'b00100000;
instr_memory[32'd84]=8'b00000000;
instr_memory[32'd85]=8'b00100000;
instr_memory[32'd86]=8'b00011000;
instr_memory[32'd87]=8'b00100000;

  end 

  always@(negedge clk) begin
  if (reset) begin
	pc=32'd0;
	full_r=0;
  end else begin
  if (wr_en) begin
    if(inp_valid_i) begin
		decode_instr=instr;
	 end else begin
		full_r=0;
	 end
	end
    a=pc+32'd1;
    b=pc+32'd2;
    c=pc+32'd3;
    instr = {instr_memory[pc],instr_memory[a],instr_memory[b],instr_memory[c]};
  $display("fetch %t %b %b %b %b",$time,instr_memory[pc],instr_memory[a],instr_memory[b],instr_memory[c]);
	 $display("fetch %t %b",$time,instr);
    if (branch_instr[15])
        sign_extension = 14'b11111111111111;
    else
        sign_extension = 14'b00000000000000;

    sgn_extnd_signal = {sign_extension,branch_instr[15:0]};
    mux_0=pc[31:2] + 30'b000000000000000000000000000001;
    mux_1= mux_0 + sgn_extnd_signal;

    if(branch & fetch_zero) 
        branch_mux=mux_1-30'b000000000000000000000000000001;
    else
        branch_mux=mux_0;

    mux2_1={jump_pc[31:28],jump_instr[25:0]};

    if (jump) 
      pc={mux2_1,2'b00};
    else
      pc={branch_mux,2'b00};

    $display("branch %b zero %b",branch , fetch_zero);
    $display("branch & zero %b",branch & fetch_zero);
	 $display("branch_instr %b",branch_instr);
    $display("pc %b",pc);
    $display("sgn_extnd_signal %b",sgn_extnd_signal);
    $display("sign_extension %b",sign_extension);
    $display("mux_0 %b",mux_0);
    $display("mux_1 %b",mux_1);
    prev_instr=instr;
    prev_pc=pc;
  end
end
  

  always @(negedge clk) begin   
  if (reset) begin
	decode_instr=32'd0;
	end
     $display("decode %t %b",$time,decode_instr);
    reg_dst=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));

    reg_wr=((~decode_instr[31]) & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
        	 ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|
        	 (decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
        	 ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
           ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26])) |
           ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) |
              (decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) ;
            
    ext_op=(decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          (decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
          (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
          (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
          (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) |
          (decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
          (decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) ;

    alu_op_2=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));
    alu_op_1=(~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]));
    alu_op_0=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));

    branch=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
    (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|
    (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;

    jump=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
         (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));
    
    jal= (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));

    alu_ctr[0]=(decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
                (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
                (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
                (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) |
              (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0)  |
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;

    
    alu_ctr[1]=(decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
               (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
               (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
               (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
               (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
               (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
               (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & decode_instr[26]) |
               (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & decode_instr[26])  |
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;



    alu_ctr[2]=(decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & ~decode_instr[27] & decode_instr[26]) |
              (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]));

    alu_ctr[3]=(decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & ~decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & decode_instr[28] & ~decode_instr[27] & decode_instr[26]) |
              (decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
              (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & ~decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & ~decode_instr[27] & decode_instr[26]) |
              (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]));


    alu_ctr[4]=(~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) |
              (decode_instr[5] & ~decode_instr[4] & decode_instr[3] & ~decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & decode_instr[26])  |
              (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) |
              (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & ~decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0) |
              (~decode_instr[5] & ~decode_instr[4] & ~decode_instr[3] & decode_instr[2] & decode_instr[1] & decode_instr[0] & alu_op_2 & ~alu_op_1 & ~alu_op_0);



    alu_src= (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|	         (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
             (decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
             (decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
             (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
             (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|  
            (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
            (decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) |
            (decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) ;


    mem_wr=decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]);

    memto_reg=decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]);
    rs=decode_instr[25:21];
    rt=decode_instr[20:16];
    rd=decode_instr[15:11];
    imm16=decode_instr[15:0];
    sa=decode_instr[10:6];
    
    sllv_n_srav_srlv=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]) & (~decode_instr[10]) & (~decode_instr[9]) & (~decode_instr[8]) & (~decode_instr[7]) & (~decode_instr[6]) & ~decode_instr[5] & (~decode_instr[4]) & (~decode_instr[3]) & (decode_instr[2]) )|
    (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]) & (~decode_instr[10]) & (~decode_instr[9]) & (~decode_instr[8]) & (~decode_instr[7]) & (~decode_instr[6]) & ~decode_instr[5] & (~decode_instr[4]) & (~decode_instr[3]) & (decode_instr[2]) & (decode_instr[1]) & (~decode_instr[0]) );

    sll_n_sra_srl=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]) & (~decode_instr[25]) & (~decode_instr[24]) & (~decode_instr[23]) & (~decode_instr[22]) & (~decode_instr[21]) & ~decode_instr[5] & (~decode_instr[4]) & (~decode_instr[3]) & (~decode_instr[2]))|
    (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]) & (~decode_instr[25]) & (~decode_instr[24]) & (~decode_instr[23]) & (~decode_instr[22]) & (~decode_instr[21]) & ~decode_instr[5] & (~decode_instr[4]) & (~decode_instr[3]) & (~decode_instr[2])& (decode_instr[1]) & (~decode_instr[0]));

    sltiu=(~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));

    bgtz_bne_blez=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & decode_instr[26]) |
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;

    lb=(decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) ;

    sb=(decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & ~decode_instr[27] & ~decode_instr[26]) ;

    //////////////////////
    if (reg_wr) begin
      if (reg_dst)
        rw=rd;
      else if(jal)
        rw=5'd31;
      else 
        rw=rt;
      end
    else 
      rw=5'bxxxxxx;
	   
  	if (ext_op & imm16[15])
  		ext=16'b1111111111111111;
  	else
  		ext=16'b0000000000000000; 
    
    imm={ext,imm16};
  	
    if (alu_src)
  		ip2=imm;
  	else if (sll_n_sra_srl)
      ip2={27'd0,sa};
    else if (sllv_n_srav_srlv)
      ip2=main_memory[rs];
    else if(jal)
        ip2=32'd8;
    else
  		ip2=main_memory[rt]; 

    if (sll_n_sra_srl | sllv_n_srav_srlv)
      ip1=main_memory[rt];
    //else if(bgtz_bne_blez)
     // ip1=imm;
    else if(jal)
      ip1=pc;// Pretty confusing here dont know whether the pc has already increment by the time this assignment is done or not. Assuming it has been done for now
    else
       ip1=main_memory[rs];


    case(alu_ctr)
      5'b00000: // Addition
          ALU_Out = ip1 + ip2 ;
      5'b00001: // Subtraction
          ALU_Out = ip1 - ip2 ;
      5'b00010: //Multiplication
          ALU_Out=ip1[15:0]*ip2[15:0];
      5'b00011: //Logical shift left
          ALU_Out = ip1<<ip2;
      5'b00100: // Logical shift right
          ALU_Out = ip1>>ip2;
      5'b00101: // Rotate left
          ALU_Out = {ip1[30:0],ip1[31]};
      5'b00110: // Rotate right
          ALU_Out = {ip1[0],ip1[31:1]};
      5'b00111: //  Logical and
          ALU_Out = ip1 & ip2;
      5'b01000: //  Logical or
          ALU_Out = ip1 | ip2;
      5'b01001: //  Logical xor
          ALU_Out = ip1 ^ ip2;
      5'b01010: //  Logical nor
          ALU_Out = ~(ip1 | ip2);
      5'b01011: // Logical nand
          ALU_Out = ~(ip1 & ip2);
      5'b01100: // not equal to
          ALU_Out = (ip1!=ip2)?32'd1:32'd0 ;
      5'b01101: // Less than or equal comparison
          ALU_Out = (ip1<=ip2)?32'd1:32'd0 ;
      5'b01110: // Equal comparison
          ALU_Out = (ip1==ip2)?32'd1:32'd0 ;
      5'b01111: //Greater than or equal comparison 
          ALU_Out = (ip1>=ip2)?32'd1:32'd0 ;
      5'b10000: //signed Less than comparison
          ALU_Out = ($signed(ip1)<$signed(ip2))?32'd1:32'd0 ;
      5'b10001: //unsigned less than comparison
          ALU_Out = (ip1<ip2)?32'd1:32'd0 ;
      5'b10010: //signed Greater than comparison to zero
          ALU_Out=($signed(ip1)>0)?32'd1:32'd0 ;
      5'b10011: //signed less than or equal comparison to zero
          ALU_Out=($signed(ip1)<=0)?32'd1:32'd0 ;
      5'b10100: //signed right shift
          ALU_Out = $signed(ip1) >>> ip2;      
      default: begin
      end
      endcase

      if (reg_wr & ~lb & ~sb)
        main_memory[rw] = ALU_Out;
      else if (lb)
        main_memory[rt] = {24'd0,data_memory[ALU_Out]};
      else if (sb)
        data_memory[ALU_Out]=main_memory[rw][7:0];
      else 
       main_memory[rw]= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

      zero=ALU_Out[0];

      if(branch) begin
        branch_instr=decode_instr;
        fetch_zero=zero;
      end
      else begin
        branch_instr=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        fetch_zero=1'bx;
      end

      if(jump) begin
        jump_instr=decode_instr;
        jump_pc=pc-32'd4; 
      end
      else begin
        jump_instr=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        jump_pc=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
      end
      
      $display("decode rs %b",rs);
      $display("decode rt %b",rt);
      $display("decode rd %b",rd);
      $display("decode rw %b",rw);
      $display("decode reg_wr %b",reg_wr);
      $display("decode alu_ctr %b",alu_ctr);
      $display("decode imm %b",imm);
      $display("decode ip1 %b",ip1); 
      $display("decode ip2 %b",ip2);
      $display("decode ALU_Out %b",ALU_Out);
      $display("decode ext_op %b",ext_op );
      $display("decode Jump %b",jump);
      $display("decode Branch %b",branch);
      $display("decode sb %b",sb); 
      $display("decode lb %b",lb);
      $display("decode main_memory[rw] %b",main_memory[rw]);
      $display("data_memory[ALU_Out] %b\n",data_memory[ALU_Out]);
    end
assign inp_ready_o = wr_en;
assign out_valid_o = full_r;
endmodule
