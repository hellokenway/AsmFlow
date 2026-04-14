org 100h

start:
    mov ax, 0013h
    int 10h 

    mov cx, 50
    mov dx, 30 
    mov bx, 150

    mov al, 9
    call draw_h_line


    mov cx, 250
    mov dx, 40
    mov bx, 100
    call draw_v_line

    mov cx, 100
    mov dx, 70
    mov bx, 40 ;(40x40)
    mov al, 12
    call draw_square 

    mov dh, 20
    mov dl, 15
    mov si, my_string
    call draw_text_anim

    mov ah, 00h
    int 16h

    mov ax, 0003h
    int 10h

    mov ax, 4c00h
    int 21h

my_string db "AsmFlow", 0

%include "library.asm"