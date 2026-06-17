bits 16
org 0x0000

;==================== 【Step2 独立模块：字符串对比 str_cmp】 ====================
; 入参：si = 字符串1，di = 字符串2
; 返回：al = 1 两字符串完全一致；al = 0 不相同
str_cmp:
.cmp_loop:
mov al, [si]
mov bl, [di]
cmp al, bl
jne .not_equal
test al, al
jz .equal_end
inc si
inc di
jmp .cmp_loop
.not_equal:
mov al, 0
ret
.equal_end:
mov al, 1
ret