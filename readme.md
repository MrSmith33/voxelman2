# Voxelman v2

[Voxelman v1](https://github.com/MrSmith33/voxelman)

## Getting deps:

* GLFW3: `glfw-3.3.3.bin.WIN64.zip\glfw-3.3.3.bin.WIN64\lib-vc2019\glfw3_mt.lib`
* Enet: `enet-1.3.17.tar.gz\enet-1.3.17.tar\enet-1.3.17\enet64.lib`
* LZ4: `lz4-1.9.3.zip`, unpack and rebuild VS2017 project with VS2019 (Release config), then use `lz4-1.9.3\build\VS2017\bin\x64_Release\liblz4_static.lib`. The file from the release causes `liblz4_static.lib(lz4.o) : error LNK2001: unresolved external symbol ___chkstk_ms` when building with `ldc2`.
* libmdbx:
    * Create `build.cmd` inside `libmdbx_0_9_3/` unpacked from `libmdbx-amalgamated-0_9_3.zip`:
```batch
mkdir build
cd build
cmake -G "Visual Studio 16 2019" -A x64 -D CMAKE_CONFIGURATION_TYPES="Debug;Release;RelWithDebInfo" -D MDBX_AVOID_CRT:BOOL=ON -D MDBX_BUILD_SHARED_LIBRARY:BOOL=OFF ..
cmake --build . --config RelWithDebInfo
```
    * Needs `cmake` to be installed.
    * Run `build.cmd`.
    * Copy `libmdbx_0_9_3\build\RelWithDebInfo\mdbx.lib`
    * Optionally disable `.pdb` output by setting `C/C++->General->Debug information format` to `None` in the VS project and rebuild `mdbx-static` project inside VS.
