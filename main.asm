org 100h

section .data
    msg db "MANIM ASSEMBLY", 0

section .text
    call set_vga

    ; 1. Animate Text
    mov dl, 13
    mov dh, 5
    mov bl, 15
    mov si, msg
    call draw_text_anim

    ; 2. Animate Circle
    mov cx, 160
    mov dx, 100
    mov si, 40
    mov bl, 10
    call draw_circle_anim

    ; Wait for key
    xor ah, ah
    int 16h

    call set_text
    mov ax, 0x4C00
    int 21h

%include "main_lib.asm"