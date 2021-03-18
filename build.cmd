@echo off
setlocal
cd /d "%~dp0"

rem -L passes following argument to the linker
rem /ignore:4286 removes LINK : warning LNK4286: symbol '_wcsnicmp' defined in 'libucrt.lib(wcsnicmp.obj)' is imported by 'mdbx.lib(mdbx.obj)'
rem /ignore:4204 removes mdbx.lib(mdbx.obj) : warning LNK4204: 'D:\voxelman2\bin\mdbx-static.pdb' is missing debugging information for referencing module; linking object as if no debug info
rem /LTCG removes mdbx.lib(mdbx.obj) : MSIL .netmodule or module compiled with /GL found; restarting link with /LTCG; add /LTCG to the link command line to improve linker performance
rem /NODEFAULTLIB:MSVCRT removes LINK : warning LNK4098: defaultlib 'MSVCRT' conflicts with use of other libs; use /NODEFAULTLIB:library

set LINKFLAGS=-L/ignore:4286 -L/ignore:4204 -L/NODEFAULTLIB:MSVCRT -L/LTCG

rem mdbx  needs  ntdll.lib User32.lib Advapi32.lib
rem enet  needs  ws2_32.lib winmm.lib
rem glfw3 needs  gdi32.lib

set LIBS=lib/liblz4_static.lib lib/glfw3_mt.lib lib/enet64.lib lib/mdbx.lib ntdll.lib User32.lib Advapi32.lib ws2_32.lib winmm.lib gdi32.lib

set DEPS=-I=D:\sources\my_sources\tiny_jit\source

dmd -m64 -i -g host/main.d -of=bin/voxelman.exe %DEPS% %LIBS% %LINKFLAGS%

del %~dp0\bin\voxelman.exp %~dp0\bin\voxelman.lib %~dp0\bin\voxelman.obj