
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    // Read from memory to fp registers
    la x5, value_one
    flw f1, 0(x5)
    la x5, value_zero
    flw f2, 0(x5)
    la x5, value_inf
    flw f3, 0(x5)

    fdiv.s  f0, f1, f2 // division by zero
    frflags x5

    fmul.s  f0, f2, f3 // invalid operation, 0 * inf
    frflags x5


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
value_one:
.float 1.0
value_zero:
.float 0.0
value_inf:
.int 0x7F800000
