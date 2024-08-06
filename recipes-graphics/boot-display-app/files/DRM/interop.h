#ifndef INTEROP_H_
#define INTEROP_H_

#include <unistd.h>
#include <stdbool.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>

/* TODO: Hopefully, abstract window & display 
 * at least compile time decision 
 */
struct InteropWindow;
typedef struct {
	struct {
		EGLDisplay dpy;
		EGLContext ctx;
		EGLConfig conf;
	} egl;
	bool initialized;
	struct InteropWindow *window;
} InteropDisplay;

typedef struct InteropWindow {
	InteropDisplay *display;
	EGLSurface egl_surface;
	int fullscreen;
	bool wait_for_configure;

	int req_width, req_height;	// Requested Dimensions by User
	int toplevel_w, toplevel_h;	// toplevel Dimensions if fullscreen
	bool initialized;
} InteropWindow;

#endif