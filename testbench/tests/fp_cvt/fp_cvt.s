#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    la x5, value1
    flw f1, 0(x5)

    fcvt.w.s  x1, f1 # FP to signed int    f1 = -1234.5 -> x1 = -1234   +  FFLAGS NX (inexact)
    fcvt.s.w  f2, x1 # signed int to FP    x1 = -1234   -> f2 = -1234.0

    fcvt.wu.s x2, f1 # FP to unsigned int  f1 = -1234.5 -> x2 = 0       +  FFLAGS NV (invalid operation)
    fcvt.s.wu f2, x2 # unsigned int to FP  x2 = 0       -> f2 = 0.0


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
.float -1234.5
