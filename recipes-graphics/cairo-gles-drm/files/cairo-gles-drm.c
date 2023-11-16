#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "cairo-gles-drm.h"
#include "TouchDevice.h"
#include "CairoContext.h"
#include "common.h"
#include "drm-common.h"

static InteropDisplay 	display = { 0 };
static InteropWindow 	window  = { 0 };
static CairoContext 	context = { 0 };
static const struct gbm *gbm;
static const struct drm *drm;
struct egl	eglData;
struct egl* const egl = &eglData;

void GetWindowDimensions(int *w, int *h)
{
	if (window.fullscreen)
	{
		*w = window.toplevel_w;
		*h = window.toplevel_h;
	}
	else
	{
		*w = window.req_width;
		*h = window.req_height;
	}
}

bool GetTouchData(TouchEvent *data, int timeoutInMs)
{
	bool result = false;
	result = dequeue(data, timeoutInMs);
	return result;
}

int InitWindowInterop(int x, int y, int w, int h, bool fullScreen)
{
	int ret = 0;
	const char *device = NULL;
	char mode_str[DRM_DISPLAY_MODE_LEN] = "";
	unsigned int vrefresh = 0;
	// TODO: Do we make these user specified?
	uint32_t format = DRM_FORMAT_XRGB8888;
	uint64_t modifier = DRM_FORMAT_MOD_LINEAR;
	// We went with direct to surface, not providing buffer objects
	bool surfaceless = false;
	// TODO: Not sure we need these ties back and forth
	display.window = &window;
	window.display = &display;
	display.initialized = false;
	window.initialized = false;

	drm = init_drm_legacy(device, mode_str, vrefresh);
	if (!drm) {
		printf("failed to initialize legacy DRM\n");
		return -1;
	}
	window.toplevel_w = drm->mode->hdisplay;
	window.toplevel_h = drm->mode->vdisplay;

	gbm = init_gbm(drm->fd, drm->mode->hdisplay, drm->mode->vdisplay,
			format, modifier, surfaceless);
	if (!gbm) {
		printf("failed to initialize GBM\n");
		return -1;
	}

	if (init_egl(egl, gbm) != 0) {
		printf("failed to initialize EGL\n");
		return -1;
	}

	// We're using kmscube init for drm/gbm/egl, but move the results to Ahsoka library egl structure
	display.egl.dpy = egl->display;
	display.egl.ctx = egl->context;
	display.egl.conf = egl->config;
	window.egl_surface = egl->surface;
	if (fullScreen)
		window.fullscreen = 1;
	window.req_width = w;
	window.req_height = h;

	ret = InitTouchDevice();
	if (ret != 0) {
		printf("[] SOL: ERROR InitTouchDevice [%d]\n\r", ret);
		return -1;
	}

	context.display = &display;
	context.window = &window;

	ret = InitCairoFW(&context);
	if (ret != 0)
		return -1;

	display.initialized = true;
	window.initialized = true;
	printf("[] Done with window interop INIT...\n\r");

	return 0;
}

cairo_surface_t* GetCairoSurface()
{
	if (!context.cairo_surface)
		return NULL;

	return context.cairo_surface;
}

cairo_t* GetCairoContext()
{
	if (!context.cr)
		return NULL;

	return context.cr;
}

// TODO: Probably need to return value here for error handling
void GLSwapBuffers(cairo_surface_t *surface)
{
	// Preserve two bo pointers for keeping one locked while user draws and releasing previously locked
	static struct gbm_bo *bo = NULL;
	static struct gbm_bo *next_bo = NULL;
	// First run we do not have two buffer objects to handle yet
	bool first_run = false;
	struct drm_fb *fb;
	int ret = 0;
    cairo_status_t status;

	cairo_gl_surface_swapbuffers(surface);
	status = cairo_surface_status(surface);
    if (status != CAIRO_STATUS_SUCCESS) {
        printf("SOL: cairo_status error [%d]\n", status);
    }

	/* TODO: Move to drm-legacy.c as new function */
	// From drm_legacy_run() in kmscube:
	// First time through, only apply current buffer
	if (bo == NULL) {
		first_run = true;
		bo = gbm_surface_lock_front_buffer(gbm->surface);
		if (!bo) {
			fprintf(stderr, "bo is null\n");
		}
		fb = drm_fb_get_from_bo(bo);
	}
	else {
		next_bo = gbm_surface_lock_front_buffer(gbm->surface);
		fb = drm_fb_get_from_bo(next_bo);
	}
	if (!fb) {
		fprintf(stderr, "Failed to get a framebuffer from BO\n");
	}

	/* May want to switch this to drmModePageFlip - see kmscube drm-legacy.c::legacy_run() */
	ret = drmModeSetCrtc(drm->fd, drm->crtc_id, fb->fb_id, 0, 0,
			&drm->connector_id, 1, drm->mode);
	if (ret) {
		printf("failed to set mode: %s\n", strerror(errno));
	}
	// Except for first run, we now release the non-displayed buffer and prepare for next
	if (bo && next_bo) {
		gbm_surface_release_buffer(gbm->surface, bo);
		bo = next_bo;
	}
}

bool UpdateSwapInterval(int interval)
{
	return eglSwapInterval(display.egl.dpy, interval);
}

void DestoryWindowContext()
{
	DestroyTouchDevice();
	// Start from the top down with Cairo
	cairo_device_destroy(context.cairo_device);
	cairo_device_finish(context.cairo_device);

	cairo_surface_destroy(context.cairo_surface);
	cairo_surface_finish(context.cairo_surface);

	if (context.data) 
		free(context.data);
	context.data = NULL;

	if (drm->fd >= 0)
		close(drm->fd);
}
