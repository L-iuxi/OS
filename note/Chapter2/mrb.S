; 最小可运行 MBR，直接写显存显示 "MBR"
; 用 nasm 编译： nasm -f bin -o mbr.bin mbr.S
; 再用 dd 写入磁盘： dd if=mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc

org 0x7c00

start:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; 显存地址 0xb8000，文本模式
    mov ax, 0xb800
    mov es, ax
    xor di, di        ; 显存偏移

    ; 显示 'H'
    mov al, 'H'
    mov ah, 0x0f      ; 颜色：白色
    stosw

    ; 显示 'I'
    mov al, 'I'
    mov ah, 0x0f
    stosw


hang:
    jmp hang

times 510-($-$$) db 0
dw 0xaa55

