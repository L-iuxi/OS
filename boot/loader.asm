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

                                                ;打印1，调试
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
                                                ;打印2
                                                ;mov byte [loadermsg], '2'
                                                ;mov bp, loadermsg
                                                ;mov cx,1
                                                ;mov dx,0x0001       ; 行0，列1
                                                ;int 0x10

;----------------- CR0 第 0 位置 1 ---------------- 
mov eax, cr0
or eax, 1
mov cr0, eax
                                                ;打印3
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
                                        ;call print_total_mem 查看内存大小函数
    mov ax, SELECTOR_VIDEO
    mov gs, ax
                                        ;mov byte [gs:0xA0], 'G'
                                        ;jmp $
                                        ;这里的显存有问题，gs寄存器指向的位置不对导致无法通过偏移打印



call setup_page


;sgdt [gdt_ptr]
mov ebx,[gdt_ptr + 2]
or dword [ebx + 0x18 +4],0xc0000000

add dword [gdt_ptr + 2],0xc0000000

add esp,0xc0000000

mov eax,PAGE_DIR_TABLE_POS
mov cr3,eax

mov eax, cr0                           ;打开cr0的pg位
or eax, 0x80000000
mov cr0,eax

lgdt [gdt_ptr]

mov byte [gs:160], 'V'
;mov byte [0xB8000], 'O'
;mov byte [0xB8001], 0x1F
;mov byte [0xB8002], 'K'
;mov byte [0xB8003], 0x1F

jmp $

                                                ;以下为对内存大小的调试
                                                ;----------------------------------------
                                                ; 函数: print_total_mem
                                                ; 功能: 将 total_mem_bytes 转为十进制字符并打印到屏幕
                                                ; 入口: 无
                                                ;----------------------------------------
                                                print_total_mem:
                                                mov eax,[total_mem_bytes]  ; eax = 内存字节数
                                                mov ecx,0                   ; 字符计数
                                                mov esi,0                   ; 用于保存字符个数

                                                cmp eax,0
                                                jne .convert_loop
                                                ; 如果内存为0
                                                mov dl,'0'
                                                mov [str_buffer],dl
                                                mov ecx,1
                                                jmp .print_chars

                                                .convert_loop:
                                                xor edx,edx
                                                mov ebx,10
                                                div ebx                     ; eax/10，余数在dl
                                                add dl,'0'                  ; 转为ASCII
                                                push dx
                                                inc esi
                                                test eax,eax
                                                jnz .convert_loop

                                                .print_chars:
                                                mov edi,0xB8000             ; 显存地址，行0列0
                                                mov bx,0x0F                 ; 属性: 白底黑字
                                                .print_loop:
                                                pop dx
                                                mov [edi],dl                ; 字符
                                                inc edi
                                                mov [edi],bl                ; 属性
                                                inc edi
                                                dec esi
                                                jnz .print_loop
                                                ret

                                                str_buffer times 12 db 0        ; 保存数字字符串，最大支持 12 位
                                                ;以上函数用于调试打印查看内存大小，打印结果为33554432，转换后为32MB


setup_page:                                     ;创建页目录及页表
        mov ecx,4096
        mov esi,0

.clear_page_dir:
        mov byte [PAGE_DIR_TABLE_POS + esi],0
        inc esi
        loop .clear_page_dir

.create_pde:                                    ;初始化页目录表，0号项与768号项指向同一页表
        mov eax,PAGE_DIR_TABLE_POS
        add eax,0x1000
        mov ebx,eax

        or eax,PG_US_U | PG_RW_W | PG_P
        mov [PAGE_DIR_TABLE_POS + 0x0],eax
        mov [PAGE_DIR_TABLE_POS + 0xc00],eax
        sub eax,0x1000
        mov [PAGE_DIR_TABLE_POS + 4092],eax     ;使最后一个页目录项指向页目录表自己的地址
        
        mov eax,0
        mov ecx,256                             ;初始化第一个页表 
        mov esi,0
        mov edx,PG_US_U | PG_RW_W | PG_P
.create_pte:
        mov [ebx+esi*4],ebx
        add edx,4096
        inc esi
        loop .create_pte

        mov eax,PAGE_DIR_TABLE_POS               ;初始化769号——1022号
        add eax,0x2000
        or eax,PG_US_U | PG_RW_W | PG_P
        mov ebx,PAGE_DIR_TABLE_POS
        mov ecx,254
        mov esi,769
.create_kernel_pde:
        mov [ebx+esi*4],eax                     ;设置页目录表项
         add eax,0x1000
        inc esi
       
        loop .create_kernel_pde                  ;循环设定254个页目录表项
        
        ret
