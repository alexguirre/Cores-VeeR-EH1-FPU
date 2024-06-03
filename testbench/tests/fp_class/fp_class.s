
#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:
    la x5, value_1_0
    flw f1, 0(x5)
    la x5, value_NaN
    flw f2, 0(x5)
    la x5, value_Inf
    flw f3, 0(x5)

    fclass.s x1, f1   // f1 = 1.0 -> x1 = 0x40   (bit 6, positive normal number)
    fclass.s x1, f2   // f2 = NaN -> x1 = 0x200  (bit 9, quiet NaN)
    fclass.s x1, f3   // f1 = Inf -> x1 = 0x80   (bit 7, positive infinity)


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
value_1_0:
.float 1.0
value_NaN:
.int 0x7FC00000
value_Inf:
.int 0x7F800000
