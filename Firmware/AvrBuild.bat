@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "Z:\AVR PROJECTS\Clocks\labels.tmp" -fI -W+ie -C V2E -o "Z:\AVR PROJECTS\Clocks\Clocks.hex" -d "Z:\AVR PROJECTS\Clocks\Clocks.obj" -e "Z:\AVR PROJECTS\Clocks\Clocks.eep" -m "Z:\AVR PROJECTS\Clocks\Clocks.map" -l "Z:\AVR PROJECTS\Clocks\Clocks.lst" "Z:\AVR PROJECTS\Clocks\Clocks.asm"
