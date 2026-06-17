@echo off
echo ==============================================
echo   Xuanwu Kernel 0.0.15 Step2 Split Build
echo ==============================================
echo.
:: 编译各模块
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
nasm -f bin command.asm -o command.bin

:: 二进制拼接顺序：引导 → 内核底层 → 命令工具模块
copy /b boot.bin + kernel.bin + command.bin os.flp

echo.
echo 构建完成，镜像文件：os.flp
echo.
pause