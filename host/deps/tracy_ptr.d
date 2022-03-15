module deps.tracy_ptr;

public import deps.tracy;

extern(C):

void function() tracy_startup_profiler;
void function() tracy_shutdown_profiler;
TracyCZoneCtx function(const TracyLoc* srcloc, int active) tracy_emit_zone_begin;
TracyCZoneCtx function(const TracyLoc* srcloc, int depth, int active) tracy_emit_zone_begin_callstack;
void function(TracyCZoneCtx ctx) tracy_emit_zone_end;
void function(const char* name) tracy_emit_frame_mark;
void function(const char* name) tracy_emit_frame_mark_start;
void function(const char* name) tracy_emit_frame_mark_end;

void function(const char* name) tracy_set_thread_name;

void function(const char* name, double val) tracy_emit_plot;
void function(const char* txt, size_t size) tracy_emit_message_appinfo;
void function(const char* txt, size_t size, int callstack) tracy_emit_message;
void function(const char* txt, int callstack) tracy_emit_messageL;
void function(const char* txt, size_t size, uint color, int callstack) tracy_emit_messageC;
void function(const char* txt, uint color, int callstack) tracy_emit_messageLC;
