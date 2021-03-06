# Voxelman v2

![CI](https://github.com/MrSmith33/voxelman2/workflows/CI/badge.svg?branch=master&event=push)

Voxel engine focused on:
- Modding via embedded Vox language compiler, which offers quick recompilation
- High performance through the use of ECS, multithreading and Vulkan API, mdbx database
- Client/Server architecture

## Status

WIP rewrite of voxelman

## Links

* [Voxelman v1](https://github.com/MrSmith33/voxelman)
* [Vox programming language](https://github.com/MrSmith33/vox)

## Getting deps

`.lib` files must be placed into `repo_root/lib/` directory\
`.dll` files must be placed into `bin/` directory

Download prebuilt libs from: https://github.com/MrSmith33/voxelman2/releases/download/deps/lib.7z

Or build/download them yourself:

* GLFW3: [glfw-3.3.3.bin.WIN64.zip](https://github.com/glfw/glfw/releases/download/3.3.3/glfw-3.3.3.bin.WIN64.zip)`/glfw-3.3.3.bin.WIN64/lib-vc2019/glfw3.lib`
* Enet: [enet-1.3.17.tar.gz](http://enet.bespin.org/download/enet-1.3.17.tar.gz)`/enet-1.3.17.tar/enet-1.3.17/enet64.lib`
* LZ4: [lz4-1.9.3.zip](https://github.com/lz4/lz4/releases/download/v1.9.3/lz4_win64_v1_9_3.zip), unpack and rebuild VS2017 project with VS2019 (Release config), then use `lz4/build/VS2017/bin/x64_Release/liblz4_static.lib`. The file from the release causes `liblz4_static.lib(lz4.o) : error LNK2001: unresolved external symbol ___chkstk_ms` when building with `ldc2`. Optionally disable debug info (`Debug Information format`: `/Zi` -> `None`).
* libmdbx:
   * Needs `cmake` to be installed.
   * Create `build.cmd` inside `libmdbx/` unpacked from [libmdbx-amalgamated-0_10_2.zip](https://github.com/erthink/libmdbx/releases/download/v0.10.2/libmdbx-amalgamated-0_10_2.zip):
   ```batch
   mkdir build
   cd build
   cmake -G "Visual Studio 16 2019" -A x64 -D CMAKE_CONFIGURATION_TYPES="Debug;Release;RelWithDebInfo" -D MDBX_AVOID_CRT:BOOL=ON -D MDBX_BUILD_SHARED_LIBRARY:BOOL=OFF -D INTERPROCEDURAL_OPTIMIZATION:BOOL=FALSE ..
   ```
   * Run `build.cmd`.
   * Change inlining option (Properties->C/C++->Optimization->Inline function expansion) in the `Release` config of `mdbx-static` project to `/Ob1`. Otherwise compile freezes.
   * `cmake --build . --config Release` or press `Build` for `mdbx-static` project.
   * Copy `libmdbx/build/Release/mdbx.lib`
* mimalloc:
   * https://github.com/microsoft/mimalloc/archive/refs/tags/v2.0.1.zip
   * Use Release build
   * In vs2019 modify `mimalloc` project settings:
      - Disable debug info (`Debug Information format`: `/Zi` -> `None`)
      - Compile as C language to reduce .lib size (from 1.5MB to 300KB) (`C/C++ -> Advanced -> Compile As`: `/TP` -> `/TC`)
   * Copy `mimalloc/out/msvc-x64/Release/mimalloc-static.lib`
* Tracy:
   * https://github.com/wolfpld/tracy/archive/refs/tags/v0.7.8.zip
   * Open `/library/win32/TracyProfiler.sln`
   * Use Release build
   * Build as dll
   * `Whole program optimization`: `/GL` -> `No`
   * `Debug Information format`: `/Zi` -> `None`
   * Copy `tracy/library/win32/x64/Release/TracyProfiler.dll`
   * Linking with `TracyProfiler.lib` caused D host to not generate proper stack traces, which is important when debugging compiler and other stuff. Loading master version of tracy dll with LoadLibraryA is super slow (like 30-40s).
