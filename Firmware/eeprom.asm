.eseg
	eDaysInMonths: .db 31,28,31,30,31,30,31,31,30,31,30,31
	eDaysOfWeekInLeapYears: .db 2, 7, 0 ;Which days of week have 28 of February in leap years
		;This numbers are valid through 2017 year after what we must to update them
		;List of numbers must be finished by zero
	eBrightnessRatio: .db 10 ;Factor to current common brightness value. Uses to
		;tune brightness value depending on room's light, Changes from 1 to 20 
		;(means from 0.1 to 2.0). Init value is 10 (means 1.0)