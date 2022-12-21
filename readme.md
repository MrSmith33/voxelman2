# Voxelman v2

![CI](https://github.com/MrSmith33/voxelman2/workflows/CI/badge.svg?branch=master&event=push)

Voxel engine focused on:
- Modding via embedded Vox language compiler, which offers quick recompilation
- High performance through the use of ECS, multithreading and Vulkan API, mdbx database
- Client/Server architecture

## Status

WIP rewrite of voxelman

Currently following [Vulkan tutorial](https://vulkan-tutorial.com)

## Profiling

Pass `--tracy` flag to the executable to enable tracy. Run the voxelman application as an administrator to get more profiling information. Start Tracy profiler and connect to the application. Tracy is disabled by default as it affects startup time.

## Links

* [Voxelman v1](https://github.com/MrSmith33/voxelman)
* [Vox programming language](https://github.com/MrSmith33/vox)

## Conventions

* Right-handed coordinate system
* Column vectors that are multiplied as `P⋅V⋅M⋅v`

## Getting deps

`.dll` files must be placed into `bin/` directory\
`.lib` files must be placed into `lib/` directory

Download pre-built dependencies from:
* https://github.com/MrSmith33/voxelman2/releases/tag/deps

Or build/download them yourself:

<details>
<summary>Instructions</summary>

* GLFW3 v3.3.8
  * [glfw-3.3.8.bin.WIN64.zip](https://github.com/glfw/glfw/releases/download/3.3.8/glfw-3.3.8.bin.WIN64.zip)`/glfw-3.3.8.bin.WIN64/lib-vc2019/glfw3.lib`
* Enet v1.3.17
  * [enet-1.3.17.tar.gz](http://enet.bespin.org/download/enet-1.3.17.tar.gz)`/enet-1.3.17/enet64.lib`
* LZ4 v1.9.4: [lz4-1.9.4.zip](https://github.com/lz4/lz4/archive/refs/tags/v1.9.4.zip)
  * The file from the release causes `liblz4_static.lib(lz4.o) : error LNK2001: unresolved external symbol ___chkstk_ms` when building with `dmd`, so we build from sources.
  * Open `lz4-1.9.4/build/VS2017/lz4.sln` with VS2019 (Release x64 config)
  * Optionally disable debug info (`Debug Information format`: `/Zi` -> `None`). Reduces static lib size.
  * Build `liblz4` project
  * Copy `lz4-1.9.4/build/VS2017/bin/x64_Release/liblz4_static.lib`
* libmdbx v0.10.2
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
* mimalloc v2.0.7
  * https://github.com/microsoft/mimalloc/archive/refs/tags/v2.0.7.zip
  * Open `mimalloc-2.0.7/ide/vs2019/mimalloc.sln`
  * Select Release build
  * In vs2019 modify `mimalloc` project settings:
    * Disable debug info (`Debug Information format`: `/Zi` -> `None`)
    * Compile as C language to reduce .lib size (from 452KiB to 341KiB) (`C/C++ -> Advanced -> Compile As`: `/TP` -> `/TC`)
  * Copy `mimalloc-2.0.7/out/msvc-x64/Release/mimalloc-static.lib`
* Tracy v0.7.8
   * https://github.com/wolfpld/tracy/archive/refs/tags/v0.7.8.zip
   * Open `/library/win32/TracyProfiler.sln`
   * Select Release build
   * ~~Build as dll~~
   * `Whole program optimization`: `/GL` -> `No`
   * `Debug Information format`: `/Zi` -> `None`
   * ~~Copy `tracy/library/win32/x64/Release/TracyProfiler.dll`~~
   * ~~Linking with `TracyProfiler.lib` caused D host to not generate proper stack traces, which is important when debugging compiler and other stuff. Loading master version of tracy dll with LoadLibraryA is super slow (like 30-40s).~~
   * Define `TRACY_DELAYED_INIT` and `TRACY_MANUAL_LIFETIME` preprocessor definitions in `C/C++` -> `Preprocessor` -> `Preprocessor Definitions`
   * Add this code to `TracyC.h` before `___tracy_init_thread` definition:
     ```C
     #if defined(TRACY_DELAYED_INIT) && defined(TRACY_MANUAL_LIFETIME)
     TRACY_API void ___tracy_startup_profiler(void);
     TRACY_API void ___tracy_shutdown_profiler(void);
     #endif
     ```
   * Add this code to `client/TracyProfiler.cpp` after `___tracy_init_thread` declaration:
     ```C
     #if defined(TRACY_DELAYED_INIT) && defined(TRACY_MANUAL_LIFETIME)
     TRACY_API void ___tracy_startup_profiler(void) { tracy::StartupProfiler(); }
     TRACY_API void ___tracy_shutdown_profiler(void) { tracy::ShutdownProfiler(); }
     #endif
     ```
   * Build as static lib
   * Copy `tracy/library/win32/x64/Release/TracyProfiler.lib`
* shaderc from VulkanSDK v1.3.236.0
   * Download from [VulkanSDK](https://vulkan.lunarg.com/sdk/home) or from releases of https://github.com/google/shaderc
   * https://sdk.lunarg.com/sdk/download/1.3.236.0/windows/VulkanSDK-1.3.236.0-Installer.exe
   * No need to install, can be opened as archive
   * ~~Shared lib `/Lib/shaderc_shared.lib` & `/Bin/shaderc_shared.dll`~~
   * Copy `VulkanSDK-1.3.236.0-Installer.exe/Lib/shaderc_combined.lib`
* zstd v1.5.2
   * Download https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz
   * Unpack into `zstd-1.5.2/`
   * Go to `zstd-1.5.2/build/cmake`
   * Execute
     ```
     mkdir build
     cd build
     cmake ..
     ```
   * Open `zstd-1.5.2/build/cmake/build/zstd.sln`
   * Select Release build and build `libzstd_static` project
   * Copy `zstd-1.5.2/build/cmake/build/lib/Release/zstd_static.lib`
* Vulkan Memory Allocator v3.0.0
  * Download [source code](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v3.0.0.zip)
  * Go to `VulkanMemoryAllocator-3.0.0/`
  * Execute in terminal
    ```
    mkdir build
    cd build
    cmake ..
    ```
  * Open `VulkanMemoryAllocator-3.0.0/build/VulkanMemoryAllocator.sln`
  * Set preprocessor directives as:
    ```C
    VMA_STATIC_VULKAN_FUNCTIONS=0
    VMA_DYNAMIC_VULKAN_FUNCTIONS=1
    VMA_MEMORY_BUDGET=1
    VMA_BIND_MEMORY2=1
    VMA_DEDICATED_ALLOCATION=1
    VMA_EXTERNAL_MEMORY=1
    VMA_STATIC_VULKAN_FUNCTIONS=0
    ```
  * Switch to Vulkan 1.3 in `VulkanMemoryAllocator-3.0.0/src/VmaUsage.h` (uncomment `#define VMA_VULKAN_VERSION 1003000`)
  * Build release version
  * Copy `VulkanMemoryAllocator-3.0.0/build/src/Release/VulkanMemoryAllocator.lib`
* GameNetworkingSockets v1.4.1
  * `git clone https://github.com/microsoft/vcpkg`
  * In `x64 Native Tools Command Prompt for VS 2019`
  * `./vcpkg/bootstrap-vcpkg.bat`
  * Apply [this patch](https://github.com/eddiejames/vcpkg/commit/420290091e82288e461473e3447e6e4901f0c8df) to `ports/gamenetworkingsockets/portfile.cmake` and `ports/gamenetworkingsockets/vcpkg.json`
  * `vcpkg install gamenetworkingsockets:x64-windows-static-md`
  * Copy `vcpkg/packages/gamenetworkingsockets_x64-windows-static-md/lib/GameNetworkingSockets_s.lib`
  * Copy `vcpkg/packages/protobuf_x64-windows-static-md/lib/libprotobuf.lib`
  * Copy `vcpkg/packages/openssl_x64-windows-static-md/lib/libcrypto.lib`

</details>
