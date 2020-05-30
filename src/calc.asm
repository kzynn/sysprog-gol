; ----------------------
; calc new field
;
; up to date field begins at 70h
; (calc field at 78h)
;
; r7 - row
; r6 - col
; r5 - col bit
; r4 - sum of alive surrounding cells
; ----------------------

cseg at 0h
jmp init

init:
	; init field
	mov 70h, #0h
	mov 71h, #0h
	mov 72h, #30h
	mov 73h, #0h
	mov 74h, #0h
	mov 75h, #0h
	mov 76h, #0h
	mov 77h, #0h
	jmp calc

calc:
	mov r7, #8d		; init row count with 8, start with first row
		loop_cols:
		; loop trough cols
		
			mov r6, #08d	; init col count with 7
			mov r5, #01h	; init col bit with 1
			loop_rows:
				; loop trough rows
				dec r6					; decrement col count
				mov a, r5				; shift col bit
				rr a
				mov r5, a
				mov r4, #0d	; reset curr cell count

				; do things
				call calc_cell
				call set_cell

				;cjne r5, #01h, loop_rows ; end loop if col bit has passed calculation for lowest bit
				cjne r6, #0d, loop_rows ; end loop if r7=colcount reaches 0

		inc r7					 ; increment row count
		cjne r7, #16d, loop_cols ; end loop if r7=rowcount reaches 7
		ajmp display

calc_cell:
	; calc surrounding cells alive
	; row above
	dec r7
	mov a, r5
	rl a
	mov r5, a
	call check_alive
	mov a, r5
	rr a
	mov r5, a
	call check_alive
	mov a, r5
	rr a
	mov r5, a
	call check_alive
	; cells left and right
	inc r7
	call check_alive
	mov a, r5
	rl a
	rl a
	mov r5, a
	call check_alive
	; cells below
	inc r7
	call check_alive
	mov a, r5
	rr a
	mov r5, a
	call check_alive
	mov a, r5
	rr a
	mov r5, a
	call check_alive
	; clean up row and col bit registers
	dec r7
	mov a, r5
	rl a
	mov r5, a
	ret

check_alive:
	; checks if a cell is alive and if so increments r4

	; calc current row offset
	; modulo operation to prevent -1 and 8 as row
	mov a, r7
	mov b, #08d
	div ab 		; calc modulo, result in b register
	mov r1, b	; correct adress now in r1

	mov a, #70h ; start calc adress for curr row
	add a, r1
	mov r0, a
	mov a, @r0	; mov current row in a
	anl a, r5	; and operation for selecting specific cell
	jz skip_if_cell_dead
	inc r4
	skip_if_cell_dead:
	ret

set_cell:
	; check value in r4 and set new value for cell in new field
	mov a, r7 	; move begin of current array in acc
	mov b, #08d
	div ab 		; calc modulo, result in b register
	mov a, b
	add a, #70h
	mov r0, a
	mov a, @r0
	mov r1, a	; move row in r1
	; calc new location
	mov a, r7	; mod because of edge cases
	mov b, #08d
	div ab 		; calc modulo, result in b register
	mov a, b
	add a, #78h
	mov r0, a	; store new memory location in r0

	cjne r4, #03d, cell_is_dead
	; cell is alive
	mov a, @r0
	orl a, r5
	mov @r0, a
	ret
	cell_is_dead:
	mov a, r5
	cpl a		; invert sequence
	mov r2, a	; move inverted to r2
	mov a, @r0
	anl a, r2	; compare with inverted sequence
	mov @r0, a
	ret

display:
	;display new field


