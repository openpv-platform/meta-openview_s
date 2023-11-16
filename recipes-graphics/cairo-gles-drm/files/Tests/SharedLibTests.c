// C++ level context implementation test
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include "../cairo-gles-drm.h"
#include "Touch.h"

// Tests Prototypes:
static cairo_t *Test_CairoContext();
static cairo_surface_t *Test_CairoSurface();
static int Test_CairoDraw(cairo_t *cr, cairo_surface_t*img);

// Drawing Utilities

// End Drawing Utilities

// Names for touch events:
#define NAME_ELEMENT(element) [element] = #element

// Assumes touch_continue is the last touch type
static const char * const touch_names[touch_continue + 1] = {
	[0 ... touch_continue] = NULL,
	NAME_ELEMENT(touch_none),		NAME_ELEMENT(touch_down),
	NAME_ELEMENT(touch_up),			NAME_ELEMENT(touch_continue),
};

int main()
{
	TouchEvent item;
	int touch_wait_s = 5;
	int touch_wait_count = 15;

	int ret = InitWindowInterop(0, 0, 300, 300, true);
	if (ret != 0)
	{
		printf("Error Initializing SDL Client! Exiting Test...\n\r");
		exit(-1);
	}

	cairo_t *ctx = Test_CairoContext();
	if (!ctx)
	{
		printf("Error getting Cairo Context! Exiting Test...\n\r");
		ret = -1;
		goto exit;
	}

	cairo_surface_t *surf = Test_CairoSurface();
	if (!surf)
	{
		printf("Error getting Cairo Surface! Exiting Test...\n\r");
		ret = -1;
		goto exit;
	}

	printf("Initial Software Tests Passed, Touch screen to validate touch...\n\r");
	printf("Touches received:\n\r");

	while (1) {
		while (dequeue(&item, 1000)) {
			printf("  %s x: %d y: %d id: %d count: %d\n\r",
				touch_names[item.type],
				item.x,
				item.y,
				item.id,
				touch_wait_count);
			touch_wait_count -= 1;
		}
		// printf("Waited 1s: %d\n\r", touch_wait_s);
		touch_wait_s -= 1;
		if (touch_wait_count <= 0 || touch_wait_s <= 0)
			break;
	}

	printf("\n\rDrawing on screen for physical inspection...\n\r");

	ret = Test_CairoDraw(ctx, surf);
	if (ret != 0)
	{
		printf("Error Drawing on surface...\n\r");
		ret = -1;
		goto exit;
	}

exit:
	DestoryWindowContext();
    return ret;
}


static cairo_t* Test_CairoContext()
{
	return GetCairoContext();
}

static cairo_surface_t* Test_CairoSurface()
{
	return GetCairoSurface();
}

static int Test_CairoDraw(cairo_t *cr, cairo_surface_t*img)
{
	int x,y;
	double colors[2][3] = {
		{0.8f, 0.2f, 0.25f},
		{0.4f, 0.7f, 0.25f},
	};
	int color_idx = 0;
	int count;
	cairo_text_extents_t te;
	static const char * const pngFile = "/usr/share/cairo-gles-drm/Cloud.png";
	cairo_surface_t *cloud;
	double cur_x, cur_y;

	cairo_surface_type_t s_t = cairo_surface_get_type (img);
	printf("Cairo Surface Type %d\n", s_t);

	GetWindowDimensions(&x, &y);
	printf("Window dimensions %dx%d\n", x, y);

	cairo_set_operator (cr, CAIRO_OPERATOR_OVER);

	cairo_scale (cr, (double) x / 1.0f, (double) y / 1.0f);

	printf("Set a background color and draw a curved line.\n");
	for (count = 0; count < 2; ++count) {
		// Set background
		cairo_set_source_rgba (cr, colors[color_idx][0], colors[color_idx][1], colors[color_idx][2], 1.0f);
		cairo_paint (cr);
		color_idx = (color_idx == 0) ? 1 : 0;
		cairo_set_source_rgba (cr, colors[color_idx][0], colors[color_idx][1], colors[color_idx][2], 1.0f);
		cairo_set_line_width (cr, .1);
		cairo_move_to (cr, 0.1f, 0.2f);
		cairo_curve_to (cr,
				0.5f,
				0.7f,
				0.75f,
				0.1f,
				0.8f,
				0.8f);
		cairo_stroke (cr);

		GLSwapBuffers(img);
		sleep(1);
		if (color_idx == 1)
			printf("  Invert colors\n");
	}
	printf("Overlay cloud image from png file.\n");
	if (access(pngFile, F_OK) == 0) {
		int img_width, img_height;
		cloud = cairo_image_surface_create_from_png (pngFile);
		img_width = cairo_image_surface_get_width(cloud);
		img_height = cairo_image_surface_get_height(cloud);
		printf("Image width [%d] height [%d]\n", img_width, img_height);
		cairo_surface_set_device_scale(cloud, (double) x / 1.0f, (double) y / 1.0f);
		cairo_set_source_surface (cr, cloud, .25, .5);
		cairo_paint (cr);
		GLSwapBuffers(img);
		cairo_surface_destroy (cloud);

		cairo_move_to (cr, 0.27, 0.54);

		cairo_select_font_face (cr, "cairo :monospace", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
		cairo_set_font_size (cr, 0.05f);
		cairo_text_extents(cr, "Cloud.png", &te);
		printf("Text Extents: width [%0.2f] height [%0.2f] x-bearing [%0.2f] y-bearing [%0.2f]\n",
					te.width, te.height, te.x_bearing, te.y_bearing);
		cairo_get_current_point(cr, &cur_x, &cur_y);
		printf("Starting point x [%0.2f] y [%0.2f]\n", cur_x, cur_y);
		cairo_set_source_rgba (cr, colors[color_idx][0], colors[color_idx][1], colors[color_idx][2], 1.0f);
		cairo_show_text(cr, "Cloud.png");
		cairo_get_current_point(cr, &cur_x, &cur_y);
		printf("Ending point x [%0.2f] y [%0.2f]\n", cur_x, cur_y);
		cairo_fill(cr);
		GLSwapBuffers(img);
		sleep(2);
	}
	else {
		printf("Error, file '%s' does not exist.\n", pngFile);
	}
	return 0;
}