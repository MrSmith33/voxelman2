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
