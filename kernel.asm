org 0x0000
bits 16

; ==============================
; XuanWu Kernel 0.0.13
; Renamed from Pangu Kernel
; Update Log:
; 1. Replace Ctrl+C with Esc for clear screen (international common)
; 2. Add built-in command: cls (clear screen)
; 3. Keep boot delay & blinking movable cursor
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

call clear_screen

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

; 临时字符缓存，用于识别 cls 命令
cmd_buf db 0,0,0

;--------------------------
; 主循环
;--------------------------
kernel_main:
    call getkey

    ; Esc 键 = 清屏(ASCII 0x1B)，替换原Ctrl+C
    cmp al, 0x1B
    je  do_clear

    cmp al, 0x0D        ; 回车
    je  check_cmd
    cmp al, 0x08        ; 退格
    je  backspace

    ; 限制行宽
    mov bl, [col]
    cmp bl, 79
    je  enter_line

    ; 存入命令缓冲区
    call save_char
    call putc
    call set_cursor
    jmp kernel_main

;--------------------------
; 检测回车，判断是否为 cls 命令
;--------------------------
check_cmd:
    ; 判断输入是否为 cls
    mov al, [cmd_buf]
    cmp al, 'c'
    jne enter_line
    mov al, [cmd_buf+1]
    cmp al, 'l'
    jne enter_line
    mov al, [cmd_buf+2]
    cmp al, 's'
    jne enter_line

    ; 匹配 cls，执行清屏
    call clear_buf
    jmp do_clear

;--------------------------
; 换行 + 输出提示符
;--------------------------
enter_line:
    call clear_buf
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
    call del_char
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
; 按键读取
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
; 同步硬件光标
;--------------------------
set_cursor:
    mov ah, 0x02
    mov bh, 0
    mov dh, [row]
    mov dl, [col]
    int 0x10
    ret

;--------------------------
; 保存字符到命令缓冲区
;--------------------------
save_char:
    mov bl, [col]
    sub bl, 2       ; 跳过 $ 提示符
    cmp bl, 3
    ja  .exit
    mov [cmd_buf+bx-1], al
.exit:
    ret

;--------------------------
; 删除缓冲区字符（退格）
;--------------------------
del_char:
    mov bl, [col]
    sub bl, 2
    cmp bl, 2
    jl  .exit
    mov byte [cmd_buf+bx], 0
.exit:
    ret

;--------------------------
; 清空命令缓冲区
;--------------------------
clear_buf:
    mov byte [cmd_buf], 0
    mov byte [cmd_buf+1], 0
    mov byte [cmd_buf+2], 0
    ret

;--------------------------
; 字符串数据
;--------------------------
msg_kernel db 'XuanWu Kernel 0.0.13', 0
prompt     db '$ ', 0
