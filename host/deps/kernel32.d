module deps.kernel32;
extern(C):
void CreateFileA();
void ExitProcess();
void ExitThread();
void GetProcessHeap();
void GetStdHandle();
void GetFileSizeEx();
void GetTickCount64();
void HeapAlloc();
void HeapFree();
void QueryPerformanceCounter();
void QueryPerformanceFrequency();
void ReadFile();
void RtlCopyMemory();
bool SetConsoleOutputCP(uint);
void WriteConsoleA();
void WriteFile();
void Sleep();
void CloseHandle();
int  GetLastError(); // llvm complains if types do not match
void LocalFree();
void FormatMessageA();
bool SetThreadPriority(void* hThread, int nPriority);
void* GetCurrentThread();
size_t SetThreadAffinityMask(void* hThread, size_t dwThreadAffinityMask);
