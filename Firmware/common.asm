;=========function Divide(d1, d2)===============
;Multiplies one register to another with remainder
;Returns result in rRes and remainder in rRes2
Divide:
function_begin Divide
	;r8 - first parameter
	;r9 - second parameter

	clr r12
	clr rRes
	cp rPar2, r12
	breq Divide_return ;division by zero

	mov r11, rPar2

Divide_shiftLeft:
	sbrc r11, 7
	rjmp Divide_shiftLeftEnd
	lsl r11
	rjmp Divide_shiftLeft
Divide_shiftLeftEnd:
	mov rRes2, rPar1

Divide_iteration:
	lsl rRes
	sub rRes2, r11
	brlo Divide_minus
Divide_plus:
	inc rRes
	rjmp Divide_d2Shift
Divide_minus:
	add rRes2, r11
Divide_d2Shift:
	lsr r11
	cp r11, rPar2
	brsh Divide_iteration

Divide_return:
	cp rRes, r12
function_end Divide
;=========End Divide(d1, d2)======================


;========function AddWithThreshold(val, addVal, threshold)====
;Increases val with addVal and if it would overflow threshold then resets
;it with remainder. If after adding result would negative (if addVal is negative)
;then set it to the threshold value minus remainder
;This function accepts unsigned values except addVal
;rRes contains new value, rRes2 contains integer part of quotient obtained by 
;dividing val by the threshold

;For example val=1, addVal=156, threshold=50
;There will be: rRes=7, rRes2=3
;If there are: val=1, addVal=-176, threshold=20
;There will be: rRes=5, rRes2=-8=0b11111000
AddWithThreshold:
function_begin AddWithThreshold
	clr r12
	add rPar1, rPar2
	brlt AddWithThreshold_negative ;Result is negative number

;Decrease result to be less than threshold
;Divide operation takes more clock cycles than this loop
AddWithThreshold_positive:
	cp rPar1, rPar3
	brlo AddWithThreshold_return
	inc r12
	sub rPar1, rPar3
	rjmp AddWithThreshold_positive
	
;Result is negative number
;Increase result to make number positive and less than threshold
AddWithThreshold_negative:
	dec r12
	add rPar1, rPar3
	brmi AddWithThreshold_negative
	rjmp AddWithThreshold_return
	
AddWithThreshold_return:
	mov rRes, rPar1
	mov rRes2, r12
function_end AddWithThreshold
;========End AddWithThreshold(val, addVal, threshold)=========
