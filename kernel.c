// Funções básicas de I/O para o kernel
// Função para ler uma string do input (versão simplificada)
#include "../system/io.h"
#include "../system/string.h"
void print_char(char c) {
    // Imprimir caractere na tela (modo texto VGA)
    volatile char* video_memory = (volatile char*)0xB8000;
    static int cursor_pos = 0;
    
    if (c == '\n') {
        cursor_pos += 80 - (cursor_pos % 80);
    } else {
        video_memory[cursor_pos * 2] = c;
        video_memory[cursor_pos * 2 + 1] = 0x07; // Cor: cinza claro em preto
        cursor_pos++;
    }
    
    // Scroll se necessário
    if (cursor_pos >= 80 * 25) {
        // Implementar scroll básico
        for (int i = 0; i < 80 * 24 * 2; i++) {
            video_memory[i] = video_memory[i + 80 * 2];
        }
        for (int i = 80 * 24 * 2; i < 80 * 25 * 2; i += 2) {
            video_memory[i] = ' ';
            video_memory[i + 1] = 0x07;
        }
        cursor_pos = 80 * 24;
    }
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

// Declarações antecipadas (protótipos)
unsigned char inb(unsigned short port);
char scancode_to_ascii(unsigned char scancode);

char get_char_simulated(void) {
    // Verifica se há tecla disponível
    while ((inb(0x64) & 0x01) == 0) {
        // Espera até que uma tecla esteja disponível
        asm volatile("pause");
    }
    
    // Lê o scancode do teclado
    unsigned char scancode = inb(0x60);
    
    // Converte scancode para caractere ASCII
    return scancode_to_ascii(scancode);
}

// Implementação da função inb
unsigned char inb(unsigned short port) {
    unsigned char result;
    asm volatile("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

// Tabela de conversão básica de scancode para ASCII
char scancode_to_ascii(unsigned char scancode) {
    // Tabela básica - apenas teclas comuns
    static const char scancode_table[128] = {
        0,   0,   '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 
        '-', '=', 0,   0,   'q', 'w', 'e', 'r', 't', 'y', 'u', 'i',
        'o', 'p', '[', ']', '\n', 0,   'a', 's', 'd', 'f', 'g', 'h',
        'j', 'k', 'l', ';', '\'', '`', 0,   '\\', 'z', 'x', 'c', 'v',
        'b', 'n', 'm', ',', '.', '/', 0,   '*', 0,   ' ', 0,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,   0,   0
    };
    
    // Ignora key-up events (bit 7 setado)
    if (scancode & 0x80) {
        return 0;
    }
    
    // Retorna o caractere correspondente
    if (scancode < sizeof(scancode_table)) {
        return scancode_table[scancode];
    }
    
    return 0;
}
void input_stringer(char* buffer, int max_length) {
    int pos = 0;
    char c;
    
    // Mostrar prompt
    print_string("> ");
    
    while (pos < max_length - 1) {
        // Em sistema real, aqui leríamos da porta do teclado
        // Por enquanto, simula entrada com valores fixos
        c = get_char_simulated();
        
        if (c == '\n' || c == '\r') { // Enter
            print_char('\n');
            buffer[pos] = '\0';
            return;
        } else if (c == '\b') { // Backspace
            if (pos > 0) {
                pos--;
                print_char('\b');
                print_char(' ');
                print_char('\b');
            }
        } else if (c >= 32 && c <= 126) { // Caracteres ASCII imprimíveis
            if (pos < max_length - 1) {
                print_char(c);
                buffer[pos] = c;
                pos++;
            }
        }
        // Ignorar outros caracteres especiais
    }
    
    // Garantir que a string termina com null
    buffer[max_length - 1] = '\0';
}

// Função simulada para obter caractere (substituir por leitura real do teclado)

// --- ATA PIO (lê/escreve HD IDE/QEMU) ---

// Espera o disco ficar pronto

// Função principal do kernel
// Função principal do kernel
void kmain(void) {
    // Limpar tela
    volatile char* video_memory = (volatile char*)0xB8000;
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video_memory[i] = ' ';
        video_memory[i + 1] = 0x07;
    }
    

    run();
    
    
}      
