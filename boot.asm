org 0x7C00
bits 16

; 初始化段寄存器
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

; 清屏
mov ax, 0x03
int 0x10

; 读内核到 0x1000:0000（2个扇区足够）
mov ah, 0x02
mov al, 2
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, 0
mov bx, 0x1000
mov es, bx
xor bx, bx
int 0x13

; 关中断
cli

; 开启A20地址线（VMware必须）
in al, 0x92
or al, 2
out 0x92, al

; 加载GDT
lgdt [gdt_ptr]

; 开启保护模式
mov eax, cr0
or al, 1
mov cr0, eax

; 远跳转刷新流水线
jmp dword 0x08:pm_entry

; GDT定义
gdt_start:
dd 0
dd 0

gdt_code:
dw 0xFFFF
dw 0
db 0
db 10011010b
db 11001111b
db 0

gdt_data:
dw 0xFFFF
dw 0
db 0
db 10010010b
db 11001111b
db 0

gdt_end:

gdt_ptr:
dw gdt_end - gdt_start - 1
dd gdt_start

; 32位代码
bits 32
pm_entry:
mov ax, 0x10
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x20000 ; 安全栈地址

; 跳转到内核入口
jmp 0x10000

; 引导扇区签名
times 510 - ($ - $$) db 0
dw 0xAA55