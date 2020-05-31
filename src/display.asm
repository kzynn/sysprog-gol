; -------------------
; Display saved field from 0x10 to 0x17
;
; P1: data of row
; P2: number of row to display (00000100 means third row)
;
; pixel lights up when row and column are 1
; -------------------

; dummy data
MOV 0x10, #00011000B
MOV 0x11, #00100100B
MOV 0x12, #01000010B
MOV 0x13, #10000001B
MOV 0x14, #01000010B
MOV 0x15, #00100100B
MOV 0x16, #00011000B
MOV 0x17, #00000000B

init:
mov R2, #001H ; Set row number to 1
MOV R0, #010H ; Address of first row

display:
mov P2, R2
mov A, @R0
mov P1, A
inc R0

; All pixels off
mov P2, #0H
mov P1, #0H

; calculate next row number
MOV A, R2
MOV B, #02h
MUL AB
MOV R2, A

JNZ display
call init
