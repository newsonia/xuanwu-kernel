void kernel_main() {
    unsigned char *vga = (unsigned char*)0xB8000;
    const char *str = "PANGA KERNEL 32BIT C SUCCESS!";
    int i = 0;
    while (str[i]) {
        vga[i*2] = str[i];
        vga[i*2+1] = 0x0A;
        i++;
    }
    while(1);
}

// 消除链接警告，确保入口正确
void _start() {
    kernel_main();
}