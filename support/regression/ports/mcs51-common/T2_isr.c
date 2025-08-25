//dummy interrupt service routine
//just to make linker happy

// void
// T2_isr (void) __interrupt (5)
// {
// }

static void
dummy (void) __naked
{
__asm
    .weak _T2_isr
    .global _T2_isr
	.section .text, "ax"
_T2_isr:
	.using 0
    reti
__endasm;
}
