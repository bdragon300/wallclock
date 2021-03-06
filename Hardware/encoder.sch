EESchema Schematic File Version 2  date Срд 01 Фев 2012 15:54:05
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
	4300 3900 4850 3900
Wire Wire Line
	4850 4250 4650 4250
Wire Wire Line
	4650 4250 4650 3800
Wire Wire Line
	4850 4150 3500 4150
Wire Wire Line
	3500 3700 3500 3350
Wire Wire Line
	4300 3700 4300 3350
Wire Wire Line
	3500 3800 3300 3800
Wire Wire Line
	3300 3800 3300 4550
Wire Wire Line
	4650 3800 4300 3800
Wire Wire Line
	3500 4150 3500 3900
Wire Wire Line
	3500 2750 4450 2750
Connection ~ 4300 2750
Wire Wire Line
	4850 3900 4850 4050
Wire Wire Line
	4300 4550 4450 4550
Wire Wire Line
	4450 4550 4450 2750
Connection ~ 4450 3900
$Comp
L CONN_3X2 P1
U 1 1 4F259DFC
P 3900 3750
F 0 "P1" H 3900 4000 50  0000 C CNN
F 1 "CONN_3X2" V 3900 3800 40  0000 C CNN
	1    3900 3750
	-1   0    0    1   
$EndComp
$Comp
L CODEUR_CONTACT_INCR ENC?
U 1 1 4F259DBA
P 5150 4150
F 0 "ENC?" H 5200 4300 60  0000 C CNN
F 1 "PEC11-4115K-S0018" H 5400 4400 60  0000 C CNN
	1    5150 4150
	-1   0    0    -1  
$EndComp
$Comp
L SPST SW2
U 1 1 4F259BE7
P 3800 4550
F 0 "SW2" H 3800 4650 70  0000 C CNN
F 1 "SPST" H 3800 4450 70  0000 C CNN
	1    3800 4550
	-1   0    0    1   
$EndComp
$Comp
L SW_PUSH SW3
U 1 1 4F259BD6
P 4300 3050
F 0 "SW3" H 4450 3160 50  0000 C CNN
F 1 "SW_PUSH" H 4300 2970 50  0000 C CNN
	1    4300 3050
	0    -1   -1   0   
$EndComp
$Comp
L SW_PUSH SW1
U 1 1 4F259BD3
P 3500 3050
F 0 "SW1" H 3650 3160 50  0000 C CNN
F 1 "SW_PUSH" H 3500 2970 50  0000 C CNN
	1    3500 3050
	0    -1   -1   0   
$EndComp
$EndSCHEMATC
