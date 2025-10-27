%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

; 构建 gdt 及其内部的描述符
GDT_BASE: dd 0x00000000
          dd 0x00000000

CODE_DESC: dd 0x0000FFFF
           dd DESC_CODE_HIGH4

DATA_STACK_DESC: dd 0x0000FFFF
                 dd DESC_DATA_HIGH4

VIDEO_DESC: dd  0x0000B800   ; limit=(0xbffff-0xb8000)/4k=0x7
           dd DESC_VIDEO_HIGH4 ; 此时 dpl 为 0

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1
times 60 dq 0 ; 此处预留 60 个描述符的空位

SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

; 以下是 gdt 的指针，前 2 字节是 gdt 界限，后 4 字节是 gdt 起始地址
gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

loadermsg db '2 loader in real.'

loader_start:
;------------------------------------------------------------
; INT 0x10 功能号:0x13 功能描述:打印字符串
;------------------------------------------------------------
; 输入:
; AH 子功能号=13H
; BH = 页码
; BL = 属性(若 AL=00H 或 01H)
; CX=字符串长度
; (DH, DL)=坐标(行, 列)
; ES:BP=字符串地址
; AL=显示输出方式
; 0—字符串中只含显示字符，其显示属性在 BL 中 显示后，光标位置不变
; 1—字符串中只含显示字符，其显示属性在 BL 中 显示后，光标位置改变
; 2—字符串中含显示字符和显示属性。显示后，光标位置不变
; 3—字符串中含显示字符和显示属性。显示后，光标位置改变
; 无返回值

mov sp, LOADER_BASE_ADDR
mov bp, loadermsg ; ES:BP = 字符串地址
mov cx, 17        ; CX = 字符串长度
mov ax, 0x1301    ; AH = 13, AL = 01h
mov bx, 0x001f    ; 页号为 0(BH=0) 蓝底粉红字(BL=1fh)
mov dx, 0x1800
int 0x10          ; 10h 号中断

; --------------------
; 准备进入保护模式
; --------------------
; 1. 打开 A20
; 2. 加载 GDT
; 3. 将 CR0 的 PE 位置 1




;----------------- 打开 A20 ----------------
in al,0x92
or al,0000_0010B
out 0x92,al

;打印1
mov byte [loadermsg], '1'
mov sp, LOADER_BASE_ADDR
mov bp, loadermsg
mov cx,1
mov ax,0x1301
mov bx,0x001F       ; 页0, 蓝底粉红字
mov dx,0x0000       ; 行0，列0
int 0x10
;----------------- 加载 GDT ----------------
lgdt [gdt_ptr]
mov byte [loadermsg], '2'
mov bp, loadermsg
mov cx,1
mov dx,0x0001       ; 行0，列1
int 0x10

;----------------- CR0 第 0 位置 1 ----------------
mov eax, cr0
or eax, 1
mov cr0, eax

mov byte [gs:4], '3'
mov byte [gs:5], 0x1F

jmp SELECTOR_CODE:p_mode_start ; 刷新流水线


[bits 32]
p_mode_start:

mov ax, SELECTOR_DATA
mov ds, ax
mov es, ax
mov ss, ax
mov esp, LOADER_STACK_TOP

mov ax, SELECTOR_VIDEO
mov gs, ax
nop
nop

mov byte [0xB8000], 'P'
mov byte [0xB8001], 0x1F

call setup_page

sgdt [gdt_ptr]
mov ebx,[gdt_ptr + 2]
or dword [ebx + 0x18 +4],0xc0000000

add dword [gdt_ptr + 2],0xc0000000

add esp,0xc0000000

mov eax,PAGE_DIR_TABLE_POS
mov cr3,eax
lgdt [gdt_ptr]
move byte [gs:160], 'V

jmp $

setup_page:
        mov ecx,3096
        mov esi,0
.clear_page_dir

.create_pde:
        mov eax,PAGE_DIR_TABLE_POS
        add eax,0x1000
        mov ebx,eax

        or eax,PG_US_U | PG_RW_W | PG_P
        mov [PAGE_DIR_TABLE_POS + 0x0],eax
        mov [PAGE_DIR_TABLE_POS + 0xc00],eax
        sub eax,0x1000
        mov [PAGE_DIR_TABLE_POS + 4092],eax
        
        mov ecx,256
        mov esi,0
        mov edx,PG_US_U | PG_RW_W | PG_P
.create_pte
        mov [ebx+esi*4],ebx
        inc esi
        loop.create_pte
        mov eax,PAGE_DIR_TABLE_POS
        add eax,0x2000
        or eax,PG_US_U | PG_RW_W | PG_P
        mov ebx,PAGE_DIR_TABLE_POS
        mov ecx,254
        mov esi,769
.create_kernel_pde:
        mov [ebx+esi*4],eax
        inc esi
        add eax,0x1000
        loop.create_kernel_pde
        ret
