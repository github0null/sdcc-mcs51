;--------------------------------------------------------------------------
;  crtbank.asm - C run-time: bank switching
;
;  Copyright (C) 2005, Maarten Brock
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

	.global _PSBANK
	.global __sdcc_banked_call, __sdcc_banked_ret
	.section .text.__sdcc_banked_call, "ax"
__sdcc_banked_call:
	push	_PSBANK		;save return bank
	xch	a,r0		;save Acc in r0, do not assume any register bank
	push	acc		;push LSB address
	mov	a,r1
	push	acc		;push MSB address
	mov	a,r2		;get new bank
	anl	a,#0x0F		;remove storage class indicator
	anl	_PSBANK,#0xF0
	orl	_PSBANK,a	;select bank
	xch	a,r0		;restore Acc
	ret				;make the call

	.section .text.__sdcc_banked_ret, "ax"
__sdcc_banked_ret:
	pop	_PSBANK		;restore bank
	ret				;return to caller
