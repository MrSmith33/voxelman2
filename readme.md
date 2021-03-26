# Voxelman v2

Voxel engine focused on:
- Modding via embedded Vox language compiler, which offers quick recompilation
- High performance through the use of ECS, multithreading and Vulkan API, mdbx database
- Client/Server architecture

## Status

WIP rewrite of voxelman

## Links

* [Voxelman v1](https://github.com/MrSmith33/voxelman)
* [Vox lang](https://github.com/MrSmith33/vox)

## Getting deps

`.lib` files must be placed into `repo_root/lib/` directory

Download prebuilt libs from: https://github.com/MrSmith33/voxelman2/releases/download/deps/lib.zip

Or build/download them yourself:

* GLFW3: [glfw-3.3.3.bin.WIN64.zip](https://github.com/glfw/glfw/releases/download/3.3.3/glfw-3.3.3.bin.WIN64.zip)`/glfw-3.3.3.bin.WIN64/lib-vc2019/glfw3.lib`
* Enet: [enet-1.3.17.tar.gz](http://enet.bespin.org/download/enet-1.3.17.tar.gz)`/enet-1.3.17.tar/enet-1.3.17/enet64.lib`
* LZ4: [lz4-1.9.3.zip](https://github.com/lz4/lz4/releases/download/v1.9.3/lz4_win64_v1_9_3.zip), unpack and rebuild VS2017 project with VS2019 (Release config), then use `lz4-1.9.3\build\VS2017\bin\x64_Release\liblz4_static.lib`. The file from the release causes `liblz4_static.lib(lz4.o) : error LNK2001: unresolved external symbol ___chkstk_ms` when building with `ldc2`.
* libmdbx:
   * Create `build.cmd` inside `libmdbx_0_9_3/` unpacked from [libmdbx-amalgamated-0_9_3.zip](https://github.com/erthink/libmdbx/releases/download/v0.9.3/libmdbx-amalgamated-0_9_3.zip):
   * In `libmdbx_0_9_3/cmake/compiler.cmake` replace `set(MSVC_LTO_AVAILABLE TRUE)` with `set(MSVC_LTO_AVAILABLE FALSE)` to prevent the use of `/LTCG`, which messes with lld linker.
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
