BUILD_DIR = ./build
ENTRY_POINT = 0xc0001500
AS = nasm
CC = gcc -m32
LD = ld -m elf_i386
LIB = -I include/kernel/ -I include/lib/ -I kernel/ -I device/ -I include/device -I include/thread
ASFLAGS = -f elf
CFLAGS = -m32 -Wall -fno-builtin -fno-stack-protector -W -Wstrict-prototypes -Wmissing-prototypes $(LIB) -c
LDFLAGS = -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map

OBJS = \
$(BUILD_DIR)/main.o \
$(BUILD_DIR)/init.o \
$(BUILD_DIR)/interrupt.o \
$(BUILD_DIR)/time.o \
$(BUILD_DIR)/kernel.o \
$(BUILD_DIR)/print.o \
$(BUILD_DIR)/debug.o \
$(BUILD_DIR)/bitmap.o \
$(BUILD_DIR)/string.o \
$(BUILD_DIR)/memory.o \
$(BUILD_DIR)/thread.o \
$(BUILD_DIR)/list.o \
$(BUILD_DIR)/switch.o \
$(BUILD_DIR)/console.o \
$(BUILD_DIR)/sync.o \
$(BUILD_DIR)/keyboard.o \
$(BUILD_DIR)/ioqueue.o


.PHONY: all mk_dir build clean

all: mk_dir build

mk_dir:
	if [ ! -d $(BUILD_DIR) ]; then mkdir -p $(BUILD_DIR); fi

# C 文件编译
$(BUILD_DIR)/main.o: kernel/main.c include/lib/print.h include/kernel/init.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/init.o: kernel/init.c include/kernel/init.h include/lib/print.h include/stdint.h include/kernel/interrupt.h include/device/time.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/interrupt.o: kernel/interrupt.c include/kernel/interrupt.h include/stdint.h include/kernel/global.h include/kernel/io.h include/lib/print.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/time.o: device/time.c include/device/time.h include/stdint.h include/kernel/io.h include/lib/print.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/debug.o: kernel/debug.c include/kernel/debug.h include/lib/print.h include/stdint.h include/kernel/interrupt.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/string.o:lib/string.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/bitmap.o:lib/bitmap.c include/lib/string.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/memory.o:kernel/memory.c include/lib/string.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/thread.o:thread/thread.c include/thread/thread.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/list.o:kernel/list.c include/kernel/list.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/console.o:device/console.c include/device/console.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/sync.o:thread/sync.c include/thread/sync.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/keyboard.o:device/keyboard.c include/device/keyboard.h
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/ioqueue.o:device/ioqueue.c include/device/ioqueue.h
	$(CC) $(CFLAGS) -o $@ $<
# 汇编文件编译
$(BUILD_DIR)/kernel.o: kernel/kernel.asm
	$(AS) $(ASFLAGS) $< -o $@
$(BUILD_DIR)/print.o: lib/print.asm
	$(AS) $(ASFLAGS) $< -o $@
$(BUILD_DIR)/switch.o:thread/switch.asm
	$(AS) $(ASFLAGS) -o $@ $<
# 链接生成 kernel.bin
$(BUILD_DIR)/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

build: $(BUILD_DIR)/kernel.bin

clean:
	rm -rf $(BUILD_DIR)
