/// Copyright Michael D. Parker 2018.
/// https://github.com/BindBC/bindbc-glfw
module deps.glfw3;

extern(C) @nogc nothrow {
	alias GLFWglproc = void function();
	alias GLFWvkproc = void function();
}

struct GLFWmonitor;
struct GLFWwindow;
struct GLFWcursor;
struct GLFWvidmode;
struct GLFWgammaramp;
struct GLFWimage;
struct GLFWgamepadstate;

extern(C) nothrow {
	alias GLFWerrorfun = void function(int,const(char)*);
	alias GLFWwindowposfun = void function(GLFWwindow*,int,int);
	alias GLFWwindowsizefun = void function(GLFWwindow*,int,int);
	alias GLFWwindowclosefun = void function(GLFWwindow*);
	alias GLFWwindowrefreshfun = void function(GLFWwindow*);
	alias GLFWwindowfocusfun = void function(GLFWwindow*,int);
	alias GLFWwindowiconifyfun = void function(GLFWwindow*,int);
	alias GLFWwindowmaximizefun = void function(GLFWwindow*,int);
	alias GLFWframebuffersizefun = void function(GLFWwindow*,int,int);
	alias GLFWwindowcontentscalefun = void function(GLFWwindow*,float,float);
	alias GLFWmousebuttonfun = void function(GLFWwindow*,int,int,int);
	alias GLFWcursorposfun = void function(GLFWwindow*,double,double);
	alias GLFWcursorenterfun = void function(GLFWwindow*,int);
	alias GLFWscrollfun = void function(GLFWwindow*,double,double);
	alias GLFWkeyfun = void function(GLFWwindow*,int,int,int,int);
	alias GLFWcharfun = void function(GLFWwindow*,uint);
	alias GLFWcharmodsfun = void function(GLFWwindow*,uint,int);
	alias GLFWdropfun = void function(GLFWwindow*,int,const(char*)*);
	alias GLFWmonitorfun = void function(GLFWmonitor*,int);
	alias GLFWjoystickfun = void function(int,int);
}

extern(C) @nogc nothrow:
// 3.0
int glfwInit();
void glfwTerminate();
void glfwGetVersion(int*,int*,int*);
const(char)* glfwGetVersionString();
GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun);
GLFWmonitor** glfwGetMonitors(int*);
GLFWmonitor* glfwGetPrimaryMonitor();
void glfwGetMonitorPos(GLFWmonitor*,int*,int*);
void glfwGetMonitorPhysicalSize(GLFWmonitor*,int*,int*);
const(char)* glfwGetMonitorName(GLFWmonitor*);
GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun);
const(GLFWvidmode)* glfwGetVideoModes(GLFWmonitor*,int*);
const(GLFWvidmode)* glfwGetVideoMode(GLFWmonitor*);
void glfwSetGamma(GLFWmonitor*,float);
const(GLFWgammaramp*) glfwGetGammaRamp(GLFWmonitor*);
void glfwSetGammaRamp(GLFWmonitor*,const(GLFWgammaramp)*);
void glfwDefaultWindowHints();
void glfwWindowHint(int,int);
GLFWwindow* glfwCreateWindow(int,int,const(char)*,GLFWmonitor*,GLFWwindow*);
void glfwDestroyWindow(GLFWwindow*);
int glfwWindowShouldClose(GLFWwindow*);
void glfwSetWindowShouldClose(GLFWwindow*,int);
void glfwSetWindowTitle(GLFWwindow*,const(char)*);
void glfwGetWindowPos(GLFWwindow*,int*,int*);
void glfwSetWindowPos(GLFWwindow*,int,int);
void glfwGetWindowSize(GLFWwindow*,int*,int*);
void glfwSetWindowSize(GLFWwindow*,int,int);
void glfwGetFramebufferSize(GLFWwindow*,int*,int*);
void glfwIconifyWindow(GLFWwindow*);
void glfwRestoreWindow(GLFWwindow*);
void glfwShowWindow(GLFWwindow*);
void glfwHideWindow(GLFWwindow*);
GLFWmonitor* glfwGetWindowMonitor(GLFWwindow*);
int glfwGetWindowAttrib(GLFWwindow*,int);
void glfwSetWindowUserPointer(GLFWwindow*,void*);
void* glfwGetWindowUserPointer(GLFWwindow*);
GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow*,GLFWwindowposfun);
GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow*,GLFWwindowsizefun);
GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow*,GLFWwindowclosefun);
GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow*,GLFWwindowrefreshfun);
GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow*,GLFWwindowfocusfun);
GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow*,GLFWwindowiconifyfun);
GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow*,GLFWframebuffersizefun);
void glfwPollEvents();
void glfwWaitEvents();
int glfwGetInputMode(GLFWwindow*,int);
void glfwSetInputMode(GLFWwindow*,int,int);
int glfwGetKey(GLFWwindow*,int);
int glfwGetMouseButton(GLFWwindow*,int);
void glfwGetCursorPos(GLFWwindow*,double*,double*);
void glfwSetCursorPos(GLFWwindow*,double,double);
GLFWkeyfun glfwSetKeyCallback(GLFWwindow*,GLFWkeyfun);
GLFWcharfun glfwSetCharCallback(GLFWwindow*,GLFWcharfun);
GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow*,GLFWmousebuttonfun);
GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow*,GLFWcursorposfun);
GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow*,GLFWcursorenterfun);
GLFWscrollfun glfwSetScrollCallback(GLFWwindow*,GLFWscrollfun);
int glfwJoystickPresent(int);
float* glfwGetJoystickAxes(int,int*);
ubyte* glfwGetJoystickButtons(int,int*);
const(char)* glfwGetJoystickName(int);
void glfwSetClipboardString(GLFWwindow*,const(char)*);
const(char)* glfwGetClipboardString(GLFWwindow*);
double glfwGetTime();
void glfwSetTime(double);
void glfwMakeContextCurrent(GLFWwindow*);
GLFWwindow* glfwGetCurrentContext();
void glfwSwapBuffers(GLFWwindow*);
void glfwSwapInterval(int);
int glfwExtensionSupported(const(char)*);
GLFWglproc glfwGetProcAddress(const(char)*);

// 3.1
void glfwGetWindowFrameSize(GLFWwindow*,int*,int*,int*,int*);
void glfwPostEmptyEvent();
GLFWcursor* glfwCreateCursor(const(GLFWimage)*,int,int);
GLFWcursor* glfwCreateStandardCursor(int);
void glfwDestroyCursor(GLFWcursor*);
void glfwSetCursor(GLFWwindow*,GLFWcursor*);
GLFWcharmodsfun glfwSetCharModsCallback(GLFWwindow*,GLFWcharmodsfun);
GLFWdropfun glfwSetDropCallback(GLFWwindow*,GLFWdropfun);

// 3.2
void glfwSetWindowIcon(GLFWwindow*,int,const(GLFWimage)*);
void glfwSetWindowSizeLimits(GLFWwindow*,int,int,int,int);
void glfwSetWindowAspectRatio(GLFWwindow*,int,int);
void glfwMaximizeWindow(GLFWwindow*);
void glfwFocusWindow(GLFWwindow*);
void glfwSetWindowMonitor(GLFWwindow*,GLFWmonitor*,int,int,int,int,int);
void glfwWaitEventsTimeout(double);
const(char)* glfwGetKeyName(int,int);
long glfwGetTimerValue();
long glfwGetTimerFrequency();
int glfwVulkanSupported();
GLFWjoystickfun glfwSetJoystickCallback(GLFWjoystickfun);

// 3.3
void glfwInitHint(int,int);
int glfwGetError(const(char)**);
void glfwGetMonitorWorkarea(GLFWmonitor*,int*,int*,int*,int*);
void glfwGetMonitorContentScale(GLFWmonitor*,float*,float*);
void glfwSetMonitorUserPointer(GLFWmonitor*,void*);
void* glfwGetMonitorUserPointer(GLFWmonitor*);
void glfwWindowHintString(int,const(char)*);
void glfwGetWindowContentScale(GLFWwindow*,float*,float*);
float glfwGetWindowOpacity(GLFWwindow*);
void glfwSetWindowOpacity(GLFWwindow*,float);
void glfwRequestWindowAttention(GLFWwindow*);
void glfwSetWindowAttrib(GLFWwindow*,int,int);
GLFWwindowmaximizefun glfwSetWindowMaximizeCallback(GLFWwindow*,GLFWwindowmaximizefun);
GLFWwindowcontentscalefun glfwSetWindowContentScaleCallback(GLFWwindow*,GLFWwindowcontentscalefun);
int glfwGetKeyScancode(int);
const(ubyte)* glfwGetJoystickHats(int,int*);
const(char)* glfwGetJoystickGUID(int);
void glfwSetJoystickUserPointer(int,void*);
void* glfwGetJoystickUserPointer(int);
int glfwJoystickIsGamepad(int);
int glfwUpdateGamepadMappings(const(char)*);
const(char)* glfwGetGamepadName(int);
int glfwGetGamepadState(int,GLFWgamepadstate*);

// Vulkan
alias VkInstance = void*;
alias VkPhysicalDevice = void*;
alias VkResult = int;
struct VkAllocationCallbacks;
struct VkSurfaceKHR;
const(char)** glfwGetRequiredInstanceExtensions(uint*);
GLFWvkproc glfwGetInstanceProcAddress(VkInstance,const(char)*);
int glfwGetPhysicalDevicePresentationSupport(VkInstance,VkPhysicalDevice,uint);
VkResult glfwCreateWindowSurface(VkInstance,GLFWwindow*,const(VkAllocationCallbacks)*,VkSurfaceKHR*);
