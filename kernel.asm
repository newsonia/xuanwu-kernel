org 0x0000
bits 16

; 段设置（关键！）
mov ax, 0x1000
mov ds, ax           ; 数据段 = 内核所在段
mov ax, 0xB800
mov es, ax           ; 显存段

mov si, msg
mov di, 0

print:
    lodsb            ; 读字符 al = [si++]
    test al, al
    je end

    mov [es:di], al
    mov byte [es:di+1], 0x0A   ; 绿色
    add di, 2
    jmp print

end:
    jmp $

msg db 'Hello Pangu Kernel!', 0