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

TracyCZoneCtx ___tracy_emit_zone_begin(const TracyLoc* srcloc, int active);
TracyCZoneCtx ___tracy_emit_zone_begin_callstack(const TracyLoc* srcloc, int depth, int active);
void ___tracy_emit_zone_end(TracyCZoneCtx ctx);
void ___tracy_emit_frame_mark(const char* name);
void ___tracy_emit_frame_mark_start(const char* name);
void ___tracy_emit_frame_mark_end(const char* name);
