                                ;主引导程序
                                ;----------
%include "boot.inc"
 
                                ;SECTION MBR vstart=0x7c00
bits 16
org 0x7c00
mov ax, cs
mov ds, ax
mov es, ax
mov ss, ax
mov fs, ax
mov sp, 0x7c00
mov ax, 0xb800
mov gs, ax

mov ax, 0600h
mov bx, 0700h
mov cx, 0      
mov dx, 184fh  

int 10h
mov byte [gs:0x00],'1'
mov byte [gs:0x01],0xA4  

mov byte [gs:0x02],' '
mov byte [gs:0x03],0xA4

mov byte [gs:0x04],'M'
mov byte [gs:0x05],0xA4

mov byte [gs:0x06],'B'
mov byte [gs:0x07],0xA4

mov byte [gs:0x08],'R'
mov byte [gs:0x09],0xA4

mov eax,LOADER_START_SECTOR         ;起始扇区lba地址
mov bx,LOADER_BASE_ADDR             ;写入的地址
mov cx,4                           ;待读入的扇区数
call rd_disk_m_16                   ;以下读取程序的起始部分，call入栈指令地址

jmp LOADER_BASE_ADDR + 0x300

rd_disk_m_16:

mov esi,eax                         ;备份数据
mov di,cx

mov dx,0x1f2                        ;1.选择特定通道的寄存器
mov al,cl                       
out dx,al

mov eax,esi             

mov dx,0x1f3                         ;2.在特定通道寄存器中放入要读取的扇区地址
out dx,al

mov cl,8                            ;以下为将lba地址写入dx中的端口，每次写完并右移cx（8位）
shr eax,cl
mov dx,0x1f4
out dx,al

shr eax,cl
mov dx,0x1f5
out dx,al

shr eax,cl
and al,0x0f
or al,0xe0
mov dx,0x1f6
out dx,al

mov dx,0x1f7                            ;3.向0x1f7写入0x20命令
mov al,0x20
out dx,al

not_ready:                              ;4.检查硬盘状态
nop                                     ;空转
in al,dx                                ;读取statu寄存器，判断硬盘状态，第四位为1表示准备好了，第七位为一表示忙
and al,0x88
cmp al,0x08
jnz not_ready

mov ax,di                               ;5.从0x1f0读数据
mov dx,256                              ;di存储的是要读取的扇区数
mul dx
mov cx,ax

mov dx,0x1f0
go_on_read:
in ax,dx
mov [bx],ax
add bx,2
loop go_on_read
ret

times 510-($-$$) db 0
db 0x55,0xaa