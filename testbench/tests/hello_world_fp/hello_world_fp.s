// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// Assembly code for Hello World
// Not using only ALU ops for creating the string


#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:

    // Clear minstret
    csrw minstret, zero
    csrw minstreth, zero

    // Set up MTVEC - not expecting to use it though
    li x1, RV_ICCM_SADR
    csrw mtvec, x1


    // Enable Caches in MRAC
    li x1, 0x5f555555
    csrw 0x7c0, x1

    // Floating-point example instruction
    li x4, 0xDEADBEEF
    fscsr x4
    frcsr x5


    la x4, value1
    flw f5, 0(x4)
    la x4, value_result
    fsw f5, 0(x4)


    la x4, value1
    flw f2, 0(x4)
    la x4, value2
    flw f3, 0(x4)
    fadd.s   f1, f2, f3
    fsub.s   f1, f2, f3
    fmul.s   f1, f2, f3
    fdiv.s   f1, f2, f3
    fsqrt.s  f1, f3
    fmin.s   f1, f2, f3
    fmax.s   f1, f2, f3
    fsgnjn.s f1, f2, f3
    div    x1, x2, x3

    la x4, value_result
    fsw f1, 0(x4)

    frcsr x4

    // Load string from hw_data
    // and write to stdout address

    li x3, STDOUT
    la x4, hw_data

loop:
   lb x5, 0(x4)
   sb x5, 0(x3)
   addi x4, x4, 1
   bnez x5, loop

// Write 0xff to STDOUT for TB to terminate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr

.global hw_data
.data
hw_data:
.ascii "-------------------------------------\n"
.ascii "Hello Floats from VeeR EH1 (with FPU)\n"
.ascii "-------------------------------------\n"
.byte 0
value1:
.float 1.23
value2:
.float 4.56
value_result:
.float 0.0
value_tmp:
.float 0.0
