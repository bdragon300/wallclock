;========complex function OnEncoder==========
;It is complex function with multiple entry points
;There are:
;function OnEncoderRight()
;function OnEncoderLeft()
;
;Do NOT call OnEncoder because this label for inner use
OnEncoder:
	lds r8, mSettingsIncrement
	lsr r8
	lsr r8
	lsr r8
	lds r20, mCurrentTimePart
	lds r21, mBrightnessRatioSet
	lds r22, mBrightnessRatio
	ret

;========function OnEncoderRight()==========
OnEncoderRight:
function_begin OnEncoderRight
	call OnEncoder

OnEncoderRight_brightnessRatio:
	tst r21
	breq OnEncoder_noSettings ;Brightness ratio button not set
	cpi r22, 15
	breq OnEncoderRight_goReturn ;brightness ratio must not be more than 15
	inc r22
	sts mBrightnessRatio, r22
	jmp OnEncoder_return
	
OnEncoderRight_goReturn:
	jmp OnEncoder_return
;========function OnEncoderLeft()==========
OnEncoderLeft:
function_begin OnEncoderLeft
	call OnEncoder
	neg r8
	
OnEncoderLeft_brightnessRatio:
	tst r21
	breq OnEncoder_noSettings ;Brightness ratio button not set
	cpi r22, 1
	breq OnEncoder_noSettings_goReturn ;brightness ratio must not be less than 0
	dec r22
	sts mBrightnessRatio, r22
	rjmp OnEncoder_return
	
	
OnEncoder_noSettings:
	cpi r20, 0
	breq OnEncoder_noSettings_goReturn
	rjmp OnEncoder_time
OnEncoder_noSettings_goReturn:
	jmp OnEncoder_return

OnEncoder_time: ;Change time (minutes and seconds)
	cpi r20, 1
	brne OnEncoder_date
	call1 IncreaseMinutes, r8
	rjmp OnEncoder_return

OnEncoder_date: ;Change date (days and months)
	cpi r20, 2
	brne OnEncoder_dayOfWeek
	call1 IncreaseDays, r8
	rjmp OnEncoder_return

OnEncoder_dayOfWeek:
	cpi r20, 3
	brne OnEncoder_alarm
	call1 IncreaseDaysOfWeek, r8
	rjmp OnEncoder_return

OnEncoder_alarm:
	lds r21, mChangingAlarm
	tst r21
	breq OnEncoder_return ;No active alarm (unlikely)
	call2 IncreaseAlarmMinutes, r8, r21
	rjmp OnEncoder_return

OnEncoder_return:
	ser r21
	sts mSettingsIncrement, r21
function_end OnEncoderRight
;========End OnEncoder=============================


;========function OnSettingsOn()===================
;Calls when user enters to settings mode
OnSettingsOn:
function_begin OnSettingsOn
	ldi r21, 1
	sts mCurrentTimePart, r21
	sts mChangingAlarm, r21
	
	;Disable RTC
	in r20, TIMSK
	andi r20, ~((1<<TOIE2) | (1<<OCIE2))
	out TIMSK, r20

	;Reset seconds to 00
	ldi r20, 0
	sts mSecond, r20

	call SetSettingsBrightness
OnSettingsOn_return:
function_end OnSettingsOn
;========End OnSettingsOn()========================


;========function OnSettingsOff()==================
;Calls when user leaves settings mode
OnSettingsOff:
function_begin OnSettingsOff
	clr r20
	sts mCurrentTimePart, r20
	sts mRTCClockCount, r20
	sts mChangingAlarm, r20

	;Enable RTC
	in r20, TIMSK
	ori r20, (1<<TOIE2) | (1<<OCIE2)
	out TIMSK, r20

OnSettingsOff_return:
	call SetSettingsBrightness
	call SetDayOfWeekBrightness
function_end OnSettingsOff
;========End OnSettingsOff()=======================


;========function OnEncoderUp()===================
;Calls when user switches time part to change
OnEncoderUp:
function_begin OnEncoderUp
	lds r20, mCurrentTimePart
	tst r20
	breq OnEncoderUp_return ;Settings mode disabled
	dec r20
	brne OnEncoderUp_setCurrentTimePart
	ldi r20, 4 ;Overflowed
OnEncoderUp_setCurrentTimePart:
	sts mCurrentTimePart, r20

OnEncoderUp_return:
	call SetSettingsBrightness
function_end OnEncoderUp
;========End OnEncoderUp()========================


;========function OnEncoderDown()=================
;Calls when user switches time part to change
OnEncoderDown:
function_begin OnEncoderDown
	lds r20, mCurrentTimePart
	inc r20
	cpi r20, 5
	brlo OnEncoderDown_setCurrentTimePart
	clr r20 ;Overflowed
OnEncoderDown_setCurrentTimePart:
	sts mCurrentTimePart, r20

OnEncoderDown_return:
	call SetSettingsBrightness
function_end OnEncoderDown
;========End OnEncoderDown()======================


;========function OnFirstAlarm()===========
;User just pressed on the first alarm button
;If settings mode enabled then alarm digits will be also enabled and will get focus
OnFirstAlarm:
function_begin OnFirstAlarm
	lds r23, mCurrentTimePart
	tst r23
	brne OnFirstAlarm_settingsEnabled
	
	;Settings mode disabled
	lds r20, mEnabledAlarms
	mov r22, r20
	andi r22, 0x01
	brne OnFirstAlarm_off
	
OnFirstAlarm_on:
	andi r20, 0xfe
	sts mEnabledAlarms, r20
	rjmp OnFirstAlarm_return
	
OnFirstAlarm_off:
	ori r20, 0x01
	sts mEnabledAlarms, r20
	rjmp OnFirstAlarm_return
	
OnFirstAlarm_settingsEnabled:
	ldi r21, 4
	sts mCurrentTimePart, r21
	ldi r22, 0x01 ;Only one alarm can be changed in the same time
	sts mChangingAlarm, r22

OnFirstAlarm_return:
	call SetSettingsBrightness
function_end OnFirstAlarm
;========End OnFirstAlarm()================


;========function OnSecondAlarm()===========
;User just pressed on the second alarm button
;If settings mode enabled then alarm digits will be also enabled and will get focus
OnSecondAlarm:
function_begin OnSecondAlarm
	lds r23, mCurrentTimePart
	tst r23
	brne OnSecondAlarm_settingsEnabled
	
	;Settings mode disabled
	lds r20, mEnabledAlarms
	mov r22, r20
	andi r22, 0x02
	brne OnSecondAlarm_off
	
OnSecondAlarm_on:
	andi r20, 0xfd
	sts mEnabledAlarms, r20
	rjmp OnSecondAlarm_return
	
OnSecondAlarm_off:
	ori r20, 0x02
	sts mEnabledAlarms, r20
	rjmp OnSecondAlarm_return
	
OnSecondAlarm_settingsEnabled:
	ldi r21, 4
	sts mCurrentTimePart, r21
	ldi r22, 0x02 ;Only one alarm can be changed in the same time
	sts mChangingAlarm, r22

OnSecondAlarm_return:
	call SetSettingsBrightness
function_end OnSecondAlarm
;========End OnSecondAlarm()================


;========function OnBrightnessRatioDown()===
OnBrightnessRatioDown:
function_begin OnBrightnessRatioDown
	ldi r20, 1
	sts mBrightnessRatioSet, r20
function_end OnBrightnessRatioDown
;========End OnBrightnessRatioDown()========


;========function OnBrightnessRatioUp()=====
OnBrightnessRatioUp:
function_begin OnBrightnessRatioUp
	clr r8
	sts mBrightnessRatioSet, r8
	lds r9, mBrightnessRatio
	
OnBrightnessRatioUp_waitForEEPROM:
	sbic EECR, EEWE
	rjmp OnBrightnessRatioUp_waitForEEPROM
	cli
	ldi r20, high(eBrightnessRatio)
	ldi r21, low(eBrightnessRatio)
	out EEARH, r20
	out EEARL, r21
	out EEDR, r9
	sbi EECR, EEMWE
	sbi EECR, EEWE
	sei
function_end OnBrightnessRatioUp
;========End OnBrightnessRatioUp()==========
