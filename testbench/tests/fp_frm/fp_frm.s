
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    // Read from memory to fp registers
    la x5, value1
    flw f1, 0(x5)
    la x5, value2
    flw f2, 0(x5)

    li x5, 0
    fsrm x5   // RNE: round to nearest, ties to even
    fdiv.s  f0, f1, f2

    li x5, 1
    fsrm x5   // RTZ: round towards zero
    fdiv.s  f0, f1, f2

    li x5, 2
    fsrm x5   // RDN: round down
    fdiv.s  f0, f1, f2

    li x5, 3
    fsrm x5   // RUP: round up
    fdiv.s  f0, f1, f2

    li x5, 4
    fsrm x5   // RMM: round to nearest, ties to max magnitude
    fdiv.s  f0, f1, f2


    fdiv.s  f0, f1, f2, rdn  // static rounding mode, RDN


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
.float 1.23
value2:
.float 4.56
