import std.string : toStringz;
import std.stdio;
import std.getopt;
import std.traits : isFunction, isFunctionPointer, isType;
import vox.all;


void main(string[] args) {
	static import deps.tracy_lib;
	import deps.tracy_ptr;
	bool enable_tracy = false;

	import deps.kernel32 : GetCurrentThread, SetThreadPriority, SetThreadAffinityMask;
	SetThreadPriority(GetCurrentThread(), 2);
	SetThreadAffinityMask(GetCurrentThread(), 1);

	GetoptResult optResult = getopt(
		args,
		"tracy", "Enable tracy profiling", &enable_tracy,
	);

	auto startTime = currTime;
	import deps.kernel32 : SetConsoleOutputCP;
	SetConsoleOutputCP(65001);

	load_tracy(enable_tracy);

	tracy_startup_profiler();
	scope(exit) tracy_shutdown_profiler();

	tracy_set_thread_name("main");

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
	registerHostSymbols(&driver.context);
	registerPackages(driver, ["core", "hello_triangle"]);

	auto times = PerPassTimeMeasurements(1, driver.passes);

	static loc = TracyLoc("Compile", "main.d", "main.d", 42, 0xFF00FF);
	auto tracy_ctx = tracy_emit_zone_begin(&loc, 1);
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
	tracy_emit_zone_end(tracy_ctx);
	//writefln("RO: %s", driver.context.roStaticDataBuffer.bufPtr);

	auto endTime = currTime;

	auto duration = endCompileTime - startCompileTime;
	times.onIteration(0, duration);
	//times.print;
	stdout.flush;
	writefln("Tracy load %ss", scaledNumberFmt(startCompileTime - startTime));
	writefln("Compiled in %ss", scaledNumberFmt(endCompileTime - startCompileTime));
	writefln("Total %ss", scaledNumberFmt(endTime - startTime));

	auto runFunc = driver.context.getFunctionPtr!(void)("main", "main");
	runFunc();
}

void registerPackages(ref Driver driver, string[] enabledPlugins)
{
	import std.file : exists, dirEntries, SpanMode, DirEntry;
	import std.path : buildPath, pathSplitter, extension, baseName;
	import std.range : back;

	auto startTime = currTime;
	string[] installedPlugins;

	foreach (DirEntry entry; dirEntries("../plugins", SpanMode.shallow, false))
	{
		if (!entry.isDir) continue;

		string pluginName = entry.name.pathSplitter.back;
		installedPlugins ~= pluginName;
	}

	uint numSourceFilesLoaded = 0;
	bool loadedMainFile = false;
	string mainFile;
	string mainFilePlugin;

	foreach (string pluginName; installedPlugins)
	{
		string pluginDir = buildPath("../plugins", pluginName);
		string pluginSrcDir = buildPath(pluginDir, "src");

		if (!exists(pluginSrcDir)) continue; // no src/ found

		foreach (DirEntry srcEntry; dirEntries(pluginSrcDir, SpanMode.depth, false))
		{
			if (!srcEntry.isFile) continue;
			if (srcEntry.name.extension != ".vx") continue;
			if (srcEntry.name.baseName == "main.vx")
			{
				if (loadedMainFile) {
					stderr.writeln("Multiple main.vx files detected");
					stderr.writeln("- ", mainFile, " from ", mainFilePlugin);
					stderr.writeln("- ", srcEntry.name);
					assert(false);
				}

				loadedMainFile = true;
				mainFile = srcEntry.name;
				mainFilePlugin = pluginName;
			}
			driver.addModule(SourceFileInfo(srcEntry.name));
			++numSourceFilesLoaded;
			//writeln("add ", srcEntry.name);
		}
	}

	auto endTime = currTime;

	stderr.writefln("Plugins scan time %ss", scaledNumberFmt(endTime - startTime));
	stderr.writefln("Found %s plugins", installedPlugins.length);
	stderr.writefln("Loaded %s source files", numSourceFilesLoaded);
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
	import deps.tracy_ptr;
	import deps.zstd;

	regHostModule!(deps.enet)("enet");
	regHostModule!(deps.glfw3)("glfw3");
	regHostModule!(deps.kernel32)("kernel32");
	regHostModule!(deps.lz4)("lz4");
	regHostModule!(deps.mdbx)("mdbx");
	regHostModule!(deps.mimalloc)("mimalloc");
	regHostModule!(deps.shaderc)("shaderc");
	regHostModule!(deps.tracy_ptr)("tracy");
	regHostModule!(deps.zstd)("zstd");

	// host
	{
		Identifier modId = context.idMap.getOrRegNoDup(context, "host");
		LinkIndex hostModuleIndex = context.getOrCreateExternalModule(modId, ObjectModuleKind.isHost);
		Identifier symId = context.idMap.getOrRegNoDup(context, "host_print");
		context.addHostSymbol(hostModuleIndex, ExternalSymbolId(modId, symId), cast(void*)&host_print);
	}
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

void load_tracy(bool enable_tracy) {
	import deps.tracy_ptr;
	import deps.tracy_lib;
	import deps.tracy_stub;

	tracy_startup_profiler          = enable_tracy ? &___tracy_startup_profiler          : &stub_tracy_startup_profiler;
	tracy_shutdown_profiler         = enable_tracy ? &___tracy_shutdown_profiler         : &stub_tracy_shutdown_profiler;
	tracy_emit_zone_begin           = enable_tracy ? &___tracy_emit_zone_begin           : &stub_tracy_emit_zone_begin;
	tracy_emit_zone_begin_callstack = enable_tracy ? &___tracy_emit_zone_begin_callstack : &stub_tracy_emit_zone_begin_callstack;
	tracy_emit_zone_end             = enable_tracy ? &___tracy_emit_zone_end             : &stub_tracy_emit_zone_end;
	tracy_emit_frame_mark           = enable_tracy ? &___tracy_emit_frame_mark           : &stub_tracy_emit_frame_mark;
	tracy_emit_frame_mark_start     = enable_tracy ? &___tracy_emit_frame_mark_start     : &stub_tracy_emit_frame_mark_start;
	tracy_emit_frame_mark_end       = enable_tracy ? &___tracy_emit_frame_mark_end       : &stub_tracy_emit_frame_mark_end;
	tracy_set_thread_name           = enable_tracy ? &___tracy_set_thread_name           : &stub_tracy_set_thread_name;
	tracy_emit_plot                 = enable_tracy ? &___tracy_emit_plot                 : &stub_tracy_emit_plot;
	tracy_emit_message_appinfo      = enable_tracy ? &___tracy_emit_message_appinfo      : &stub_tracy_emit_message_appinfo;
	tracy_emit_message              = enable_tracy ? &___tracy_emit_message              : &stub_tracy_emit_message;
	tracy_emit_messageL             = enable_tracy ? &___tracy_emit_messageL             : &stub_tracy_emit_messageL;
	tracy_emit_messageC             = enable_tracy ? &___tracy_emit_messageC             : &stub_tracy_emit_messageC;
	tracy_emit_messageLC            = enable_tracy ? &___tracy_emit_messageLC            : &stub_tracy_emit_messageLC;
}

extern(C) void host_print(SliceString str) {
	write(str.slice);
}
