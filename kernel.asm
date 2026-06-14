org 0x0000
bits 16

; ==============================
; XuanWu Kernel 0.0.13
; Renamed from Pangu Kernel
; Update Log:
; 1. Replace Ctrl+C with Esc for clear screen
; 2. Add boot delay & blinking movable cursor
; 3. Rename to XuanWu Kernel
; Original Features:
; 1. Normal 'c' key can be typed normally
; 2. Double protection for 80-char line limit
; 3. Different colors for system text and user input
; 4. Protect prompt from backspace
; ==============================

; 段设置
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

; 光标行列变量
row db 0
col db 0

; 同步初始光标位置
call set_cursor

;--------------------------
; 主循环
;--------------------------
kernel_main:
    call getkey        ; 读取按键

    ; ========== 改为 Esc 清屏 ==========
    ; al=0x1B 代表 Esc
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
    mov byte [es:di], 0
    mov byte [es:di+1], 0x00
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
    mov si, prompt
    call print_str
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
; 单字符输出（用户输入 黄色）
;--------------------------
putc:
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    ret

;--------------------------
; 字符串输出（系统文本 绿色）
;--------------------------
print_str:
    lodsb
    test al, al
    je  .end
    mov [es:di], al
    mov byte [es:di+1], 0x0A
    add di, 2
    inc byte [col]
    jmp print_str
.end:
    ret

;--------------------------
; 清屏函数
;--------------------------
clear_screen:
    push di
    mov di, 0
clear_loop:
    mov byte [es:di], 0
    mov byte [es:di+1], 0x00
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

;--------------------------
; 字符串数据（已更名 XuanWu）
;--------------------------
msg_kernel db 'XuanWu Kernel 0.0.13', 0
prompt     db '$ ', 0
