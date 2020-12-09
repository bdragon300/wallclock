	;==========VARIABLES================
	
	;----------Time variables-----------
	;Do not change order of time variables definition
	mSecond: .BYTE 1 ;Changes from 0 to 59
	mHour: .BYTE 1 ;Changes from 0 to 23
	mMinute: .BYTE 1 ;Changes from 0 to 59
	mDay: .BYTE 1 ;Changes from 1 to 31 (or 30, 29, 28 depending on month)
	mMonth: .BYTE 1 ;Changes from 1 to 12
	mDayOfWeek: .BYTE 1 ;Changes from 1 to 7
	

	;----------Alarms variables-----------
	mAlarms: .BYTE 4 ;High 2 bytes are the first alarm, low 2 bytes - second alarm
					 ;First and third bytes is hours, second and forth bytes is minutes
	mEnabledAlarms: .BYTE 1 ;TODO multiple alarms
	;contains what alarm(s) now enabled. Each bit means state appropriate alarm
	;0x00 - no alarms
	;0x01 - first alarm
	;0x02 - second alarm
	;0x03 - both


	;----------Timer/Counter2 variables----------
	mRTCClockCount: .BYTE 1		;Temp counter for Timer/Counter2. Uses for blink time colon leds
	mRTCTimeIncrement: .BYTE 1	;1 - we must to increment current time value in main cycle, 0 - do nothing

	;----------Output variables-----------
	mCommonBrightness: .BYTE 1  ;Brightness of all leds and digits. Changes from 0x00 to 0x0f
		;Calculates by ADC interrupt based on ADC value and mBrightnessRatio
		;Affects on all leds and digits together. Switched on elements at a time determines by formula:
		;    K = { 0 ≤ x ≤ 128 };  E = { ∀n ∈ K, counter + (0x0f - ADC * ratio) > br(n) }
		;,where:
		; K - set of all 128 bytes of individual elements brightness
		; E - result set of enabled elements
		; counter - mChannelDelayCounter (0 ≤ counter ≤ 125)
		; ADC - value directly from ADC (0x00 ≤ ADC ≤ 0x0f)
		; ratio - mBrightnessRatio (0.1 ≤ ratio ≤ 1.5)
		; br(n) - mElementBrightness + n (0x00 ≤ br(n) ≤ 0x0f)
	mRawDisplayData: .BYTE 16  ;Contains output data for digits and leds
		;Channel is two following bytes (starting from even byte) that contains
		;information for two digits or two led groups
		
		;7-segment display:
		;     __/ <-a
		;b->|    |<-c
		;     --  <-d
		;e->| __ |<-f ./<-dot
		;       \ <-g
		;One channel format:
		;Bits:     7 6 5 4 3 2 1  0
		;Segments: g f e d c b a dot (zero bit is for dot)
		
		;byte - the first part of channel, byte+1 - the second part of channel
		;Channels
		;[Channel number(+offset)]
		;0(+0) -  0:7 - time first digit
		;         8:15 - time second digit
		;1(+2) -  0:7 - time third digit
		;         8:15 - time forth digit
		;2(+4) -  0:7 - date first digit
		;         8:15 - date second digit
		;3(+6) -  0:7 - date third digit
		;         8:15 - date forth digit
		;4(+8) -  0:7 - alarm/frequency first digit
		;         8:15 - alarm/frequency second digit
		;5(+10) - 0:7 - alarm/frequency third digit
		;         8:15 - alarm/frequency forth digit
		;6(+12) - 0:2 - radio stations indicators
		;         3:4 - time colon
		;         5:6 - alarm indicators
		;         8:14 - day of week indicators
		;         15 - alarm colon led
	mCurrentOutChannel: .BYTE 1  ;Determines which digit should be displayed on current 
		;iteration of display cycle. InitValue=0
	mElementBrightness: .BYTE 128 ;Each element (led or segment) has its separate brightness
		;It changes from 0x00 to 0x0f. Higher values will interpret as 0x0f
		;This brightness is relative on common brightness
		;0x0f for one element means common brightness
		;Structure of data is same as mRawDisplayData
	mChannelDelayCounter: .BYTE 1 ;Changes from 0x00 to 0x0f and holds count of 
		;Timer/Counter0 ticks before mCurrentOutChannel changes
	mRecalculateChannelsData: .BYTE 1 ;If 1 then we must to recalculate all channel 
		;data in main cycle
	mAlwaysRecalculateChannelsData: .BYTE 1; If 1 we must to recalculate all channel
		;data on each main cycle iteration independently on mRecalculateChannelsData value
	mBrightnessRatio: .BYTE 1 ;Factor to current common brightness value. Uses to
		;tune brightness value from ADC depending on user's set (user can do display
		;a bit darker or lighter by adjusting appropriate setting), 
		;Changes from 1 to 15 (means from 0.1 to 1.5)


	;----------Input variables------------
	mInputState: .BYTE 2 ;Input controls that are currently activated
	mFotoSensor: .BYTE 2
	mEncoderInitialized: .BYTE 1 ;Uses for initialization encoder, i.e. getting its initial value
	mLastInputState: .BYTE 2	 ;Input controls that was activated in last input reading
	mButtonDelay: .BYTE 1	;Delay before the same button will be triggered if it still pressed
		;Decrements by Timer/Counter0


	;----------Settings variables----------
	mCurrentTimePart: .BYTE 1 ;Uses on settings mode to choose which time part 
		;currently changing (0 - none)
	mChangingAlarm: .BYTE 1 ;Each bit points to appropriate currently changing alarm
	;on settings mode. In the same time only one alarm can be changed, thus only one bit
	;can be set
	mEncoderValue: .BYTE 1 ;Last stored encoder value (number, not bits)
	mSettingsIncrement: .BYTE 1 ;How much value we should add to changing time part
		;on each encoder pulse (progressive settings changing, depended on encoder 
		;rotation speed). First 5 bits are increment value, last 3 bits are tick count.
		;Decrements by Timer/Counter0
	mBrightnessRatioSet: .BYTE 1 ;1 when brightness ratio button is pressing
		;and user able to tune brightness ratio.

.cseg
	;==========REGISTERS============
	;r0:r1 - results of functions executing
	;r2 - uses for counting subroutines call depth
	;r3:r7 - general code registers level 1
	;r8:r12 - general code registers level 2 (also they can be used as parameters starting from r8)
	;r13:r15 - interrupt registers
	;r16:r19 - general code registers with immediate loading level 1
	;r20:r23 - general code registers with immediate loading level 2
	;r24:r25 - interrupt registers with immediate loading
	;X (r26:r27) pointer uses by interrupts so we must not use it in general code
	.def rRes = r0
	.def rRes2 = r1
	.def rPar1 = r8
	.def rPar2 = r9
	.def rPar3 = r10
	.def rTmp = r16
	.def rTmpInt = r21


	;==========CONSTANTS==================
	;----------Output constants-----------
	.equ cOutChannelsCount = 8

	;----------Input constants------------
	.equ cButtonsWithDelayL = 0b00011110 ;Select all buttons that must be delayed after its pressing
	.equ cButtonsWithDelayH = 0b11111111 ;Switches and encoder we are not select because switch contacts are
		;closed in any time and encoder dont need in delay
	.equ cButtonDelay = 200 ;How much time we wait before the same button will be triggered
		;if it still pressed (how many times to about 2 ms). Empirical value


	;Number of bits in input bytes for appropriate swtiches and buttons
	.equ cAEncoder = 7	;<---The first byte
	.equ cBEncoder = 6
	.equ cSettingsSwitch = 5
	.equ cUpButton = 4
	.equ cDownButton = 3
	.equ cFirstAlarmButton = 2
	.equ cSecondAlarmButton = 1
	.equ cBrightnessRatioButton = 0 ;<---The second byte
	.equ cRadioButton = 7
	.equ cNextRadioStation = 6
	.equ cRadioStationTuningUp = 5
	.equ cRadioStationTuningDown = 4
