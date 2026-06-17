org 0x0000
bits 16

; ==============================
; XuanWu Kernel 0.0.15 Step2 Base Kernel
; Update Log:
; 1. Replace Ctrl+C with Esc for clear screen
; 2. Add boot delay & blinking movable cursor
; 3. Rename from Pangu Kernel
; 4. Fix bug: ESC clear screen reprint kernel title
; 5. Move all data to file end, add jmp $ to block execution overflow
; 6. Optimize VGA write to eliminate character residual shadow
; 7. Fix special key lost: swap judge order
; 8. v0.0.15 Step1: Add 64-byte input buffer
; 9. v0.0.15 Step2: str_cmp moved to independent command.asm
; ==============================

; 段寄存器配置（boot将内核加载至 0x1000:0000）
mov ax, 0x1000
mov ds, ax
mov ax, 0xB800
mov es, ax

; ============ 清空开机键盘缓冲区，吸干残留垃圾按键 ============
flush_kb:
mov ah, 0x01
int 0x16
jz kb_end
mov ah, 0x00
int 0x16
jmp flush_kb
kb_end:

; 开机1秒延时
mov cx, 0x000F
mov dx, 0x4240
mov ah, 0x86
int 0x15

; 光标配置
mov ah, 0x01
mov ch, 0x06
mov cl, 0x07
int 0x10

call clear_screen

; 打印内核标题
mov di, 0
mov si, msg_kernel
call print_str

; 生成首行提示符
call enter_line

; 同步硬件光标
call set_cursor

;==================== 主输入循环 ====================
kernel_main:
    call getkey

    ; 优先处理特殊控制键
    cmp al, 0x1B    ; ESC 全局清屏
    je  do_clear
    cmp al, 0x0D    ; 回车换行
    je  enter_line
    cmp al, 0x08    ; 退格删除
    je  backspace

    ; 过滤普通控制字符
    cmp al, 0x20
    jb kernel_main
    cmp al, 0x7E
    ja kernel_main

    ; 单行80字符上限判断
    mov bl, [col]
    cmp bl, 79
    je  enter_line

    ; 写入输入缓冲区
    mov bl, [buf_ptr]
    cmp bl, 63
    je skip_buf_write
    mov bh, 0
    lea si, [input_buf]
    add si, bx
    mov [si], al
    inc byte [buf_ptr]
skip_buf_write:

    call putc
    call set_cursor
    jmp kernel_main

;==================== 回车换行逻辑（清空缓冲区） ====================
enter_line:
    mov byte [buf_ptr], 0
    mov byte [col], 0
    inc byte [row]
    mov al, [row]
    mov bl, 160
    mul bl
    mov di, ax

    mov si, prompt
    call print_str
    call set_cursor
    jmp kernel_main

;==================== 退格逻辑（同步回退缓冲区指针） ====================
backspace:
    cmp byte [col], 2
    jle kernel_main

    dec byte [col]
    dec byte [buf_ptr]
    sub di, 2
    mov word [es:di], 0
    call set_cursor
    jmp kernel_main

;==================== ESC清屏完整重绘（清空缓冲区） ====================
do_clear:
    call clear_screen
    mov di, 0
    mov byte [row], 0
    mov byte [col], 0
    mov byte [buf_ptr], 0
    ; 重绘标题
    mov si, msg_kernel
    call print_str
    ; 重绘提示符
    mov di, 160
    mov si, prompt
    call print_str
    mov byte [row], 1
    mov byte [col], 2
    mov di, 164
    call set_cursor
    jmp kernel_main

;==================== 工具函数：读取键盘按键 ====================
getkey:
    mov ah, 0x00
    int 0x16
    ret

;==================== 工具函数：打印单个输入字符（黄色0x0E） ====================
putc:
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    ret

;==================== 工具函数：打印字符串（系统绿色0x0A） ====================
print_str:
print_next:
    lodsb
    test al, al
    je  .end
    mov [es:di], al
    mov byte [es:di+1], 0x0A
    add di, 2
    inc byte [col]
    jmp print_next
.end:
    ret

;==================== 工具函数：全屏清空 ====================
clear_screen:
    push di
    mov di, 0
clear_loop:
    mov word [es:di], 0
    add di, 2
    cmp di, 80*25*2
    jb clear_loop
    pop di
    ret

;==================== 工具函数：同步硬件光标坐标 ====================
set_cursor:
    mov ah, 0x02
    mov bh, 0
    mov dh, [row]
    mov dl, [col]
    int 0x10
    ret

;==================== 全局数据区 ====================
row         db 1
col         db 2
buf_ptr     db 0
input_buf   times 64 db 0
msg_kernel  db 'XuanWu Kernel 0.0.15 Step2', 0
prompt      db '$ ', 0

; 死循环拦截，防止CPU向下读取数据区乱执行
jmp $