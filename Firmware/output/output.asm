;=========function DigitToLED(digit)=======
;Converts digit to 7-segment code
;rRes contains segment bits (for writing to port)
DigitToLED:
function_begin DigitToLED
	clr r9
	clr r11
	ldi ZL, low(DigitToLED_indexTable * 2)
	ldi ZH, high(DigitToLED_indexTable * 2)
	lsl rPar1
	add ZL, rPar1
	adc ZH, r9
	lpm r8, Z+
	lpm r9, Z
	movw ZL:ZH, r8:r9
	ijmp

DigitToLED_0:
	ldi r20, 0xee
	rjmp DigitToLED_return
DigitToLED_1:
	ldi r20, 0x48
	rjmp DigitToLED_return
DigitToLED_2:
	ldi r20, 0xba
	rjmp DigitToLED_return
DigitToLED_3:
	ldi r20, 0xda
	rjmp DigitToLED_return
DigitToLED_4:
	ldi r20, 0x5c
	rjmp DigitToLED_return
DigitToLED_5:
	ldi r20, 0xd6
	rjmp DigitToLED_return
DigitToLED_6:
	ldi r20, 0xf4
	rjmp DigitToLED_return
DigitToLED_7:
	ldi r20, 0x4a
	rjmp DigitToLED_return
DigitToLED_8:
	ldi r20, 0xfe
	rjmp DigitToLED_return
DigitToLED_9:
	ldi r20, 0x4e

DigitToLED_return:
	mov rRes, r20
function_end DigitToLED

DigitToLED_indexTable: .dw DigitToLED_0, DigitToLED_1, DigitToLED_2, DigitToLED_3, DigitToLED_4, DigitToLED_5, DigitToLED_6, DigitToLED_7, DigitToLED_8, DigitToLED_9
;=========End DigitToLED(digit)============


;========function GetTimeColonStatus()=========
;Returns byte that should be added (OR operation) to appropriate mRawDisplayData byte
;Scheme: both (about 700 ms), lower (about 100ms), none (about 100ms), upper (about 100ms)
GetTimeColonStatus:
function_begin GetTimeColonStatus
	lds r20, mRTCClockCount
	clr r21

	lds r22, mBrightnessRatioSet ;Disable time colon when we are setting brightness ratio
	tst r22
	brne GetTimeColonStatus_default
	cpi r20, 63
	brlo GetTimeColonStatus_1
	brsh GetTimeColonStatus_2
	cpi r20, 75
	brsh GetTimeColonStatus_3
	cpi r20, 100
	brsh GetTimeColonStatus_4

GetTimeColonStatus_1: ;both leds
	ldi r21, 0x18
	jmp GetTimeColonStatus_default
GetTimeColonStatus_2: ;lower led
	ldi r21, 0x08
	jmp GetTimeColonStatus_default
GetTimeColonStatus_3: ;none
	ldi r21, 0x00
	jmp GetTimeColonStatus_default
GetTimeColonStatus_4: ;upper led
	ldi r21, 0x10
GetTimeColonStatus_default:
	mov rRes, r21
GetTimeColonStatus_return:
function_end GetTimeColonStatus
;========End GetTimeColonStatus()=================


;========function CalculateChannelsData()=========
;Converts time from time and date numbers and LEDs to raw data for display
;Sets correct data in mRawDisplayData except last two bytes because they are reserved
CalculateChannelsData_indTable: .dw mHour, mMinute, mDay, mMonth
CalculateChannelsData:
function_begin CalculateChannelsData
	clr r12
	ldi YL, low(mRawDisplayData)
	ldi YH, high(mRawDisplayData)
	ldi ZL, low(mHour)
	ldi ZH, high(mHour)
	ldi r21, 10 ;Uses for separating number to digits
	ldi r22, 4 ;Time and date digits decoding cycle counter
CalculateChannelsData_brightnessRatio:
	lds r8, mBrightnessRatioSet
	tst r8
	breq CalculateChannelsData_digits ;User is not set brightness ratio now
	lds r20, mBrightnessRatio
	st Y+, r12 ;First two digits will be disabled
	st Y+, r12 ;
	call2 Divide, r20, r21
	mov r8, rRes2
	call1 DigitToLED, rRes
	mov r20, rRes
	sbr r20, 0x01 ;Enable dot between the third and the forth digits
	st Y+, r20
	call1 DigitToLED, r8
	st Y+, rRes
	adiw ZL, 4 ;Skip time variables reading for next loop (mHour and mMinute)
	ldi r22, 2 ;Count of cycles of setting channels data now is 2 (date only)
	
CalculateChannelsData_digits: ;Time and date digits
	ld r20, Z+
CalculateChannelsData_digitsDivide:
	call2 Divide, r20, r21
	mov r20, rRes
	mov r21, rRes2
	call1 DigitToLED, r20
	st Y+, rRes
	call1 DigitToLED, r21
	st Y+, rRes
	dec r22
	brne CalculateChannelsData_digits
	
CalculateChannelsData_alarmDigits:
	lds r20, mChangingAlarm
	tst r20
	brne CalculateChannelsData_alarmDigits_settingsMode ;Settings mode on
	lds r20, mEnabledAlarms
	tst r20
	brne CalculateChannelsData_alarmDigits_noSettingsMode ;Settings mode off and any alarm enabled
	st Y+, r12 ;No numbers to output (alarm disabled)
	st Y+, r12
	st Y+, r12
	st Y+, r12
	rjmp CalculateChannelsData_leds
CalculateChannelsData_alarmDigits_noSettingsMode:
	call EarlyAlarm ;Determine what alarm is closest to RTC
	lsl rRes
	mov r9, rRes
	rjmp CalculateChannelsData_alarmDigits_out
CalculateChannelsData_alarmDigits_settingsMode:
	clr r9
CalculateChannelsData_alarmDigits_settingsMode_:
	lsr r20
	inc r9
	brcc CalculateChannelsData_alarmDigits_settingsMode_
	dec r9
CalculateChannelsData_alarmDigits_out:
	ldi ZL, low(mAlarms)
	ldi ZH, high(mAlarms)
	add ZL, r9
	adc ZH, r12
	ldi r22, 2 ;Loop counter
CalculateChannelsData_alarmDigits_out_:
	ldi r21, 10
	ld r20, Z+
	call2 Divide, r20, r21
	mov r20, rRes
	mov r21, rRes2
	call1 DigitToLED, r20
	st Y+, rRes
	call1 DigitToLED, r21
	st Y+, rRes
	dec r22
	brne CalculateChannelsData_alarmDigits_out_

CalculateChannelsData_leds:
	;dot between date digits
	lds r21, mRawDisplayData + 5
	ori r21, 0x80
	sts mRawDisplayData + 5, r21
	
	clr r8 ;Will contain mRawDisplayData + 12 byte
	clr r10 ;Will contain mRawDisplayData + 13 byte
CalculateChannelsData_leds_dayOfWeek:
	lds r21, mDayOfWeek
	sec
CalculateChannelsData_leds_dayOfWeek1:
	ror r10
	dec r21
	sec
	brne CalculateChannelsData_leds_dayOfWeek1

CalculateChannelsData_leds_alarmButtonsIndicators:
	ldi r22, 2 ;Loop counter
	lds r20, mChangingAlarm
	tst r20
	brne CalculateChannelsData_leds_alarmButtonsIndicators_out ;Settings mode on
	lds r20, mEnabledAlarms
	tst r20
	breq CalculateChannelsData_leds_radioButtonsIndicators
CalculateChannelsData_leds_alarmButtonsIndicators_out: ;Settings mode off and any alarm enabled
	lsr r20
	rol r8
	dec r22
	brne CalculateChannelsData_leds_alarmButtonsIndicators_out
	lsl r8
CalculateChannelsData_leds_alarmColon:
	;If we are here then there is needed to enable alarm colon
	ldi r22, 1
	or r10, r22
CalculateChannelsData_leds_radioButtonsIndicators:
	nop ;TODO: radio indicators
CalculateChannelsData_leds_store:
	st Y+, r8 ;mRawDisplayData + 12
	st Y+, r10 ;mRawDisplayData + 13
CalculateChannelsData_return:
function_end CalculateChannelsData
;========End CalculateChannelsData()==============


;========function EarlyAlarm()====================
;Returns offset on mAlarms to early alarm
EarlyAlarm:
function_begin EarlyAlarm
	lds r8, mAlarms
	lds r9, mAlarms + 1 
	lds r10, mAlarms + 2
	lds r11, mAlarms + 3
	lds r20, mHour
	lds r21, mMinute
	clr r12

EarlyAlarm_alarmsCompare: ;Alarms compare with each other
	cp r8, r10
	breq EarlyAlarm_alarmsCompare_minutes
	brlo EarlyAlarm_firstEarlier
	rjmp EarlyAlarm_secondEarlier
EarlyAlarm_alarmsCompare_minutes: ;Hours are equal
	cp r9, r11
	brsh EarlyAlarm_secondEarlier
	
EarlyAlarm_firstEarlier: ;Compare with RTC
	cp r20, r8
	breq EarlyAlarm_firstEarlier_minutes1
	brpl EarlyAlarm_firstEarlier_continue
	rjmp EarlyAlarm_returnFirst ;First alarm is earliest
EarlyAlarm_firstEarlier_minutes1:
	cp r21, r9
	brpl EarlyAlarm_firstEarlier_continue
	rjmp EarlyAlarm_returnFirst ;First alarm is earliest
EarlyAlarm_firstEarlier_continue:
	cp r10, r20
	breq EarlyAlarm_firstEarlier_minutes2
	brpl EarlyAlarm_returnSecond ;Second alarm is earliest
EarlyAlarm_firstEarlier_minutes2:
	cp r11, r21
	brmi EarlyAlarm_returnFirst ;First alarm is earliest
	rjmp EarlyAlarm_returnSecond ;Second alarm is earliest
	
EarlyAlarm_secondEarlier: ;Compare with RTC
	cp r20, r10
	breq EarlyAlarm_secondEarlier_minutes1
	brpl EarlyAlarm_secondEarlier_continue
	rjmp EarlyAlarm_returnFirst ;First alarm is earliest
EarlyAlarm_secondEarlier_minutes1:
	cp r21, r11
	brpl EarlyAlarm_secondEarlier_continue
	rjmp EarlyAlarm_returnFirst ;First alarm is earliest
EarlyAlarm_secondEarlier_continue:
	cp r8, r20
	breq EarlyAlarm_secondEarlier_minutes2
	brpl EarlyAlarm_returnSecond ;Second alarm is earliest
EarlyAlarm_secondEarlier_minutes2:
	cp r9, r21
	brmi EarlyAlarm_returnFirst ;First alarm is earliest
	rjmp EarlyAlarm_returnSecond ;Second alarm is earliest
	
EarlyAlarm_returnSecond:
	inc r12
EarlyAlarm_returnFirst:
	mov rRes, r12
function_end EarlyAlarm
;========End EarlyAlarm()=========================