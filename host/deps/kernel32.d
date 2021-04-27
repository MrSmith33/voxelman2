module deps.kernel32;
extern(C):
void ExitProcess();
void ExitThread();
void GetProcessHeap();
void GetStdHandle();
void GetTickCount64();
void HeapAlloc();
void HeapFree();
void QueryPerformanceCounter();
void QueryPerformanceFrequency();
void RtlCopyMemory();
bool SetConsoleOutputCP(uint);
void WriteConsoleA();
void WriteFile();
void Sleep();
