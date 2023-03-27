# Makefile that demonstrates how to compile the overlays we use
all: 7-inch-screen-overlay m4-can-overlay

7-inch-screen-overlay:
	dtc -@ -O dtb -o disabled_7-inch-screen-overlay.dtbo 7-inch-screen-overlay.dts

m4-can-overlay:
	dtc -@ -O dtb -o disabled_m4-can-overlay.dtbo m4-can-overlay.dts

clean:
	rm -rf disabled_m4-can-overlay.dtbo disabled_7-inch-screen-overlay.dtbo
