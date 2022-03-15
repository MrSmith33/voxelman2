module deps.tracy;

extern(C):

struct TracyLoc {
	const char* name;
	const char* func;
	const char* file;
	uint line;
	uint color;
}

struct TracyCZoneCtx {
	uint id;
	int active;
}
