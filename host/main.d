import std.string : toStringz;
import std.stdio;
import std.traits : isFunction;
import all;

void main() {
	import deps.kernel32 : SetConsoleOutputCP;
	SetConsoleOutputCP(65001);

	auto startCompileTime = currTime;
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
	auto endCompileTime = currTime;
	writefln("Compiled in %ss", scaledNumberFmt(endCompileTime - startCompileTime));

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
	driver.addModule(SourceFileInfo("../plugins/core/utils.vx"));
	driver.addModule(SourceFileInfo("../plugins/core/vulkan.vx"));
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
			static if (isFunction!member) { // only pickup functions
				//writefln("reg %s %s", hostModuleName, m);
				driver.addHostSymbol(hostModuleIndex, HostSymbol(m, cast(void*)&member));
			}
		}
	}

	import deps.glfw3;
	import deps.enet;
	import deps.lz4;
	import deps.mdbx;
	import deps.kernel32;

	regHostModule!(deps.glfw3)("glfw3");
	regHostModule!(deps.enet)("enet");
	regHostModule!(deps.lz4)("lz4");
	regHostModule!(deps.mdbx)("mdbx");
	regHostModule!(deps.kernel32)("kernel32");

	LinkIndex hostModuleIndex = driver.getOrCreateHostModuleIndex();
	driver.addHostSymbol(hostModuleIndex, HostSymbol("host_print", cast(void*)&host_print));
}

extern(C) void host_print(SliceString str) {
	write(str.slice);
}
