global scan

section .text

scan:
    ; esperar PS/2 ter dado pronto
.wait:
    in   al, 0x64        ; PS/2 status
    test al, 1           ; bit 0 = tem dado
    jz   .wait

    ; ler o scancode
    in   al, 0x60

    ; se for key release (>= 0x80), ignorar
    test al, 0x80
    jnz  scan            ; lê de novo

    ret

