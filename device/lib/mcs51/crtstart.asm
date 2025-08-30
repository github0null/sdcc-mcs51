;--------------------------------------------------------------------------
;  crtstart.asm - C run-time: startup
;
;  Copyright (C) 2004, Erik Petrich
;
;  This library is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by the
;  Free Software Foundation; either version 2, or (at your option) any
;  later version.
;
;  This library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License 
;  along with this library; see the file COPYING. If not, write to the
;  Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
;   MA 02110-1301, USA.
;
;  As a special exception, if you link this library with other files,
;  some of which are compiled with SDCC, to produce an executable,
;  this library does not by itself cause the resulting executable to
;  be covered by the GNU General Public License. This exception does
;  not however invalidate any other reasons why the executable file
;  might be covered by the GNU General Public License.
;--------------------------------------------------------------------------

	.global __start__stack, __idata_seg_end, _main
	.global __xinit_start, __xdata_start
	.global __xdata_has_copy, __xdata_ov_flag, __xdata_clear_end, __xdata_copy_end
	.global bits, b0, b1, b2, b3, b4, b5, b6, b7

	.section .bss, "aw"
	.equ bits, 0x20
	.equ b0, (bits - 0x20) * 8 + 0
	.equ b1, (bits - 0x20) * 8 + 1
	.equ b2, (bits - 0x20) * 8 + 2
	.equ b3, (bits - 0x20) * 8 + 3
	.equ b4, (bits - 0x20) * 8 + 4
	.equ b5, (bits - 0x20) * 8 + 5
	.equ b6, (bits - 0x20) * 8 + 6
	.equ b7, (bits - 0x20) * 8 + 7

	.global __sdcc_startup
	.section .init.0, "ax"
__sdcc_startup:
	.using 0
	;-----------------------------
	; Clear IDATA
	;-----------------------------
	mov r0, #__idata_seg_end
.L00001:
	mov @r0, #0
	djnz r0, .L00001
	; init SP
	mov sp, #__start__stack - 1

	;-----------------------------
	; Clear PDATA/XDATA
	;-----------------------------
	mov r0, #lo_(__xdata_clear_end)
	mov r1, #hi_(__xdata_clear_end)
	mov a, r0
	orl a, r1
	jz .L00010
	; Clear pdata by movx @ri,a
	push ar0
	mov r0, #0xFF
	clr a
.L00020:
	movx @r0, a
	djnz r0, .L00020
	movx @r0, a
	pop ar0
	; Clear xdata by movx @dptr,a
	mov dptr, #0
.L00002:
	clr a
	movx @dptr, a
	inc dptr
	mov a, r1
	cjne a, dph, .L00002
	mov a, r0
	cjne a, dpl, .L00002
	mov a, #__xdata_ov_flag
	jz .L00004
	clr a
	mov dptr, #0xFFFF
	movx @dptr, a
.L00004:

	;-----------------------------
	; Do some user's startup code
	;-----------------------------
	mov r0, #___sdcc_external_startup
	mov r1, #hi_(___sdcc_external_startup)
	mov a, r0
	orl a, r1
	jz .L00005
	lcall ___sdcc_external_startup
.L00005:

	;-----------------------------
	; Copy initialized xdata
	;-----------------------------
	mov a, #__xdata_has_copy
	jz .L00010
	mov r0, #lo_(__xinit_start)
	mov r1, #hi_(__xinit_start)
	mov r2, #lo_(__xdata_start)
	mov r3, #hi_(__xdata_start)
.L00011:
	; copy one byte
	clr a
	mov dpl, r0
	mov dph, r1
	movc a, @a+dptr
	mov dpl, r2
	mov dph, r3
	movx @dptr, a
	; increment r0 r1
	inc r0
	cjne r0, #0, .L00012
	inc r1
.L00012:
	; increment r2 r3
	inc r2
	cjne r2, #0, .L00013
	inc r3
.L00013:
	cjne r3, #hi_(__xdata_copy_end), .L00011
	cjne r2, #lo_(__xdata_copy_end), .L00011
	; copy the end byte if overflowed
	mov a, #__xdata_ov_flag
	cjne a, #2, .L00010
	mov dpl, r0
	mov dph, r1
	movc a, @a+dptr
	mov dptr, #0xFFFF
	movx @dptr, a
.L00010:

	;-----------------------------
	; Global & static init code 
	;-----------------------------
	.section .init.1, "ax"

	;-----------------------------
	; Jump to main()
	;-----------------------------
	.section .init.3, "ax"
	ljmp _main
	ljmp __sdcc_startup
