
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    la x5, value1
    flw f1, 0(x5)
    flw f3, 0(x5)
    la x5, value2
    flw f2, 0(x5)

    // Test comparisons
    // f1 = 1.0, f2 = 2.0, f3 = 1.0
    feq.s  x1, f1, f3 // x1 = 1.0 == 1.0 = 1
    feq.s  x1, f1, f2 // x1 = 1.0 == 2.0 = 0
    fle.s  x1, f1, f2 // x1 = 1.0 <= 2.0 = 1
    fle.s  x1, f2, f1 // x1 = 2.0 <= 1.0 = 0
    fle.s  x1, f1, f3 // x1 = 1.0 <= 1.0 = 1
    flt.s  x1, f2, f1 // x1 = 2.0 <  1.0 = 0
    flt.s  x1, f1, f2 // x1 = 1.0 <  2.0 = 1


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
