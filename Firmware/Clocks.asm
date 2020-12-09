.include "m32Adef.inc"

.dseg
.include "definitions.asm"
;--------Interrupt vector table----------------------
.org $000
	jmp RESET
.org INT0addr
	reti
.org INT1addr
	reti
.org INT2addr
	reti
.org OC2addr
	jmp RTCTICK
.org OVF2addr
	reti
.org ICP1addr
	reti
.org OC1Aaddr
	reti
.org OC1Baddr
	reti
.org OVF1addr
	reti
.org OC0addr
	jmp DYNAMICINDICATION
.org OVF0addr
	reti
.org SPIaddr
	reti
.org URXCaddr
	reti
.org UDREaddr
	reti
.org UTXCaddr
	reti
.org ADCCaddr
	jmp ADCREADY
.org ERDYaddr
	reti
.org ACIaddr
	reti
.org TWIaddr
	reti
.org SPMRaddr
	reti
;--------End interrupt vector table----------------

.include "macros.asm"
.include "interrupts.asm"
.include "input\input.asm"
.include "input\events.asm"
.include "output\output.asm"
.include "output\brightness.asm"
.include "common.asm"
.include "time.asm"

;------Main cycle-------------------------------
RESET:
.include "init.asm" ;Initialization

mainCycle:
calculateDisplayData:
	lds r3, mRecalculateChannelsData 
	tst r3
	breq checkRTCTimeIncrement
	call CalculateChannelsData ;We should to recalculate all display data immediately
	call ReadFotosensor
	clr r3
	sts mRecalculateChannelsData, r3
	rjmp getKeyboard
checkRTCTimeIncrement:
	lds r3, mRTCTimeIncrement ;If second not changed there is no need to recalculate segments
	tst r3
	breq getKeyboard
	clr r3
	sts mRTCTimeIncrement, r3
	inc r3
	call1 IncreaseSeconds, r3
	call CalculateChannelsData
	call ReadFotosensor
	call SetDayOfWeekBrightness ;Sets brightness image for days of week indicators

getKeyboard:
	call ReadKeyboard
	call DelayButton ;Check for button delay after its pressing
	clr r3
	sbrs rRes, 0
	call ExecuteInputEvent

endMainCycle:
	jmp mainCycle

;--------End main cycle---------------------------

.include "eeprom.asm"
.exit
