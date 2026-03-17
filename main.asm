org 100h

section .data
    msg db "AsmFlow ASSEMBLY", 0

section .text
    call set_vga


    mov dl, 13
    mov dh, 5
    mov bl, 15
    mov si, msg
    call draw_text_anim

  
    mov cx, 160
    mov dx, 100
    mov si, 40
    mov bl, 10
    call draw_circle_anim


    xor ah, ah
    int 16h

    call set_text
    mov ax, 0x4C00
    int 21h

%include "main_lib.asm"