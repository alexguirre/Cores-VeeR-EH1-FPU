OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

SECTIONS
{
    . = 0;
  .text   : { *(.text*) }
 _end = .;
  . = 0x1000000;
  .data  :  ALIGN(0x800) { *(.*data) *(.rodata*) STACK = ALIGN(16) + 0x8000; }
  .bss : { *(.bss) }
  . = 0xd0580000;
  .data.io   : { *(.data.io) }
}
/* SECTIONS */
/* { */
/*   . = 0x80000000; */
/*   .text.init : { *(.text.init) } */
/*   . = ALIGN(0x1000); */
/*   .tohost : { *(.tohost) } */
/*   . = ALIGN(0x1000); */
/*   .text : { *(.text) } */
/*   . = ALIGN(0x1000); */
/*   .data : { *(.data) } */
/*   .data.string : { *(.data.string)} */
/*   .bss : { *(.bss) } */
/*   _end = .; */
/* } */

