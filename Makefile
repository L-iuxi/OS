BUILD_DIR = ./build
ENTRY_POINT = 0xc0001500
HD60M_PATH = /home/xfdhm/bochs/hd60M.img

AS = nasm
CC = gcc -m32
LD = ld -m elf_i386

LIB = -I include/kernel/ -I fs/ -I include/fs/ -I command/ -I shell/ \
      -I include/user/ -I lib/user/ -I include/userprog/ -I include/lib/ \
      -I kernel/ -I device/ -I include/device -I include/thread -I include/shell

ASFLAGS = -f elf
CFLAGS  = -m32 -Wall -fno-builtin -fno-stack-protector \
          -W -Wstrict-prototypes -Wmissing-prototypes $(LIB) -c
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
$(BUILD_DIR)/ioqueue.o \
$(BUILD_DIR)/tss.o \
$(BUILD_DIR)/process.o \
$(BUILD_DIR)/syscall.o \
$(BUILD_DIR)/syscall-init.o \
$(BUILD_DIR)/stdio.o \
$(BUILD_DIR)/stdio-kernel.o \
$(BUILD_DIR)/ide.o \
$(BUILD_DIR)/fs.o \
$(BUILD_DIR)/inode.o \
$(BUILD_DIR)/file.o \
$(BUILD_DIR)/dir.o \
$(BUILD_DIR)/fork.o \
$(BUILD_DIR)/shell.o \
$(BUILD_DIR)/buildin_cmd.o \
$(BUILD_DIR)/exec.o \
$(BUILD_DIR)/assert.o \
$(BUILD_DIR)/wait_exit.o \
$(BUILD_DIR)/pipe.o

.PHONY: all mk_dir clean build hd gdb_symbol

all: mk_dir build hd gdb_symbol

mk_dir:
	@if [ ! -d $(BUILD_DIR) ]; then mkdir $(BUILD_DIR); fi

# 链接生成内核
build: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

# 写入虚拟磁盘
hd: $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/mbr.o $(BUILD_DIR)/loader.o
	dd if=$(BUILD_DIR)/mbr.o of=$(HD60M_PATH) count=1 bs=512 conv=notrunc && \
	dd if=$(BUILD_DIR)/loader.o of=$(HD60M_PATH) count=4 bs=512 seek=2 conv=notrunc && \
	dd if=$(BUILD_DIR)/kernel.bin of=$(HD60M_PATH) bs=512 count=200 seek=9 conv=notrunc

# GDB 符号表
gdb_symbol:
	objcopy --only-keep-debug $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/kernel.sym

clean:
	@if [ -d $(BUILD_DIR) ]; then \
		rm -f $(BUILD_DIR)/* && echo "remove ./build all done"; \
	fi
