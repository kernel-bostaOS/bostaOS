#include "string.h"
#include "types.h"
void *memset(void *dest, int value, size_t count) {
    unsigned char *d = dest;
    while(count--) *d++ = (unsigned char)value;
    return dest;
}

char *strcpy(char *dest, const char *src) {
    char *r = dest;
    while((*dest++ = *src++));
    return r;
}

