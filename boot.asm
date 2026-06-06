org 0x7C00
bits 16

;初始化段
mov ax,0
mov ds,ax
mov es,ax
mov ss,ax
mov sp,0x7C00

;INT13读软盘：第2扇区→内存0x1000:0000
mov ah,0x02    ;读磁盘
mov al,1       ;读1个扇区
mov ch,0       ;柱面0
mov cl,2       ;起始扇区2（内核位置）
mov dh,0       ;磁头0
mov dl,0       ;A盘软盘
mov bx,0x1000
mov es,bx
xor bx,bx
int 0x13

jmp 0x1000:0000 ;跳内核

;补齐512字节+引导魔数
times 510-($-$$) db 0
dw 0xAA55