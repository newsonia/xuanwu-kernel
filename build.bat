@echo off
echo ==============================================
echo   Xuanwu Kernel 0.0.4 完整构建脚本 (Windows 纯原生)
echo ==============================================
echo.

set IMAGE=os.flp

:: 1. 编译
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin

:: 2. 创建空软盘镜像
echo Creating empty disk image...
copy /b nul+nul temp.empty
copy /y temp.empty os.flp

:: 3. 写入 boot + kernel
copy /b boot.bin + kernel.bin %IMAGE%

del temp.empty

echo.
echo ? 构建完成！镜像：%IMAGE%
echo.
pause
