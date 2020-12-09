;TODO: radio s-meter on ADC
;========function ReadKeyboard()===================
;Functions reads data from keyboard shift registers and puts it to mInputState
ReadKeyboard:
function_begin ReadKeyboard
	in r20, TIMSK ;PORTA should not be changed while this chunk of code executes, so restrict T/C0 interrupts
	andi r20, ~((1<<TOIE0) | (1<<OCIE0))
	out TIMSK, r20

	;LOW impulse to PL pin of shift register to lock inputs
	cbi PORTA, PORTA5
	nop
	sbi PORTA, PORTA5

	clr r8
	clr r9
	ldi r21, 16
ReadKeyboard_read:
	lsl r9
	rol r8
	
	;Get next bit
	sbic PINA, PINA7
	inc r9

	;Clock impulse
	cbi PORTA, PORTA6
	sbi PORTA, PORTA6

	dec r21
	brne ReadKeyboard_read

	in r20, TIMSK
	ori r20, (1<<TOIE0) | (1<<OCIE0)
	out TIMSK, r20

	;Data comes from shift registers in inverted format (see schematic). So, invert it again 
	com r8
	com r9

	lds r10, mInputState
	lds r11, mInputState + 1
	sts mLastInputState, r10
	sts mLastInputState + 1, r11
	sts mInputState, r8
	sts mInputState + 1, r9
function_end ReadKeyboard
;========End ReadKeyboard()========================


;========function ExecuteInputEvent()==============
;Calls appropriate action based on signals on input
;In other words the function executes event function linked with
;buttons or their combinations
ExecuteInputEvent:
function_begin ExecuteInputEvent
	lds r8, mInputState
	lds r9, mInputState + 1
	lds r10, mLastInputState
	lds r11, mLastInputState + 1
	eor r10, r8 ;Determine what input controls changed their state, if none - do nothing
	brne ExecuteInputEvent_eventHandling
	eor r11, r9
	brne ExecuteInputEvent_eventHandling
	jmp ExecuteInputEvent_return
	
ExecuteInputEvent_eventHandling:
	mov r20, r8
	mov r21, r9
	and r20, r10 ;Select only just pressed buttons
	and r21, r11 ;
	
	;Settings switch
	sbrc r10, cSettingsSwitch
	rjmp ExecuteInputEvent_up
	sbrc r8, cSettingsSwitch
	call OnSettingsOn ;Encoder just pulled
	sbrs r8, cSettingsSwitch
	call OnSettingsOff ;Encoder just pushed
	
ExecuteInputEvent_up:
	;Encoder just pushed up
	sbrc r20, cUpButton
	call OnEncoderUp

	;Encoder just pushed down
	sbrc r20, cDownButton
	call OnEncoderDown
	
	;First alarm button pushed
	sbrc r20, cFirstAlarmButton
	call OnFirstAlarm

	;Second alarm button pushed
	sbrc r20, cSecondAlarmButton
	call OnSecondAlarm

	;Brightness ratio button
	sbrc r10, cBrightnessRatioButton
	rjmp ExecuteInputEvent_encoder ;Brightness ratio button did not change its state
	sbrc r8, cBrightnessRatioButton
	call OnBrightnessRatioDown ;Brightness ratio button just pressed
	sbrs r8, cBrightnessRatioButton
	call OnBrightnessRatioUp ;Brightness ratio button just released

	;Encoder rotation detection
ExecuteInputEvent_encoder:
	mov r22, r10
	andi r22, cAEncoder | cBEncoder
	breq ExecuteInputEvent_finishActions ;Encoder was not rotated
	
	mov r22, r8
	andi r22, cAEncoder | cBEncoder
	clc
	rol r22 ;Convert 2-bit gray code to number
	rol r22
	rol r22
	mov r23, r22
	lsr r23
	eor r22, r23 ;r22 is result

	lds r23, mEncoderInitialized
	tst r23
	brne ExecuteInputEvent_encoderDirection
	;Initialize last encoder value and exit
	inc r23
	sts mEncoderValue, r22
	sts mEncoderInitialized, r23
	rjmp ExecuteInputEvent_finishActions
ExecuteInputEvent_encoderDirection:
	lds r23, mEncoderValue
	cp r22, r23
	sts mEncoderValue, r22
	breq ExecuteInputEvent_finishActions
	brlo ExecuteInputEvent_encoderLeft
	brsh ExecuteInputEvent_encoderRight
ExecuteInputEvent_encoderLeft:
	call OnEncoderLeft
	rjmp ExecuteInputEvent_finishActions
ExecuteInputEvent_encoderRight:
	call OnEncoderRight
ExecuteInputEvent_finishActions:
	clr r8
	inc r8
	sts mRecalculateChannelsData, r8
ExecuteInputEvent_return:
function_end ExecuteInputEvent
;========End ExecuteInputEvent()===================


;========function DelayButton()====================
;Buttons (not switch or encoder) need to be delayed after they pressed
;This function returns 1 in rRes when button needs to be delayed
;No need to care about contact jitter because reading keyboard frequency is lower
;then contact jitter duration
DelayButton:
function_begin DelayButton
	clr rRes
	lds r22, mInputState
	lds r23, mInputState + 1

	andi r22, cButtonsWithDelayL
	andi r23, cButtonsWithDelayH
	mov r9, r22
	or r9, r23	;Check whether no button was pressed
	breq DelayButton_noButtons
	clr r9

	lds r20, mLastInputState
	lds r21, mLastInputState + 1
	andi r20, cButtonsWithDelayL
	andi r21, cButtonsWithDelayH	
	cp r22, r20	;Pressed buttons is changed so reset delay
	brne DelayButton_reset	;
	cp r23, r21	;
	brne DelayButton_reset	;

	lds r8, mButtonDelay
	dec r8	
	brmi DelayButton_reset ;Delay is expired

DelayButton_yesDelay:
	inc r9
	mov r21, r8
	rjmp DelayButton_return
DelayButton_reset:
	ldi r21, cButtonDelay
	rjmp DelayButton_return
DelayButton_noButtons: ;r9 already is zero
	clr r21
DelayButton_return:
	sts mButtonDelay, r21
	mov rRes, r9
function_end DelayButton
;========End DelayButton()========================


;========function ReadFotosensor()================
ReadFotosensor:
function_begin ReadFotosensor
	sbi ADCSRA, ADSC
function_end ReadFotosensor
;========End ReadFotosensor()=====================
