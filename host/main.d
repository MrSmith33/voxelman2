import std.string : toStringz;
import std.stdio;
import std.getopt;
import std.traits : isFunction, isFunctionPointer, isType;
import std.conv : text;
import vox.all;


void main(string[] args) {
	static import deps.tracy_lib;
	import deps.tracy_ptr;
	bool enable_tracy = false;
	string entryPoint = "default";

	import deps.kernel32 : GetCurrentThread, SetThreadPriority, SetThreadAffinityMask;
	SetThreadPriority(GetCurrentThread(), 2);
	SetThreadAffinityMask(GetCurrentThread(), 1);

	GetoptResult optResult = getopt(
		args,
		"tracy", "Enable tracy profiling", &enable_tracy,
		"entry", `Plugin to start ["default"]`, &entryPoint,
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
	Identifier mainModule = registerPackages(driver, entryPoint);

	auto times = PerPassTimeMeasurements(1, driver.passes);

	static loc = TracyLoc("Compile Vox", __FILE__, __FILE__, __LINE__, 0xFF00FF);
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
	//writefln("Tracy load %ss", scaledNumberFmt(startCompileTime - startTime));
	writefln("Compiled in %ss", scaledNumberFmt(endCompileTime - startCompileTime));
	//writefln("Total %ss", scaledNumberFmt(endTime - startTime));
	stdout.flush;

	Identifier main_id = driver.context.idMap.getOrReg(&driver.context, "main");
	Identifier funcId = driver.context.idMap.getOrRegFqn(&driver.context, FullyQualifiedName(mainModule, main_id));
	try {
		FunctionDeclNode* func = driver.context.findFunction(funcId);
		auto mainFunc = driver.context.getFunctionPtr!void(func);
		mainFunc();
	} catch(CompilationException e) {
		writeln(driver.context.errorSink.text);
	}
}

struct RawPluginInfo
{
	string name;
	string[] dependencies; // plugin names found in plugin/deps.txt
	string[] sourceFiles;  // .vx files inside      plugin/src/ dir
	string[] resFiles;     // resource files inside plugin/res/ dir (currently .frag and .vert)
	Identifier mainModule;
	string mainFile;
	bool isOnStack;
	bool isSelected;
}

// Returns name of the entry function
Identifier registerPackages(ref Driver driver, string rootPluginName)
{
	import std.file : dirEntries, SpanMode, DirEntry;
	import std.path : buildPath, pathSplitter, extension, baseName, stripExtension;
	import std.range : back;

	auto startTime = currTime;
	RawPluginInfo[] detectedPlugins;
	uint[string] pluginMap;
	bool foundRootPlugin;
	uint rootPluginIndex;

	static void onPluginDepsFile(ref RawPluginInfo info, string depsFilename)
	{
		import std.file : read;
		import std.string : lineSplitter;
		import std.algorithm : filter;
		import std.range : empty;
		import std.array : array;
		string data = cast(string)read(depsFilename);
		info.dependencies = cast(string[])data.lineSplitter.filter!(line => !line.empty).array;
	}

	static void onPluginSrcDir(ref Driver driver, ref RawPluginInfo info, string srcDir)
	{
		//writefln("-d src");
		bool foundMainFile = false;

		void visitDir(string dir, Identifier parentId) {
			foreach (DirEntry srcEntry; dirEntries(dir, SpanMode.shallow, false))
			{
				Identifier entryId = driver.context.idMap.getOrReg(&driver.context, srcEntry.name.baseName.stripExtension);
				Identifier fullEntryId = driver.context.idMap.getOrRegFqn(&driver.context, FullyQualifiedName(parentId, entryId));

				if (srcEntry.isDir) {
					visitDir(srcEntry.name, fullEntryId);
					continue;
				}

				if (!srcEntry.isFile) continue;
				if (srcEntry.name.extension != ".vx") continue;

				if (srcEntry.name.baseName == "main.vx")
				{
					if (foundMainFile) {
						stderr.writeln("Plugin %s has multiple main.vx files:", info.name);
						stderr.writeln("- ", srcEntry.name);
						stderr.writeln("- ", info.mainFile);
						assert(false);
					}

					foundMainFile = true;
					info.mainModule = fullEntryId;
					info.mainFile = srcEntry.name;
				}

				//writeln("-s ", srcEntry.name);
				info.sourceFiles ~= srcEntry.name;
			}
		}

		visitDir(srcDir, Identifier());
	}

	void onPluginDir(string dir)
	{
		RawPluginInfo info;
		info.name = dir.pathSplitter.back;

		//writefln("Plugin: %s in %s", info.name, dir);
		foreach (DirEntry entry; dirEntries(dir, SpanMode.shallow, false))
		{
			string base = entry.name.pathSplitter.back;
			if (entry.isDir) {
				switch(base) {
					case "src":
						onPluginSrcDir(driver, info, entry.name);
						break;
					case "res":
						//writefln("-d res");
						break;
					default: break;
				}
			} else if (entry.isFile) {
				switch(base) {
					case "deps.txt":
						onPluginDepsFile(info, entry.name);
						break;
					default: break;
				}
			}
		}

		uint pluginIndex = cast(uint)detectedPlugins.length;

		if (info.name in pluginMap) {
			assert(false, text("Found multiple plugins named ", info.name));
		}

		pluginMap[info.name] = pluginIndex;

		if (info.name == rootPluginName) {
			foundRootPlugin = true;
			rootPluginIndex = pluginIndex;
		}

		detectedPlugins ~= info;
	}

	// Gather available plugins
	foreach (DirEntry entry; dirEntries("../plugins", SpanMode.shallow, false))
	{
		if (entry.isDir) onPluginDir(entry.name);
	}

	assert(foundRootPlugin, text("Cannot find root plugin ", rootPluginName));

	uint[] stack;
	uint[] selectedPlugins;

	void walkDependencies(uint index) {
		import std.algorithm : countUntil;

		// Already loaded by some other plugin
		if (detectedPlugins[index].isSelected) return;

		stack ~= index;

		if (detectedPlugins[index].isOnStack) {
			stderr.writefln("Detected loop of plugin dependencies:");
			ptrdiff_t from = countUntil(stack, index);
			foreach(i; stack[from..$])
			{
				if (i == index) stderr.writeln("> ", detectedPlugins[i].name);
				else stderr.writeln("- ", detectedPlugins[i].name);
			}
			assert(false);
		}

		selectedPlugins ~= index;
		detectedPlugins[index].isOnStack = true;
		detectedPlugins[index].isSelected = true;

		foreach(string depName; detectedPlugins[index].dependencies)
		{
			if (auto depIndex = depName in pluginMap) {
				walkDependencies(*depIndex);
			} else {
				assert(false, format("Cannot find dependency `%s` of `%s`", depName, detectedPlugins[index].name));
			}
		}

		detectedPlugins[index].isOnStack = false;
		stack.length--;
	}

	// Gather all dependencies and detect cyclic dependencies
	walkDependencies(rootPluginIndex);

	uint numSourceFilesLoaded = 0;
	bool loadedMainFile = false;
	size_t mainPlugin;

	foreach (i; selectedPlugins)
	{
		RawPluginInfo* info = &detectedPlugins[i];

		foreach (string file; info.sourceFiles) {
			driver.addModule(SourceFileInfo(file));
			++numSourceFilesLoaded;
		}

		if (info.mainFile) {
			if (loadedMainFile) {
				stderr.writeln("Multiple plugins define main.vx file:");
				stderr.writeln("- ", info.name, " ", info.mainFile);
				stderr.writeln("- ", detectedPlugins[mainPlugin].name, " ", detectedPlugins[mainPlugin].mainFile);
				assert(false);
			}

			loadedMainFile = true;
			mainPlugin = i;
		}
	}

	auto endTime = currTime;
	stdout.flush;
	//stderr.writefln("Plugins scan time %ss", scaledNumberFmt(endTime - startTime));
	//stderr.writefln("Detected %s plugins in ../plugins", detectedPlugins.length);
	//stderr.writefln("Selected %s plugins starting from %s", selectedPlugins.length, rootPluginName);
	//stderr.writefln("Loaded %s source files", numSourceFilesLoaded);

	if (!loadedMainFile) {
		stderr.writeln("Cannot find main.vx");
		return Identifier();
	}

	return detectedPlugins[mainPlugin].mainModule;
}

void registerHostSymbols(CompilationContext* context)
{
	void regHostSymbol(alias member)(string symName, Identifier modId, LinkIndex hostModuleIndex)
	{
		//writefln("reg %s %s", hostModuleName, symName);
		Identifier symId = context.idMap.getOrReg(context, symName);
		static if (isFunction!member) { // pickup functions
			context.addHostSymbol(hostModuleIndex, symId, cast(void*)&member);
		} else static if (isFunctionPointer!member && !isType!member) { // pickup function pointers
			context.addHostSymbol(hostModuleIndex, symId, cast(void*)member);
		}
	}

	void regHostModule(alias Module)(string hostModuleName)
	{
		Identifier modId = context.idMap.getOrReg(context, hostModuleName);
		LinkIndex hostModuleIndex = context.getOrCreateExternalModule(modId, ObjectModuleKind.isHost);

		foreach(m; __traits(allMembers, Module))
		{
			alias member = __traits(getMember, Module, m);
			regHostSymbol!member(m, modId, hostModuleIndex);
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
	import deps.vma;
	import deps.zstd;
	import qoi;

	regHostModule!(deps.enet)("enet");
	regHostModule!(deps.glfw3)("glfw3");
	regHostModule!(deps.kernel32)("kernel32");
	regHostModule!(deps.lz4)("lz4");
	regHostModule!(deps.mdbx)("mdbx");
	regHostModule!(deps.mimalloc)("mimalloc");
	regHostModule!(deps.shaderc)("shaderc");
	regHostModule!(deps.tracy_ptr)("tracy");
	regHostModule!(deps.vma)("vma");
	regHostModule!(deps.zstd)("zstd");

	// host
	{
		Identifier modId = context.idMap.getOrReg(context, "host");
		LinkIndex hostModuleIndex = context.getOrCreateExternalModule(modId, ObjectModuleKind.isHost);
		regHostSymbol!host_print("host_print", modId, hostModuleIndex);
		regHostSymbol!(sin!float)("sin_f32", modId, hostModuleIndex);
		regHostSymbol!(sin!double)("sin_f64", modId, hostModuleIndex);
		regHostSymbol!(cos!float)("cos_f32", modId, hostModuleIndex);
		regHostSymbol!(cos!double)("cos_f64", modId, hostModuleIndex);
		regHostSymbol!(sqrt!float)("sqrt_f32", modId, hostModuleIndex);
		regHostSymbol!(sqrt!double)("sqrt_f64", modId, hostModuleIndex);
		regHostSymbol!__debugbreak("__debugbreak", modId, hostModuleIndex);
		regHostSymbol!(format_val!float)("format_f32", modId, hostModuleIndex);
		regHostSymbol!(format_val!double)("format_f64", modId, hostModuleIndex);
	}

	// QOI
	{
		Identifier modId = context.idMap.getOrReg(context, "qoi");
		LinkIndex hostModuleIndex = context.getOrCreateExternalModule(modId, ObjectModuleKind.isHost);
		regHostSymbol!qoi_encode("qoi_encode", modId, hostModuleIndex);
		regHostSymbol!qoi_decode("qoi_decode", modId, hostModuleIndex);
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
static import core.math;
extern(C) T sin(T)(T x) @safe pure nothrow @nogc { return core.math.sin(x); }
extern(C) T cos(T)(T x) @safe pure nothrow @nogc { return core.math.cos(x); }
extern(C) T sqrt(T)(T x) @safe pure nothrow @nogc { return core.math.sqrt(x); }
extern(C) void __debugbreak() {
	asm { int 3; }
}

extern(C) SliceString format_val(T)(char[64]* buf, T val) {
	import std.format;
	auto spec = singleSpec("%s");
	char[] bufSlice = (*buf)[];
	formatValue(bufSlice, val, spec);
	return SliceString((*buf)[0..64-bufSlice.length]);
}
