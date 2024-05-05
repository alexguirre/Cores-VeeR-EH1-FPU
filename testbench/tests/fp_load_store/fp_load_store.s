
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:

    // Clear minstret
    //csrw minstret, zero
    //csrw minstreth, zero
    // Set up MTVEC - not expecting to use it though
    //li x1, RV_ICCM_SADR
    //csrw mtvec, x1
    // Enable Caches in MRAC
    //li x1, 0x5f555555
    //csrw 0x7c0, x1


    // Fill some random values to make sure we are using fp registers and not int registers
    li x1, 0xABCD1234
    li x2, 0xDEADBEEF

    // Read from memory to fp registers
    la x4, value1
    flw f1, 0(x4)
    la x5, value2
    flw f2, 0(x5)

    // Write to memory from fp registers
    la x4, value_result1
    fsw f1, 0(x4)
    la x5, value_result2
    fsw f2, 0(x5)


// Write 0xff to STDOUT for TB to terminate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr

.data
value1:
.float 1.0
value2:
.float 2.0
value_result1:
.float 0.0
value_result2:
.float 0.0
