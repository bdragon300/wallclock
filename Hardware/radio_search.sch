EESchema Schematic File Version 2  date Срд 01 Фев 2012 15:54:34
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 1 1
Title ""
Date "1 feb 2012"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4500 3200 4600 3200
Wire Wire Line
	4600 3200 4600 2700
Wire Wire Line
	4600 2700 4950 2700
Connection ~ 4950 3300
Wire Wire Line
	4500 3300 5200 3300
Wire Wire Line
	4500 3100 4500 2600
Wire Wire Line
	4500 2600 5200 2600
Wire Wire Line
	5200 2600 5200 2700
$Comp
L SW_PUSH SW1
U 1 1 4F25A90E
P 4950 3000
F 0 "SW1" H 5100 3110 50  0000 C CNN
F 1 "SW_PUSH" H 4950 2920 50  0000 C CNN
	1    4950 3000
	0    1    1    0   
$EndComp
$Comp
L SW_PUSH SW2
U 1 1 4F25A8F8
P 5200 3000
F 0 "SW2" H 5350 3110 50  0000 C CNN
F 1 "SW_PUSH" H 5200 2920 50  0000 C CNN
	1    5200 3000
	0    1    1    0   
$EndComp
$Comp
L CONN_3 K1
U 1 1 4F25A8E4
P 4150 3200
F 0 "K1" V 4100 3200 50  0000 C CNN
F 1 "CONN_3" V 4200 3200 40  0000 C CNN
	1    4150 3200
	-1   0    0    1   
$EndComp
$EndSCHEMATC
