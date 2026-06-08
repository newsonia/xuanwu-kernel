org 0x0000
bits 16

; ==============================
; Pangu Kernel 0.1 (冻结版)
; 功能：打印 + 键盘输入
; ==============================

mov ax, 0x1000
mov ds, ax
mov ax, 0xB800
mov es, ax

; 打印欢迎信息
mov si, msg
mov di, 0

print:
    lodsb
    test al, al
    je kernel_ready

    mov [es:di], al
    mov byte [es:di+1], 0x0A
    add di, 2
    jmp print

; ==============================
; 内核公共函数
; ==============================

; 读取键盘
kernel_read_key:
    mov ah, 0x00
    int 0x16
    ret

; 打印字符
kernel_print_char:
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    ret

; 跳转到分支
kernel_ready:
    jmp branch_entry

msg db 'Pangu Kernel 0.1', 0