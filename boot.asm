bits 16
org 0x7C00

start:
    ; Configurar segmentos
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Limpar tela
    mov ax, 0x0003
    int 0x10

    ; Mensagem de inicialização
    mov si, boot_msg
    call print_string

    ; Carregar kernel da memória
    mov si, kernel_msg
    call print_string

    ; Reset disk system
    mov ah, 0x00
    mov dl, 0x80    ; Primeiro disco HD
    int 0x13
    jc disk_error

    ; Configurar parâmetros para o kernel
    mov ax, 0x1000      ; Segmento onde o kernel será carregado
    mov es, ax
    xor bx, bx          ; Offset 0

    ; Carregar setores do kernel
    mov ah, 0x02        ; Função de leitura
    mov al, 4           ; Número de setores para ler
    mov ch, 0           ; Cylinder
    mov cl, 2           ; Setor inicial (setor 1 é o bootloader)
    mov dh, 0           ; Head
    mov dl, 0x80        ; Drive (0x80 = primeiro HD)
    int 0x13

    jc disk_error       ; Se carry flag set, erro no disco

    ; Verificar se leu todos os setores
    cmp al, 4
    jne disk_error

    ; Mudar para modo protegido
    cli
    lgdt [gdt_descriptor]

    ; Ativar modo protegido
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Jump far para código de 32 bits


    jmp CODE_SEG:init_pm

disk_error:
    mov si, error_msg
    call print_string
    mov ah, 0x00
    int 0x16    ; Aguardar tecla
    int 0x19    ; Reiniciar

; Funções 16-bit
print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

; Dados 16-bit
boot_msg    db "Bootloader iniciado...", 0x0D, 0x0A, 0
kernel_msg  db "Carregando kernel...", 0x0D, 0x0A, 0
error_msg   db "Erro no disco! Pressione qualquer tecla...", 0x0D, 0x0A, 0

; GDT (Global Descriptor Table)
gdt_start:
    ; Null descriptor
    dq 0

    ; Code segment descriptor
gdt_code:
    dw 0xFFFF       ; Limit (0-15)
    dw 0x0000       ; Base (0-15)
    db 0x00         ; Base (16-23)
    db 10011010b    ; Flags (P=1, DPL=00, S=1, Type=1010)
    db 11001111b    ; Flags + Limit (16-19)
    db 0x00         ; Base (24-31)

    ; Data segment descriptor
gdt_data:
    dw 0xFFFF       ; Limit (0-15)
    dw 0x0000       ; Base (0-15)
    db 0x00         ; Base (16-23)
    db 10010010b    ; Flags (P=1, DPL=00, S=1, Type=0010)
    db 11001111b    ; Flags + Limit (16-19)
    db 0x00         ; Base (24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Código 32-bit
bits 32
init_pm:
    ; Configurar segmentos de dados
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Configurar pilha
    mov ebp, 0x90000
    mov esp, ebp

    ; Chamar o kernel - CORREÇÃO AQUI
    jmp CODE_SEG:0x10000  ; Em modo protegido, endereço linear

    ; Se retornar, halt
    cli
    hlt




; Preencher bootloader
times 510-($-$$) db 0
dw 0xAA55       ; Boot signature CORRIGIDA
