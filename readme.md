; ==========================================
; ANIMLIB.ASM - The Foundation
; ==========================================

; ------------------------------------------
; Function: set_vga
; Switches the screen to 320x200 graphics mode
; ------------------------------------------
set_vga:
    mov ah, 00h     ; Set video mode command
    mov al, 13h     ; Mode 13h (VGA 320x200, 256 colors)
    int 10h         ; Call BIOS
    ret

; ------------------------------------------
; Function: set_text
; Restores the standard DOS text mode
; ------------------------------------------
set_text:
    mov ah, 00h
    mov al, 03h     ; Mode 3 (standard 80x25 text)
    int 10h
    ret

; ------------------------------------------
; Function: clear_screen
; Fills the screen with black (color 0)
; ------------------------------------------
clear_screen:
    pusha           ; Save all registers
    push es         
    
    mov ax, 0A000h  ; Point ES to VGA memory
    mov es, ax
    xor di, di      ; Start at pixel 0 (top left)
    
    mov cx, 32000   ; 320 * 200 pixels = 64,000 bytes. We write 2 bytes at a time, so 32,000 loops
    xor ax, ax      ; Set AX to 0 (Black pixels)
    rep stosw       ; Rapidly write AX to ES:DI, CX times!
    
    pop es
    popa            ; Restore registers
    ret

; ------------------------------------------
; Function: draw_pixel
; Inputs: CX = X coordinate, DX = Y coordinate, BL = Color (0-255)
; ------------------------------------------
draw_pixel:
    pusha
    push es

    mov ax, 0A000h  
    mov es, ax

    ; Math: Offset = (Y * 320) + X
    mov ax, 320
    mul dx          ; AX = Y * 320
    add ax, cx      ; AX = (Y * 320) + X
    mov di, ax      ; DI is our memory destination

    mov [es:di], bl ; Write the color to the screen!

    pop es
    popa
    ret

; ------------------------------------------
; Function: delay
; Inputs: CX:DX = microseconds to wait
; ------------------------------------------
delay:
    pusha
    mov ah, 86h     ; BIOS Wait function
    int 15h         
    popa
    ret