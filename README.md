# 2-Stage MIPS Processor
Code for the project for the course Introduction to Processor Architecture

## Contents
* processor.v - Contains the whole code in one module
* instr_memory.mem - Contains 32-bit instructions written into 4 lines
* main_memory.mem - Contains the register memory with the R0 initialized to zero
* processor_tb.v - Contains the driver code to test the code
* Instruction testbench - Contains examples which can be used to check the working of individual instructions (like add, sub, and,or,etc.)

## Description
This a 2-stage [MIPS ISA](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00086-2B-MIPS32BIS-AFP-6.06.pdf) based processor capable of decoding and executing 28 instructions, namely
1. ADD
2. ADDI
3. AND
4. ANDI
5. NOR
6. OR
7. ORI
8. SLL
9. SLLV
10. SRA
11. SRAV
12. SRL
13. SRLV
14. SUB
15. XOR
16. XORI
17. SLT
18. SLTU
19. SLTI
20. SLTIU
21. BEQ
22. BGTZ
23. BLEZ
24. BNE
25. J
26. JAL
27. LB
28. SB

