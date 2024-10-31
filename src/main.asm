%define ENDL 0x0D, 0x0A
%define ENTER_KEY 0x0D

org 0x7C00
bits 16

start:
    jmp main

puts:
    push si
    push ax

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; BIOS interrupt for teletype output
    mov bh, 0           ; Set page number to 0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret

get_key:
    xor ah, ah
    int 0x16            ; BIOS interrupt to get key press
    ret

putch:
    push ax
    mov ah, 0x0E        ; BIOS teletype interrupt
    int 0x10            ; Display character in AL
    pop ax
    ret

clear_screen:
    mov ah, 0x06        ; BIOS scroll function
    mov al, 0           ; Clear entire screen
    mov bh, 0x07        ; Text attribute (white on black)
    mov cx, 0           ; Upper left corner of screen (0, 0)
    mov dx, 0x184F      ; Lower right corner of screen (80x25)
    int 0x10            ; Call BIOS
    ret

getline:
    push di
    mov cx, 0                ; Initialize the character count

.read_loop:
    call get_key             ; Get a key press from BIOS
    cmp al, ENTER_KEY        ; Check if Enter is pressed
    je .done                 ; If Enter, finish input

    stosb                    ; Store the character in the buffer
    call putch               ; Display the character on the screen
    inc cx                   ; Increment the character count
    jmp .read_loop           ; Continue reading input

.done:
    mov al, 0                ; Null-terminate the input string
    stosb
    pop di
    ret

compare_input:
    ; Compare DI (user input) with SI (expected string)
    push si
    push di

.compare_loop:
    lodsb                   ; Load character from SI into AL
    scasb                   ; Compare AL with byte at DI
    jne .not_equal          ; If not equal, jump
    test al, al             ; Check if end of string (null terminator)
    jz .equal               ; If so, strings are equal
    jmp .compare_loop       ; Continue comparison

.equal:
    mov ax, 1               ; Set AX to 1 for equal
    jmp .end_compare

.not_equal:
    mov ax, 0               ; Set AX to 0 for not equal

.end_compare:
    pop di
    pop si
    ret

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print welcome message
    mov si, msg_welcome
    call puts

.loop_input:
    ; Print prompt (on a new line)
    mov ah, 0x0E            ; BIOS teletype interrupt
    mov al, 0x0D            ; Print carriage return (newline)
    int 0x10
    mov al, 0x0A            ; Print line feed (newline)
    int 0x10

    mov si, msg_prompt
    call puts

    ; Capture input from the user
    mov di, input_buffer
    call getline          ; Capture input from the user

    ; Check if user typed "clear"
    mov si, cmd_clear
    mov di, input_buffer
    call compare_input

    cmp ax, 1              ; Check if strings were equal
    je .clear_screen       ; Jump to clear screen if match found

    ; Repeat input
    jmp .loop_input

.clear_screen:
    call clear_screen
    jmp .loop_input        ; Go back to input loop after clearing

msg_welcome:     db 'Welcome to My OS!', ENDL, 0
msg_prompt:      db 'Type something: ', 0
cmd_clear:       db 'clear', 0
input_buffer:    times 64 db 0

times 510-($-$$) db 0
dw 0xAA55
