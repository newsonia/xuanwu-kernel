; ==============================
; Game 0.1.1
; 依赖 Kernel 0.1
; ==============================
branch_entry:
    ; 调用内核键盘
    call kernel_read_key
    ; 调用内核打印
    call kernel_print_char
    ; 循环
    jmp branch_entry