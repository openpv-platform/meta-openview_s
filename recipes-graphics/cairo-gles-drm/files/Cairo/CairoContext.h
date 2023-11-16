#ifndef CAIROCONTEXT_H_
#define CAIROCONTEXT_H_

#include <cairo/cairo.h>
#include "interop.h"

#ifdef  __cplusplus
extern "C" {
#endif

typedef struct
{
    cairo_surface_t *cairo_surface;
    cairo_device_t  *cairo_device;
    cairo_t         *cr;
    unsigned char   *data;    

    InteropDisplay   *display;
    InteropWindow    *window;
} CairoContext;

int
InitCairoFW(CairoContext *context);

#ifdef  __cplusplus
}
#endif
#endif