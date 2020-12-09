;This macros uses for calling subroutine with 1 parameter
;It puts all parameters to registers and calls function
.macro call1
	cli
	push r8
	mov rPar1, @1
	call @0
	pop r8
.endmacro


;This macros uses for calling subroutine with 2 parameters
;It puts all parameters to registers and calls function
;no need to sei instruction - it will set by function_begin
.macro call2
	cli
	push r8
	push r9
	mov rPar1, @1
	mov rPar2, @2
	call @0
	pop r9
	pop r8
.endmacro



;This macros uses for calling subroutine with 3 parameters
;It puts all parameters to registers and calls function
.macro call3
	cli
	push r8
	push r9
	push r10
	mov rPar1, @1
	mov rPar2, @2
	mov rPar3, @3
	call @0
	pop r10
	pop r9
	pop r8
.endmacro



;This macros should preceed any commands in each subroutine
;The macros checks whether call of this subroutine is the first call in the stack
;If not this macros saves registers state in the stack
.macro function_begin
	cli
	push YH
	push YL
	push ZH
	push ZL
	tst r2
	breq _@0_incr0
	push r10
	push r11
	push r12
	push r20
	push r21
	push r22
	push r23
	push rPar1
	push rPar2
_@0_incr0:
	inc r2
	sei
.endmacro


;This macros should be placed at the end of each subroutine after all commmand
;The macros check whether call of this subroutine is the first call in the stack
;If not this macros restores registers state from the stack
;ret instruction must not be used before calling the macros
.macro function_end
	cli
	dec r2
	breq _@0_ret
	pop rPar2
	pop rPar1
	pop r23
	pop r22
	pop r21
	pop r20
	pop r12
	pop r11
	pop r10
_@0_ret:
	pop ZL
	pop ZH
	pop YL
	pop YH
	sei
	ret
.endmacro


;This macros should proceed any commands on each interrupt handler
;The macros saves to the stack rRes and rRes2 registers for ability to call
; subroutines in handlers
.macro interrupt_begin
	push rRes
	push rRes2
.endmacro

;This macros should be placed at the end of each interrupt handler
;The macros restores rRes and rRes2 registers from the stack
;reti instruction must not be used before calling the macros
.macro interrupt_end
	pop rRes2
	pop rRes
	reti
.endmacro