;================Initialization=================
	;Clear RAM (0x00)
	ldi ZL, low(SRAM_START)
	ldi ZH, high(SRAM_START)
	clr rTmp
flush:
	st 	Z+,rTmp
	cpi	ZH,High(RAMEND+1)
	brne flush
	cpi	ZL,Low(RAMEND+1)
	brne flush
	clr ZL
	clr ZH

	;Clear registers
flushRegs:
	st Z+, rTmp
	cpi ZL, 30
	brne flushRegs
	clr ZL


	;Initialize stack
	ldi rTmp,HIGH(RAMEND)
	out SPH,rTmp
	ldi rTmp,LOW(RAMEND)
	out SPL,rTmp


	;Initialize time (01/01/2011 00:00:00)
	ldi rTmp, 0
	sts mHour, rTmp
	sts mMinute, rTmp
	sts mSecond, rTmp
	ldi rTmp, 1
	sts mDay, rTmp
	sts mMonth, rTmp
	sts mDayOfWeek, rTmp

	;Initialize ports
	;
	;PORTA is digits kathodes and foto sensor
	ldi rTmp, 0x60 ;TODO: PA0-PA3 - determine port direction (when tuner will be made)
	out DDRA, rTmp
	ldi rTmp, 0x6f ;PL and CP are high, tuner pins are pulled-up
	out PORTA, rTmp
	
	;PORTB is digits segments
	ldi rTmp, 0xff
	out DDRB, rTmp
	ldi rTmp, 0
	out PORTB, rTmp
	
	;PORTC is decoder and dot for second part of channel
	ldi rTmp, 0xf8
	out DDRC, rTmp
	ldi rTmp, 0x07
	out PORTC, rTmp ;Pull-up reserved pins

	;PORTD is digits segments (except PD3)
	ldi rTmp, 0xf7
	out DDRD, rTmp
	ldi rTmp, 0
	out PORTD, rTmp
	

	;ADC initialization
	ldi rTmp, (1<<ADEN) | (1<<ADIE)
	out ADCSRA, rTmp
	ldi rTmp, (1<<REFS0) | (1<<MUX2) ;ADC4 with Vcc reference voltage and capacitor on AREF
	out ADMUX, rTmp


	;Initialize real-time counter
	;
	;triggers 125 times per second
	ldi rTmp, 250
	out OCR2, rTmp

	in rTmp, TIMSK
	ori rTmp, (1<<OCIE2)
	out TIMSK, rTmp

	in rTmp, SFIOR
	ori rTmp, (1<<PSR2)
	out SFIOR, rTmp

	ldi rTmp, 0
	out TCNT2, rTmp

	;1/256 prescaler, CTC mode
	ldi rTmp, (1<<WGM21) | (1<<CS21) | (1<<CS22)
	out TCCR2, rTmp


	;Initialize display timer
	ldi rTmp, 0x7f ;Triggers about 7900 times per second (about 13 microseconds)
	out OCR0, rTmp

	in rTmp, TIMSK
	ori rTmp, (1<<OCIE0)
	out TIMSK, rTmp

	in rTmp, SFIOR
	ori rTmp, (1<<PSR10)
	out SFIOR, rTmp

	ldi rTmp, 0
	out TCNT0, rTmp

	;1/8 prescaler, CTC mode
	ldi rTmp, (1<<WGM01) | (1<<CS01)
	out TCCR0, rTmp


	;Other initialization
	clr rTmp
	sts mCurrentOutChannel, rTmp
	sts mAlwaysRecalculateChannelsData, rTmp
	sts mChangingAlarm, rTmp
	ldi rTmp, 0x0f
	sts mSettingsIncrement, rTmp ;0b00001 111
	sts mCommonBrightness, rTmp
	ldi r31, high(mElementBrightness)
	ldi r30, low(mElementBrightness)
setAllElementsBrightness:
	st Z+, rTmp
	cpi ZL, low(mElementBrightness + 64)
	brne setAllElementsBrightness
	cpi ZH, high(mElementBrightness + 64)
	brne setAllElementsBrightness

readBrightnessRatio:
	sbic EECR, EEWE
	rjmp readBrightnessRatio
	ldi r16, low(eBrightnessRatio)
	ldi r17, high(eBrightnessRatio)
	out EEARL, r16
	out EEARH, r17
	sbi EECR, EERE
	in rTmp, EEDR
	sts mBrightnessRatio, rTmp

	sei
;================End initialization==================
