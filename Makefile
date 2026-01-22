BUILD_DIR = ./build
ENTRY_POINT = 0xc0001500
HD60M_PATH=/home/xfdhm/bochs/hd60M.img
AS = nasm
CC = gcc -m32
LD = ld -m elf_i386
LIB = -I include/kernel/ -I fs/ -I include/fs/ -I command/ -I shell/ -I include/user/ -I lib/user/ -I include/userprog/ -I include/lib/ -I kernel/ -I device/ -I include/device -I include/thread -I include/shell
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
$(BUILD_DIR)/fork.o	\
$(BUILD_DIR)/shell.o \
$(BUILD_DIR)/buildin_cmd.o \
$(BUILD_DIR)/exec.o \
$(BUILD_DIR)/assert.o \
$(BUILD_DIR)/wait_exit.o \
$(BUILD_DIR)/pipe.o  


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
$(BUILD_DIR)/tss.o:userprog/tss.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/process.o:userprog/process.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/syscall.o:lib/user/syscall.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/syscall-init.o:userprog/syscall-init.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/stdio.o:lib/user/stdio.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/stdio-kernel.o:kernel/stdio-kernel.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/ide.o:device/ide.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/fs.o:fs/fs.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/inode.o:fs/inode.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/file.o:fs/file.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/dir.o:fs/dir.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/fork.o:userprog/fork.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/shell.o:shell/shell.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/buildin_cmd.o:shell/buildin_cmd.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/exec.o:userprog/exec.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/assert.o:lib/user/assert.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/wait_exit.o:userprog/wait_exit.c
	$(CC) $(CFLAGS) -o $@ $<
$(BUILD_DIR)/pipe.o:shell/pipe.c
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
# $^表示规则中所有依赖文件的集合，如果有重复，会自动去重

.PHONY:mk_dir hd clean build all boot gdb_symbol	#定义了7个伪目标
mk_dir:
	if [ ! -d $(BUILD_DIR) ];then mkdir $(BUILD_DIR);fi 
#判断build文件夹是否存在，如果不存在，则创建

hd:
	dd if=build/mbr.o of=$(HD60M_PATH) count=1 bs=512 conv=notrunc && \
	dd if=build/loader.o of=$(HD60M_PATH) count=4 bs=512 seek=2 conv=notrunc && \
	dd if=$(BUILD_DIR)/kernel.bin of=$(HD60M_PATH) bs=512 count=200 seek=9 conv=notrunc
	
clean:
	@cd $(BUILD_DIR) && rm -f ./* && echo "remove ./build all done"
#-f, --force忽略不存在的文件，从不给出提示，执行make clean就会删除build下所有文件

build:$(BUILD_DIR)/kernel.bin
#执行build需要依赖kernel.bin，但是一开始没有，就会递归执行之前写好的语句编译kernel.bin

#生成可以被GDB理解的符号表，用于GDB调试
gdb_symbol:
	objcopy --only-keep-debug $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/kernel.sym

all:mk_dir boot build hd gdb_symbol
#make all 就是依次执行mk_dir build hd gdb_symbol