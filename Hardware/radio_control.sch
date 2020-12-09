EESchema Schematic File Version 2  date Срд 01 Фев 2012 15:54:22
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
NoConn ~ 4850 3450
Wire Wire Line
	5650 3150 5650 2850
Wire Wire Line
	5650 2850 6800 2850
Wire Wire Line
	6800 2850 6800 3050
Wire Wire Line
	5650 3350 5900 3350
Wire Wire Line
	5900 3350 5900 3050
Wire Wire Line
	5900 3050 6200 3050
Wire Wire Line
	4850 3250 4600 3250
Wire Wire Line
	4600 3250 4600 3750
Wire Wire Line
	4600 3750 4400 3750
Connection ~ 4400 3150
Wire Wire Line
	4850 3150 4100 3150
Wire Wire Line
	4100 3750 4100 3900
Wire Wire Line
	4100 3900 4700 3900
Wire Wire Line
	4700 3900 4700 3350
Wire Wire Line
	4700 3350 4850 3350
Wire Wire Line
	5650 3450 6800 3450
Connection ~ 6500 3450
Connection ~ 6200 3450
Wire Wire Line
	6500 3050 6500 2950
Wire Wire Line
	6500 2950 5800 2950
Wire Wire Line
	5800 2950 5800 3250
Wire Wire Line
	5800 3250 5650 3250
$Comp
L LED D3
U 1 1 4F25A9C4
P 6800 3250
F 0 "D3" H 6800 3350 50  0000 C CNN
F 1 "LED" H 6800 3150 50  0000 C CNN
	1    6800 3250
	0    -1   -1   0   
$EndComp
$Comp
L LED D2
U 1 1 4F25A9C2
P 6500 3250
F 0 "D2" H 6500 3350 50  0000 C CNN
F 1 "LED" H 6500 3150 50  0000 C CNN
	1    6500 3250
	0    -1   -1   0   
$EndComp
$Comp
L LED D1
U 1 1 4F25A9B7
P 6200 3250
F 0 "D1" H 6200 3350 50  0000 C CNN
F 1 "LED" H 6200 3150 50  0000 C CNN
	1    6200 3250
	0    -1   -1   0   
$EndComp
$Comp
L SW_PUSH SW1
U 1 1 4F25A94F
P 4100 3450
F 0 "SW1" H 4250 3560 50  0000 C CNN
F 1 "SW_PUSH" H 4100 3370 50  0000 C CNN
	1    4100 3450
	0    -1   -1   0   
$EndComp
$Comp
L SW_PUSH SW2
U 1 1 4F25A941
P 4400 3450
F 0 "SW2" H 4550 3560 50  0000 C CNN
F 1 "SW_PUSH" H 4400 3370 50  0000 C CNN
	1    4400 3450
	0    -1   -1   0   
$EndComp
$Comp
L CONN_4X2 P1
U 1 1 4F25A935
P 5250 3300
F 0 "P1" H 5250 3550 50  0000 C CNN
F 1 "CONN_4X2" V 5250 3300 40  0000 C CNN
	1    5250 3300
	1    0    0    -1  
$EndComp
$EndSCHEMATC
