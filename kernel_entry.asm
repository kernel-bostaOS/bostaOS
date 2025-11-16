bits 32

global start
extern kmain        ; Função principal do kernel em C

section .text
start:
    ; Configurar stack
    mov esp, kernel_stack + 0x4000
    
    ; Chamar função principal do kernel
    call kmain
    
    ; Loop infinito se o kernel retornar
    jmp $

section .bss
kernel_stack:
    resb 0x4000     ; 16KB de stack
