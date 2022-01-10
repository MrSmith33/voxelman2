import std.string : toStringz;
import std.stdio;
import std.getopt;
import std.traits : isFunction, isFunctionPointer, isType;
import all;
import deps.tracy;

void main(string[] args) {
	bool enable_tracy = false;

	GetoptResult optResult = getopt(
		args,
		"tracy", "Enable tracy profiling", &enable_tracy,
	);

	auto startTime = currTime;
	import deps.kernel32 : SetConsoleOutputCP;
	SetConsoleOutputCP(65001);

	if (enable_tracy) {
		load_dll!(deps.tracy)("TracyProfiler.dll");
	} else {
		stub_tracy();
	}

	auto startCompileTime = currTime;
	Driver driver;
	driver.initialize(jitPasses);
	driver.context.buildType = BuildType.jit;
	version(Windows) driver.context.targetOs = TargetOs.windows;
	else version(linux) driver.context.targetOs = TargetOs.linux;
	else static assert(false, "Unhandled OS");

	//driver.context.validateIr = true;
	//driver.context.printIr = true;
	//driver.context.printLirRA = true;
	//driver.context.printCodeHex = true;
	driver.context.printTraceOnError = true;
	driver.context.useFramePointer = true;

	driver.beginCompilation();
	//driver.context.setDumpFilter("createInstance");
	// add files
	regModules(driver);

	auto times = PerPassTimeMeasurements(1, driver.passes);

	static loc = TracyLoc("Compile", "main.d", "main.d", 42, 0xFF00FF);
	auto tracy_ctx = ___tracy_emit_zone_begin(&loc, 1);
	// compile
	try {
		driver.compile();
	} catch(CompilationException e) {
		writefln("Compile error:");
		writeln(driver.context.errorSink.text);
		if (e.isICE) throw e;
		return;
	} catch(Throwable e) {
		writeln(driver.context.errorSink.text);
		throw e;
	}
	driver.markCodeAsExecutable();
	auto endCompileTime = currTime;
	___tracy_emit_zone_end(tracy_ctx);
	//writefln("RO: %s", driver.context.roStaticDataBuffer.bufPtr);

	auto runFunc = driver.context.getFunctionPtr!(void)("main", "run");

	runFunc();

	auto endTime = currTime;

	auto duration = endCompileTime - startCompileTime;
	times.onIteration(0, duration);
	//times.print;
	stdout.flush;
	writefln("Tracy dll load %ss", scaledNumberFmt(startCompileTime - startTime));
	writefln("Compiled in %ss", scaledNumberFmt(endCompileTime - startCompileTime));
	writefln("Run %ss", scaledNumberFmt(endTime - endCompileTime));
	writefln("Total %ss", scaledNumberFmt(endTime - startTime));
}

void regModules(ref Driver driver)
{
	registerHostSymbols(&driver.context);
	driver.addModule(SourceFileInfo("../plugins/hello_triangle/src/hello_triangle/main.vx"));

	driver.addModule(SourceFileInfo("../plugins/core/src/core/enet.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/glfw3.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/host.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/kernel32.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/lz4.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/mdbx.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/mimalloc.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/shaderc.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/tracy.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/utils.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/vulkan/dispatch_device.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/vulkan/functions.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/src/core/vulkan/types.vx"));
}

void registerHostSymbols(CompilationContext* context)
{
	void regHostModule(alias Module)(string hostModuleName)
	{
		Identifier modId = context.idMap.getOrRegNoDup(context, hostModuleName);
		LinkIndex hostModuleIndex = context.getOrCreateExternalModule(modId, ObjectModuleKind.isHost);

		foreach(m; __traits(allMembers, Module))
		{
			alias member = __traits(getMember, Module, m);
			Identifier symId = context.idMap.getOrRegNoDup(context, m);
			static if (isFunction!member) { // pickup functions
				//writefln("reg %s %s", hostModuleName, m);
				context.addHostSymbol(hostModuleIndex, ExternalSymbolId(modId, symId), cast(void*)&member);
			} else static if (isFunctionPointer!member && !isType!member) { // pickup function pointers
				//writefln("reg %s %s", hostModuleName, m);
				context.addHostSymbol(hostModuleIndex, ExternalSymbolId(modId, symId), cast(void*)member);
			}
		}
	}

	import deps.enet;
	import deps.glfw3;
	import deps.kernel32;
	import deps.lz4;
	import deps.mdbx;
	import deps.mimalloc;
	import deps.shaderc;
	import deps.tracy;

	regHostModule!(deps.enet)("enet");
	regHostModule!(deps.glfw3)("glfw3");
	regHostModule!(deps.kernel32)("kernel32");
	regHostModule!(deps.lz4)("lz4");
	regHostModule!(deps.mdbx)("mdbx");
	regHostModule!(deps.mimalloc)("mimalloc");
	regHostModule!(deps.shaderc)("shaderc");
	regHostModule!(deps.tracy)("tracy");

	Identifier modId = context.idMap.getOrRegNoDup(context, "host");
	LinkIndex hostModuleIndex = context.getOrCreateExternalModule(modId, ObjectModuleKind.isHost);
	Identifier symId = context.idMap.getOrRegNoDup(context, "host_print");
	context.addHostSymbol(hostModuleIndex, ExternalSymbolId(modId, symId), cast(void*)&host_print);
}

void load_dll(alias Module)(string dllFile) {
	import core.sys.windows.windows : LoadLibraryA, GetProcAddress;
	void* lib = LoadLibraryA(dllFile.toStringz);
	enforce(lib !is null, format("Cannot load %s", dllFile));
	//writefln("lib %X %s", lib, dllFile);

	foreach(m; __traits(allMembers, Module))
	{
		alias member = __traits(getMember, Module, m);
		static if (isFunctionPointer!member && !isType!member) { // only pickup function pointers
			void* symPtr = GetProcAddress(lib, m);
			//writefln("  sym %X %s", symPtr, m);
			enforce(symPtr !is null, format("Cannot find `%s` in %s", m, dllFile));
			member = cast(typeof(member))symPtr;
		}
	}
}

void stub_tracy() {
	import deps.tracy;
	___tracy_emit_zone_begin = &stub_tracy_emit_zone_begin;
	___tracy_emit_zone_begin_callstack = &stub_tracy_emit_zone_begin_callstack;
	___tracy_emit_zone_end = &stub_tracy_emit_zone_end;
	___tracy_emit_frame_mark = &stub_tracy_emit_frame_mark;
	___tracy_emit_frame_mark_start = &stub_tracy_emit_frame_mark_start;
	___tracy_emit_frame_mark_end = &stub_tracy_emit_frame_mark_end;
	___tracy_set_thread_name = &stub_tracy_set_thread_name;
	___tracy_emit_plot = &stub_tracy_emit_plot;
	___tracy_emit_message_appinfo = &stub_tracy_emit_message_appinfo;
	___tracy_emit_message = &stub_tracy_emit_message;
	___tracy_emit_messageL = &stub_tracy_emit_messageL;
	___tracy_emit_messageC = &stub_tracy_emit_messageC;
	___tracy_emit_messageLC = &stub_tracy_emit_messageLC;
}

extern(C) TracyCZoneCtx stub_tracy_emit_zone_begin(const TracyLoc* srcloc, int active) { return TracyCZoneCtx(); }
extern(C) TracyCZoneCtx stub_tracy_emit_zone_begin_callstack(const TracyLoc* srcloc, int depth, int active) { return TracyCZoneCtx(); }
extern(C) void stub_tracy_emit_zone_end(TracyCZoneCtx ctx) {}
extern(C) void stub_tracy_emit_frame_mark(const char* name) {}
extern(C) void stub_tracy_emit_frame_mark_start(const char* name) {}
extern(C) void stub_tracy_emit_frame_mark_end(const char* name) {}
extern(C) void stub_tracy_set_thread_name(const char* name) {}
extern(C) void stub_tracy_emit_plot(const char* name, double val) {}
extern(C) void stub_tracy_emit_message_appinfo(const char* txt, size_t size) {}
extern(C) void stub_tracy_emit_message(const char* txt, size_t size, int callstack) {}
extern(C) void stub_tracy_emit_messageL(const char* txt, int callstack) {}
extern(C) void stub_tracy_emit_messageC(const char* txt, size_t size, uint color, int callstack) {}
extern(C) void stub_tracy_emit_messageLC(const char* txt, uint color, int callstack) {}

extern(C) void host_print(SliceString str) {
	write(str.slice);
}
