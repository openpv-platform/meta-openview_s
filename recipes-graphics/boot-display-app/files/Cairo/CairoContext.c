#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <cairo/cairo.h>
#include <cairo/cairo-gl.h>
#include "CairoContext.h"

// FROM gl-cairo-simple
// Calls to this function have been removed below, but kept as comments in case
// we want to go this route in the future. Documentation for cairo says opengl
// image type is deprecated and opengl support is removed in v1.18 (we are v1.16)
static cairo_t* create_cairo_context (  int               width,
                                        int               height,
                                        int               channels,
                                        cairo_surface_t** surf,
                                        unsigned char**   buffer)
{
	cairo_t* cr;

	// create cairo-surface/context to act as OpenGL-texture source
	*buffer = calloc (channels * width * height, sizeof (unsigned char));
	if (!*buffer)
	{
		return NULL;
	}

	*surf = cairo_image_surface_create_for_data (*buffer,
						     CAIRO_FORMAT_ARGB32,
						     width,
						     height,
						     channels * width);
	if (cairo_surface_status (*surf) != CAIRO_STATUS_SUCCESS)
	{
		free (*buffer);
		return NULL;
	}

	cr = cairo_create (*surf);
	if (cairo_status (cr) != CAIRO_STATUS_SUCCESS)
	{
		free (*buffer);
		return NULL;
	}

	return cr;
}

int InitCairoFW(CairoContext *context)
{
    cairo_status_t status;
    context->cairo_device = cairo_egl_device_create(context->display->egl.dpy, context->display->egl.ctx);
    status = cairo_device_status(context->cairo_device);
    if ( status != CAIRO_STATUS_SUCCESS ) {
        printf("cairo_device_status error [%d]\r\n", status);
        return -1;
    }

    if (context->window->fullscreen)
    {
        printf("Fullscreen %dx%d\r\n", context->window->toplevel_w, context->window->toplevel_h);
        // context->cr = create_cairo_context(context->window->toplevel_w,
        //                                     context->window->toplevel_h,
        //                                     4,
        //                                     &context->cairo_surface,
        //                                     &context->data);
        context->cairo_surface = cairo_gl_surface_create_for_egl(context->cairo_device,
                                                            context->window->egl_surface,
                                                            context->window->toplevel_w,
                                                            context->window->toplevel_h);
    }
    else
    {
        printf("Window Requested %dx%d\r\n", context->window->req_width, context->window->req_height);
        // context->cr = create_cairo_context(context->window->req_width,
        //                                     context->window->req_height,
        //                                     4,
        //                                     &context->cairo_surface,
        //                                     &context->data);
        context->cairo_surface = cairo_gl_surface_create_for_egl(context->cairo_device,
                                                            context->window->egl_surface,
                                                            context->window->req_width,
                                                            context->window->req_height);
    }

    // if (context->cr == NULL)
    //     return -1;
    // if (cairo_status(context->cr) != CAIRO_STATUS_SUCCESS)
    //     return -1;

    if (context->cairo_surface == NULL)
        return -1;
    printf("Cairo Surface Creation: Success\r\n");

    // printf("Created surface %dx%d\n", cairo_image_surface_get_width(context->cairo_surface), cairo_image_surface_get_height(context->cairo_surface));
    context->cr = cairo_create(context->cairo_surface);
    status = cairo_status(context->cr);
    if (status != CAIRO_STATUS_SUCCESS) {
        printf("cairo_status error [%d]\r\n", status);
        return -1;
    }
    return 0;
}
