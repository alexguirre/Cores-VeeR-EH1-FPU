
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    // set some value in FRM
    li x1, 3
    fsrm x1

    // set some value in FFLAGS
    li x1, 1
    fsflags x1

    // read FCSR
    frcsr   x2  // whole FCSR
    frrm    x2  // only FRM
    frflags x2  // only FFLAGS

    // set some value in the whole FCSR
    li x1, 0xFFFF
    fscsr x1
    frcsr x2  // read it back, bits outside FRM and FFLAGS should be 0


// Write 0xff to STDOUT for TB to terminate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr
