@echo off
echo ==============================================
echo   Pangu OS 0.1 完整构建脚本 (Windows 纯原生)
echo ==============================================
echo.

set GAME=game_0.1.2.asm
set IMAGE=os.flp

:: 1. 合并内核+游戏
copy /b kernel.asm + %GAME% full_kernel.asm

:: 2. 编译
nasm -f bin boot.asm -o boot.bin
nasm -f bin full_kernel.asm -o kernel.bin

:: 3. 创建空软盘镜像
echo Creating empty disk image...
copy /b nul+nul temp.empty
copy /y temp.empty os.flp

:: 4. 写入 boot + kernel
copy /b boot.bin + kernel.bin %IMAGE%

del temp.empty
del full_kernel.asm

echo.
echo ? 构建完成！镜像：%IMAGE%
echo.
pause