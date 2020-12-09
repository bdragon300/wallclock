;-------Interrupt handlers-------------------------

;=======function RTCTICK()=============================
RTCTICK: 
interrupt_begin RTCTICK
	lds r24, mRTCClockCount
	inc r24
	cpi r24, 126
	brne RTCTICK_setTimeColon
	clr r24
	ldi r25, 1
	sts mRTCTimeIncrement, r25

RTCTICK_setTimeColon:
	call GetTimeColonStatus
	lds r25, mRawDisplayData + 12
	andi r25, 0xe7
	or r25, rRes
	sts mRawDisplayData + 12, r25

RTCTICK_return:
	sts mRTCClockCount, r24
interrupt_end RTCTICK
;======End RTCTICK==================================

;======function DYNAMICINDICATION()==========================
DYNAMICINDICATION:
interrupt_begin DYNAMICINDICATION
	lds r24, mChannelDelayCounter
	cpi r24, 0x10
	brne DYNAMICINDICATION_calculateBrightness

	;This code executes about every 2 ms (one time in 16 interrupt handling)
	cbi PORTC, PC6 ;Disable display while we calculate brightness for next channel
	clr r24
	lds r25, mCurrentOutChannel
	inc r25
	sts mCurrentOutChannel, r25
	cpi r25, cOutChannelsCount
	brne DYNAMICINDICATION_buttonDelay
	clr r25
	sts mCurrentOutChannel, r25
	
	;Set channel number on decoder pins
	in r24, PORTC
	andi r24, 0b11100011
	lsl r25
	lsl r25
	or r24, r25
	out PORTC, r24

DYNAMICINDICATION_buttonDelay:
	;Decrement button delay
	lds r25, mButtonDelay
	tst r25
	breq DYNAMICINDICATION_settingsIncrement
	dec r25
	sts mButtonDelay, r25

DYNAMICINDICATION_settingsIncrement:
	;Decrement settings increment value (uses for progressive settings changing)
	lds r25, mSettingsIncrement
	cpi r25, 0b00001001 ;see mSettingsIncrement description in definitions.asm
	brlo DYNAMICINDICATION_calculateBrightness
	dec r25
	sts mSettingsIncrement, r25

DYNAMICINDICATION_calculateBrightness: ;Must be called on each interrupt handling
	call CalculateBrightness
	call2 OutChannels, rRes, rRes2
	sbi PORTC, PC6 ;Enable display if it disabled
	lds r24, mChannelDelayCounter
	inc r24
	sts mChannelDelayCounter, r24

DYNAMICINDICATION_return:
interrupt_end DYNAMICINDICATION
;======End DYNAMICINDICATION()===============================


;========function ADCREADY()======================
ADCREADY:
interrupt_begin ADCREADY
	in r14, ADCL
	in r13, ADCH
	lds r15, mBrightnessRatio
	ldi r25, 10

	;r13 will contain high 4 bits of ADC value
	lsl r14
	rol r13
	lsl r14
	rol r13
	ldi r24, 0x0f
	sub r24, r13 ;calculated common brightness
	mul r24, r15
	call2 Divide, r24, r25 ;Calculated common brightness given with importance of brightness ratio
	sts mCommonBrightness, r24
interrupt_end ADCREADY
;========End ADCREADY()===========================

;------End interrupt handlers-------------------


;--------Functions--------------------------------

;========function CalculateBrightness()===========
;Returns output data for each element depending on its individual brightness value
CalculateBrightness:
function_begin CalculateBrightness
	clr r12
	lds r20, mCommonBrightness
	lds r9, mChannelDelayCounter
	com r20
	andi r20, 0x0f
	add r9, r20 ;Add one's complement value of common brightness for switching off all
		;elements early. The less common brightness has value the less part of time
		;all elements will be switched on
	lds r10, mCurrentOutChannel
	
	ldi ZL, low(mRawDisplayData)
	ldi ZH, high(mRawDisplayData)
	lsl r10 ;NOTE: right?
	add ZL, r10 ;Now Z points to the part of mRawDisplayData of current channel
	adc ZH, r12
	ld r20, Z+
	ld r21, Z+
	clr r11 ;mask to clearing current bit (AND operation) from input data (init value 0b01111111)
	com r11	;
	lsr r11	;
	
	ldi ZL, low(mElementBrightness)
	ldi ZH, high(mElementBrightness)
	lsl r10 ;NOTE: right?
	lsl r10
	lsl r10
	add ZL, r10 ;Now Z points to the part of mElementBrightness of current channel
	adc ZH, r12
	
	clr r10 ;If we are setting the second channel, register will be 1
CalculateBrightness_readBrightness: ;Determine whether we should to show each element depending on its brightness value
	ld r22, Z+
	cp r9, r22
	brlo CalculateBrightness_nextElement
	and r20, r11 ;clear bit if time of lighting of appropriate element has expired
		;(it has lower brightness then other elements)
CalculateBrightness_nextElement:
	sec			;rotate shift right to one bit with 1 fill
	ror r11 ;
	brcs CalculateBrightness_readBrightness
CalculateBrightness_nextChannel:
	tst r10 ;Test whether there is second channel (r10 will be 1)
	brne CalculateBrightness_return
	eor r20, r21 ;exchange registers
	eor r21, r20 ;
	eor r20, r21 ;
	inc r10
	lsr r11 ;Restore init value (0b01111111)
	rjmp CalculateBrightness_readBrightness
CalculateBrightness_return:
	mov rRes, r21 ;The first part of channel
	mov rRes2, r20 ;The second part of channel
function_end CalculateBrightness
;========End CalculateBrightness()================


;========function OutChannels(byte1, byte2)============
;Simply moves input bytes to the ports (with moving any bits to the PORTC)
OutChannels:
function_begin OutChannels
	clr r22
	mov r20, rPar1
	mov r21, rPar2
	sbrc r21, 3		;move PD3 to PC7
	sbr r22, 0x80	;
	cbr r21, 0x04	;

	in r23, PORTC
	andi r23, 0b01111111
	or r22, r23
	out PORTB, r20
	out PORTD, r21
	out PORTC, r22
function_end OutChannels
;========End OutChannels()=============================

;--------End functions----------------------------
