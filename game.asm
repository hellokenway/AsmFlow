org 100h
jmp start

p1y: dw 100
p2y: dw 100
ball: dw 160, 100		 ; x,y
ball_direction: dw -4, -4
; 8x5 Font (Each number is 5 rows high)
font_0: db 11100000b, 10100000b, 10100000b, 10100000b, 11100000b
font_1: db 01000000b, 01000000b, 01000000b, 01000000b, 01000000b
font_2: db 11100000b, 00100000b, 11100000b, 10000000b, 11100000b
font_3: db 11100000b, 00100000b, 11100000b, 00100000b, 11100000b
font_4: db 10100000b, 10100000b, 11100000b, 00100000b, 00100000b
font_5: db 11100000b, 10000000b, 11100000b, 00100000b, 11100000b
font_6: db 11100000b, 10000000b, 11100000b, 10100000b, 11100000b
font_7: db 11100000b, 00100000b, 00100000b, 00100000b, 00100000b
font_8: db 11100000b, 10100000b, 11100000b, 10100000b, 11100000b
font_9: db 11100000b, 10100000b, 11100000b, 00100000b, 11100000b

font_table: 
	dw font_0, font_1, font_2, font_3, font_4, font_5, font_6, font_7, font_8, font_9

p1_score: dw 0
p2_score: dw 0
buffer_seg: dw 0
start:
	mov ax, 0013h
	int 10h

	mov ax, cs
	add ax, 0x1000
	mov [buffer_seg], ax

	mov ax, 0A000h
	mov es, ax


game_loop:
	call clear_screen
	call move_ball
	call p1_rect
	call p2_rect
	call draw_ball
	call update_score
	mov ah, 1
	int 16h
	jz continue   ; jump if a key is not available
	call key_pressed
continue:	
	call swap_buffer
	call wait_vsync
	jmp game_loop


swap_buffer:
	; copy back buffer to screen
	push ds
	push es
	push si
	push di

	mov ds,[buffer_seg]
	xor si, si

	mov ax, 0A000h
	mov es, ax
	xor di, di

	mov cx, 32000
	cld
	rep movsw

	pop di
	pop si
	pop es
	pop ds
	ret

p1_rect:
	push 0fh
	mov ax,10
	push 10
	push [p1y]
	push 10
	push 30
	call drawRect
	ret
p2_rect:
	push 0fh
	push 300
	push [p2y]
	push 10
	push 30
	call drawRect
	ret

key_pressed:
	push ax
	mov ah, 0
	int 16h
	cmp al, 'w'
	je paddle_up_1
	cmp al, 's'
	je paddle_down_1
	cmp al, 'k'
	je paddle_up_2
	cmp al, 'j'
	je paddle_down_2
	cmp al,'q'
	je done
key_done:
	pop ax
	ret

paddle_up_1:
	sub word [p1y] , 8
	cmp word [p1y],0
	jg key_done
	mov word [p1y], 0
	jmp key_done
paddle_down_1:
	add word [p1y] , 8
	cmp word [p1y], 169
	jl key_done
	mov word [p1y], 169
	jmp key_done
paddle_up_2:
	sub word [p2y] , 8
	cmp word [p2y],0
	jg key_done
	mov word [p2y], 0
	jmp key_done
paddle_down_2:
	add word [p2y] , 8
	cmp word [p2y], 169
	jl key_done
	mov word [p2y], 169
	jmp key_done

	push ax
	pop ax
	ret
done:
	; Restore text mode
	mov ax, 0003h
	int 10h

	mov ax, 4C00h
	int 21h


move_ball:
    push ax
    push bx
    push cx
    push dx

    mov ax, [ball]          ; ball X
    mov bx, [ball+2]        ; ball Y

    add ax, [ball_direction]
    add bx, [ball_direction+2]

    ; ball left < p1_right (10 + 10 = 20) AND ball right > p1_left (10)
    cmp ax, 20              
    jg .check_p2            ; too far right to hit P1
    mov cx, ax
    add cx, 5               ; ball right
    cmp cx, 10
    jl .check_p1_miss       ; too far left (might be a miss)

    ; rf x overlaps, check y overlap
    ; ball bottom > p1_top AND ball top < p1_bottom (p1y + 30)
    mov dx, bx
    add dx, 5               ; ball bottom
    cmp dx, [p1y]
    jl .check_p2            ; ball is above paddle
    mov dx, [p1y]
    add dx, 30              ; paddle bottom
    cmp bx, dx
    jg .check_p2            ; ball is below paddle
    
    ; collision confirmed with p1
    mov ax, 21              ; place ball just outside paddle
    neg word [ball_direction]
    jmp .save_coords

.check_p1_miss:
    cmp ax, 0
    jl .reset_ball          ; ball went off left screen
    jmp .check_p2

    ;check collision with player 2
.check_p2:
    mov cx, ax
    add cx, 5
    cmp cx, 300
    jl .check_y_bounds
    cmp ax, 310
    jg .check_p2_miss

    ; Check Y overlap
    mov dx, bx
    add dx, 5
    cmp dx, [p2y]
    jl .check_y_bounds
    mov dx, [p2y]
    add dx, 30
    cmp bx, dx
    jg .check_y_bounds

    mov ax, 294
    neg word [ball_direction]
    jmp .save_coords

.check_p2_miss:
    cmp cx, 319
    jg .reset_ball
    jmp .check_y_bounds

.check_y_bounds:
    cmp bx, 0
    jle .hit_top
    mov dx, bx
    add dx, 5
    cmp dx, 199
    jge .hit_bottom
    jmp .save_coords

.hit_top:
    mov bx, 1
    neg word [ball_direction+2]
    jmp .save_coords

.hit_bottom:
	mov bx, 194
	neg word [ball_direction+2]
	jmp .save_coords

.reset_ball:
	mov ax, 160
	mov bx, 100
	cmp word [ball_direction],0
	jg .p1_score_inc
	add word [p2_score], 1
	jmp .score_skip
.p1_score_inc:
	add word [p1_score], 1
.score_skip:
	neg word [ball_direction]

.save_coords:
    mov [ball], ax
    mov [ball+2], bx

    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_ball:
	push 0fh
	push [ball]
	push [ball+2]
	push 5
	push 5
	call drawRect
	ret

drawPixel:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push di
	push es

	cmp word [bp+6], 319
	ja .skip
	cmp word [bp+4], 199
	ja .skip

	mov es, [buffer_seg]
	mov cx,[bp+8]
	mov ax, [bp+4]
	shl ax, 6           ; y*64
	mov bx, [bp+4]
	shl bx, 8           ; y*256
	add ax, bx          ; y*320
	add word ax, [bp+6] ; +x
	mov di, ax
	mov byte [es:di], cl


.skip:
	pop es
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6

drawDigit:	;bp+10=address,bp+8=color, bp+6 = x, bp+4=y
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov cx,[bp+6]
	xor di,di
	mov si,[bp+10]
.out_loop:
	xor ax,ax
	mov ax,[si]
	add si,1
	mov bx,3
	mov word [bp+6], cx
.inner_loop:
		shl al, 1
		jnc .skip_digit
		push [bp+8]
		push [bp+6]
		push [bp+4]
		push 4
		push 2
		call drawRect
	.skip_digit:
		add word [bp+6], 4
		dec bx
		jnz .inner_loop
	add word [bp+4], 2
	inc di
	cmp di,5
	jl .out_loop

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8

drawRect:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx

	mov ax, [bp+8]			; y
	mov cx, [bp+4]			; height
	add cx,ax						; y+height
	mov dx, [bp+6]			; width
	add dx, [bp+10]			; x+width
y_loop:
	mov bx, [bp+10]			; x
x_loop:
	push [bp+12]
	push bx
	push ax
	call drawPixel
	inc bx
	cmp bx, dx
	jl x_loop
	inc ax
	cmp ax, cx
	jl y_loop

	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10
reset_score:
	mov word [p1_score],0
	mov word [p2_score],0
	ret
update_score:
	pusha
	mov bx, [p1_score]
	cmp bx,9
	jle .skip_p1_score
	call reset_score
	.skip_p1_score:
		shl bx,1
		push [font_table+bx]
		push 0fh
		push 100
		push 20
		call drawDigit

	mov bx, [p2_score]
	cmp bx,9
	jle .skip_p2_score
	call reset_score
	.skip_p2_score:
		shl bx,1

		push [font_table+bx]
		push 0fh
		push 200
		push 20
		call drawDigit
	popa
	ret

clear_screen:
	push ax
	push cx
	push di
	push es

	mov es, [buffer_seg]
	xor di,di
	xor ax, ax
	mov cx, 32000
	cld
	rep stosw

	pop es
	pop di
	pop cx
	pop ax
	ret

wait_vsync:
	push ax
	push dx

	mov dx, 03DAh        ; VGA Input Status Register #1

	.wait_not_retrace:
		in al, dx
		test al, 8           ; bit 3 = vertical retrace
		jnz .wait_not_retrace

	.wait_retrace:
		in al, dx
		test al, 8
		jz .wait_retrace

		pop dx
		pop ax
		ret