org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

;
; Reads a key from the keyboard
; Returns:
;   - al contains the ASCII value of the key pressed
;
get_key:
    xor ah, ah          ; set ah = 0 for reading keystroke
    int 0x16            ; BIOS interrupt for keyboard
    ret

;
; Prints a single character from al to the screen
;
putch:
    push ax
    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10
    pop ax
    ret

main:
    ; setup data segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory

    ; print hello message
    mov si, msg_hello
    call puts

    ; prompt user input
    mov si, msg_prompt
    call puts

    ; read input and print it
    call get_key
    call putch

    hlt

.halt:
    jmp .halt

msg_hello:  db 'Hello! Press any key: ', ENDL, 0
msg_prompt: db 'You pressed: ', 0

times 510-($-$$) db 0
dw 0xAA55
