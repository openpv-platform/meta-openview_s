// C++ level context implementation test
#include <stdio.h>
#include <unistd.h>
#include <fstream>
#include <sstream>
#include <string>
#include <stdlib.h>
#include <iostream>
#include <algorithm>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include "cairo-gles-drm.h"
#include "Touch.h"

// Tests Prototypes:
static int DrawMainSurface(cairo_t *cr, cairo_surface_t*img, std::string);


// Names for touch events:
#define NAME_ELEMENT(element) [element] = #element


int main(int argc, char *argv[])
{

	std::string fileToRead = "/tmp/workingtext.txt";
	if (argc == 2)
	{
		fileToRead = argv[1];
	}
	
	printf("Startup File %s\n", fileToRead);


	int ret = InitWindowInterop(0, 0, 300, 300, true);
	if (ret != 0)
	{
		printf("Error Initializing SDL Client! Exiting Test...\r\n");
		exit(-1);
	}

	cairo_t *ctx = GetCairoContext();
	if (!ctx)
	{
		printf("Error getting Cairo Context! Exiting Test...\r\n");
		ret = -1;
		DestoryWindowContext();
    	return ret;
	}

	cairo_surface_t *surf = GetCairoSurface();
	if (!surf)
	{
		printf("Error getting Cairo Surface! Exiting Test...\r\n");
		ret = -1;
		DestoryWindowContext();
    	return ret;
	}

	ret = DrawMainSurface(ctx, surf, fileToRead);
	if (ret != 0)
	{
		printf("Error Drawing on surface...\r\n");
		ret = -1;
		DestoryWindowContext();
    	return ret;
	}

}


static int DrawMainSurface(cairo_t *cr, cairo_surface_t*img, std::string fileToRead)
{
	int x,y;
	double colors[2][3] = 
	{
		{01.0f, 1.0f, 1.0f}, // White
		{0.0f, 0.0f, 0.0f},  // Black
	};

	cairo_text_extents_t te;
	static const char * const pngFile = "Cloud.png";
	cairo_surface_t *cloud;
	double cur_x, cur_y;

	cairo_surface_type_t s_t = cairo_surface_get_type (img);

	GetWindowDimensions(&x, &y);
	printf("Window dimensions %dx%d\n", x, y);
	cairo_set_operator (cr, CAIRO_OPERATOR_OVER);

	int background_color = 0;
	int forground_color = 1;

	int count = 0;
	while(true)
	{
		std::string displayTxt = "Distro Upgrade in Progress";
		
		// Set background
		cairo_set_source_rgba (cr, colors[background_color][0], colors[background_color][1], colors[background_color][2], 1.0f);
		cairo_paint (cr);
	
		cairo_select_font_face (cr, "cairo :monospace", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);//, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD
		cairo_set_font_size (cr, 28.0f);
		cairo_text_extents(cr, displayTxt.c_str(), &te);
	
		// Center Text on Screen
		double textX = x / 2 - (te.x_bearing + te.width / 2);
		double textY = y / 2 + te.y_bearing - te.height / 2;
		cairo_move_to (cr, textX, textY);

		displayTxt = displayTxt + std::string((count % 3 ) + 1, '.');
		cairo_set_source_rgba (cr, colors[forground_color][0], colors[forground_color][1], colors[forground_color][2], 1.0f);
		cairo_show_text(cr,displayTxt.c_str());
		cairo_fill(cr);

		std::ifstream t(fileToRead);
		if (t.good())
		{
			std::stringstream buffer;
			buffer << t.rdbuf();
			displayTxt = buffer.str();
				
			displayTxt.erase(std::remove(displayTxt.begin(), displayTxt.end(), '\n'), displayTxt.cend());
		}
		else
		{
			displayTxt = "Waiting";
		}

		if (displayTxt == "exit")
			return 0;
		
		cairo_set_font_size (cr, 23.0f);
		cairo_text_extents(cr, displayTxt.c_str(), &te);
	
		// Center Text on Screen
		textX = x / 2 - (te.x_bearing + te.width / 2);
		textY = y / 2 - te.y_bearing - te.height / 2;
		cairo_move_to (cr, textX, textY);

		cairo_show_text(cr,displayTxt.c_str());
		cairo_fill(cr);

		GLSwapBuffers(img);
		sleep(1);

		count++;
	}

	return 0;
}