@echo off
setlocal
cd /d "%~dp0"
.\build.cmd && cd bin && voxelman.exe