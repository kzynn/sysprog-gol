EQU ZUF8R, 0x20
CSEG At 0H
jmp init
ORG 100H

;-- Initialisire Zähler (Start-Adresse)--; 
init:
        MOV R1, #28h
ANF:
	CJNE R1, #30h, LOOP
	JMP FINISH
LOOP:
;-- Generiere ZahZufallszahl --;
	CALL ZUFALL
	MOV @R1, A
;----------- CASE-ANWEISUNG-------------------------
neu:	INC R1
        jmp ANF
;--------------------------------------------------


; ------ Zufallszahlengenerator-----------------
ZUFALL:	mov	A, ZUF8R   ; initialisiere A mit ZUF8R
	jnz	ZUB
	cpl	A
	mov	ZUF8R, A
ZUB:	anl	a, #10111000b
	mov	C, P
	mov	A, ZUF8R
	rlc	A
	mov	ZUF8R, A
	ret

FINISH:

end
