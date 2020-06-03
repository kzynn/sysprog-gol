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
;1. wert
mov a, b ; -- lade b in a
movc a, @a+dptr ;-- kopierer aus dem ram den a-ten eintrag
mov 028H, a ;-- speicher den a-ten eintrag in den speicher
inc b ;-- erhöhe b um 1

;2. wert
mov a, b
movc a, @a+dptr
mov 029H, a
inc b

;3. wert
mov a, b
movc a, @a+dptr
mov 02AH, a
inc b

;4. wert
mov a, b
movc a, @a+dptr
mov 02BH, a
inc b

;5. wert
mov a, b
movc a, @a+dptr
mov 02CH, a
inc b

;6. wert
mov a, b
movc a, @a+dptr
mov 02DH, a
inc b

;7. wert
mov a, b
movc a, @a+dptr
mov 02EH, a
inc b

;8. wert
mov a, b
movc a, @a+dptr
mov 02FH, a
inc b

ljmp CALC

calc:
	mov r7, #8d		; init row count with 8, start with first row
	loop_cols:
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
	ajmp display

shift:
	mov 78h, 70h
	mov 79h, 71h
	mov 7Ah, 72h
	mov 7Bh, 73h
	mov 7Ch, 74h
	mov 7Dh, 75h
	mov 7Eh, 76h
	mov 7Fh, 77h

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

display:
	;display new field


;-- Initialisire Zähler (Speicheradressen)--; 
RAND:
        MOV R1, #28h
ANF:
	CJNE R1, #30h, LOOP
	JMP CALC
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


org 40h
table:
; -- erster zustand   00 Pedal
db 00000000b
db 00011000b
db 00110000b
db 00000000b
db 00000000b
db 00001100b
db 00011000b
db 00000000b


; -- erster zustand   01 Kegel
db 01000010b
db 11000011b
db 00100100b
db 00000000b
db 00000000b
db 00100100b
db 11000011b
db 01000010b

; -- erster zustand   10 Unruh(1)
db 00000000b
db 00000000b
db 00001000b
db 00110000b
db 00001100b
db 00010000b
db 00000000b
db 00000000b


; -- erster zustand   11 Strudel
db 00000000b
db 00010100b
db 01010000b
db 00000110b
db 01100000b
db 00001010b
db 00101000b
db 00000000b
END

