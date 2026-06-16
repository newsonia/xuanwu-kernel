org 0x0000
bits 16

; ==============================
; XuanWu Kernel 0.0.13
; Fixed: Data all placed at file end, no execution flow overflow
; ==============================

; 段设置（匹配boot加载地址 0x1000:0000）
mov ax, 0x1000
mov ds, ax
mov ax, 0xB800
mov es, ax

; 开机延时 约1秒
mov cx, 0x000F
mov dx, 0x4240
mov ah, 0x86
int 0x15

; 设置下划线闪烁光标
mov ah, 0x01
mov ch, 0x06
mov cl, 0x07
int 0x10

call clear_screen       ; 开机清屏

mov di, 0
mov si, msg_kernel
call print_str

; 首次换行并显示提示符
call enter_line

; 同步初始光标位置
call set_cursor

;--------------------------
; 主循环
;--------------------------
kernel_main:
    call getkey        ; 读取按键

    ; ESC 清屏 al=0x1B
    cmp al, 0x1B
    je  do_clear

    cmp al, 0x0D
    je  enter_line

    cmp al, 0x08
    je  backspace

    mov bl, [col]
    cmp bl, 79
    je  enter_line

    call putc
    call set_cursor
    jmp kernel_main

;--------------------------
; 换行 + 输出提示符
;--------------------------
enter_line:
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

;--------------------------
; 退格：保护提示符区域
;--------------------------
backspace:
    cmp byte [col], 2
    jle kernel_main

    dec byte [col]
    sub di, 2
    mov word [es:di], 0
    call set_cursor
    jmp kernel_main

;--------------------------
; 清屏处理
;--------------------------
do_clear:
    call clear_screen
    mov di, 0
    mov byte [row], 0
    mov byte [col], 0
    mov si, msg_kernel
    call print_str
    mov di, 160
    mov si, prompt
    call print_str
    mov byte [row], 1
    mov byte [col], 2
    mov di, 164
    call set_cursor
    jmp kernel_main

;--------------------------
; 按键读取 getkey
;--------------------------
getkey:
    mov ah, 0x00
    int 0x16
    ret

;--------------------------
; 单字符输出（用户输入 黄色 0x0E）
;--------------------------
putc:
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    ret

;--------------------------
; 字符串输出（系统文本 绿色 0x0A）
;--------------------------
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

;--------------------------
; 清屏函数
;--------------------------
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

;--------------------------
; 同步硬件光标位置
;--------------------------
set_cursor:
    mov ah, 0x02
    mov bh, 0        ; 显示页 0
    mov dh, [row]
    mov dl, [col]
    int 0x10
    ret

; ==============================
; 【全部数据移至代码末尾，杜绝执行流跑飞】
; ==============================
row         db 1
col         db 2
msg_kernel  db 'XuanWu Kernel 0.0.13', 0
prompt      db '$ ', 0

; 死循环拦截执行流，绝对不会向下读取数据
jmp $