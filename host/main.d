import std.string : toStringz;
import std.stdio;
import std.traits : isFunction, isFunctionPointer, isType;
import all;
import deps.tracy;

void main() {
	import deps.kernel32 : SetConsoleOutputCP;
	SetConsoleOutputCP(65001);

	load_dll!(deps.tracy)("TracyProfiler.dll");

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

	driver.beginCompilation();
	//driver.context.setDumpFilter("createInstance");
	// add files
	regModules(driver);

	static loc = TracyLoc("Compile", "main.d", "main.d", 42, 0xFF00FF);
	auto tracy_ctx = ___tracy_emit_zone_begin(&loc, 1);
	// compile
	try {
		driver.compile();
	} catch(CompilationException e) {
		if (e.isICE) throw e;
		writefln("Compile error:");
		writeln(driver.context.errorSink.text);
		return;
	} catch(Throwable e) {
		driver.context.print_analysis_stack;
		writeln(driver.context.errorSink.text);
		auto func = driver.context.currentFunction;
		if (func) {
			auto mod = func._module.get!ModuleDeclNode(&driver.context);
			writefln("Failed in %s.%s", driver.context.idString(mod.id), driver.context.idString(func.id));
		}
		throw e;
	}
	driver.markCodeAsExecutable();
	auto endCompileTime = currTime;
	___tracy_emit_zone_end(tracy_ctx);
	writefln("Compiled in %ss", scaledNumberFmt(endCompileTime - startCompileTime));
	//writefln("RO: %s", driver.context.roStaticDataBuffer.bufPtr);

	stdout.flush;

	auto runFunc = driver.context.getFunctionPtr!(void)("main", "run");

	runFunc();
}

void regModules(ref Driver driver)
{
	registerHostSymbols(driver);
	driver.addModule(SourceFileInfo("../plugins/core/glfw3.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/kernel32.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/lz4.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/enet.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/mdbx.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/host.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/main.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/tracy.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/utils.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/vulkan/dispatch_device.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/vulkan/functions.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/vulkan/types.vx"));
}

void registerHostSymbols(ref Driver driver)
{
	void regHostModule(alias Module)(string hostModuleName)
	{
		ObjectModule hostModule = {
			kind : ObjectModuleKind.isHost,
			id : driver.context.idMap.getOrRegNoDup(&driver.context, hostModuleName)
		};
		LinkIndex hostModuleIndex = driver.context.objSymTab.addModule(hostModule);

		foreach(m; __traits(allMembers, Module))
		{
			alias member = __traits(getMember, Module, m);
			static if (isFunction!member) { // pickup functions
				//writefln("reg %s %s", hostModuleName, m);
				driver.addHostSymbol(hostModuleIndex, HostSymbol(m, cast(void*)&member));
			} else static if (isFunctionPointer!member && !isType!member) { // pickup function pointers
				//writefln("reg %s %s", hostModuleName, m);
				driver.addHostSymbol(hostModuleIndex, HostSymbol(m, cast(void*)member));
			}
		}
	}

	import deps.enet;
	import deps.glfw3;
	import deps.kernel32;
	import deps.lz4;
	import deps.mdbx;
	import deps.mimalloc;
	import deps.tracy;

	regHostModule!(deps.enet)("enet");
	regHostModule!(deps.glfw3)("glfw3");
	regHostModule!(deps.kernel32)("kernel32");
	regHostModule!(deps.lz4)("lz4");
	regHostModule!(deps.mdbx)("mdbx");
	regHostModule!(deps.mimalloc)("mimalloc");
	regHostModule!(deps.tracy)("tracy");

	LinkIndex hostModuleIndex = driver.getOrCreateHostModuleIndex();
	driver.addHostSymbol(hostModuleIndex, HostSymbol("host_print", cast(void*)&host_print));
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

extern(C) void host_print(SliceString str) {
	write(str.slice);
}
