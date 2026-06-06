org 0x1000
bits 16

; VGA 显存起始段 0xB800
mov ax, 0xB800
mov es, ax

; 输出 Pangu Kernel
mov byte [es:0],  'P'
mov byte [es:1],  0x07
mov byte [es:2],  'a'
mov byte [es:3],  0x07
mov byte [es:4],  'n'
mov byte [es:5],  0x07
mov byte [es:6],  'g'
mov byte [es:7],  0x07
mov byte [es:8],  'u'
mov byte [es:9],  0x07

mov byte [es:10], ' '
mov byte [es:11], 0x07

mov byte [es:12], 'K'
mov byte [es:13], 0x07
mov byte [es:14], 'e'
mov byte [es:15], 0x07
mov byte [es:16], 'r'
mov byte [es:17], 0x07
mov byte [es:18], 'n'
mov byte [es:19], 0x07
mov byte [es:20], 'e'
mov byte [es:21], 0x07
mov byte [es:22], 'l'
mov byte [es:23], 0x07

jmp $ ; 死循环，内核停在这里