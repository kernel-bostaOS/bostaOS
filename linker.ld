ENTRY(start)

SECTIONS
{
    . = 0x10000;    /* Endereço de carregamento do kernel */
    
    .text : {
        *(.text)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
