org 100h


mov ax, 13h
int 10h
mov ax, 0A000h
mov es, ax

draw_loop:
   
    mov ax, [py]
    mov bx, 320
    mul bx
    add ax, [px]
    mov di, ax

   
    mov byte [es:di], 15

   
    mov ah, 00h
    int 16h

  
    mov byte [es:di], 0

   
    cmp ah, 48h
    je move_up
    cmp ah, 50h 
    je move_down
    cmp ah, 4Bh 
    je move_left
    cmp ah, 4Dh 
    je move_right
    cmp al, 1Bh 
    je quit
    jmp draw_loop 

move_up:    dec word [py]
            jmp draw_loop
move_down:  inc word [py]
            jmp draw_loop
move_left:  dec word [px]
            jmp draw_loop
move_right: inc word [px]
            jmp draw_loop

quit:
    mov ax, 03h ; Back to text mode
    int 10h
    ret         ; Exit program

px dw 160
py dw 100
