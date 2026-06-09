org 0x0000
bits 16

; 段设置
mov ax, 0x1000
mov ds, ax
mov ax, 0xB800
mov es, ax

; 开机清屏
call clear_screen

; 打印欢迎信息
mov si, msg
mov di, 0

print:
    lodsb
    test al, al
    je kernel_main

    mov [es:di], al
    mov byte [es:di+1], 0x0A
    add di, 2
    jmp print

; 记录当前行列，用于换行/退格
row db 1
col db 0

;==============================
; 内核主循环：键盘处理
;==============================
kernel_main:
    ; 等待按键
    mov ah, 0x00
    int 0x16

    ; 按 c 清屏
    cmp al, 'c'
    je  do_clear_screen

    ; 回车键 0x0D：换行
    cmp al, 0x0D
    je  enter_key

    ; 退格键 0x08：删除
    cmp al, 0x08
    je  backspace_key

    ; 普通字符：判断是否超出行宽
    mov bl, [col]
    cmp bl, 79
    je  enter_key   ; 一行满了自动换行

    ; 显示字符
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    jmp kernel_main

; 回车处理：跳到下一行行首
enter_key:
    mov byte [col], 0
    inc byte [row]
    ; 计算新行显存偏移: 行*160
    mov al, [row]
    mov bl, 160
    mul bl
    mov di, ax
    jmp kernel_main

; 退格处理：删除上一个字符
backspace_key:
    mov bl, [col]
    cmp bl, 0
    je  kernel_main ; 行首无法退格

    dec byte [col]
    sub di, 2
    ; 清空当前位置字符和颜色
    mov byte [es:di], 0
    mov byte [es:di+1], 0x00
    jmp kernel_main

; 清屏处理
do_clear_screen:
    call clear_screen
    mov di, 0
    mov byte [row], 0
    mov byte [col], 0
    jmp kernel_main

;==============================
; 清屏函数
;==============================
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

;==============================
; 数据
;==============================
msg db 'Hello Pangu Kernel! ', 0
