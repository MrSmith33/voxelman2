module deps.tracy_lib;

import deps.tracy;

extern(C):

void ___tracy_startup_profiler();
void ___tracy_shutdown_profiler();
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

