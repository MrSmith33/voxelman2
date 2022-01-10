module deps.tracy;

extern(C):

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
