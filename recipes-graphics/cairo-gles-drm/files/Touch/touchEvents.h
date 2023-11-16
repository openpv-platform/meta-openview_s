#ifndef TOUCH_EVENTS_H_
#define TOUCH_EVENTS_H_

#include <unistd.h>
#include <stdbool.h>
#include "Touch.h"
#include <linux/input.h>
//#include <linux/input-event-codes.h>
#ifdef  __cplusplus
extern "C" {
#endif

#define BITS_PER_LONG (sizeof(long) * 8)
#define NBITS(x) ((((x)-1)/BITS_PER_LONG)+1)
#define OFF(x)  ((x)%BITS_PER_LONG)
#define BIT(x)  (1UL<<OFF(x))
#define LONG(x) ((x)/BITS_PER_LONG)
#define test_bit(bit, array)	((array[LONG(bit)] >> OFF(bit)) & 1)

#ifndef EV_SYN
#define EV_SYN 0
#endif
#ifndef SYN_MAX
#define SYN_MAX 3
#define SYN_CNT (SYN_MAX + 1)
#endif
#ifndef SYN_MT_REPORT
#define SYN_MT_REPORT 2
#endif
#ifndef SYN_DROPPED
#define SYN_DROPPED 3
#endif

#define NAME_ELEMENT(element) [element] = #element

enum evtest_mode {
	MODE_CAPTURE,
	MODE_QUERY,
	MODE_VERSION,
};



#ifdef  __cplusplus
}
#endif
#endif