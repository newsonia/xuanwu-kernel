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

;==============================
; 内核主循环：键盘处理
;==============================
kernel_main:
    ; 等待按键
    mov ah, 0x00
    int 0x16

    ; ==============================
    ; 核心：按 c 键 = 清屏
    ; ==============================
    cmp al, 'c'          ; 判断是否按了 c
    je  do_clear_screen  ; 是 → 清屏

    ; 普通按键：显示字符
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2

    jmp kernel_main

;==============================
; 清屏处理
;==============================
do_clear_screen:
    call clear_screen   ; 执行清屏
    mov di, 0           ; 光标回到左上角
    jmp kernel_main

;==============================
; 清屏函数
;==============================
clear_screen:
    push di
    mov di, 0
clear_loop:
    mov byte [es:di], 0        ; 空字符
    mov byte [es:di+1], 0x00   ; 黑色
    add di, 2
    cmp di, 80*25*2
    jb clear_loop
    pop di
    ret

;==============================
; 数据
;==============================
msg db 'Hello Pangu Kernel!', 0