const char scancode_table[128] = {
    0, 27, '1','2','3','4','5','6','7','8','9','0','-','=', '\b',
    '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',
    0, 'a','s','d','f','g','h','j','k','l',';','\'','`',
    0,'\\','z','x','c','v','b','n','m',',','.','/', 0,
    '*', 0,' '
};
char scan();

char input() {
    unsigned char code = scan();   // ler scancode pelo ASM

    if (code < 128)
        return scancode_table[code];

    return 0;
}


void input_string(char *buf, int max) {
    int i = 0;

    while (1) {
        char c = input();   // ASCII

        // Enter → termina a string
        if (c == '\n') {
            buf[i] = 0;
            return;
        }

        // ignorar caracteres inválidos
        if (c == 0)
            continue;

        // evitar estourar o buffer
        if (i < max - 1) {
            buf[i++] = c;
        }
    }
}

