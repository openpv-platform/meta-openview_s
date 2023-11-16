#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <pthread.h>
#include <time.h>
#include <semaphore.h>
#include <signal.h>
#include <errno.h>
#include <linux/input.h>
#include <sys/select.h>
#include <fcntl.h>
#include "TouchDevice.h"
#include <sys/resource.h>

#ifdef DEBUG
// Only for debug printing
#include "evtest-names.h"
static inline const char* typename(unsigned int type)
{
	return (type <= EV_MAX && events[type]) ? events[type] : "?";
}

static inline const char* codename(unsigned int type, unsigned int code)
{
	return (type <= EV_MAX && code <= maxval[type] && names[type] && names[type][code]) ? names[type][code] : "?";
}
#endif

#define DEV_INPUT_NAME	"/dev/input/event0"		// We only ever expect one input device
typedef enum TouchThreadState {
    TOUCH_THREAD_FAIL = -1,
    TOUCH_THREAD_INIT = 0,
    TOUCH_THREAD_RUNNING = 1,
	TOUCH_THREAD_STOP = 2
} TouchThreadState_t;

typedef struct {
    enum TouchType type;
	int cur_x;
	int cur_y;
    int id;
} TouchState;

static volatile TouchThreadState_t touchThreadState = TOUCH_THREAD_INIT;
static sem_t touchThreadSem;
static pthread_mutex_t touchThreadMutex;

static void* touch_thread(void * arg);
// From evtest.c
static int test_grab(int fd, int grab_flag);

/**
 * Grab and immediately ungrab the device.
 *
 * @param fd The file descriptor to the device.
 * @return 0 if the grab was successful, or 1 otherwise.
 */
static int test_grab(int fd, int grab_flag)
{
	int rc;

	rc = ioctl(fd, EVIOCGRAB, (void*)1);

	if (rc == 0 && !grab_flag)
		ioctl(fd, EVIOCGRAB, (void*)0);

	return rc;
}

static void* touch_thread(void * arg)
{
	int fd = -1;
	struct input_event ev[64];
	int i, rd;
	fd_set rdfs;
	TouchThreadState_t localThreadState;
	volatile struct timeval tv;
	TouchState state = {0};
	TouchEvent event = {0};

	// start the touch input queue
	createTouchQueue();

	if ((fd = open(DEV_INPUT_NAME, O_RDONLY)) < 0) {
		perror("Touch");
		goto exit;
	}

	/* TODO: Not sure of value for test_grab, will grab if grab flag = 1, do we grab or not grab? */
	if (test_grab(fd, 0))
	{
		printf("Device '%s' is grabbed by another process\n\r", DEV_INPUT_NAME);
		goto exit;
	}

	localThreadState = touchThreadState = TOUCH_THREAD_RUNNING;
	sem_post(&touchThreadSem);

	FD_ZERO(&rdfs);

	while (localThreadState == TOUCH_THREAD_RUNNING)
	{
		int selResult, rd, i;

		localThreadState = touchThreadState;
		FD_SET(fd, &rdfs);
		// Break from listening every 500ms to check for end of thread
		tv.tv_sec = 0;
		tv.tv_usec = 500000;

		selResult = select(fd + 1, &rdfs, NULL, NULL, &tv);
		if (selResult > 0) {
			rd = read(fd, ev, sizeof(ev));
			if (rd < (int) sizeof(struct input_event)) {
				printf("expected %d bytes, got %d\n\r", (int) sizeof(struct input_event), rd);
				perror("touch : error reading");
				// Should anything else happen here?
			}

			for (i = 0; i < rd / sizeof(struct input_event); i++) {
				unsigned int type, code;

				type = ev[i].type;
				code = ev[i].code;

				switch (type) {
					case EV_SYN:
						// End of a single event
						if (event.type == touch_none) {
							// Continuous touch does not send a button touch
							if ( state.type == touch_down || state.type == touch_continue ) {
								event.type = state.type = touch_continue;
							}
						}
						if (event.type != touch_none) {
							event.x = state.cur_x;
							event.y = state.cur_y;
							event.id = state.id;
							enqueue(&event);
							event.type = touch_none;
						}
						break;
					case EV_KEY:
						if (code == BTN_TOUCH)
							event.type = ev[i].value == 0 ? touch_up : touch_down;
							state.type = event.type;
						break;
					case EV_ABS:
						switch (code) {
							case ABS_MT_TRACKING_ID:
								state.id = ev[i].value;
								break;
							case ABS_X:
								state.cur_x = ev[i].value;
								break;
							case ABS_Y:
								state.cur_y = ev[i].value;
								break;
							default:
								break;
						}
						break;
					default:
						// Ignore any unrecognized
						break;
				}
#ifdef DEBUG
				printf("Event: time %ld.%06ld, ", ev[i].input_event_sec, ev[i].input_event_usec);
				if (type == EV_SYN) {
					// printf("Event: time %ld.%06ld, ", ev[i].input_event_sec, ev[i].input_event_usec);
					// End of one report, assume 
					if (code == SYN_MT_REPORT)
						printf("++++++++++++++ %s ++++++++++++\n", codename(type, code));
					else if (code == SYN_DROPPED)
						printf(">>>>>>>>>>>>>> %s <<<<<<<<<<<<\n", codename(type, code));
					else
						printf("-------------- %s ------------\n", codename(type, code));
				} else {
					printf("type %d (%s), code %d (%s), ",
						type, typename(type),
						code, codename(type, code));
					if (type == EV_MSC && (code == MSC_RAW || code == MSC_SCAN))
						printf("value %02x\n", ev[i].value);
					else
						printf("value %d\n", ev[i].value);
				}
#endif
			}
		}
	}

exit:
	touchThreadState = TOUCH_THREAD_FAIL;
	if (fd >= 0)
		close(fd);
#ifdef DEBUG
	printf("Exiting touch thread\n\r");
#endif
	sem_post(&touchThreadSem);
	return NULL;
}

int InitTouchDevice()
{
	pthread_t touch_thread_id;
	int ret;

    pthread_mutex_init(&touchThreadMutex, NULL);
    sem_init(&touchThreadSem, 0, 0);
	ret = pthread_create(&touch_thread_id, NULL, touch_thread, NULL);
	if (ret == 0) {
		sem_wait(&touchThreadSem);
		if (touchThreadState != TOUCH_THREAD_RUNNING) {
			ret = -1;
		}
	}
	return ret;
}

void DestroyTouchDevice()
{
	struct timespec ts = { 0 };
	int s;
	if (touchThreadState == TOUCH_THREAD_RUNNING) {
		touchThreadState = TOUCH_THREAD_STOP;
		if (clock_gettime(CLOCK_REALTIME, &ts) == -1) {
	        perror("Touch: clock_gettime error:");
		}
		else {
			ts.tv_sec += 2;
			errno = 0;
			while ((s = sem_timedwait(&touchThreadSem, &ts)) == -1 && errno == EINTR)
				continue;
			if (s == -1 && errno == ETIMEDOUT) {
				fprintf(stderr, "Touch: Time out waiting for touch thread\n\r");
			}
			else {
				sem_destroy(&touchThreadSem);
			}
		}
	}
	else {
		fprintf(stderr, "Touch handler not running\n\r");
	}
}