org 0x0000
bits 16

; 段设置
mov ax, 0x1000
mov ds, ax
mov ax, 0xB800
mov es, ax

call clear_screen       ; 开机清屏

; ==============================
; ?? 演示：打印函数怎么用
; ==============================
mov di, 0          ; 从屏幕第一行开始

mov si, msg_kernel   ; 打印第1句
call print_str

; 变量
row db 0
col db 0

;--------------------------
; 主循环
;--------------------------
kernel_main:
    mov ah, 0x00
    int 0x16

    cmp al, 'c'
    je  do_clear

    cmp al, 0x0D
    je  enter_line

    cmp al, 0x08
    je  backspace

    mov bl, [col]
    cmp bl, 79
    je  enter_line

    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    jmp kernel_main

enter_line:
    mov byte [col], 0
    inc byte [row]
    mov al, [row]
    mov bl, 160
    mul bl
    mov di, ax
    jmp kernel_main

backspace:
    cmp byte [col], 0
    je  kernel_main
    dec byte [col]
    sub di, 2
    mov byte [es:di], 0
    mov byte [es:di+1], 0x00
    jmp kernel_main

do_clear:
    call clear_screen
    mov di, 0
    mov byte [row], 0
    mov byte [col], 0
    jmp kernel_main

;--------------------------
; ? 简单打印函数（核心）
; 用法：
; mov si, 字符串
; call print_str
;--------------------------
print_str:
    lodsb
    test al, al
    je  .end

    mov [es:di], al
    mov byte [es:di+1], 0x0A
    add di, 2
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
; 字符串（可以随便加）
;--------------------------
msg_kernel db 'Pangu Kernel 0.0.5', 0
