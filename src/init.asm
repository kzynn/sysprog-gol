CSEG AT 0H
LJMP start
ORG 100H

; Eingabevektor
EIN1 EQU 20H
START EQU EIN1.0
IN1 EQU EIN1.1
IN2 EQU EIN1.2
INRand EQU EIN1.3

start:
MOV EIN1, P0          ;-- lade P0 nach x020h
Mov C, Start          ;-- lade das 0. Bit in C
JNC loadState         ;-- wenn C 0 ist, beginne mit laden aus der datenbank
SJMP waitOneSconde    ;-- wenn noch nicht gestartet ist warte


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
ljmp startlogic


loadState:
mov DPTR, #table      ;-- set pointer to tabel
;-- setze startwert
JB INRAND, random     ;-- wenn state random
JB IN2, bigger        ;-- wenn state 3 oder 4
JNB IN2, lower        ;-- wenn state 1 oder 2

move:
;1. wert
mov a, b          ; -- lade b in a
movc a, @a+dptr   ;-- kopierer aus dem ram den a-ten eintrag
mov 028H, a       ;-- speicher den a-ten eintrag in den speicher
inc b             ;-- erhöhe b um 1

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

ljmp startlogic


startLogic:


org 300h
table:
db 009H, 0AH, 0BH, 0CH, 0DH, 0EH, 0FH, 1FH ; -- erster zustand   00
db 0A0H, 01H, 02H, 03H, 04H, 05H, 06H, 01H ; -- zweiter zustand  01
db 0B0H, 01H, 02H, 03H, 04H, 05H, 06H, 01H ; -- dritter zustand  10
db 0C0H, 01H, 02H, 03H, 04H, 05H, 06H, 01H ; -- vierter zustand  11

END
