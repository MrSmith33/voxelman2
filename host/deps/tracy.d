module deps.tracy;

extern(C):

version = TRACY_DLL;

struct TracyLoc
{
	const char* name;
	const char* func;
	const char* file;
	uint line;
	uint color;
}

struct TracyCZoneCtx
{
	uint id;
	int active;
}

version(TRACY_DLL) {
	TracyCZoneCtx function(const TracyLoc* srcloc, int active) ___tracy_emit_zone_begin;
	TracyCZoneCtx function(const TracyLoc* srcloc, int depth, int active) ___tracy_emit_zone_begin_callstack;
	void function(TracyCZoneCtx ctx) ___tracy_emit_zone_end;
	void function(const char* name) ___tracy_emit_frame_mark;
	void function(const char* name) ___tracy_emit_frame_mark_start;
	void function(const char* name) ___tracy_emit_frame_mark_end;

	void function(const char* name) ___tracy_set_thread_name;

	void function(const char* name, double val) ___tracy_emit_plot;
	void function(const char* txt, size_t size) ___tracy_emit_message_appinfo;
	void function(const char* txt, size_t size, int callstack) ___tracy_emit_message;
	void function(const char* txt, int callstack) ___tracy_emit_messageL;
	void function(const char* txt, size_t size, uint color, int callstack) ___tracy_emit_messageC;
	void function(const char* txt, uint color, int callstack) ___tracy_emit_messageLC;
} else {
	TracyCZoneCtx ___tracy_emit_zone_begin(const TracyLoc* srcloc, int active);
	TracyCZoneCtx ___tracy_emit_zone_begin_callstack(const TracyLoc* srcloc, int depth, int active);
	void ___tracy_emit_zone_end(TracyCZoneCtx ctx);
	void ___tracy_emit_frame_mark(const char* name);
	void ___tracy_emit_frame_mark_start(const char* name);
	void ___tracy_emit_frame_mark_end(const char* name);

	void ___tracy_set_thread_name(const char* name);

	void ___tracy_emit_plot(const char* name, double val);
	void ___tracy_emit_message_appinfo(const char* txt, size_t size);
	void ___tracy_emit_message(const char* txt, size_t size, int callstack);
	void ___tracy_emit_messageL(const char* txt, int callstack);
	void ___tracy_emit_messageC(const char* txt, size_t size, uint color, int callstack);
	void ___tracy_emit_messageLC(const char* txt, uint color, int callstack);
}
