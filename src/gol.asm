; ----------------------
; conways game of life
; 3/3 world
; ----------------------
; run with max clock speed (99999)

cseg at 0h
LJMP start
ORG 100H

; Eingabevektor
EIN1 EQU 20H
START EQU EIN1.0
IN1 EQU EIN1.1
IN2 EQU EIN1.2
INRand EQU EIN1.3

ZUF8R EQU 0x20

start:
MOV P1, #0h
MOV P2, #0h
MOV EIN1, P0 ;-- lade P0 nach x020h
Mov C, Start ;-- lade das 0. Bit in C
JNC loadState ;-- wenn C 0 ist, beginne mit laden aus der datenbank
SJMP waitOneSconde ;-- wenn noch nicht gestartet ist warte


waitOneSconde:
MOV R2, #005h
MOV R1, #001h
MOV R0, #001h
NOP
DJNZ R0, $
DJNZ R1, $-5
DJNZ R2, $-9
MOV R0, #059h
DJNZ R0, $
SJMP start

firstState:
mov b, #0 ;--offset 0
sjmp move

secondeState:
mov b, #8;-- offset 8
sjmp move

thiredState:
mov b, #16 ;offest 16
sjmp move

fourthState:
mov b, #24; offset 24
sjmp move

bigger:
JB IN1, fourthState  ;-- wenn state 4
JNB IN1, thiredState ;-- wenn state 3

lower:
JB IN1, secondestate ;-- wenn state 2
JNB IN1, firststate  ;-- wenn state 1

random:
ljmp RAND


loadState:
mov DPTR, #table ;-- set pointer to tabel
;-- setze startwert
JB INRAND, random ;-- wenn state random
JB IN2, bigger ;-- wenn state 3 oder 4
JNB IN2, lower ;-- wenn state 1 oder 2

move:
;-- load values from db into correct adresses in ram
mov r0, #70h

loadByte:
mov a, b 		;-- lade b in a
movc a, @a+dptr ;-- kopiere aus dem ram den a-ten eintrag
mov @r0, a 		;-- speicher den a-ten eintrag in den speicher
inc b 			;-- erhöhe b um 1
inc r0			;-- erhöhe speicheradresse um 1
cjne r0, #78h, loadByte


calc:
	call display
	mov r7, #8d		; init row count with 8, start with first row
	loop_cols:
		call display
		; loop trough cols
		mov r6, #01h	; init col bit with 1
		loop_rows:
			; loop trough rows
			mov a, r6	; shift col bit
			rr a
			mov r6, a
			mov r5, #0d	; reset surrounding cell count

			; do things
			call calc_cell
			call set_cell

			cjne r6, #01h, loop_rows ; end loop if col bit has passed calculation for lowest bit
	inc r7					 ; increment row count
	cjne r7, #16d, loop_cols ; end loop if r7=rowcount reaches 16
	call shift
	jmp calc

shift:
	mov 70h, 78h
	mov 71h, 79h
	mov 72h, 7Ah
	mov 73h, 7Bh
	mov 74h, 7Ch
	mov 75h, 7Dh
	mov 76h, 7Eh
	mov 77h, 7Fh
	ret

calc_cell:
	; calc surrounding cells alive
	; row above
	dec r7
	call calc_current_row_adress
	mov a, r6
	rl a
	mov r6, a
	call check_alive
	mov a, r6
	rr a
	mov r6, a
	call check_alive
	mov a, r6
	rr a
	mov r6, a
	call check_alive
	; cells left and right
	inc r7
	call calc_current_row_adress
	call check_alive
	mov a, r6
	rl a
	rl a
	mov r6, a
	call check_alive
	; cells below
	inc r7
	call calc_current_row_adress
	call check_alive
	mov a, r6
	rr a
	mov r6, a
	call check_alive
	mov a, r6
	rr a
	mov r6, a
	call check_alive
	; clean up row and col bit registers
	dec r7
	mov a, r6
	rl a
	mov r6, a
	ret

calc_current_row_adress:
	; moves current row adress in r0
	; calc current row offset (modulo operation to prevent -1 and 9)
	mov a, r7
	mov b, #08d
	div ab 		; calc modulo, result in b register

	mov a, #70h ; start calc adress for curr row
	add a, b
	mov r0, a
	ret

check_alive:
	; checks if a cell is alive and if so increments r5
	mov a, @r0	; mov current row in a
	anl a, r6	; and operation for selecting specific cell
	jz skip_if_cell_dead
	inc r5
	skip_if_cell_dead:
	ret

set_cell:
	; check value in r5 and set new value for cell in new field
	; calc new memory adress for current row
	mov a, r7	; mod because of edge cases
	mov b, #08d
	div ab 		; calc modulo, result in b register
	mov a, b
	add a, #78h
	mov r0, a	; store new memory location in r0

	cjne r5, #03d, cell_is_dead
	; cell is alive
	mov a, @r0
	orl a, r6
	mov @r0, a
	ret
	cell_is_dead:
	mov a, r6
	cpl a		; invert sequence
	mov r1, a	; move inverted to r1
	mov a, @r0
	anl a, r1	; compare with inverted sequence
	mov @r0, a
	ret


;-- Initialisiere Zähler (Speicheradressen)--;
RAND:
    MOV R1, #70h
ANF:
	CJNE R1, #78h, LOOP
	JMP CALC
LOOP:
;-- Generiere ZahZufallszahl --;
	CALL ZUFALL
	MOV @R1, A
;----------- CASE-ANWEISUNG-------------------------
neu:
	INC R1
	jmp ANF
;--------------------------------------------------


; ------ Zufallszahlengenerator-----------------
ZUFALL:
	mov	A, ZUF8R   ; initialisiere A mit ZUF8R
	jnz	ZUB
	cpl	A
	mov	ZUF8R, A
ZUB:
	anl	a, #10111000b
	mov	C, P
	mov	A, ZUF8R
	rlc	A
	mov	ZUF8R, A
	ret

display:
	mov R2, #001H ; Set row number to 1
	MOV R0, #070H ; Address of first row

displayRow:
	mov P2, R2
	mov A, @R0
	mov P1, A
	inc R0

	; All pixels off
	mov P2, #0H
	mov P1, #0H

	; calculate next row number
	MOV A, R2
	RL A
	MOV R2, A

	CJNE A, #01H, displayRow
	ret


org 40h
table:
; -- erster Zustand: 00 Pedal
db 00000000b
db 00011000b
db 00110000b
db 00000000b
db 00000000b
db 00001100b
db 00011000b
db 00000000b

; -- zweiter Zustand: 01 Kegel
db 00000000b
db 00100000b
db 01100000b
db 00010000b
db 00000000b
db 00001000b
db 00000110b
db 00000100b

; -- dritter Zustand: 10 Unruh(1)
db 00000000b
db 00000000b
db 00001000b
db 00110000b
db 00001100b
db 00010000b
db 00000000b
db 00000000b

; -- vierter Zustand: 11 Strudel
db 00000000b
db 00010100b
db 01010000b
db 00000110b
db 01100000b
db 00001010b
db 00101000b
db 00000000b

END
