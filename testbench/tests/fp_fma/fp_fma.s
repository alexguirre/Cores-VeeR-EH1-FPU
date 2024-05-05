
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    // Fill some random values to make sure we are using fp registers and not int registers
    li x1, 0xABCD1234
    li x2, 0xDEADBEEF
    li x3, 0xBAADF00D

    // Read from memory to fp registers
    la x5, value1
    flw f1, 0(x5)
    la x5, value2
    flw f2, 0(x5)
    la x5, value3
    flw f3, 0(x5)

    // FMA
    fmadd.s  f0, f1, f2, f3
    fmsub.s  f0, f1, f2, f3
    fnmadd.s f0, f1, f2, f3
    fnmsub.s f0, f1, f2, f3


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
value3:
.float 3.0
