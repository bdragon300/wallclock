;========function SetDayOfWeekBrightness()========
SetDayOfWeekBrightness:
function_begin SetDayOfWeekBrightness
	lds r8, mCurrentTimePart
	tst r8
	;If settings mode is active, we break brightness image at all display
	;So, exit
	brne SetDayOfWeekBrightness_return 
	lds r8, mDayOfWeek
	ldi r20, 0x09 ;Low brightness value
	ldi r21, 0x0f ;High brightness value

	ldi ZH, high(mElementBrightness + 104)
	ldi ZL, low(mElementBrightness + 104)
SetDayOfWeekBrightness_low:
	dec r8
	breq SetDayOfWeekBrightness_high
	st Z+, r20
	rjmp SetDayOfWeekBrightness_low

SetDayOfWeekBrightness_high:
	st Z+, r21
SetDayOfWeekBrightness_return:
function_end SetDayOfWeekBrightness
;========End SetDayOfWeekBrightness()=============


;========function SetSettingsBrightness()=========
;Realizes shadow effect when settings mode is active. It enlights active changing
;setting (i.e. date) and darkens others
SetSettingsBrightness:
function_begin SetSettingsBrightness
	lds r8, mCurrentTimePart
	tst r8
	breq SetSettingsBrightness_return

SetSettingsBrightness_time:
	ldi r21, 32
	ldi ZH, high(mElementBrightness)
	ldi ZL, low(mElementBrightness)
	dec r8
	brne SetSettingsBrightness_time_dark
	ldi r20, 0x0f
	rjmp SetSettingsBrightness_time_set
SetSettingsBrightness_time_dark:
	ldi r20, 0x06
SetSettingsBrightness_time_set:
	st Z+, r20
	dec r21
	brne SetSettingsBrightness_time_set
	
SetSettingsBrightness_date:
	ldi r21, 32
	dec r8
	brne SetSettingsBrightness_date_dark
	ldi r20, 0x0f
	rjmp SetSettingsBrightness_date_set
SetSettingsBrightness_date_dark:
	ldi r20, 0x06
SetSettingsBrightness_date_set:
	st Z+, r20
	dec r21
	brne SetSettingsBrightness_date_set
	
SetSettingsBrightness_dayOfWeek:
	ldi r21, 7
	ldi ZH, high(mElementBrightness + 104)
	ldi ZL, low(mElementBrightness + 104)
	dec r8
	brne SetSettingsBrightness_dayOfWeek_dark
	ldi r20, 0x0f
	rjmp SetSettingsBrightness_dayOfWeek_set
SetSettingsBrightness_dayOfWeek_dark:
	ldi r20, 0x06
SetSettingsBrightness_dayOfWeek_set:
	st Z+, r20
	dec r21
	brne SetSettingsBrightness_dayOfWeek_set
	
SetSettingsBrightness_alarm:
	ldi r21, 32
	ldi ZH, high(mElementBrightness + 64)
	ldi ZL, low(mElementBrightness + 64)
	dec r8
	brne SetSettingsBrightness_alarm_dark
	ldi r20, 0x0f
	rjmp SetSettingsBrightness_alarm_set
SetSettingsBrightness_alarm_dark:
	ldi r20, 0x06
SetSettingsBrightness_alarm_set:
	st Z+, r20
	dec r21
	brne SetSettingsBrightness_alarm_set
SetSettingsBrightness_return:
function_end SetSettingsBrightness
;========End SetSettingsBrightness()==============