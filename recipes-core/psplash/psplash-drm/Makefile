all: modeset

psplash:
	$(CC) $(CFLAGS) $(LDFLAGS) -o psplash-drm basic_splash_drm.c -I. `pkg-config --cflags --libs libdrm glib-2.0 gdk-pixbuf-2.0` -Wall -Os

clean:
	rm -rf psplash-drm
