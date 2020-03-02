# 2-Stage MIPS Processor
Code for the project for the course Introduction to Processor Architecture

## Contents
* processor.v - Contains the whole code in one module
* instr_memory.mem - Contains 32-bit instructions written into 4 lines
* main_memory.mem - Contains the register memory with the R0 initialized to zero
* processor_tb.v - Contains the driver code to test the code

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
14. SRLV
15. SUB
16. XOR
17. XORI
18. SLT
19. SLTU
20. SLTI
21. SLTIU
22. BEQ
23. BGTZ
24. BLEZ
25. BNE
26. J
27. JAL
28. LB
29. SB
