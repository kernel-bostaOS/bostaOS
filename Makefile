# Makefile para Sistema Operacional
# Configurações
ASM=nasm
CC=gcc
LD=ld
CFLAGS=-ffreestanding -fno-builtin -fno-stack-protector -nostdlib -m32 -I.
LDFLAGS=-m elf_i386 -T src/linker.ld
QEMU=qemu-system-i386
BOOTLOADER_SRC=asm/boot.asm
KERNEL_ENTRY_SRC=asm/kernel_entry.asm
KMAIN_SRC=src/kernel.c
OS_SRC=var/os.c
INPUT_SRC=asm/input.asm
INPUT_OBJ=build/input.o
STRING_SRC = system/string.c
STRING_OBJ = build/string.o


# Arquivos de saída
BOOTLOADER=build/boot.bin
KERNEL_ENTRY=build/kernel_entry.o
KMAIN_OBJ=build/kernel.o
OS_OBJ=build/os.o
KERNEL_ELF=build/elf/kernel.elf
KERNEL_BIN=build/kernel.bin
OS_IMAGE=os.img

# Alvo principal
all: $(OS_IMAGE)

# Gerar imagem do sistema operacional
$(OS_IMAGE): $(BOOTLOADER) $(KERNEL_BIN)
	@echo "Criando imagem do sistema..."
	dd if=/dev/zero of=$(OS_IMAGE) bs=512 count=2880
	dd if=$(BOOTLOADER) of=$(OS_IMAGE) bs=512 count=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(OS_IMAGE) bs=512 seek=1 conv=notrunc

$(INPUT_OBJ): $(INPUT_SRC)
	@echo "Compilando input.asm..."
	$(ASM) -f elf32 $(INPUT_SRC) -o $(INPUT_OBJ)

# Bootloader
$(BOOTLOADER): $(BOOTLOADER_SRC)
	@echo "Compilando bootloader..."
	$(ASM) -f bin $(BOOTLOADER_SRC) -o $(BOOTLOADER)

# Kernel binário
$(KERNEL_BIN): $(KERNEL_ELF)
	@echo "Extraindo código binário do kernel..."
	objcopy -O binary $(KERNEL_ELF) $(KERNEL_BIN)

# Kernel ELF - AGORA INCLUI OS.OBJ
$(KERNEL_ELF): $(KERNEL_ENTRY) $(KMAIN_OBJ) $(OS_OBJ) $(INPUT_OBJ) $(STRING_OBJ)
	@echo "Linkando kernel com input.asm..."
	$(LD) $(LDFLAGS) -o $(KERNEL_ELF) $(KERNEL_ENTRY) $(KMAIN_OBJ) $(OS_OBJ) $(INPUT_OBJ) build/string.o

# Entry point do kernel (assembly)
$(KERNEL_ENTRY): $(KERNEL_ENTRY_SRC)
	@echo "Compilando entry point do kernel..."
	$(ASM) -f elf32 $(KERNEL_ENTRY_SRC) -o $(KERNEL_ENTRY)

# Main do kernel
$(KMAIN_OBJ): $(KMAIN_SRC)
	@echo "Compilando kmain (C)..."
	$(CC) $(CFLAGS) -c $(KMAIN_SRC) -o $(KMAIN_OBJ)
$(STRING_OBJ): $(STRING_SRC) system/string.h
	$(CC) $(CFLAGS) -c system/string.c -o build/string.o
# Sistema operacional (distro)
$(OS_OBJ): $(OS_SRC)
	@echo "Compilando os.c (distro)..."
	$(CC) $(CFLAGS) -c $(OS_SRC) -o $(OS_OBJ)





# Executar no QEMU
run: $(OS_IMAGE)
	@echo "Executando no QEMU..."
	$(QEMU) -drive format=raw,file=$(OS_IMAGE)

# Debug no QEMU
debug: $(OS_IMAGE)
	@echo "Executando em modo debug..."
	$(QEMU) -drive format=raw,file=$(OS_IMAGE) -d guest_errors -no-reboot -no-shutdown -S -s &

# Limpar arquivos gerados
clean:
	@echo "Limpando arquivos..."
	rm -f $(BOOTLOADER) $(KERNEL_ENTRY) $(KMAIN_OBJ) $(OS_OBJ)
	rm -f $(KERNEL_ELF) $(KERNEL_BIN) $(INPUT_OBJ) 


# Limpar tudo (incluindo backups)
distclean: clean
	rm -f *~ *.bak

# Ajuda
help:
	@echo "Targets disponíveis:"
	@echo "  all        - Compila todo o sistema"
	@echo "  run        - Executa no QEMU"
	@echo "  debug      - Executa em modo debug"
	@echo "  clean      - Remove arquivos gerados"
	@echo "  distclean  - Remove tudo + backups"
	@echo "  help       - Mostra esta ajuda"

.PHONY: all run debug clean distclean help
