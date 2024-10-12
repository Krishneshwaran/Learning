org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A
%define ENTER_KEY 0x0D
%define BACKSPACE_KEY 0x08

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

;
; Read a line of input into a buffer
; Params:
;   - ds:di points to buffer
;
getline:
    push di
    mov cx, 0           ; character count

.read_loop:
    call get_key        ; get key from user
    cmp al, ENTER_KEY   ; check if Enter is pressed
    je .done            ; if Enter, we're done

    cmp al, BACKSPACE_KEY ; check if Backspace is pressed
    je .backspace

    ; store character in buffer
    stosb               ; store al in buffer
    call putch          ; display character
    inc cx              ; increase character count
    jmp .read_loop

.backspace:
    cmp cx, 0           ; if there's something to delete
    je .read_loop       ; if buffer is empty, ignore
    dec di              ; move pointer back in buffer
    dec cx              ; reduce character count
    mov al, ' '         ; overwrite the character on screen with space
    call putch
    mov al, BACKSPACE_KEY ; move cursor back
    call putch
    jmp .read_loop

.done:
    ; null-terminate the input
    mov al, 0
    stosb
    pop di
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

    ; buffer for user input
    mov di, input_buffer
    call getline

    ; display the typed command
    mov si, msg_you_typed
    call puts
    mov si, input_buffer
    call puts

    hlt

.halt:
    jmp .halt

msg_hello:      db 'Welcome to My OS!', ENDL, 0
msg_prompt:     db 'Type something: ', 0
msg_you_typed:  db ENDL, 'You typed: ', 0

input_buffer:   times 64 db 0         ; buffer for input (64 bytes)

times 510-($-$$) db 0
dw 0xAA55
