put_pixel:
    
    pusha
    mov bp, ax
    mov bx, dx
    mov dx, 0A000h
    mov es, dx

    mov ax, 320
    mul bx
    add ax, cx
    mov di, ax

    mov ax, bp
    mov [es:di], al

    popa
    ret


delay:
    pusha
    mov ah, 86h
    int 15h
    popa
    ret


draw_h_line:
    pusha

.h_loop:
    call put_pixel

    push cx
    push dx

    mov cx, 0x0000
    mov dx, 0x2710
    call delay
    pop dx
    pop cx

    inc cx 
    dec bx 
    jnz .h_loop

    popa
    ret


draw_v_line:
    pusha

.v_loop:
    call put_pixel
    push cx
    push dx
    
    mov cx, 0x0000
    mov dx, 0x2710
    call delay
    pop dx
    pop cx
    
    inc dx
    dec bx
    jnz .v_loop
    popa
    ret


draw_square:
    pusha
    mov bp, bx

.sq_y_loop:
    push cx
    push bx
.sq_x_loop:

    call put_pixel
    inc cx
    dec bx
    jnz .sq_x_loop

    push cx
    push dx

    mov cx, 0x0000
    mov dx, 0x4E20  
    call delay 
    pop dx
    pop cx


    pop bx
    pop cx


    
    inc dx 
    dec bp
    jnz .sq_y_loop
    popa
    ret

draw_text_anim:
    pusha

    mov ah, 02h 
    mov bh, 00h
    int 10h  

.print_loop:
    lodsb
    cmp al, 0 
    je .done
    mov ah, 0EH
    int  10h 
    mov cx, 0x0001
    mov dx, 0x86A0
    call delay
    jmp .print_loop

.done:
    popa
    ret





