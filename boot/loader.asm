%include "boot.inc"

;本代码现在实现的内容有 1.初始化gdt 2.查看内存 3.打开保护模式
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

                                        ; 构建 gdt 及其内部的描述符
GDT_BASE: 
        dd 0x00000000
        dd 0x00000000

CODE_DESC: 
        dd 0x0000FFFF
        dd DESC_CODE_HIGH4

DATA_STACK_DESC:
        dd 0x0000FFFF
        dd DESC_DATA_HIGH4

VIDEO_DESC: 
        dd  0x0000B800    ; limit=(0xbffff-0xb8000)/4k=0x7
        dd DESC_VIDEO_HIGH4          ; 此时 dpl 为 0

        GDT_SIZE equ $ - GDT_BASE
        GDT_LIMIT equ GDT_SIZE - 1
        times 60 dq 0                           ; 此处预留 60 个描述符的空位

        SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0
        SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0
        SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

total_mem_bytes dd 0                    ;用于保存计算出来的内存容量

                                        ; 以下是 gdt 的指针，前 2 字节是 gdt 界限，后 4 字节是 gdt 起始地址
gdt_ptr dw GDT_SIZE - 1
        dd GDT_BASE

ards_buf times 244 db 0                 ;人工对齐
ards_nr dw 0                            ;用于记录ards结构体数量

;loadermsg db '2 loader in real.'

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

                                        ;mov sp, LOADER_BASE_ADDR
                                        ;mov bp, loadermsg ; ES:BP = 字符串地址
                                        ;mov cx, 17        ; CX = 字符串长度
                                        ;mov ax, 0x1301    ; AH = 13, AL = 01h
                                        ;mov bx, 0x001f    ; 页号为 0(BH=0) 蓝底粉红字(BL=1fh)
                                        ;mov dx, 0x1800
                                        ;int 0x10          ; 10h 号中断

                                        ;========int 15 h eax = 0000E820h,edx = 534D4150h ('SMAP')获取内存布局

xor ebx,ebx                             ;寄存器自异或以清0，第一次调用时，ebx要为0
mov edx,0x534d4150
mov di,ards_buf
.e820_mem_get_loop:                     ;循环获取每个ards内存范围描述结构
        mov eax,0x0000e820
        mov ecx,20
        int 0x15
        add di,cx
        inc word [ards_nr]              ;记录ards数量
        cmp ebx,0                       ;若ebx为0,cf不为1,说明ards全部返回
        jnz .e820_mem_get_loop

        mov cx,[ards_nr]
        mov ebx,ards_buf
        xor edx,edx
.find_max_mem_area:
        mov eax,[ebx]
        add eax,[ebx+8]
        add ebx,20
        cmp edx,eax                     ;冒泡排序，找出最大，edx寄存器是最大内存容量
        jge .next_ards                  ;若大于等于则下一次循环，否则不会执行此条指令
        mov edx,eax                     ;edx为总内存大小

.next_ards:
        loop .find_max_mem_area

        mov [total_mem_bytes],edx


; --------------------
; 准备进入保护模式
; --------------------
; 1. 打开 A20
; 2. 加载 GDT
; 3. 将 CR0 的 PE 位置 1




;----------------- 打开 A20 ----------------
in al, 0x92
or al, 0x02
out 0x92, al

;打印1
;mov byte [loadermsg], '1'
;mov sp, LOADER_BASE_ADDR
;mov bp, loadermsg
;mov cx,1
;mov ax,0x1301
;mov bx,0x001F       ; 页0, 蓝底粉红字
;mov dx,0x0000       ; 行0，列0
;int 0x10
;----------------- 加载 GDT ----------------
mov dword [gdt_ptr+2], GDT_BASE
mov word  [gdt_ptr],   GDT_LIMIT

lgdt [gdt_ptr]
;mov byte [loadermsg], '2'
;mov bp, loadermsg
;mov cx,1
;mov dx,0x0001       ; 行0，列1
;int 0x10

;----------------- CR0 第 0 位置 1 ----------------
mov eax, cr0
or eax, 1
mov cr0, eax

;mov byte [gs:4], '3'
;mov byte [gs:5], 0x1F

jmp SELECTOR_CODE:p_mode_start ; 刷新流水线

.error_hlt:
 hlt

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax
    mov byte [gs:0xA0], 'G'
    jmp $


;call setup_page


;sgdt [gdt_ptr]
;;mov ebx,[gdt_ptr + 2]
;or dword [ebx + 0x18 +4],0xc0000000

;add dword [gdt_ptr + 2],0xc0000000

;add esp,0xc0000000

;mov eax,PAGE_DIR_TABLE_POS
;mov cr3,eax
;lgdt [gdt_ptr]
;mov byte [gs:160], 'V'

;jmp $


