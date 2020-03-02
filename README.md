# 2-Stage MIPS Processor
Code for the project for the course Introduction to Processor Architecture

## Contents
* processor.v - Contains the whole code in one module
* instr_memory.mem - Contains 32-bit instructions written into 4 lines
* main_memory.mem - Contains the register memory with the R0 initialized to zero
* processor_tb.v - Contains the driver code to test the code

## Description
This a 2-stage [MIPS ISA](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00086-2B-MIPS32BIS-AFP-6.06.pdf) based processor capable of decoding and executing 28 instructions, namely
a. ADD
b. ADDI
c. AND
d. ANDI
e. NOR
f. OR
g. ORI
h. SLL
i. SLLV
j. SRA
k. SRAV
l. SRL
m. SRLV
n. SUB
o. XOR
p. XORI
q. SLT
r. SLTU
s. SLTI
t. SLTIU
u. BEQ
v. BGTZ
w. BLEZ
x. BNE
y. J
z. JAL
aa. LB
bb. SB
