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
  reg [5:0] prev_pc;
  reg [31:0] prev_instr,decode_instr,branch_instr;
  reg jump,branch,zero;
  ////////////DECODE UNIT AND EXECUTE/////////////////////////////////
  reg [31:0] main_memory [63:0];
 // initial begin
   // $readmemb("main_memory.mem",main_memory);
 // end
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
  //Register Write and Register Destination
  reg [4:0] rw,sa;

  //EXTENDER
  reg [15:0] ext;

  // INSTR
  reg sll_n_sra_srl,sllv_n_srav_srlv;
  reg [31:0] ip1,ip2,imm;
  initial begin
  jump=0;
  branch=0;
  zero=0;
  decode_instr=0;
  pc=0;
  instr=0;
  main_memory[0]=32'd0;
  end 

  always@(negedge clk) begin
    decode_instr=instr;
    a=pc+31'd1;
    b=pc+31'd2;
    c=pc+31'd3;
    instr = {instr_memory[pc],instr_memory[a],instr_memory[b],instr_memory[c]};
  //  $display("fetch %t %b %b %b %b",$time,instr_memory[pc],instr_memory[a],instr_memory[b],instr_memory[c]);
	 $display("fetch %t %b",$time,instr);
    // instr=prev_instr;
    if (branch_instr[15])
        sign_extension = 14'b11111111111111;
    else
        sign_extension = 14'b00000000000000;

    sgn_extnd_signal = {sign_extension,branch_instr[15:0]};
    mux_0=pc[31:2] + 30'b000000000000000000000000000001;
    mux_1= mux_0 + sgn_extnd_signal;
    //branch_mux=((~(branch && zero ))& mux_0) | ((branch && zero )& mux_1);

    if(branch & zero)
        branch_mux=mux_1;
    else
        branch_mux=mux_0;


    mux2_1={prev_pc[31:28],prev_instr[25:0]};

    if (jump) 
      pc={mux2_1,2'b00};
    else
      pc={branch_mux,2'b00};
    //pc={pc,2'b00};
    $display("branch %b zero %b",branch , zero);
   $display("branch & zero %b",branch & zero);
   $display("pc %b",pc);
   $display("sgn_extnd_signal %b",sgn_extnd_signal);
  $display("sign_extension %b",sign_extension);
   $display("mux_0 %b",mux_0);
   $display("mux_1 %b",mux_1);
    prev_instr=instr;
    prev_pc=pc;
  end

  always @(negedge clk) begin   
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
              (~decode_instr[31] & ~decode_instr[30] & decode_instr[29] & ~decode_instr[28] & decode_instr[27] & decode_instr[26]) ;
            
    ext_op=(decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          (decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
          (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
          (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;


    alu_op_2=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));
    alu_op_1=(~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]));
    alu_op_0=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]));

    branch=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
    (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|
    (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;

    jump=(~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
         (~decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));
    
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
    (~decode_instr[31] & ~decode_instr[30] & ~decode_instr[29] & decode_instr[28] & decode_instr[27] & ~decode_instr[26]) ;



    alu_src= (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (decode_instr[26]))|	         (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
             (decode_instr[31] & (~decode_instr[30]) & (~decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
             (decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]))|
             (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (~decode_instr[27]) & (~decode_instr[26]))|
             (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           ((~decode_instr[31]) & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|
           (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (~decode_instr[26]))|  
            (~decode_instr[31] & (~decode_instr[30]) & (decode_instr[29]) & (~decode_instr[28]) & (decode_instr[27]) & (decode_instr[26]));


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


    //////////////////////
    if (reg_wr) begin
      if (reg_dst)
        rw=rd;
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
    else
  		ip2=main_memory[rt]; 

    if (sll_n_sra_srl | sllv_n_srav_srlv)
      ip1=main_memory[rt];
    else if(bgtz_bne_blez)
      ip1=imm;
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
      default: begin
      end
      endcase

      if (reg_wr)
        main_memory[rw] = ALU_Out;
      else 
       main_memory[rw]= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

      zero=ALU_Out[0];

      if(branch)
        branch_instr=decode_instr;
      else
        branch_instr=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
      
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
      $display("decode ext_op %b",ext_op & imm[15]);
      $display("decode Jump %b",jump);
      $display("decode Branch %b",branch);
      $display("decode main_memory[rw] %b\n",main_memory[rw]);
      //Need to make changes for Load and Store Word
    end

endmodule
