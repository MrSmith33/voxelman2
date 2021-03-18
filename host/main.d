import std.string : toStringz;
import std.stdio;
import all;

void main() {
	SetConsoleOutputCP(65001);

	Driver driver;
	driver.initialize(jitPasses);
	driver.context.buildType = BuildType.jit;
	version(Windows) driver.context.targetOs = TargetOs.windows;
	else version(linux) driver.context.targetOs = TargetOs.linux;
	else static assert(false, "Unhandled OS");

	driver.beginCompilation();
	// add files
	regModules(driver);

	// compile
	try {
		driver.compile();
	} catch(CompilationException e) {
		if (e.isICE) throw e;
		writefln("Compile error:");
		writeln(driver.context.errorSink.text);
		return;
	} catch(Throwable e) {
		auto func = driver.context.currentFunction;
		if (func) {
			auto mod = func._module.get!ModuleDeclNode(&driver.context);
			writefln("Failed in %s.%s", driver.context.idString(mod.id), driver.context.idString(func.id));
		}
		throw e;
	}
	driver.markCodeAsExecutable();

	auto runFunc = driver.context.getFunctionPtr!(void)("main", "run");

	runFunc();
}

void regModules(ref Driver driver)
{
	driver.addHostSymbols(expose_symbols());
	driver.addModule(SourceFileInfo("../plugins/core/glfw3.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/kernel32.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/lz4.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/enet.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/mdbx.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/host.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/main.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/utils.vx"));
}

HostSymbol[] expose_symbols() {
	HostSymbol[] hostSymbols;

	hostSymbols ~= HostSymbol("host_print", cast(void*)&host_print);

	hostSymbols ~= HostSymbol("mdbx_env_create", cast(void*)&mdbx_env_create);
	hostSymbols ~= HostSymbol("mdbx_env_open", cast(void*)&mdbx_env_open);
	hostSymbols ~= HostSymbol("mdbx_env_close_ex", cast(void*)&mdbx_env_close_ex);

	hostSymbols ~= HostSymbol("glfwInit", cast(void*)&glfwInit);
	hostSymbols ~= HostSymbol("glfwTerminate", cast(void*)&glfwTerminate);

	hostSymbols ~= HostSymbol("enet_initialize", cast(void*)&enet_initialize);

	hostSymbols ~= HostSymbol("LZ4_compress_default", cast(void*)&LZ4_compress_default);
	hostSymbols ~= HostSymbol("LZ4_decompress_safe", cast(void*)&LZ4_decompress_safe);

	hostSymbols ~= HostSymbol("ExitProcess", cast(void*)&ExitProcess);
	hostSymbols ~= HostSymbol("GetTickCount64", cast(void*)&GetTickCount64);
	hostSymbols ~= HostSymbol("QueryPerformanceCounter", cast(void*)&QueryPerformanceCounter);
	hostSymbols ~= HostSymbol("QueryPerformanceFrequency", cast(void*)&QueryPerformanceFrequency);
	hostSymbols ~= HostSymbol("WriteConsoleA", cast(void*)&WriteConsoleA);
	hostSymbols ~= HostSymbol("GetStdHandle", cast(void*)&GetStdHandle);
	hostSymbols ~= HostSymbol("GetProcessHeap", cast(void*)&GetProcessHeap);
	hostSymbols ~= HostSymbol("HeapAlloc", cast(void*)&HeapAlloc);
	hostSymbols ~= HostSymbol("HeapFree", cast(void*)&HeapFree);
	hostSymbols ~= HostSymbol("RtlCopyMemory", cast(void*)&RtlCopyMemory);
	hostSymbols ~= HostSymbol("WriteFile", cast(void*)&WriteFile);
	hostSymbols ~= HostSymbol("SetConsoleOutputCP", cast(void*)&SetConsoleOutputCP);

	return hostSymbols;
}

extern(C) void host_print(SliceString str) {
	write(str.slice);
}

extern(C) nothrow {
	void LZ4_compress_default();
	void LZ4_decompress_safe();
}

extern(C) {
	void enet_initialize();

	void glfwInit();
	void glfwTerminate();

	void mdbx_env_create();
	void mdbx_env_open();
	void mdbx_env_close_ex();

	void ExitProcess();
	void GetTickCount64();
	void QueryPerformanceCounter();
	void QueryPerformanceFrequency();
	void WriteConsoleA();
	void GetStdHandle();
	void GetProcessHeap();
	void HeapAlloc();
	void HeapFree();
	void RtlCopyMemory();
	void WriteFile();
	bool SetConsoleOutputCP(uint);
}
