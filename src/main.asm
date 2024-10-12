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

    ; You can add any processing of the input here if desired

    ; Repeat input
    jmp .loop_input

msg_welcome:     db 'Welcome to My OS!', ENDL, 0
msg_prompt:      db 'Type something: ', 0
input_buffer:    times 64 db 0

times 510-($-$$) db 0
dw 0xAA55
