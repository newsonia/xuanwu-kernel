; ==============================
; Game 0.1.1
; 依赖 Kernel 0.1
; ==============================
branch_entry:
    ; ======================================
    ; 替换欢迎信息（不改内核，直接覆盖）
    ; ======================================
    mov si, new_msg
    mov di, 0          ; 屏幕第一行开始

print_new:
    lodsb
    test al, al
    je game_start

    mov [es:di], al
    mov byte [es:di+1], 0Ah   ; 绿色
    add di, 2
    jmp print_new

new_msg:
    db 'Welcome to PanguGames 0.1.2', 0

game_start:

    ; 1. 固定输出字符 #
    mov al, '#'        

    ; 2. 固定位置：屏幕正中间
    mov di, (12*160) + (40*2)  

    ; 3. 调用内核打印
    call kernel_print_char

    ; 循环
    jmp branch_entry

; 坐标变量（暂时不用，先测试画点）
player_x db 40
player_y db 12
