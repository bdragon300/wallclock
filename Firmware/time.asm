;========function GetMatchAlarm()==================
;Checks which alarm is matched on the moment
GetMatchAlarm:
function_begin GetMatchAlarm
	lds r8, mHour
	lds r9, mMinute
	lds r20, mEnabledAlarms
	cpi r20, 0
	breq GetMatchAlarm_return
GetMatchAlarm_1:
	cpi r20, 1
	brne GetMatchAlarm_2
	lds r10, mAlarms ;Hour
	lds r11, mAlarms + 1 ;Minutes
	cp r10, r8
	brne GetMatchAlarm_return
	cp r11, r9
	brne GetMatchAlarm_return
	mov rRes, r20
	rjmp GetMatchAlarm_return
GetMatchAlarm_2:
	cpi r20, 2
	brne GetMatchAlarm_return
	lds r10, mAlarms + 2 ;Hour
	lds r11, mAlarms + 3 ;Minutes
	cp r10, r8
	brne GetMatchAlarm_return
	cp r11, r9
	brne GetMatchAlarm_return
	mov rRes, r20
GetMatchAlarm_return:
function_end GetMatchAlarm
;========End AlarmCheck()=======================


;========complex function IncreaseTimeDate========
;It is complex function with multiple entry points
;There are:
;function IncreaseSeconds(val)
;function IncreaseMinutes(val)
;function IncreaseHours(val)
;function IncreaseDaysOfWeek(val)
;function IncreaseDays(val)
;function IncreaseMonths(val)
;Adds to changing value addKind value, Add kind can be two's complement value to decrease addKind value
;
;========function IncreaseSeconds(val)=============
IncreaseSeconds:
function_begin IncreaseSeconds
	tst rPar1
	breq IncreaseTimeDate_goReturn1
	lds r20, mSecond
	ldi r21, 59
	call3 AddWithThreshold, r20, rPar1, r21
	sts mSecond, rRes
	mov rPar1, rRes2
	rjmp IncreaseMinutes1 ;Skip function_begin macros
	
;========function IncreaseMinutes(val)=============
IncreaseMinutes:
function_begin IncreaseMinutes
IncreaseMinutes1:
	tst rPar1
	breq IncreaseTimeDate_goReturn1
	lds r20, mMinute
	ldi r21, 59
	call3 AddWithThreshold, r20, rPar1, r21
	sts mMinute, rRes
	mov rPar1, rRes2
	rjmp IncreaseHours1 ;Skip function_begin macros
	
IncreaseTimeDate_goReturn1:
	jmp IncreaseTimeDate_return	
;========function IncreaseHours(val)=============
IncreaseHours:
function_begin IncreaseHours
IncreaseHours1:
	tst rPar1
	breq IncreaseTimeDate_goReturn1
	lds r20, mHour
	ldi r21, 23
	call3 AddWithThreshold, r20, rPar1, r21
	sts mHour, rRes
	mov rPar1, rRes2
	clr r11
	rjmp IncreaseDaysOfWeek1 ;Skip function_begin macros
	
;========function IncreaseDaysOfWeek(val)=============
IncreaseDaysOfWeek:
function_begin IncreaseDaysOfWeek
	clr r11
	inc r11
IncreaseDaysOfWeek1:
	tst rPar1
	breq IncreaseTimeDate_goReturn1
	lds r20, mDayOfWeek
	ldi r21, 7
	call3 AddWithThreshold, r20, rPar1, r21
	sts mDayOfWeek, rRes
	tst r11
	brne IncreaseTimeDate_goReturn2 ;If we call this function by other code not by IncreaseAlarmHours
		;then exit because we should not to change day number in this case
	rjmp IncreaseDays1 ;Skip function_begin macros

;========function IncreaseDays(val)=============
IncreaseDays:
function_begin IncreaseDays
IncreaseDays1:
	tst rPar1
	breq IncreaseTimeDate_goReturn2
	clr r12
	lds r20, mDay
	lds r11, mMonth
	dec r11 ;Month should start from zero
IncreaseDays_eeprom:
	sbic EECR, EEWE
	rjmp IncreaseDays_eeprom
	ldi r22, low(eDaysInMonths)
	ldi r23, high(eDaysInMonths)
	add r22, r11
	adc r23, r12
	out EEARL, r22
	out EEARH, r23
	sbi EECR, EERE
	in r21, EEDR
	call3 AddWithThreshold, r20, rPar1, r21
	sts mDay, rRes
	mov rPar1, rRes2
	rjmp IncreaseMonths1 ;Skip function_begin macros

IncreaseTimeDate_goReturn2:
	jmp IncreaseTimeDate_return	
;========function IncreaseMonths(val)=============
IncreaseMonths:
function_begin IncreaseMonths
IncreaseMonths1:
	tst rPar1
	breq IncreaseTimeDate_return
	lds r20, mMonth
	ldi r21, 12
	call3 AddWithThreshold, r20, rPar1, r21
	sts mMonth, rRes
IncreaseTimeDate_return:
function_end IncreaseTimeDate
;========End IncreaseTimeDate======================


;========complex function IncreaseAlarmTime========
;It is complex function with multiple entry points
;Increases value of alarm time. You can put to the addVal two's complement value (negative value)
;addVal - what we should to add to the time
;alarmNum - value starting from 1 that points to alarm number
;Do NOT call IncreaseAlarmTime because this label for inner use
IncreaseAlarmTime:
	clr r12
	dec rPar2
	lsl rPar2
	ldi ZL, low(mAlarms)
	ldi ZH, high(mAlarms)
	add ZL, rPar2
	adc ZH, r12
	ld r20, Z+ ;Hours
	ld r21, Z+ ;Minutes
	ret
	
;========function IncreaseAlarmMinutes(addVal, alarmNum)===
IncreaseAlarmMinutes:
function_begin IncreaseAlarmMinutes
	tst rPar1
	breq IncreaseAlarmTime_return
	call IncreaseAlarmTime
	ldi r22, 59
	call3 AddWithThreshold, r21, rPar1, r22
	st -Z, rRes
	mov rPar1, rRes2
	rjmp IncreaseAlarmHours1

;========function IncreaseAlarmHours(addVal, alarmNum)===
IncreaseAlarmHours:
function_begin IncreaseAlarmHours
	tst rPar1
	breq IncreaseAlarmTime_return
	call IncreaseAlarmTime
	st -Z, r21 ;Dummy operation just for decrement Z pointer
IncreaseAlarmHours1:
	ldi r22, 23
	call3 AddWithThreshold, r20, rPar1, r22
	st -Z, rRes
	
IncreaseAlarmTime_return:
function_end IncreaseAlarmTime
;========End IncreaseAlarmTime(addVal)=============


;=======function IsLeapYear()================
;determines whether current year is leap year based on day of week and date
;current date must be 28 of February
;rRes contains non-zero value if it is leap year
IsLeapYear:
function_begin IsLeapYear
	clr r12
	lds r8, mDayOfWeek
IsLeapYear_loadAddress:
	ldi r20, low(eDaysOfWeekInLeapYears)
	ldi r21, high(eDaysOfWeekInLeapYears)
IsLeapYear_waitForEEPROMFree:
	sbic EECR, EEWE
	rjmp IsLeapYear_waitForEEPROMFree
	out EEARL, r20
	out EEARH, r21
	sbi EECR, EERE
	in r22, EEDR
	inc r21
	adc r20, r12
	cp r22, r8
	brne IsLeapYear_loadAddress
	cpi r22, 0
	brne IsLeapYear_loadAddress
IsLeapYear_return:
	mov rRes, r22
function_end IsLeapYear
;=======End IsLeapYear()=====================
