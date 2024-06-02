
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    la x5, value1
    flw f1, 0(x5)
    la x5, value2
    flw f2, 0(x5)

    // Test read-after-writes
    fdiv.s  f0, f1, f2  // f0 = 1.0 / 2.0 = 0.5
    fadd.s  f3, f0, f2  // f3 = 0.5 + 2.0 = 2.5
    fmul.s  f4, f0, f3  // f4 = 0.5 + 2.5 = 1.25



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
